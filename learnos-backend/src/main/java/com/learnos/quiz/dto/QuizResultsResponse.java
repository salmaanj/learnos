package com.learnos.quiz.dto;

import java.util.List;

public record QuizResultsResponse(
        int passedCount,
        int failedCount,
        int avgScorePercent,
        List<QuizAttemptResponse> attempts
) {}
