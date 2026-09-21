package com.learnos.certificate.dto;

import java.time.LocalDateTime;

public record CertificateVerifyResponse(
        boolean valid,
        String certificateNumber,
        String learnerName,
        String courseTitle,
        String companyName,
        Integer quizScorePercent,
        String status,
        LocalDateTime issuedAt,
        String message
) {
}