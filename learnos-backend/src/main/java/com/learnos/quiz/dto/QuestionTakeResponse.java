package com.learnos.quiz.dto;

import java.util.List;
import java.util.UUID;

public record QuestionTakeResponse(
        UUID id,
        String text,
        String type,
        List<OptionTakeResponse> options
) {}
