package com.learnos.subscription.dto;

import jakarta.validation.constraints.NotNull;

import java.util.UUID;

public record CreateRazorpayOrderRequest(
        @NotNull UUID companyId,
        @NotNull UUID planId
) {
}