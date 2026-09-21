package com.learnos.coursepayment.dto;

import jakarta.validation.constraints.NotBlank;

public record VerifyCoursePaymentRequest(
        @NotBlank String razorpayOrderId,
        @NotBlank String razorpayPaymentId,
        @NotBlank String razorpaySignature
) {}

