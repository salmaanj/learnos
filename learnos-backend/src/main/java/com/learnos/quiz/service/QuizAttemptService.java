package com.learnos.quiz.service;

import com.learnos.auth.model.User;
import com.learnos.auth.repository.UserRepository;
import com.learnos.certificate.service.CertificateService;
import com.learnos.content.repository.LessonProgressRepository;
import com.learnos.quiz.dto.OptionTakeResponse;
import com.learnos.quiz.dto.QuestionTakeResponse;
import com.learnos.quiz.dto.QuizAttemptResponse;
import com.learnos.quiz.dto.QuizSummaryResponse;
import com.learnos.quiz.dto.QuizTakeResponse;
import com.learnos.quiz.dto.SubmitAttemptRequest;
import com.learnos.quiz.model.Question;
import com.learnos.quiz.model.Quiz;
import com.learnos.quiz.model.QuizAttempt;
import com.learnos.quiz.model.QuizStatus;
import com.learnos.quiz.repository.QuizAttemptRepository;
import com.learnos.quiz.repository.QuizRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class QuizAttemptService {

    private final QuizRepository quizRepository;
    private final QuizAttemptRepository quizAttemptRepository;
    private final UserRepository userRepository;
    private final LessonProgressRepository lessonProgressRepository;
    private final CertificateService certificateService;

    @Transactional(readOnly = true)
    public List<QuizSummaryResponse> getPublishedQuizzesForCourse(UUID courseId) {
        return quizRepository.findByCourse_Id(courseId).stream()
                .filter(quiz -> quiz.getStatus() == QuizStatus.PUBLISHED)
                .map(quiz -> new QuizSummaryResponse(
                        quiz.getId(),
                        quiz.getTitle(),
                        quiz.getDurationMinutes(),
                        quiz.getPassPercent(),
                        quiz.getQuestions().size()
                ))
                .toList();
    }

    @Transactional(readOnly = true)
    public QuizTakeResponse getQuizToTake(UUID quizId) {
        Quiz quiz = findPublishedQuizOrThrow(quizId);
        User currentUser = requireCurrentUser();

        assertNotAlreadyPassed(currentUser, quiz);
        assertAssessmentUnlocked(currentUser, quiz);

        List<QuestionTakeResponse> questions = quiz.getQuestions().stream()
                .map(question -> new QuestionTakeResponse(
                        question.getId(),
                        question.getText(),
                        question.getType().name(),
                        question.getOptions().stream()
                                .map(option -> new OptionTakeResponse(
                                        option.getId(),
                                        option.getText()
                                ))
                                .toList()
                ))
                .toList();

        return new QuizTakeResponse(
                quiz.getId(),
                quiz.getTitle(),
                quiz.getDurationMinutes(),
                quiz.getPassPercent(),
                quiz.getQuestions().size(),
                questions
        );
    }

    @Transactional
    public QuizAttemptResponse submitAttempt(SubmitAttemptRequest request) {
        Quiz quiz = findPublishedQuizOrThrow(request.quizId());
        User currentUser = requireCurrentUser();

        assertNotAlreadyPassed(currentUser, quiz);
        assertAssessmentUnlocked(currentUser, quiz);

        Map<String, String> answers = request.answers() != null
                ? request.answers()
                : new HashMap<>();

        int correctCount = 0;

        for (Question question : quiz.getQuestions()) {
            String selectedOptionId = answers.get(question.getId().toString());

            if (selectedOptionId == null) {
                continue;
            }

            boolean isCorrect = question.getOptions().stream()
                    .anyMatch(option ->
                            option.getId().toString().equals(selectedOptionId)
                                    && option.isCorrect()
                    );

            if (isCorrect) {
                correctCount++;
            }
        }

        int totalQuestions = quiz.getQuestions().size();

        int scorePercent = totalQuestions == 0
                ? 0
                : (int) Math.round(
                correctCount * 100.0 / totalQuestions
        );

        boolean passed = scorePercent >= quiz.getPassPercent();

        QuizAttempt attempt = QuizAttempt.builder()
                .quiz(quiz)
                .user(currentUser)
                .totalQuestions(totalQuestions)
                .correctCount(correctCount)
                .scorePercent(scorePercent)
                .passed(passed)
                .answers(answers)
                .build();

        QuizAttempt saved = quizAttemptRepository.save(attempt);

        if (saved.isPassed() && quiz.getCourse() != null) {
            certificateService.issueIfEligible(
                    currentUser,
                    quiz.getCourse()
            );
        }

        return new QuizAttemptResponse(
                saved.getId(),
                quiz.getId(),
                quiz.getTitle(),
                currentUser.getId(),
                currentUser.getFullName(),
                saved.getTotalQuestions(),
                saved.getCorrectCount(),
                saved.getScorePercent(),
                saved.isPassed(),
                saved.getSubmittedAt()
        );
    }

    @Transactional(readOnly = true)
    public List<QuizAttemptResponse> getMyAttempts() {
        User currentUser = getCurrentUser();

        if (currentUser == null) {
            return List.of();
        }

        return quizAttemptRepository.findByUser_Id(currentUser.getId()).stream()
                .map(attempt -> new QuizAttemptResponse(
                        attempt.getId(),
                        attempt.getQuiz().getId(),
                        attempt.getQuiz().getTitle(),
                        currentUser.getId(),
                        currentUser.getFullName(),
                        attempt.getTotalQuestions(),
                        attempt.getCorrectCount(),
                        attempt.getScorePercent(),
                        attempt.isPassed(),
                        attempt.getSubmittedAt()
                ))
                .toList();
    }

    private void assertNotAlreadyPassed(
            User currentUser,
            Quiz quiz
    ) {
        if (
                currentUser == null
                        || currentUser.getId() == null
                        || quiz == null
                        || quiz.getId() == null
        ) {
            return;
        }

        boolean alreadyPassed =
                quizAttemptRepository
                        .existsByQuiz_IdAndUser_IdAndPassedTrue(
                                quiz.getId(),
                                currentUser.getId()
                        );

        if (alreadyPassed) {
            throw new IllegalStateException(
                    "This assessment has already been passed."
            );
        }
    }

    private Quiz findPublishedQuizOrThrow(UUID quizId) {
        Quiz quiz = quizRepository.findById(quizId)
                .orElseThrow(() -> new RuntimeException("Quiz not found"));

        if (quiz.getStatus() != QuizStatus.PUBLISHED) {
            throw new RuntimeException("This quiz is not currently available");
        }

        return quiz;
    }

    private void assertAssessmentUnlocked(User user, Quiz quiz) {
        if (quiz.getCourse() == null) {
            return;
        }

        UUID courseId = quiz.getCourse().getId();

        long totalLessons = lessonProgressRepository
                .countPublishedLessonsForCourse(courseId);

        if (totalLessons == 0) {
            throw new RuntimeException(
                    "This assessment is unavailable because the course has no published lessons."
            );
        }

        long completedLessons = lessonProgressRepository
                .countCompletedLessonsForCourse(user.getId(), courseId);

        if (completedLessons < totalLessons) {
            throw new RuntimeException(
                    "Complete all course lessons before starting the assessment."
            );
        }
    }

    private User requireCurrentUser() {
        User user = getCurrentUser();

        if (user == null) {
            throw new RuntimeException("Not authenticated");
        }

        return user;
    }

    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder
                .getContext()
                .getAuthentication();

        if (authentication == null || authentication.getName() == null) {
            return null;
        }

        return userRepository
                .findByEmail(authentication.getName())
                .orElse(null);
    }
}