package com.learnos.ai.dto;

import jakarta.validation.constraints.NotBlank;

public record AiChatRequest(
        @NotBlank String message,
        String lessonContext
) {
}
