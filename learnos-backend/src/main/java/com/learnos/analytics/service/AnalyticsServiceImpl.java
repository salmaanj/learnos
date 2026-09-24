package com.learnos.analytics.service;

import com.learnos.analytics.dto.AnalyticsResponse;
import com.learnos.auth.model.Role;
import com.learnos.auth.model.User;
import com.learnos.auth.repository.UserRepository;
import com.learnos.auth.service.AuthorizationService;
import com.learnos.company.entity.Company;
import com.learnos.company.repository.CompanyRepository;
import com.learnos.course.repository.CourseRepository;
import com.learnos.coursepayment.model.CoursePaymentStatus;
import com.learnos.coursepayment.repository.CoursePaymentRepository;
import com.learnos.subscription.entity.CompanySubscription;
import com.learnos.subscription.entity.SubscriptionStatus;
import com.learnos.subscription.repository.CompanySubscriptionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AnalyticsServiceImpl implements AnalyticsService {

    private final UserRepository userRepository;
    private final AuthorizationService authorizationService;
    private final CompanyRepository companyRepository;
    private final CourseRepository courseRepository;
    private final CoursePaymentRepository coursePaymentRepository;
    private final CompanySubscriptionRepository
            companySubscriptionRepository;

    @Override
    public AnalyticsResponse getAnalytics(UUID requestedCompanyId) {
        User currentUser = getCurrentUser();

        if (isSuperAdmin(currentUser)) {
            return buildSuperAdminAnalytics(requestedCompanyId);
        }

        return buildCompanyAdminAnalytics(currentUser);
    }

    private AnalyticsResponse buildSuperAdminAnalytics(
            UUID requestedCompanyId
    ) {
        List<Company> companies = companyRepository.findAll();

        BigDecimal subscriptionRevenue = safeAmount(
                companySubscriptionRepository.sumAmountByStatus(
                        SubscriptionStatus.ACTIVE
                )
        );

        BigDecimal courseRevenue = companies.stream()
                .map(company -> getCourseRevenue(company.getId()))
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        long successfulPayments = companySubscriptionRepository.findAll()
                .stream()
                .filter(subscription -> subscription.getStatus()
                        == SubscriptionStatus.ACTIVE)
                .count();

        long pendingPayments = companySubscriptionRepository.findAll()
                .stream()
                .filter(subscription -> subscription.getStatus()
                        == SubscriptionStatus.PENDING_PAYMENT)
                .count();

        long failedPayments = companySubscriptionRepository.findAll()
                .stream()
                .filter(subscription -> subscription.getStatus()
                        == SubscriptionStatus.PAYMENT_FAILED)
                .count();

        List<AnalyticsResponse.CompanyRow> rows = companies.stream()
                .map(this::toCompanyRow)
                .sorted(Comparator.comparing(
                        AnalyticsResponse.CompanyRow::companyName,
                        String.CASE_INSENSITIVE_ORDER
                ))
                .toList();

        AnalyticsResponse.CompanyDetail selectedCompany = null;

        if (requestedCompanyId != null) {
            Company selected = companies.stream()
                    .filter(company -> requestedCompanyId.equals(
                            company.getId()
                    ))
                    .findFirst()
                    .orElseThrow(() -> new IllegalArgumentException(
                            "Company not found"
                    ));

            selectedCompany = toCompanyDetail(selected);
        }

        AnalyticsResponse.Summary summary = new AnalyticsResponse.Summary(
                companies.size(),
                countAllLearners(companies),
                countAllCourses(companies),
                subscriptionRevenue,
                courseRevenue,
                successfulPayments,
                pendingPayments,
                failedPayments
        );

        return new AnalyticsResponse(summary, rows, selectedCompany);
    }

    private AnalyticsResponse buildCompanyAdminAnalytics(User user) {
        if (user == null || user.getCompany() == null) {
            throw new IllegalArgumentException(
                    "Authenticated user is not assigned to a company"
            );
        }

        Company company = user.getCompany();
        AnalyticsResponse.CompanyRow row = toCompanyRow(company);
        AnalyticsResponse.CompanyDetail detail = toCompanyDetail(company);

        long successfulPayments = coursePaymentRepository
                .countByCompanyIdAndStatus(
                        company.getId(),
                        CoursePaymentStatus.ACTIVE
                );

        long pendingPayments = coursePaymentRepository
                .countByCompanyIdAndStatus(
                        company.getId(),
                        CoursePaymentStatus.PENDING_PAYMENT
                );

        long failedPayments = coursePaymentRepository
                .countByCompanyIdAndStatus(
                        company.getId(),
                        CoursePaymentStatus.PAYMENT_FAILED
                );

        AnalyticsResponse.Summary summary = new AnalyticsResponse.Summary(
                1,
                countLearners(company.getId()),
                courseRepository.countByCompanyId(company.getId()),
                BigDecimal.ZERO,
                getCourseRevenue(company.getId()),
                successfulPayments,
                pendingPayments,
                failedPayments
        );

        return new AnalyticsResponse(
                summary,
                List.of(row),
                detail
        );
    }

    private AnalyticsResponse.CompanyRow toCompanyRow(Company company) {
        CompanySubscription subscription =
                latestSubscription(company.getId());

        return new AnalyticsResponse.CompanyRow(
                company.getId(),
                company.getName(),
                countLearners(company.getId()),
                courseRepository.countByCompanyId(company.getId()),
                getCourseRevenue(company.getId()),
                subscriptionStatus(company, subscription),
                planName(company, subscription),
                expiryDate(company, subscription)
        );
    }

    private AnalyticsResponse.CompanyDetail toCompanyDetail(
            Company company
    ) {
        CompanySubscription subscription =
                latestSubscription(company.getId());

        long successfulPayments = companySubscriptionRepository
                .findByCompany_IdOrderByCreatedAtDesc(company.getId())
                .stream()
                .filter(item ->
                        item.getStatus() == SubscriptionStatus.ACTIVE
                )
                .count();

        return new AnalyticsResponse.CompanyDetail(
                company.getId(),
                company.getName(),
                countLearners(company.getId()),
                courseRepository.countByCompanyId(company.getId()),
                getCourseRevenue(company.getId()),
                subscriptionStatus(company, subscription),
                planName(company, subscription),
                expiryDate(company, subscription),
                successfulPayments,
                company.getLogoUrl()
        );
    }

    private long countAllLearners(List<Company> companies) {
        return companies.stream()
                .mapToLong(company -> countLearners(company.getId()))
                .sum();
    }

    private long countAllCourses(List<Company> companies) {
        return companies.stream()
                .mapToLong(company ->
                        courseRepository.countByCompanyId(
                                company.getId()
                        )
                )
                .sum();
    }

    private long countLearners(UUID companyId) {
        return userRepository.countByCompanyIdAndRole(
                companyId,
                Role.LEARNER
        );
    }

    private BigDecimal getCourseRevenue(UUID companyId) {
        return safeAmount(
                coursePaymentRepository.sumAmountByCompanyIdAndStatus(
                        companyId,
                        CoursePaymentStatus.ACTIVE
                )
        );
    }

    private CompanySubscription latestSubscription(UUID companyId) {
        return companySubscriptionRepository
                .findTopByCompany_IdOrderByCreatedAtDesc(companyId)
                .orElse(null);
    }

    private String subscriptionStatus(
            Company company,
            CompanySubscription subscription
    ) {
        if (subscription != null && subscription.getStatus() != null) {
            return subscription.getStatus().name();
        }

        return company.getStatus();
    }

    private String planName(
            Company company,
            CompanySubscription subscription
    ) {
        if (subscription != null && subscription.getPlan() != null) {
            if (subscription.getPlan().getName() != null
                    && !subscription.getPlan().getName().isBlank()) {
                return subscription.getPlan().getName();
            }

            if (subscription.getPlan().getCode() != null) {
                return subscription.getPlan().getCode();
            }
        }

        return company.getPlanCode();
    }

    private LocalDate expiryDate(
            Company company,
            CompanySubscription subscription
    ) {
        if (subscription != null
                && subscription.getExpiryDate() != null) {
            return subscription.getExpiryDate();
        }

        return company.getPlanExpiryDate();
    }

    private BigDecimal safeAmount(BigDecimal amount) {
        return amount == null ? BigDecimal.ZERO : amount;
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

        return userRepository.findByEmail(authentication.getName())
                .orElse(null);
    }

    private boolean isSuperAdmin(User user) {
        return authorizationService.isSuperAdmin(user);
    }
}