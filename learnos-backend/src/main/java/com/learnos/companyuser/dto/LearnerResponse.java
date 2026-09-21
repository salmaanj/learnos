package com.learnos.companyuser.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record LearnerResponse(
        UUID id,
        UUID userId,
        String name,
        String email,
        String phone,
        UUID companyId,
        String companyName,
        int coursesEnrolled,
        int avgProgressPercent,
        LocalDateTime lastActive,
        String status
) {
}