package com.learnos.coursepayment.service;

import com.learnos.auth.model.Role;
import com.learnos.auth.model.User;
import com.learnos.auth.repository.UserRepository;
import com.learnos.config.RazorpayProperties;
import com.learnos.course.model.Course;
import com.learnos.course.model.Enrollment;
import com.learnos.course.model.EnrollmentStatus;
import com.learnos.course.repository.CourseRepository;
import com.learnos.course.repository.EnrollmentRepository;
import com.learnos.coursepayment.dto.CoursePaymentOrderResponse;
import com.learnos.coursepayment.dto.CreateCoursePaymentOrderRequest;
import com.learnos.coursepayment.dto.VerifyCoursePaymentRequest;
import com.learnos.coursepayment.model.CoursePayment;
import com.learnos.coursepayment.model.CoursePaymentStatus;
import com.learnos.coursepayment.repository.CoursePaymentRepository;
import com.razorpay.Order;
import com.razorpay.RazorpayClient;
import com.razorpay.RazorpayException;
import com.razorpay.Utils;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.json.JSONObject;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Transactional
public class CoursePaymentServiceImpl
        implements CoursePaymentService {

    private final CoursePaymentRepository paymentRepository;
    private final CourseRepository courseRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final UserRepository userRepository;
    private final RazorpayProperties razorpayProperties;

    private RazorpayClient razorpayClient;

    @PostConstruct
    void initialize() {
        if (isBlank(razorpayProperties.getKeyId())
                || isBlank(razorpayProperties.getKeySecret())) {
            throw new IllegalStateException(
                    "Razorpay key ID and key secret must be configured"
            );
        }

        try {
            razorpayClient = new RazorpayClient(
                    razorpayProperties.getKeyId(),
                    razorpayProperties.getKeySecret()
            );
        } catch (RazorpayException exception) {
            throw new IllegalStateException(
                    "Could not initialize Razorpay client",
                    exception
            );
        }
    }

    @Override
    public CoursePaymentOrderResponse createOrder(
            CreateCoursePaymentOrderRequest request
    ) {
        User learner = getCurrentUser();

        if (learner == null || learner.getRole() != Role.LEARNER) {
            throw new IllegalArgumentException(
                    "Only learners can purchase courses"
            );
        }

        Course course = courseRepository.findById(request.courseId())
                .orElseThrow(() -> new IllegalArgumentException(
                        "Course not found"
                ));

        if (!course.isPaid()) {
            throw new IllegalArgumentException(
                    "This course does not require payment"
            );
        }

        if (course.getPrice() == null
                || course.getPrice().compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException(
                    "Course price must be greater than zero"
            );
        }

        if (course.getCompany() == null
                || learner.getCompany() == null
                || !course.getCompany().getId().equals(
                learner.getCompany().getId()
        )) {
            throw new IllegalArgumentException(
                    "The learner must belong to the course company"
            );
        }

        if (enrollmentRepository.existsByUserIdAndCourseId(
                learner.getId(),
                course.getId()
        )) {
            throw new IllegalArgumentException(
                    "You are already enrolled in this course"
            );
        }

        String currency = "INR";
        long amountInPaise = toPaise(course.getPrice());

        CoursePayment payment = CoursePayment.builder()
                .learner(learner)
                .company(course.getCompany())
                .course(course)
                .amount(course.getPrice())
                .currency(currency)
                .status(CoursePaymentStatus.PENDING_PAYMENT)
                .build();

        CoursePayment saved = paymentRepository.save(payment);

        JSONObject orderRequest = new JSONObject();
        orderRequest.put("amount", amountInPaise);
        orderRequest.put("currency", currency);
        orderRequest.put(
                "receipt",
                "course_" + saved.getId().toString()
        );

        JSONObject notes = new JSONObject();
        notes.put("course_payment_id", saved.getId().toString());
        notes.put("course_id", course.getId().toString());
        notes.put("learner_id", learner.getId().toString());
        orderRequest.put("notes", notes);

        try {
            Order order = razorpayClient.orders.create(orderRequest);
            String orderId = order.get("id").toString();

            saved.setRazorpayOrderId(orderId);
            paymentRepository.save(saved);

            return new CoursePaymentOrderResponse(
                    saved.getId(),
                    course.getId(),
                    razorpayProperties.getKeyId(),
                    orderId,
                    course.getPrice(),
                    currency,
                    CoursePaymentStatus.PENDING_PAYMENT.name()
            );
        } catch (RazorpayException exception) {
            saved.setStatus(CoursePaymentStatus.PAYMENT_FAILED);
            paymentRepository.save(saved);

            throw new IllegalStateException(
                    "Could not create course payment order",
                    exception
            );
        }
    }

    @Override
    public String verifyPayment(
            VerifyCoursePaymentRequest request
    ) {
        CoursePayment payment = paymentRepository
                .findByRazorpayOrderId(request.razorpayOrderId())
                .orElseThrow(() -> new IllegalArgumentException(
                        "Course payment order not found"
                ));

        User learner = getCurrentUser();

        if (learner == null
                || !learner.getId().equals(
                payment.getLearner().getId()
        )) {
            throw new IllegalArgumentException(
                    "Payment does not belong to the authenticated learner"
            );
        }

        if (payment.getStatus() == CoursePaymentStatus.ACTIVE) {
            return "Course payment already verified";
        }

        JSONObject attributes = new JSONObject();
        attributes.put(
                "razorpay_order_id",
                request.razorpayOrderId()
        );
        attributes.put(
                "razorpay_payment_id",
                request.razorpayPaymentId()
        );
        attributes.put(
                "razorpay_signature",
                request.razorpaySignature()
        );

        try {
            Utils.verifyPaymentSignature(
                    attributes,
                    razorpayProperties.getKeySecret()
            );

            payment.setRazorpayPaymentId(
                    request.razorpayPaymentId()
            );
            payment.setRazorpaySignature(
                    request.razorpaySignature()
            );
            payment.setStatus(CoursePaymentStatus.ACTIVE);
            payment.setPaidAt(LocalDateTime.now());
            paymentRepository.save(payment);

            activateEnrollment(payment);

            return "Payment verified and course enrollment activated";
        } catch (RazorpayException exception) {
            payment.setStatus(CoursePaymentStatus.PAYMENT_FAILED);
            paymentRepository.save(payment);

            throw new IllegalArgumentException(
                    "Invalid Razorpay payment signature",
                    exception
            );
        }
    }

    private void activateEnrollment(CoursePayment payment) {
        Enrollment enrollment = enrollmentRepository
                .findByUserIdAndCourseId(
                        payment.getLearner().getId(),
                        payment.getCourse().getId()
                )
                .orElse(null);

        if (enrollment == null) {
            enrollment = Enrollment.builder()
                    .user(payment.getLearner())
                    .course(payment.getCourse())
                    .status(EnrollmentStatus.ACTIVE)
                    .progressPercent(0)
                    .build();

            enrollmentRepository.save(enrollment);

            Course course = payment.getCourse();
            course.setTotalEnrollments(
                    course.getTotalEnrollments() + 1
            );
            courseRepository.save(course);
            return;
        }

        if (enrollment.getStatus() != EnrollmentStatus.ACTIVE) {
            enrollment.setStatus(EnrollmentStatus.ACTIVE);
            enrollmentRepository.save(enrollment);
        }
    }

    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder
                .getContext()
                .getAuthentication();

        if (authentication == null
                || authentication.getName() == null
                || authentication.getName().isBlank()) {
            return null;
        }

        return userRepository
                .findByEmail(authentication.getName())
                .orElse(null);
    }

    private long toPaise(BigDecimal amount) {
        return amount
                .movePointRight(2)
                .setScale(0, RoundingMode.UNNECESSARY)
                .longValueExact();
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}

