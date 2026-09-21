package com.learnos.course.repository;

import com.learnos.auth.model.Role;
import com.learnos.course.model.Enrollment;
import com.learnos.course.model.EnrollmentStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface EnrollmentRepository
        extends JpaRepository<Enrollment, UUID> {

    Optional<Enrollment> findByUserIdAndCourseId(
            UUID userId,
            UUID courseId
    );

    boolean existsByUserIdAndCourseId(
            UUID userId,
            UUID courseId
    );

    List<Enrollment> findByUserId(UUID userId);

    List<Enrollment> findByUserIdAndStatus(
            UUID userId,
            EnrollmentStatus status
    );

    List<Enrollment> findByCourseIdOrderByEnrolledAtAsc(
            UUID courseId
    );

    List<Enrollment> findByCourseIdAndStatusOrderByEnrolledAtAsc(
            UUID courseId,
            EnrollmentStatus status
    );

    @Query("""
        SELECT e
        FROM Enrollment e
        JOIN FETCH e.user user
        JOIN FETCH e.course course
        WHERE e.course.id = :courseId
          AND e.status = :status
          AND user.role = :role
        ORDER BY e.enrolledAt ASC
        """)
    List<Enrollment> findLearnerEnrollmentsForCourse(
            @Param("courseId") UUID courseId,
            @Param("status") EnrollmentStatus status,
            @Param("role") Role role
    );

    long countByCourseId(UUID courseId);

    long countByCourseIdAndStatus(
            UUID courseId,
            EnrollmentStatus status
    );

    @Query("""
        SELECT COALESCE(AVG(e.progressPercent), 0)
        FROM Enrollment e
        WHERE e.course.id = :courseId
          AND e.status = :status
        """)
    Double findAverageProgressByCourseIdAndStatus(
            @Param("courseId") UUID courseId,
            @Param("status") EnrollmentStatus status
    );
}