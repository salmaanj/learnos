package com.learnos.ai.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.util.UUID;

public record AiChatRequest(
        @NotNull UUID lessonId,
        @NotBlank String message
) {
}
