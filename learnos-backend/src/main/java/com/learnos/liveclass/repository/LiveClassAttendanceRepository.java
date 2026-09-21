package com.learnos.liveclass.repository;

import com.learnos.liveclass.model.LiveClassAttendance;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface LiveClassAttendanceRepository
        extends JpaRepository<LiveClassAttendance, UUID> {

    Optional<LiveClassAttendance>
    findByLiveClassIdAndLearnerId(
            UUID liveClassId,
            UUID learnerId
    );

    List<LiveClassAttendance>
    findByLearnerIdOrderByJoinAtDesc(
            UUID learnerId
    );

    List<LiveClassAttendance>
    findByLiveClassIdOrderByJoinAtAsc(
            UUID liveClassId
    );
}