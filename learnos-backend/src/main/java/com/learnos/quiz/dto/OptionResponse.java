package com.learnos.quiz.dto;

import java.util.UUID;

public record OptionResponse(
        UUID id,
        String text,
        boolean correct
) {}
