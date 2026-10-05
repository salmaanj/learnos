package com.learnos.ai.service;

import com.learnos.ai.dto.AiChatRequest;
import com.learnos.ai.dto.AiChatResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

import java.util.List;
import java.util.Map;

@Service
public class OllamaAiService {

    private final RestClient restClient;
    private final String model;

    public OllamaAiService(
            RestClient.Builder restClientBuilder,
            @Value("${ai.ollama.base-url:http://localhost:11434}") String baseUrl,
            @Value("${ai.ollama.model:llama3.2:3b}") String model
    ) {
        this.restClient = restClientBuilder
                .baseUrl(baseUrl)
                .build();
        this.model = model;
    }

    public AiChatResponse chat(AiChatRequest request) {
        String prompt = """
                You are LearnOS, a helpful course tutor.
                Answer only from the lesson context provided.
                If the answer is not present in the context, say:
                "I don't know based on this lesson."

                Lesson context:
                %s

                Learner question:
                %s
                """.formatted(
                request.lessonContext() == null
                        ? ""
                        : request.lessonContext(),
                request.message()
        );

        Map<?, ?> result = restClient.post()
                .uri("/api/chat")
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of(
                        "model", model,
                        "messages", List.of(
                                Map.of(
                                        "role", "user",
                                        "content", prompt
                                )
                        ),
                        "stream", false
                ))
                .retrieve()
                .body(Map.class);

        return new AiChatResponse(
                extractAnswer(result),
                "ollama",
                model
        );
    }

    private String extractAnswer(Map<?, ?> result) {
        if (result == null) {
            throw new IllegalStateException("Empty response from Ollama");
        }

        Object messageObject = result.get("message");

        if (messageObject instanceof Map<?, ?> message) {
            Object content = message.get("content");

            if (content instanceof String text && !text.isBlank()) {
                return text.trim();
            }
        }

        throw new IllegalStateException(
                "Ollama response did not contain an answer"
        );
    }
}
