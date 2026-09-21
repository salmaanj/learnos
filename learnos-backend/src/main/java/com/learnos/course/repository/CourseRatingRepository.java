package com.learnos.course.repository;

import com.learnos.course.model.CourseRating;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface CourseRatingRepository
        extends JpaRepository<CourseRating, UUID> {

    Optional<CourseRating> findByCourseIdAndUserId(
            UUID courseId,
            UUID userId
    );

    long countByCourseId(UUID courseId);

    @Query("""
        SELECT COALESCE(AVG(r.stars), 0)
        FROM CourseRating r
        WHERE r.course.id = :courseId
        """)
    Double findAverageRatingByCourseId(
            @Param("courseId") UUID courseId
    );
}