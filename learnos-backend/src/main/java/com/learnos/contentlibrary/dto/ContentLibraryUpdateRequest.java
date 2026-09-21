package com.learnos.contentlibrary.dto;

import com.learnos.contentlibrary.model.ContentLibraryItemType;
import com.learnos.contentlibrary.model.ContentLibraryStatus;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.UUID;

public record ContentLibraryUpdateRequest(

        @NotBlank(message = "Title is required")
        @Size(max = 200, message = "Title must not exceed 200 characters")
        String title,

        @Size(max = 3000, message = "Description must not exceed 3000 characters")
        String description,

        @NotNull(message = "Content type is required")
        ContentLibraryItemType type,

        @Size(max = 2000, message = "Content URL is too long")
        String contentUrl,

        @Size(max = 2000, message = "Streaming URL is too long")
        String streamingUrl,

        @Size(max = 2000, message = "Thumbnail URL is too long")
        String thumbnailUrl,

        @Size(max = 1000, message = "Tags are too long")
        String tags,

        Integer durationSeconds,

        Long fileSizeBytes,

        @Size(max = 500, message = "Original file name is too long")
        String originalFileName,

        @NotNull(message = "Status is required")
        ContentLibraryStatus status,

        UUID companyId
) {}