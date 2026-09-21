package com.learnos.quiz.controller;

import com.learnos.quiz.dto.*;
import com.learnos.quiz.service.QuizService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/quizzes")
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
public class QuizController {

    private final QuizService quizService;

    @GetMapping
    public ResponseEntity<List<QuizResponse>> getAll(
            @RequestParam(required = false) UUID courseId) {
        if (courseId != null) {
            return ResponseEntity.ok(quizService.getQuizzesForCourse(courseId));
        }
        return ResponseEntity.ok(quizService.getAllQuizzes());
    }

    @GetMapping("/{id}")
    public ResponseEntity<QuizResponse> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(quizService.getQuizById(id));
    }

    @PostMapping
    public ResponseEntity<QuizResponse> create(@RequestBody QuizRequest request) {
        return ResponseEntity.ok(quizService.createQuiz(request));
    }

    @PutMapping("/{id}")
    public ResponseEntity<QuizResponse> update(@PathVariable UUID id, @RequestBody QuizRequest request) {
        return ResponseEntity.ok(quizService.updateQuiz(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        quizService.deleteQuiz(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/publish")
    public ResponseEntity<QuizResponse> publish(@PathVariable UUID id) {
        return ResponseEntity.ok(quizService.publishQuiz(id));
    }

    @PostMapping("/{id}/questions")
    public ResponseEntity<QuizResponse> addQuestion(@PathVariable UUID id, @RequestBody QuestionRequest request) {
        return ResponseEntity.ok(quizService.addQuestion(id, request));
    }

    @PutMapping("/{id}/questions/{questionId}")
    public ResponseEntity<QuizResponse> updateQuestion(
            @PathVariable UUID id,
            @PathVariable UUID questionId,
            @RequestBody QuestionRequest request) {
        return ResponseEntity.ok(quizService.updateQuestion(id, questionId, request));
    }

    @DeleteMapping("/{id}/questions/{questionId}")
    public ResponseEntity<QuizResponse> deleteQuestion(@PathVariable UUID id, @PathVariable UUID questionId) {
        return ResponseEntity.ok(quizService.deleteQuestion(id, questionId));
    }

    @GetMapping("/{id}/results")
    public ResponseEntity<QuizResultsResponse> getResults(@PathVariable UUID id) {
        return ResponseEntity.ok(quizService.getResults(id));
    }
}
