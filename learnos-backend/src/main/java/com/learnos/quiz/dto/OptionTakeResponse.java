package com.learnos.quiz.dto;

import java.util.UUID;

public record OptionTakeResponse(
        UUID id,
        String text
) {}
