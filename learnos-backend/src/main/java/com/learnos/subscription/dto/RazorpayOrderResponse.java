package com.learnos.subscription.dto;

import java.math.BigDecimal;
import java.util.UUID;

public record RazorpayOrderResponse(
        UUID subscriptionId,
        UUID companyId,
        UUID planId,
        String keyId,
        String orderId,
        BigDecimal amount,
        String currency,
        String status
) {
}