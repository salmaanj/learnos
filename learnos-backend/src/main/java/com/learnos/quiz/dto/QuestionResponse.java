package com.learnos.quiz.dto;

import java.util.List;
import java.util.UUID;

public record QuestionResponse(
        UUID id,
        String text,
        String type,
        int displayOrder,
        List<OptionResponse> options
) {}
