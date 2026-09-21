package com.learnos.content.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.util.UUID;

@Data
public class ProgressRequest {

    @NotNull
    private UUID lessonId;

    private Integer watchedSeconds;   // ← renamed from progressSeconds

    private boolean completed;
}
