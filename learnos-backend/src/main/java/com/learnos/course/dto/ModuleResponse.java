package com.learnos.course.dto;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
public class ModuleResponse {
    private UUID id;
    private String title;
    private String description;
    private int displayOrder;
    private boolean isPreview;
    private LocalDateTime createdAt;
}