package com.learnos.subscription.service;

import com.learnos.auth.model.User;
import com.learnos.auth.repository.UserRepository;
import com.learnos.company.entity.Company;
import com.learnos.company.repository.CompanyRepository;
import com.learnos.plan.entity.Plan;
import com.learnos.plan.repository.PlanRepository;
import com.learnos.subscription.dto.CompanySubscriptionResponse;
import com.learnos.subscription.dto.CreateCompanySubscriptionRequest;
import com.learnos.subscription.entity.CompanySubscription;
import com.learnos.subscription.entity.PaymentMethod;
import com.learnos.subscription.entity.SubscriptionStatus;
import com.learnos.subscription.repository.CompanySubscriptionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional
public class CompanySubscriptionServiceImpl
        implements CompanySubscriptionService {

    private final CompanySubscriptionRepository subscriptionRepository;
    private final UserRepository userRepository;
    private final CompanyRepository companyRepository;
    private final PlanRepository planRepository;

    @Override
    @Transactional(readOnly = true)
    public CompanySubscriptionResponse getMySubscription() {
        User currentUser = getCurrentUser();

        if (currentUser == null) {
            throw new IllegalArgumentException("Authenticated user not found");
        }

        if (currentUser.getCompany() == null) {
            throw new IllegalArgumentException("User is not assigned to a company");
        }

        Company company = companyRepository.findById(
                currentUser.getCompany().getId()
        ).orElseThrow(() -> new IllegalArgumentException("Company not found"));

        return getSubscriptionForCompany(company);
    }

    @Override
    @Transactional(readOnly = true)
    public CompanySubscriptionResponse getSubscriptionByCompanyId(UUID companyId) {
        User currentUser = getCurrentUser();

        if (!isSuperAdmin(currentUser)) {
            throw new IllegalArgumentException(
                    "Only the Super Admin can access another company's subscription"
            );
        }

        Company company = companyRepository.findById(companyId)
                .orElseThrow(() -> new IllegalArgumentException("Company not found"));

        return getSubscriptionForCompany(company);
    }

    @Override
    public CompanySubscriptionResponse createSubscription(
            CreateCompanySubscriptionRequest request
    ) {
        User currentUser = getCurrentUser();

        if (!isSuperAdmin(currentUser)) {
            throw new IllegalArgumentException(
                    "Only the Super Admin can create a subscription"
            );
        }

        Company company = companyRepository.findById(request.companyId())
                .orElseThrow(() -> new IllegalArgumentException("Company not found"));

        Plan plan = planRepository.findById(request.planId())
                .orElseThrow(() -> new IllegalArgumentException("Plan not found"));

        if (!Boolean.TRUE.equals(plan.getActive())) {
            throw new IllegalArgumentException("Plan is not active");
        }

        if (plan.getPrice() == null
                || plan.getPrice().compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException(
                    "Plan price must be greater than zero"
            );
        }

        if (request.paymentMethod() == PaymentMethod.RAZORPAY) {
            throw new IllegalArgumentException(
                    "Use the Razorpay payment-order endpoint for online payments"
            );
        }

        CompanySubscription subscription = subscriptionRepository
                .findTopByCompany_IdOrderByCreatedAtDesc(company.getId())
                .orElse(null);

        if (subscription == null) {
            subscription = new CompanySubscription();
            subscription.setCompany(company);
        }

        LocalDate startDate = LocalDate.now();
        LocalDate expiryDate = null;

        if (plan.getDurationMonths() != null) {
            expiryDate = startDate.plusMonths(plan.getDurationMonths());
        }

        subscription.setPlan(plan);
        subscription.setPaymentMethod(PaymentMethod.CASH);
        subscription.setStatus(SubscriptionStatus.ACTIVE);
        subscription.setAmount(plan.getPrice());
        subscription.setCurrency(resolveCurrency(plan));
        subscription.setDurationMonths(plan.getDurationMonths());
        subscription.setMaxLearners(plan.getMaxLearners());
        subscription.setMaxCourses(plan.getMaxCourses());
        subscription.setRazorpayOrderId(null);
        subscription.setRazorpayPaymentId(null);
        subscription.setStartDate(startDate);
        subscription.setExpiryDate(expiryDate);

        CompanySubscription saved = subscriptionRepository.save(subscription);

        company.setStatus("ACTIVE");
        company.setPlanCode(plan.getCode());
        company.setPlanStartDate(startDate);
        company.setPlanExpiryDate(expiryDate);
        companyRepository.save(company);

        return toResponse(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Plan> getMyUpgradeOptions() {
        User currentUser = getCurrentUser();

        if (currentUser == null) {
            throw new IllegalArgumentException("Authenticated user not found");
        }

        if (currentUser.getCompany() == null) {
            throw new IllegalArgumentException("User is not assigned to a company");
        }

        Company company = companyRepository.findById(
                currentUser.getCompany().getId()
        ).orElseThrow(() -> new IllegalArgumentException("Company not found"));

        String currentPlanCode = normalizeCode(company.getPlanCode());

        if (currentPlanCode == null) {
            return planRepository.findByActiveTrueOrderByDisplayOrderAscNameAsc();
        }

        BigDecimal currentPrice = getCurrentPlanPrice(company);

        return planRepository.findByActiveTrueOrderByDisplayOrderAscNameAsc()
                .stream()
                .filter(plan -> plan.getPrice() != null)
                .filter(plan -> plan.getPrice().compareTo(currentPrice) > 0)
                .toList();
    }

    private CompanySubscriptionResponse getSubscriptionForCompany(Company company) {
        CompanySubscription subscription = subscriptionRepository
                .findTopByCompany_IdOrderByCreatedAtDesc(company.getId())
                .orElse(null);

        if (subscription != null) {
            return toResponse(subscription);
        }

        return buildFallbackResponse(company);
    }

    private CompanySubscriptionResponse buildFallbackResponse(Company company) {
        String planCode = normalizeCode(company.getPlanCode());
        Plan plan = null;

        if (planCode != null) {
            plan = planRepository.findByCodeIgnoreCase(planCode).orElse(null);
        }

        SubscriptionStatus status = resolveSubscriptionStatus(company);
        BigDecimal amount = plan != null && plan.getPrice() != null
                ? plan.getPrice()
                : BigDecimal.ZERO;
        String currency = plan != null ? resolveCurrency(plan) : "INR";

        return new CompanySubscriptionResponse(
                null,
                company.getId(),
                normalizeCompanyStatus(company.getStatus()),
                plan != null ? plan.getId() : null,
                planCode,
                plan != null ? plan.getName() : null,
                amount,
                currency,
                plan != null ? plan.getDurationMonths() : null,
                plan != null ? plan.getMaxLearners() : company.getMaxLearners(),
                plan != null ? plan.getMaxCourses() : company.getMaxCourses(),
                status,
                null,
                company.getPlanStartDate(),
                company.getPlanExpiryDate(),
                null
        );
    }

    private SubscriptionStatus resolveSubscriptionStatus(Company company) {
        String companyStatus = normalizeStatus(company.getStatus());

        if ("ACTIVE".equals(companyStatus)) {
            return SubscriptionStatus.ACTIVE;
        }

        if ("PENDING".equals(companyStatus)
                || "PENDING_PAYMENT".equals(companyStatus)) {
            return SubscriptionStatus.PENDING_PAYMENT;
        }

        if ("SUSPENDED".equals(companyStatus)
                || "INACTIVE".equals(companyStatus)) {
            return SubscriptionStatus.CANCELLED;
        }

        return SubscriptionStatus.PENDING_PAYMENT;
    }

    private BigDecimal getCurrentPlanPrice(Company company) {
        CompanySubscription subscription = subscriptionRepository
                .findTopByCompany_IdOrderByCreatedAtDesc(company.getId())
                .orElse(null);

        if (subscription != null && subscription.getAmount() != null) {
            return subscription.getAmount();
        }

        String planCode = normalizeCode(company.getPlanCode());

        if (planCode == null) {
            return BigDecimal.ZERO;
        }

        return planRepository.findByCodeIgnoreCase(planCode)
                .map(Plan::getPrice)
                .orElse(BigDecimal.ZERO);
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

    private boolean isSuperAdmin(User user) {
        return user != null
                && user.getEmail() != null
                && user.getEmail().equalsIgnoreCase("admin@blute.co.in");
    }

    private String normalizeCode(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }

        return value.trim().toUpperCase(Locale.ROOT);
    }

    private String normalizeStatus(String value) {
        if (value == null || value.isBlank()) {
            return "";
        }

        return value.trim()
                .toUpperCase(Locale.ROOT)
                .replace('-', '_')
                .replace(' ', '_');
    }

    private String normalizeCompanyStatus(String value) {
        String normalized = normalizeStatus(value);

        if ("PENDING".equals(normalized)) {
            return "PENDING_PAYMENT";
        }

        return normalized;
    }

    private String resolveCurrency(Plan plan) {
        if (plan.getCurrency() == null || plan.getCurrency().isBlank()) {
            return "INR";
        }

        return plan.getCurrency();
    }

    private CompanySubscriptionResponse toResponse(
            CompanySubscription subscription
    ) {
        Company company = subscription.getCompany();
        Plan plan = subscription.getPlan();

        return new CompanySubscriptionResponse(
                subscription.getId(),
                company != null ? company.getId() : null,
                company != null
                        ? normalizeCompanyStatus(company.getStatus())
                        : null,
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
}
