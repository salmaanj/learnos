package com.learnos.batch.dto;

import com.learnos.batch.model.BatchMemberStatus;

import java.time.LocalDateTime;
import java.util.UUID;

public record BatchMemberResponse(
        UUID membershipId,
        UUID learnerId,
        String learnerName,
        String learnerEmail,
        String companyName,
        BatchMemberStatus status,
        int courseProgressPercent,
        LocalDateTime joinedAt,
        LocalDateTime completedAt
) {
}