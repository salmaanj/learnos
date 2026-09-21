package com.learnos.subscription.dto;

import com.learnos.subscription.entity.PaymentMethod;
import com.learnos.subscription.entity.SubscriptionStatus;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public record CompanySubscriptionResponse(
        UUID id,
        UUID companyId,
        String companyStatus,
        UUID planId,
        String planCode,
        String planName,
        BigDecimal amount,
        String currency,
        Integer durationMonths,
        Integer maxLearners,
        Integer maxCourses,
        SubscriptionStatus status,
        PaymentMethod paymentMethod,
        LocalDate startDate,
        LocalDate expiryDate,
        String razorpayOrderId
) {
}
