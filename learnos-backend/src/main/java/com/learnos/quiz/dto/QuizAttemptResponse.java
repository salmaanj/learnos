package com.learnos.quiz.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record QuizAttemptResponse(
        UUID id,
        UUID quizId,
        String quizTitle,
        UUID userId,
        String userName,
        int totalQuestions,
        int correctCount,
        int scorePercent,
        boolean passed,
        LocalDateTime submittedAt
) {}
