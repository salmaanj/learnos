package com.learnos.quiz.controller;

import com.learnos.quiz.dto.QuizAttemptResponse;
import com.learnos.quiz.dto.QuizTakeResponse;
import com.learnos.quiz.dto.SubmitAttemptRequest;
import com.learnos.quiz.service.QuizAttemptService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/quiz-attempts")
@RequiredArgsConstructor
public class QuizAttemptController {

    private final QuizAttemptService quizAttemptService;

    @GetMapping("/course/{courseId}")
    public ResponseEntity<List<com.learnos.quiz.dto.QuizSummaryResponse>> getQuizzesForCourse(@PathVariable UUID courseId) {
        return ResponseEntity.ok(quizAttemptService.getPublishedQuizzesForCourse(courseId));
    }

    @GetMapping("/quiz/{quizId}/take")
    public ResponseEntity<QuizTakeResponse> getQuizToTake(@PathVariable UUID quizId) {
        return ResponseEntity.ok(quizAttemptService.getQuizToTake(quizId));
    }

    @PostMapping
    public ResponseEntity<QuizAttemptResponse> submit(@RequestBody SubmitAttemptRequest request) {
        return ResponseEntity.ok(quizAttemptService.submitAttempt(request));
    }

    @GetMapping("/my")
    public ResponseEntity<List<QuizAttemptResponse>> getMyAttempts() {
        return ResponseEntity.ok(quizAttemptService.getMyAttempts());
    }
}
