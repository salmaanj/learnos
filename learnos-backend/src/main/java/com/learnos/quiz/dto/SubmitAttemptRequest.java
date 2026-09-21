package com.learnos.quiz.dto;

import java.util.Map;
import java.util.UUID;

public record SubmitAttemptRequest(
        UUID quizId,
        Map<String, String> answers // questionId (string) -> selected optionId (string)
) {}
