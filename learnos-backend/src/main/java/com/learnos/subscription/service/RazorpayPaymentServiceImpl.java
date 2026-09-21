package com.learnos.subscription.service;

import com.learnos.auth.model.User;
import com.learnos.auth.repository.UserRepository;
import com.learnos.company.entity.Company;
import com.learnos.company.repository.CompanyRepository;
import com.learnos.config.RazorpayProperties;
import com.learnos.plan.entity.Plan;
import com.learnos.plan.repository.PlanRepository;
import com.learnos.subscription.dto.CompanySubscriptionResponse;
import com.learnos.subscription.dto.CreateRazorpayOrderRequest;
import com.learnos.subscription.dto.RazorpayOrderResponse;
import com.learnos.subscription.dto.VerifyRazorpayPaymentRequest;
import com.learnos.subscription.entity.CompanySubscription;
import com.learnos.subscription.entity.PaymentMethod;
import com.learnos.subscription.entity.SubscriptionStatus;
import com.learnos.subscription.repository.CompanySubscriptionRepository;
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
import java.time.LocalDate;

@Service
@RequiredArgsConstructor
@Transactional
public class RazorpayPaymentServiceImpl
        implements RazorpayPaymentService {

    private final CompanySubscriptionRepository subscriptionRepository;
    private final UserRepository userRepository;
    private final CompanyRepository companyRepository;
    private final PlanRepository planRepository;
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
    public RazorpayOrderResponse createOrder(
            CreateRazorpayOrderRequest request
    ) {
        User currentUser = getCurrentUser();

        if (currentUser == null) {
            throw new IllegalArgumentException(
                    "Authenticated user not found"
            );
        }

        Company company = companyRepository.findById(
                request.companyId()
        ).orElseThrow(() -> new IllegalArgumentException(
                "Company not found"
        ));

        Plan plan = planRepository.findById(
                request.planId()
        ).orElseThrow(() -> new IllegalArgumentException(
                "Plan not found"
        ));

        if (!Boolean.TRUE.equals(plan.getActive())) {
            throw new IllegalArgumentException(
                    "Plan is not active"
            );
        }

        if (plan.getPrice() == null
                || plan.getPrice().compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException(
                    "Plan price must be greater than zero"
            );
        }

        String currency = resolveCurrency(plan);
        long amountInPaise = toPaise(plan.getPrice());

        CompanySubscription subscription =
                new CompanySubscription();

        subscription.setCompany(company);
        subscription.setPlan(plan);
        subscription.setPaymentMethod(PaymentMethod.RAZORPAY);
        subscription.setStatus(
                SubscriptionStatus.PENDING_PAYMENT
        );
        subscription.setAmount(plan.getPrice());
        subscription.setCurrency(currency);
        subscription.setDurationMonths(plan.getDurationMonths());
        subscription.setMaxLearners(plan.getMaxLearners());
        subscription.setMaxCourses(plan.getMaxCourses());

        CompanySubscription savedSubscription =
                subscriptionRepository.save(subscription);

        String receipt = "learnos_" +
                savedSubscription.getId()
                        .toString()
                        .replace("-", "")
                        .substring(0, 20);

        JSONObject orderRequest = new JSONObject();
        orderRequest.put("amount", amountInPaise);
        orderRequest.put("currency", currency);
        orderRequest.put("receipt", receipt);

        JSONObject notes = new JSONObject();
        notes.put(
                "subscription_id",
                savedSubscription.getId().toString()
        );
        notes.put(
                "company_id",
                company.getId().toString()
        );
        notes.put(
                "plan_id",
                plan.getId().toString()
        );

        orderRequest.put("notes", notes);

        try {
            Order razorpayOrder =
                    razorpayClient.orders.create(orderRequest);

            String orderId =
                    razorpayOrder.get("id").toString();

            savedSubscription.setRazorpayOrderId(orderId);
            subscriptionRepository.save(savedSubscription);

            return new RazorpayOrderResponse(
                    savedSubscription.getId(),
                    company.getId(),
                    plan.getId(),
                    razorpayProperties.getKeyId(),
                    orderId,
                    plan.getPrice(),
                    currency,
                    SubscriptionStatus.PENDING_PAYMENT.name()
            );

        } catch (RazorpayException exception) {
            savedSubscription.setStatus(
                    SubscriptionStatus.PAYMENT_FAILED
            );
            subscriptionRepository.save(savedSubscription);

            throw new IllegalStateException(
                    "Could not create Razorpay order",
                    exception
            );
        }
    }

    @Override
    public CompanySubscriptionResponse verifyPayment(
            VerifyRazorpayPaymentRequest request
    ) {
        CompanySubscription subscription =
                subscriptionRepository.findByRazorpayOrderId(
                        request.razorpayOrderId()
                ).orElseThrow(() -> new IllegalArgumentException(
                        "Razorpay order not found"
                ));

        User currentUser = getCurrentUser();

        if (currentUser == null) {
            throw new IllegalArgumentException(
                    "Authenticated user not found"
            );
        }

        if (subscription.getPaymentMethod() != PaymentMethod.RAZORPAY) {
            throw new IllegalArgumentException(
                    "This subscription is not a Razorpay payment"
            );
        }

        if (!request.razorpayOrderId().equals(
                subscription.getRazorpayOrderId()
        )) {
            throw new IllegalArgumentException(
                    "Razorpay order does not match subscription"
            );
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

            subscription.setRazorpayPaymentId(
                    request.razorpayPaymentId()
            );
            subscription.setStatus(
                    SubscriptionStatus.ACTIVE
            );
            subscription.setStartDate(LocalDate.now());

            if (subscription.getDurationMonths() != null) {
                subscription.setExpiryDate(
                        LocalDate.now().plusMonths(
                                subscription.getDurationMonths()
                        )
                );
            }

            Company company = subscription.getCompany();
            company.setStatus("ACTIVE");
            company.setPlanCode(
                    subscription.getPlan().getCode()
            );
            company.setPlanStartDate(
                    subscription.getStartDate()
            );
            company.setPlanExpiryDate(
                    subscription.getExpiryDate()
            );
            companyRepository.save(company);

            return toResponse(subscription);

        } catch (RazorpayException exception) {
            subscription.setStatus(
                    SubscriptionStatus.PAYMENT_FAILED
            );
            subscriptionRepository.save(subscription);

            throw new IllegalArgumentException(
                    "Invalid Razorpay payment signature",
                    exception
            );
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

        return userRepository.findByEmail(authentication.getName()).orElse(null);
    }

    private long toPaise(BigDecimal amount) {
        return amount
                .movePointRight(2)
                .setScale(0, RoundingMode.UNNECESSARY)
                .longValueExact();
    }

    private String resolveCurrency(Plan plan) {
        if (isBlank(plan.getCurrency())) {
            return "INR";
        }

        return plan.getCurrency().trim().toUpperCase();
    }

    private CompanySubscriptionResponse toResponse(
            CompanySubscription subscription
    ) {
        Company company = subscription.getCompany();
        Plan plan = subscription.getPlan();

        return new CompanySubscriptionResponse(
                subscription.getId(),
                company != null ? company.getId() : null,
                company != null ? company.getStatus() : null,
                plan != null ? plan.getId() : null,
                plan != null ? plan.getCode() : null,
                plan != null ? plan.getName() : null,
                subscription.getAmount(),
                subscription.getCurrency(),
                subscription.getDurationMonths(),
                subscription.getMaxLearners(),
                subscription.getMaxCourses(),
                subscription.getStatus(),
                subscription.getPaymentMethod(),
                subscription.getStartDate(),
                subscription.getExpiryDate(),
                subscription.getRazorpayOrderId()
        );
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}
