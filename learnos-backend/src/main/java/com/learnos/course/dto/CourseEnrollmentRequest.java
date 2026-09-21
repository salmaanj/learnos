package com.learnos.course.dto;

import java.util.UUID;

public record CourseEnrollmentRequest(
        UUID learnerId
) {
}