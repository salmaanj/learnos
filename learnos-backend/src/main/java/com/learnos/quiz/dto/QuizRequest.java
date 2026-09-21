package com.learnos.quiz.dto;

import java.util.List;
import java.util.UUID;

public record QuizRequest(
        String title,
        UUID courseId,
        Integer durationMinutes,
        Integer passPercent
) {}
