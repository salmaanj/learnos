package com.learnos.quiz.dto;

import java.util.List;
import java.util.UUID;

public record QuizTakeResponse(
        UUID id,
        String title,
        int durationMinutes,
        int passPercent,
        int totalQuestions,
        List<QuestionTakeResponse> questions
) {}
