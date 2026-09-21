package com.learnos.subscription.dto;

import com.learnos.subscription.entity.PaymentMethod;
import jakarta.validation.constraints.NotNull;

import java.util.UUID;

public record CreateCompanySubscriptionRequest(
        @NotNull UUID companyId,
        @NotNull UUID planId,
        @NotNull PaymentMethod paymentMethod
) {
}