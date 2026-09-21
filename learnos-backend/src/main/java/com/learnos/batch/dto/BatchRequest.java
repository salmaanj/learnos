package com.learnos.batch.dto;

import com.learnos.batch.model.BatchDeliveryMode;
import com.learnos.batch.model.BatchStatus;

import java.time.LocalDate;
import java.util.UUID;

public record BatchRequest(
        String name,
        String code,
        String description,
        UUID courseId,
        UUID companyId,
        UUID instructorId,
        BatchDeliveryMode deliveryMode,
        BatchStatus status,
        LocalDate startDate,
        LocalDate endDate,
        Integer maxLearners
) {
}