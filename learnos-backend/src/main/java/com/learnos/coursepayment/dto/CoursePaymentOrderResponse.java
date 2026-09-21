package com.learnos.coursepayment.dto;

import java.math.BigDecimal;
import java.util.UUID;

public record CoursePaymentOrderResponse(
        UUID paymentId,
        UUID courseId,
        String keyId,
        String orderId,
        BigDecimal amount,
        String currency,
        String status
) {}
