package com.learnos.liveclass.dto;

import com.learnos.liveclass.model.LiveClassStatus;
import jakarta.validation.constraints.NotNull;

public record LiveClassStatusRequest(

        @NotNull(message = "Status is required")
        LiveClassStatus status
) {
}