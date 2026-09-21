package com.learnos.batch.repository;

import com.learnos.batch.model.BatchMemberStatus;
import com.learnos.batch.model.BatchMembership;
import com.learnos.course.model.EnrollmentStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface BatchMembershipRepository
        extends JpaRepository<BatchMembership, UUID> {

    List<BatchMembership> findByBatch_IdOrderByJoinedAtAsc(
            UUID batchId
    );

    List<BatchMembership> findByBatch_IdAndStatusOrderByJoinedAtAsc(
            UUID batchId,
            BatchMemberStatus status
    );

    Optional<BatchMembership> findByBatch_IdAndUser_Id(
            UUID batchId,
            UUID userId
    );

    boolean existsByBatch_IdAndUser_IdAndStatusNot(
            UUID batchId,
            UUID userId,
            BatchMemberStatus status
    );

    long countByBatch_IdAndStatus(
            UUID batchId,
            BatchMemberStatus status
    );

    @Query("""
        SELECT COALESCE(AVG(e.progressPercent), 0)
        FROM BatchMembership bm
        JOIN Enrollment e
          ON e.user.id = bm.user.id
         AND e.course.id = bm.batch.course.id
        WHERE bm.batch.id = :batchId
          AND bm.status = :memberStatus
          AND e.status = :enrollmentStatus
        """)
    Double findAverageCourseProgressForBatch(
            @Param("batchId") UUID batchId,
            @Param("memberStatus") BatchMemberStatus memberStatus,
            @Param("enrollmentStatus")
            EnrollmentStatus enrollmentStatus
    );

    @Query("""
        SELECT COUNT(bm)
        FROM BatchMembership bm
        JOIN Enrollment e
          ON e.user.id = bm.user.id
         AND e.course.id = bm.batch.course.id
        WHERE bm.batch.id = :batchId
          AND bm.status = :memberStatus
          AND e.status = :enrollmentStatus
          AND e.progressPercent >= 100
        """)
    long countCompletedMembersForBatch(
            @Param("batchId") UUID batchId,
            @Param("memberStatus") BatchMemberStatus memberStatus,
            @Param("enrollmentStatus")
            EnrollmentStatus enrollmentStatus
    );
}