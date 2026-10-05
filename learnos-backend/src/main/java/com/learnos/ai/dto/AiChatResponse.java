package com.learnos.ai.dto;

public record AiChatResponse(
        String answer,
        String provider,
        String model
) {
}
