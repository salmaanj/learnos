package com.learnos.ai.controller;

import com.learnos.ai.dto.AiChatRequest;
import com.learnos.ai.dto.AiChatResponse;
import com.learnos.ai.service.OllamaAiService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/ai")
@RequiredArgsConstructor
public class AiChatController {

    private final OllamaAiService ollamaAiService;

    @PostMapping("/chat")
    @PreAuthorize("hasAnyRole('LEARNER','ADMIN','USER','TUTOR')")
    public ResponseEntity<AiChatResponse> chat(
            @Valid @RequestBody AiChatRequest request
    ) {
        return ResponseEntity.ok(
                ollamaAiService.chat(currentUserEmail(), request)
        );
    }

    private String currentUserEmail() {
        return SecurityContextHolder.getContext()
                .getAuthentication()
                .getName();
    }
}
