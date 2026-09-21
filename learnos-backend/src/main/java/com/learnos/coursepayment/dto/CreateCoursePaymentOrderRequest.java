package com.learnos.coursepayment.dto;

import jakarta.validation.constraints.NotNull;

import java.util.UUID;

public record CreateCoursePaymentOrderRequest(
        @NotNull UUID courseId
) {}

