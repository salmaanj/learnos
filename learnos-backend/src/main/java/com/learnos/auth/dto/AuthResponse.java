package com.learnos.auth.dto;

import com.learnos.auth.model.Role;
import lombok.Builder;
import lombok.Data;

import java.util.List;
import java.util.UUID;

@Data
@Builder
public class AuthResponse {

    private String accessToken;
    private String refreshToken;

    @Builder.Default
    private String tokenType = "Bearer";

    private long expiresIn;
    private UserInfo user;

    @Data
    @Builder
    public static class UserInfo {
        private UUID id;
        private String email;
        private String firstName;
        private String lastName;
        private String fullName;
        private String phone;
        private Role role;
        private String profileImageUrl;
        private String companyId;
        private String companyName;
        private String companyLogoUrl;
        private String companyPrimaryColor;
        private String companySecondaryColor;
        private String companyAccentColor;

        @Builder.Default
        private List<String> permissions = List.of();
    }
}