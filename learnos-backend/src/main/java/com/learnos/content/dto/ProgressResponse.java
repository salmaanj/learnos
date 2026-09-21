package com.learnos.content.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
public class ProgressResponse {

    private UUID lessonId;
    private UUID moduleId;
    private UUID courseId;

    private boolean completed;
    private int watchedSeconds;
    private Integer durationSeconds;
    private int progressPercent;

    private LocalDateTime completedAt;
    private LocalDateTime lastAccessedAt;
}
