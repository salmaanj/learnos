package com.learnos.course.dto;

import com.learnos.course.model.EnrollmentStatus;

import java.time.LocalDateTime;
import java.util.UUID;

public record CourseEnrollmentResponse(
        UUID enrollmentId,
        UUID learnerId,
        String learnerName,
        String learnerEmail,
        UUID courseId,
        String courseTitle,
        EnrollmentStatus status,
        int progressPercent,
        LocalDateTime enrolledAt,
        LocalDateTime completedAt
) {
}