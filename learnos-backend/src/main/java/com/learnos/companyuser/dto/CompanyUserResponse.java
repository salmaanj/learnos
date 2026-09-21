package com.learnos.companyuser.dto;

import java.util.UUID;

public record CompanyUserResponse(
        UUID id,
        UUID userId,
        String name,
        String email,
        String phone,
        UUID companyId,
        String companyName,
        String role,
        String status
) {}