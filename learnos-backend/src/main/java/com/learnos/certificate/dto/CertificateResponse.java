package com.learnos.certificate.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record CertificateResponse(
        UUID id,
        String certificateNumber,
        String verificationCode,
        UUID learnerId,
        String learnerName,
        UUID courseId,
        String courseTitle,
        UUID companyId,
        String companyName,
        Integer quizScorePercent,
        String status,
        LocalDateTime issuedAt,
        LocalDateTime revokedAt,
        String revocationReason
) {
}