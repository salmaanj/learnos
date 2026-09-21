package com.learnos.auth.dto;

import lombok.Builder;
import lombok.Data;

import java.util.UUID;

@Data
@Builder
public class UpdateProfileResponse {
    private UUID id;
    private String email;
    private String firstName;
    private String lastName;
    private String fullName;
    private String phone;
    private String profileImageUrl;
    private String role;
    private String companyId;
    private String companyName;
}