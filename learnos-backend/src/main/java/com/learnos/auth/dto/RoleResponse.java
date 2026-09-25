package com.learnos.auth.dto;

import java.util.List;
import java.util.UUID;

public record RoleResponse(
        UUID id,
        String name,
        String description,
        boolean systemRole,
        List<String> permissions
) {
}