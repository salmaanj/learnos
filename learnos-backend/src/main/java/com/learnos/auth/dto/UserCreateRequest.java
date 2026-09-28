package com.learnos.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

import java.util.UUID;

public record UserCreateRequest(
        @NotBlank String firstName,
        @NotBlank String lastName,
        @Email @NotBlank String email,
        @NotBlank String password,
        String phone,
        String role,
        UUID roleId,
        UUID companyId,
        String companyRole,
        String status
) {
}
