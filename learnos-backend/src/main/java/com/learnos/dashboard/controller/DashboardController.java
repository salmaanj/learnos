package com.learnos.dashboard.controller;

import com.learnos.auth.model.User;
import com.learnos.auth.repository.UserRepository;
import com.learnos.auth.service.AuthorizationService;
import com.learnos.coursepayment.model.CoursePaymentStatus;
import com.learnos.coursepayment.repository.CoursePaymentRepository;
import com.learnos.subscription.entity.SubscriptionStatus;
import com.learnos.subscription.repository.CompanySubscriptionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;

@RestController
@RequiredArgsConstructor
@RequestMapping("/dashboard")
public class DashboardController {

    private final UserRepository userRepository;
    private final AuthorizationService authorizationService;
    private final CoursePaymentRepository coursePaymentRepository;
    private final CompanySubscriptionRepository
            companySubscriptionRepository;

    @GetMapping("/course-revenue")
    public BigDecimal getCourseRevenue() {
        User user = getCurrentUser();

        if (user == null || user.getCompany() == null) {
            throw new IllegalArgumentException(
                    "Authenticated user is not assigned to a company"
            );
        }

        if (isSuperAdmin(user)) {
            throw new IllegalArgumentException(
                    "Super Admin dashboard uses subscription revenue"
            );
        }

        BigDecimal revenue = coursePaymentRepository
                .sumAmountByCompanyIdAndStatus(
                        user.getCompany().getId(),
                        CoursePaymentStatus.ACTIVE
                );

        return revenue != null ? revenue : BigDecimal.ZERO;
    }

    @GetMapping("/subscription-revenue")
    public BigDecimal getSubscriptionRevenue() {
        User user = getCurrentUser();

        if (!isSuperAdmin(user)) {
            throw new IllegalArgumentException(
                    "Only the Super Admin can access subscription revenue"
            );
        }

        BigDecimal revenue = companySubscriptionRepository
                .sumAmountByStatus(SubscriptionStatus.ACTIVE);

        return revenue != null ? revenue : BigDecimal.ZERO;
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
        return authorizationService.isSuperAdmin(user);
    }
}