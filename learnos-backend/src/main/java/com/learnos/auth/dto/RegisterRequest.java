package com.learnos.auth.dto;

import com.learnos.auth.model.Role;
import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class RegisterRequest {
    @NotBlank(message = "First name is required")
    private String firstName;

    @NotBlank(message = "Last name is required")
    private String lastName;

    @Email(message = "Valid email is required")
    @NotBlank(message = "Email is required")
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 8, message = "Password must be at least 8 characters")
    private String password;

    private String phone;

    // Deprecated: ignored by the server. Self-registration always creates a
    // USER (learner) account; kept only for backward compatibility with
    // older mobile builds that still send this field.
    private Role role;

    private String companyId;
    private String companyCode;
}
