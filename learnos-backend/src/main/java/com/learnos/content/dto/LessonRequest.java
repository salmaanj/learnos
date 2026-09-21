package com.learnos.content.dto;

import com.learnos.content.model.LessonType;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class LessonRequest {
    @NotBlank
    private String title;
    private String description;
    private LessonType type;
    private String contentUrl;
    private String streamingUrl;
    private String thumbnailUrl;
    private String textContent;
    private Integer durationSeconds;
    private boolean isPreview;
    private boolean isPublished = true;
    private int displayOrder;
}