package com.learnos.content.repository;

import com.learnos.content.model.LessonProgress;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface LessonProgressRepository
        extends JpaRepository<LessonProgress, UUID> {

    Optional<LessonProgress> findByUserIdAndLessonId(
            UUID userId,
            UUID lessonId
    );

    @Query("""
        SELECT lp
        FROM LessonProgress lp
        JOIN FETCH lp.lesson lesson
        JOIN FETCH lesson.module module
        JOIN FETCH module.course course
        WHERE lp.user.id = :userId
        ORDER BY lp.updatedAt DESC
        """)
    List<LessonProgress> findDetailedByUserId(
            @Param("userId") UUID userId
    );

    @Query("""
        SELECT lp
        FROM LessonProgress lp
        JOIN FETCH lp.lesson lesson
        JOIN FETCH lesson.module module
        JOIN FETCH module.course course
        WHERE lp.user.id = :userId
          AND course.id = :courseId
        ORDER BY lp.updatedAt DESC
        """)
    List<LessonProgress> findDetailedByUserIdAndCourseId(
            @Param("userId") UUID userId,
            @Param("courseId") UUID courseId
    );

    @Query("""
        SELECT COUNT(lesson)
        FROM Lesson lesson
        WHERE lesson.module.course.id = :courseId
          AND lesson.isPublished = true
        """)
    long countPublishedLessonsForCourse(
            @Param("courseId") UUID courseId
    );

    @Query("""
        SELECT COUNT(lp)
        FROM LessonProgress lp
        WHERE lp.user.id = :userId
          AND lp.completed = true
          AND lp.lesson.module.course.id = :courseId
          AND lp.lesson.isPublished = true
        """)
    long countCompletedLessonsForCourse(
            @Param("userId") UUID userId,
            @Param("courseId") UUID courseId
    );

    @Query("""
        SELECT COALESCE(
            (
                SUM(
                    CASE
                        WHEN lp.completed = true THEN 100.0
                        WHEN lp.lesson.durationSeconds IS NOT NULL
                             AND lp.lesson.durationSeconds > 0
                        THEN LEAST(
                            100.0,
                            lp.watchedSeconds * 100.0 /
                            lp.lesson.durationSeconds
                        )
                        WHEN lp.watchedSeconds > 0 THEN 1.0
                        ELSE 0.0
                    END
                )
                /
                NULLIF(
                    (
                        SELECT COUNT(lesson)
                        FROM Lesson lesson
                        WHERE lesson.module.course.id = :courseId
                          AND lesson.isPublished = true
                    ),
                    0
                )
            ),
            0
        )
        FROM LessonProgress lp
        WHERE lp.user.id = :userId
          AND lp.lesson.module.course.id = :courseId
          AND lp.lesson.isPublished = true
        """)
    Double calculateCourseCompletionPercent(
            @Param("userId") UUID userId,
            @Param("courseId") UUID courseId
    );
}