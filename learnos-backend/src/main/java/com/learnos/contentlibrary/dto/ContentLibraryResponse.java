package com.learnos.contentlibrary.dto;

import com.learnos.contentlibrary.model.ContentLibraryItemType;
import com.learnos.contentlibrary.model.ContentLibraryStatus;

import java.time.LocalDateTime;
import java.util.UUID;

public record ContentLibraryResponse(
        UUID id,
        String title,
        String description,
        ContentLibraryItemType type,
        String contentUrl,
        String streamingUrl,
        String thumbnailUrl,
        String tags,
        Integer durationSeconds,
        Long fileSizeBytes,
        String originalFileName,
        ContentLibraryStatus status,
        UUID companyId,
        String companyName,
        UUID createdByUserId,
        String createdByName,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {}