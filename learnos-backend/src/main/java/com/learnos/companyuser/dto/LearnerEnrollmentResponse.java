package com.learnos.companyuser.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record LearnerEnrollmentResponse(
        UUID enrollmentId,
        UUID learnerId,
        String courseId,
        String courseTitle,
        String courseCategory,
        String status,
        int progressPercent,
        LocalDateTime enrolledAt,
        LocalDateTime completedAt
) {
}