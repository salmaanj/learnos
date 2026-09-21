package com.learnos.quiz.repository;

import com.learnos.quiz.model.Quiz;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface QuizRepository extends JpaRepository<Quiz, UUID> {

    List<Quiz> findByCourse_Id(UUID courseId);

    @Query("SELECT q FROM Quiz q WHERE q.course.company.id = :companyId")
    List<Quiz> findByCourse_Company_Id(@Param("companyId") UUID companyId);
}
