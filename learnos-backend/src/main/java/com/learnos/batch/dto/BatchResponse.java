package com.learnos.batch.dto;

import com.learnos.batch.model.BatchDeliveryMode;
import com.learnos.batch.model.BatchStatus;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

public record BatchResponse(
        UUID id,
        String name,
        String code,
        String description,
        UUID courseId,
        String courseTitle,
        UUID companyId,
        String companyName,
        UUID instructorId,
        String instructorName,
        BatchDeliveryMode deliveryMode,
        BatchStatus status,
        LocalDate startDate,
        LocalDate endDate,
        Integer maxLearners,
        long learnerCount,
        int averageProgressPercent,
        long completedLearnerCount,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}