package com.learnos.paymenthistory.service;

import com.learnos.auth.model.Role;
import com.learnos.auth.model.User;
import com.learnos.auth.repository.UserRepository;
import com.learnos.company.entity.Company;
import com.learnos.company.repository.CompanyRepository;
import com.learnos.coursepayment.model.CoursePayment;
import com.learnos.coursepayment.repository.CoursePaymentRepository;
import com.learnos.paymenthistory.dto.PaymentHistoryResponse;
import com.learnos.subscription.entity.CompanySubscription;
import com.learnos.subscription.repository.CompanySubscriptionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PaymentHistoryServiceImpl
        implements PaymentHistoryService {

    private final UserRepository userRepository;
    private final CompanyRepository companyRepository;
    private final CoursePaymentRepository coursePaymentRepository;
    private final CompanySubscriptionRepository subscriptionRepository;

    @Override
    public List<PaymentHistoryResponse> getMyPaymentHistory() {
        User user = getCurrentUser();

        if (user == null) {
            throw new IllegalArgumentException(
                    "Authenticated user not found"
            );
        }

        if (user.getRole() == Role.LEARNER) {
            return coursePaymentRepository
                    .findByLearnerIdOrderByCreatedAtDesc(user.getId())
                    .stream()
                    .map(this::toCoursePaymentResponse)
                    .toList();
        }

        if (user.getCompany() == null) {
            return List.of();
        }

        List<PaymentHistoryResponse> result = new ArrayList<>();

        subscriptionRepository
                .findByCompany_IdOrderByCreatedAtDesc(
                        user.getCompany().getId()
                )
                .stream()
                .map(this::toSubscriptionResponse)
                .forEach(result::add);

        result.sort(
                Comparator.comparing(
                        PaymentHistoryResponse::createdAt,
                        Comparator.nullsLast(Comparator.reverseOrder())
                )
        );

        return result;
    }

    @Override
    public List<PaymentHistoryResponse> getCompanyPaymentHistory(
            UUID companyId
    ) {
        User user = getCurrentUser();

        if (!isSuperAdmin(user)) {
            throw new IllegalArgumentException(
                    "Only the Super Admin can access another company's payment history"
            );
        }

        Company company = companyRepository.findById(companyId)
                .orElseThrow(() -> new IllegalArgumentException(
                        "Company not found"
                ));

        List<PaymentHistoryResponse> result = new ArrayList<>();

        subscriptionRepository
                .findByCompany_IdOrderByCreatedAtDesc(company.getId())
                .stream()
                .map(this::toSubscriptionResponse)
                .forEach(result::add);

        coursePaymentRepository
                .findByCompanyIdOrderByCreatedAtDesc(company.getId())
                .stream()
                .map(this::toCoursePaymentResponse)
                .forEach(result::add);

        result.sort(
                Comparator.comparing(
                        PaymentHistoryResponse::createdAt,
                        Comparator.nullsLast(Comparator.reverseOrder())
                )
        );

        return result;
    }

    private PaymentHistoryResponse toSubscriptionResponse(
            CompanySubscription subscription
    ) {
        Company company = subscription.getCompany();

        return new PaymentHistoryResponse(
                subscription.getId(),
                "COMPANY_SUBSCRIPTION",
                company != null ? company.getId() : null,
                company != null ? company.getName() : null,
                null,
                null,
                subscription.getPlan() != null
                        ? subscription.getPlan().getId()
                        : null,
                subscription.getPlan() != null
                        ? subscription.getPlan().getCode()
                        : null,
                subscription.getPlan() != null
                        ? subscription.getPlan().getName()
                        : null,
                subscription.getAmount(),
                subscription.getCurrency(),
                subscription.getStatus() != null
                        ? subscription.getStatus().name()
                        : null,
                subscription.getPaymentMethod() != null
                        ? subscription.getPaymentMethod().name()
                        : null,
                subscription.getRazorpayOrderId(),
                subscription.getRazorpayPaymentId(),
                subscription.getStatus() != null
                        && "ACTIVE".equals(
                        subscription.getStatus().name()
                )
                        ? subscription.getUpdatedAt()
                        : null,
                subscription.getCreatedAt()
        );
    }

    private PaymentHistoryResponse toCoursePaymentResponse(
            CoursePayment payment
    ) {
        Company company = payment.getCompany();

        return new PaymentHistoryResponse(
                payment.getId(),
                "COURSE_ENROLLMENT",
                company != null ? company.getId() : null,
                company != null ? company.getName() : null,
                payment.getCourse() != null
                        ? payment.getCourse().getId()
                        : null,
                payment.getCourse() != null
                        ? payment.getCourse().getTitle()
                        : null,
                null,
                null,
                null,
                payment.getAmount(),
                payment.getCurrency(),
                payment.getStatus() != null
                        ? payment.getStatus().name()
                        : null,
                "RAZORPAY",
                payment.getRazorpayOrderId(),
                payment.getRazorpayPaymentId(),
                payment.getPaidAt(),
                payment.getCreatedAt()
        );
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

    private boolean isSuperAdmin(User user) {
        return user != null
                && user.getEmail() != null
                && user.getEmail().equalsIgnoreCase(
                "admin@blute.co.in"
        );
    }
}