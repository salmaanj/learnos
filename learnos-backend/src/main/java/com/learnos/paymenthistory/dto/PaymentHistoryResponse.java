package com.learnos.paymenthistory.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

public record PaymentHistoryResponse(
        UUID id,
        String paymentType,
        UUID companyId,
        String companyName,
        UUID courseId,
        String courseName,
        UUID planId,
        String planCode,
        String planName,
        BigDecimal amount,
        String currency,
        String status,
        String paymentMethod,
        String razorpayOrderId,
        String razorpayPaymentId,
        LocalDateTime paidAt,
        LocalDateTime createdAt
) {}