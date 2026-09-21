package com.learnos.liveclass.dto;

import com.learnos.liveclass.model.LiveClassAttendanceStatus;
import com.learnos.liveclass.model.LiveClassStatus;
import com.learnos.liveclass.model.MeetingProvider;

import java.time.LocalDateTime;
import java.util.UUID;

public record LearnerLiveClassResponse(

        UUID id,

        String title,
        String description,

        UUID courseId,
        String courseTitle,

        String instructorName,

        LocalDateTime startAt,
        LocalDateTime endAt,
        String timezone,

        MeetingProvider provider,

        Integer capacity,
        LiveClassStatus status,

        String thumbnailUrl,
        String recordingUrl,

        boolean eligible,
        boolean joinAvailable,

        LiveClassAttendanceStatus attendanceStatus,
        LocalDateTime joinAt,
        LocalDateTime leaveAt,
        Integer minutesAttended
) {
}