package com.learnos.ai.service;

import com.learnos.ai.dto.AiChatRequest;
import com.learnos.ai.dto.AiChatResponse;
import com.learnos.content.model.Lesson;
import com.learnos.content.service.LessonService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.web.server.ResponseStatusException;

import java.time.Duration;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class OllamaAiService {

    private final RestClient.Builder restClientBuilder;
    private final LessonService lessonService;

    @Value("${ai.ollama.base-url:http://localhost:11434}")
    private String baseUrl;

    @Value("${ai.ollama.model:llama3.2:3b}")
    private String model;

    public AiChatResponse chat(String userEmail, AiChatRequest request) {
        Lesson lesson = lessonService.getAuthorizedLessonForAi(
                userEmail,
                request.lessonId()
        );

        String lessonText = lesson.getTextContent();

        if (lessonText == null || lessonText.isBlank()) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "AI questions are currently available only for text lessons."
            );
        }

        String question = request.message().trim();

        String systemMessage = """
                You are a helpful tutor inside LearnOS.

                Follow these rules:
                1. Use only the supplied lesson title and lesson content.
                2. Do not use outside knowledge.
                3. Do not contradict the lesson content.
                4. Answer the learner's question directly and clearly.
                5. If the lesson does not support an answer, say:
                   "I don't know based on this lesson."
                6. Do not add facts that are not present in the lesson.
                7. Keep the answer concise, using one to three sentences.
                """;

        String userMessage = """
                Lesson title:
                %s

                Lesson content:
                %s

                Learner question:
                %s
                """.formatted(
                lesson.getTitle(),
                lessonText,
                question
        );

        SimpleClientHttpRequestFactory requestFactory =
                new SimpleClientHttpRequestFactory();

        requestFactory.setConnectTimeout(Duration.ofSeconds(5));
        requestFactory.setReadTimeout(Duration.ofSeconds(120));

        RestClient restClient = restClientBuilder
                .baseUrl(baseUrl)
                .requestFactory(requestFactory)
                .build();

        Map<?, ?> result = restClient.post()
                .uri("/api/chat")
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of(
                        "model", model,
                        "messages", List.of(
                                Map.of(
                                        "role", "system",
                                        "content", systemMessage
                                ),
                                Map.of(
                                        "role", "user",
                                        "content", userMessage
                                )
                        ),
                        "stream", false,
                        "keep_alive", "10m",
                        "options", Map.of(
                                "temperature", 0.1,
                                "num_predict", 120
                        )
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
