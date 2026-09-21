package com.learnos.quiz.service;

import com.learnos.auth.model.User;
import com.learnos.auth.repository.UserRepository;
import com.learnos.course.model.Course;
import com.learnos.course.repository.CourseRepository;
import com.learnos.quiz.dto.*;
import com.learnos.quiz.model.*;
import com.learnos.quiz.repository.QuizAttemptRepository;
import com.learnos.quiz.repository.QuizRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class QuizService {

    private final QuizRepository quizRepository;
    private final QuizAttemptRepository quizAttemptRepository;
    private final CourseRepository courseRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public List<QuizResponse> getAllQuizzes() {
        User currentUser = getCurrentUser();

        List<Quiz> quizzes;
        if (isSuperAdmin(currentUser)) {
            quizzes = quizRepository.findAll();
        } else if (currentUser != null && currentUser.getCompany() != null) {
            quizzes = quizRepository.findByCourse_Company_Id(currentUser.getCompany().getId());
        } else {
            quizzes = List.of();
        }

        return quizzes.stream().map(this::toQuizResponse).toList();
    }

    @Transactional(readOnly = true)
    public List<QuizResponse> getQuizzesForCourse(UUID courseId) {
        return quizRepository.findByCourse_Id(courseId).stream()
                .map(this::toQuizResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public QuizResponse getQuizById(UUID id) {
        return toQuizResponse(findQuizOrThrow(id));
    }

    @Transactional
    public QuizResponse createQuiz(QuizRequest request) {
        Course course = null;
        if (request.courseId() != null) {
            course = courseRepository.findById(request.courseId())
                    .orElseThrow(() -> new RuntimeException("Course not found"));
        }

        Quiz quiz = Quiz.builder()
                .title(request.title())
                .course(course)
                .durationMinutes(request.durationMinutes() != null ? request.durationMinutes() : 30)
                .passPercent(request.passPercent() != null ? request.passPercent() : 60)
                .status(QuizStatus.DRAFT)
                .build();

        return toQuizResponse(quizRepository.save(quiz));
    }

    @Transactional
    public QuizResponse updateQuiz(UUID id, QuizRequest request) {
        Quiz quiz = findQuizOrThrow(id);

        if (request.title() != null) quiz.setTitle(request.title());
        if (request.durationMinutes() != null) quiz.setDurationMinutes(request.durationMinutes());
        if (request.passPercent() != null) quiz.setPassPercent(request.passPercent());
        if (request.courseId() != null) {
            Course course = courseRepository.findById(request.courseId())
                    .orElseThrow(() -> new RuntimeException("Course not found"));
            quiz.setCourse(course);
        }

        return toQuizResponse(quizRepository.save(quiz));
    }

    @Transactional
    public void deleteQuiz(UUID id) {
        Quiz quiz = findQuizOrThrow(id);
        quizRepository.delete(quiz);
    }

    @Transactional
    public QuizResponse publishQuiz(UUID id) {
        Quiz quiz = findQuizOrThrow(id);

        if (quiz.getQuestions().isEmpty()) {
            throw new RuntimeException("Cannot publish a quiz with no questions");
        }

        quiz.setStatus(QuizStatus.PUBLISHED);
        return toQuizResponse(quizRepository.save(quiz));
    }

    @Transactional
    public QuizResponse addQuestion(UUID quizId, QuestionRequest request) {
        Quiz quiz = findQuizOrThrow(quizId);

        Question question = Question.builder()
                .quiz(quiz)
                .text(request.text())
                .type(parseType(request.type()))
                .displayOrder(quiz.getQuestions().size())
                .build();

        int order = 0;
        for (OptionRequest optionReq : request.options()) {
            question.getOptions().add(
                    QuestionOption.builder()
                            .question(question)
                            .text(optionReq.text())
                            .correct(optionReq.correct())
                            .displayOrder(order++)
                            .build()
            );
        }

        quiz.getQuestions().add(question);
        return toQuizResponse(quizRepository.save(quiz));
    }

    @Transactional
    public QuizResponse updateQuestion(UUID quizId, UUID questionId, QuestionRequest request) {
        Quiz quiz = findQuizOrThrow(quizId);

        Question question = quiz.getQuestions().stream()
                .filter(q -> q.getId().equals(questionId))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Question not found"));

        question.setText(request.text());
        question.setType(parseType(request.type()));

        question.getOptions().clear();
        int order = 0;
        for (OptionRequest optionReq : request.options()) {
            question.getOptions().add(
                    QuestionOption.builder()
                            .question(question)
                            .text(optionReq.text())
                            .correct(optionReq.correct())
                            .displayOrder(order++)
                            .build()
            );
        }

        return toQuizResponse(quizRepository.save(quiz));
    }

    @Transactional
    public QuizResponse deleteQuestion(UUID quizId, UUID questionId) {
        Quiz quiz = findQuizOrThrow(quizId);
        quiz.getQuestions().removeIf(q -> q.getId().equals(questionId));
        return toQuizResponse(quizRepository.save(quiz));
    }

    @Transactional(readOnly = true)
    public QuizResultsResponse getResults(UUID quizId) {
        findQuizOrThrow(quizId); // 404s if the quiz doesn't exist

        List<QuizAttempt> attempts = quizAttemptRepository.findByQuiz_Id(quizId);

        int passedCount = (int) attempts.stream().filter(QuizAttempt::isPassed).count();
        int failedCount = attempts.size() - passedCount;
        int avgScore = attempts.isEmpty()
                ? 0
                : (int) Math.round(attempts.stream().mapToInt(QuizAttempt::getScorePercent).average().orElse(0));

        List<QuizAttemptResponse> attemptResponses = attempts.stream()
                .map(this::toAttemptResponse)
                .toList();

        return new QuizResultsResponse(passedCount, failedCount, avgScore, attemptResponses);
    }

    private Quiz findQuizOrThrow(UUID id) {
        return quizRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Quiz not found"));
    }

    private QuestionType parseType(String type) {
        try {
            return QuestionType.valueOf(type);
        } catch (Exception e) {
            return QuestionType.MCQ;
        }
    }

    private QuizResponse toQuizResponse(Quiz quiz) {
        List<QuestionResponse> questions = quiz.getQuestions().stream()
                .map(q -> new QuestionResponse(
                        q.getId(),
                        q.getText(),
                        q.getType().name(),
                        q.getDisplayOrder(),
                        q.getOptions().stream()
                                .map(o -> new OptionResponse(o.getId(), o.getText(), o.isCorrect()))
                                .toList()
                ))
                .toList();

        return new QuizResponse(
                quiz.getId(),
                quiz.getTitle(),
                quiz.getCourse() != null ? quiz.getCourse().getId() : null,
                quiz.getCourse() != null ? quiz.getCourse().getTitle() : null,
                quiz.getDurationMinutes(),
                quiz.getPassPercent(),
                quiz.getStatus().name(),
                quiz.getQuestions().size(),
                questions
        );
    }

    private QuizAttemptResponse toAttemptResponse(QuizAttempt attempt) {
        return new QuizAttemptResponse(
                attempt.getId(),
                attempt.getQuiz().getId(),
                attempt.getQuiz().getTitle(),
                attempt.getUser().getId(),
                attempt.getUser().getFullName(),
                attempt.getTotalQuestions(),
                attempt.getCorrectCount(),
                attempt.getScorePercent(),
                attempt.isPassed(),
                attempt.getSubmittedAt()
        );
    }

    private User getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || auth.getName() == null) return null;
        return userRepository.findByEmail(auth.getName()).orElse(null);
    }

    private boolean isSuperAdmin(User user) {
        return user != null && user.getEmail() != null
                && user.getEmail().equalsIgnoreCase("admin@blute.co.in");
    }
}
