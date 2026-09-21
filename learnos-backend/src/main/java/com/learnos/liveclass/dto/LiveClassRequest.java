package com.learnos.liveclass.dto;

import com.learnos.liveclass.model.LiveClassStatus;
import com.learnos.liveclass.model.MeetingProvider;
import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDateTime;
import java.util.UUID;

public record LiveClassRequest(

        UUID companyId,

        UUID courseId,

        UUID instructorId,

        @NotBlank(message = "Title is required")
        @Size(
                max = 200,
                message = "Title must not exceed 200 characters"
        )
        String title,

        @Size(
                max = 3000,
                message = "Description must not exceed 3000 characters"
        )
        String description,

        @NotNull(message = "Start date and time are required")
        LocalDateTime startAt,

        @NotNull(message = "End date and time are required")
        LocalDateTime endAt,

        @NotBlank(message = "Timezone is required")
        @Size(
                max = 64,
                message = "Timezone must not exceed 64 characters"
        )
        String timezone,

        @NotNull(message = "Meeting provider is required")
        MeetingProvider provider,

        @NotBlank(message = "Meeting URL is required")
        @Size(
                max = 2000,
                message = "Meeting URL must not exceed 2000 characters"
        )
        String meetingUrl,

        @Size(
                max = 255,
                message = "Meeting password must not exceed 255 characters"
        )
        String meetingPassword,

        @Min(
                value = 1,
                message = "Capacity must be at least 1"
        )
        Integer capacity,

        @Size(
                max = 2000,
                message = "Thumbnail URL must not exceed 2000 characters"
        )
        String thumbnailUrl,

        @Size(
                max = 2000,
                message = "Recording URL must not exceed 2000 characters"
        )
        String recordingUrl,

        LiveClassStatus status
) {
    @AssertTrue(message = "End date and time must be after start date and time")
    public boolean isEndAfterStart() {
        if (startAt == null || endAt == null) {
            return true;
        }

        return endAt.isAfter(startAt);
    }
}