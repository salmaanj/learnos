package com.learnos.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

import java.util.UUID;

public record UserUpdateRequest(
        @NotBlank String firstName,
        @NotBlank String lastName,
        @NotBlank @Email String email,
        String password,
        String phone,
        @NotBlank String role,
        UUID roleId,
        String companyId,
        String status
) {
    public UserUpdateRequest(
            String firstName,
            String lastName,
            String email,
            String password,
            String phone,
            String role,
            String companyId,
            String status
    ) {
        this(
                firstName,
                lastName,
                email,
                password,
                phone,
                role,
                null,
                companyId,
                status
        );
    }
}