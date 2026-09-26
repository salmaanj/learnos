package com.learnos.auth.dto;

import jakarta.validation.constraints.NotBlank;

import java.util.List;
import java.util.UUID;

public record UpdateRoleRequest(
        @NotBlank String name,
        String description,
        List<UUID> permissionIds
) {
}
