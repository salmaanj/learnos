package com.learnos.course.dto;

import java.util.UUID;

public record CategoryResponse(
        UUID id,
        String name,
        String description,
        String iconUrl,
        String color,
        boolean active,
        int displayOrder,
        UUID companyId,
        String companyName,
        long courseCount
) {}