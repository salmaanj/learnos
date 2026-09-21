package com.learnos.quiz.repository;

import com.learnos.quiz.model.QuizAttempt;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface QuizAttemptRepository extends JpaRepository<QuizAttempt, UUID> {

    List<QuizAttempt> findByQuiz_Id(UUID quizId);

    List<QuizAttempt> findByUser_Id(UUID userId);

    List<QuizAttempt> findByQuiz_IdAndUser_Id(UUID quizId, UUID userId);
}
