package com.learnos.content.dto;

import com.learnos.content.model.LessonType;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
public class LessonResponse {
    private UUID id;
    private String title;
    private String description;
    private LessonType type;
    private String contentUrl;
    private String streamingUrl;
    private String thumbnailUrl;
    private String textContent;
    private String mimeType;
    private String originalFileName;
    private long fileSizeBytes;
    private Integer durationSeconds;
    private int order;
    private boolean isPreview;
    private boolean isPublished;
    private UUID moduleId;
    private String moduleTitle;
    private LocalDateTime createdAt;
}