package com.learnos.quiz.dto;

import java.util.List;
import java.util.UUID;

public record QuizResponse(
        UUID id,
        String title,
        UUID courseId,
        String courseName,
        int durationMinutes,
        int passPercent,
        String status,
        int totalQuestions,
        List<QuestionResponse> questions
) {}
