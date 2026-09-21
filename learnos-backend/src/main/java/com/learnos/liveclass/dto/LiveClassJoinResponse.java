package com.learnos.liveclass.dto;

import com.learnos.liveclass.model.MeetingProvider;

import java.time.LocalDateTime;
import java.util.UUID;

public record LiveClassJoinResponse(

        UUID liveClassId,

        String title,

        MeetingProvider provider,

        String meetingUrl,
        String meetingPassword,

        LocalDateTime joinedAt
) {
}