package com.learnos.liveclass.dto;

import com.learnos.liveclass.model.LiveClassStatus;
import com.learnos.liveclass.model.MeetingProvider;

import java.time.LocalDateTime;
import java.util.UUID;

public record LiveClassResponse(

        UUID id,

        UUID companyId,
        String companyName,

        UUID courseId,
        String courseTitle,

        UUID instructorId,
        String instructorName,

        String title,
        String description,

        LocalDateTime startAt,
        LocalDateTime endAt,
        String timezone,

        MeetingProvider provider,
        String meetingUrl,

        Integer capacity,
        LiveClassStatus status,

        String thumbnailUrl,
        String recordingUrl,

        UUID createdByUserId,
        String createdByName,

        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}