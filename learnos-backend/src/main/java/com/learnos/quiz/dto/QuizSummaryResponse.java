package com.learnos.quiz.dto;

import java.util.UUID;

public record QuizSummaryResponse(
        UUID id,
        String title,
        int durationMinutes,
        int passPercent,
        int totalQuestions
) {}
