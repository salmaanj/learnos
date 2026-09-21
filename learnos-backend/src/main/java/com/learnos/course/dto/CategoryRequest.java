package com.learnos.course.dto;

import java.util.UUID;

public record CategoryRequest(
        String name,
        String description,
        String iconUrl,
        String color,
        Boolean active,
        Integer displayOrder,
        UUID companyId
) {}