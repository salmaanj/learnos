package com.learnos.auth.controller;

import com.learnos.auth.dto.AuthResponse;
import com.learnos.auth.dto.ForgotPasswordRequest;
import com.learnos.auth.dto.LoginRequest;
import com.learnos.auth.dto.OtpVerifyRequest;
import com.learnos.auth.dto.RegisterRequest;
import com.learnos.auth.dto.ResetPasswordRequest;
import com.learnos.auth.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/auth")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    public AuthResponse login(
            @RequestBody LoginRequest request
    ) {
        return authService.login(request);
    }

    @PostMapping("/register")
    public String register(
            @RequestBody RegisterRequest request
    ) {
        return authService.register(request);
    }

    @PostMapping("/forgot-password")
    public String forgotPassword(
            @Valid @RequestBody ForgotPasswordRequest request
    ) {
        return authService.forgotPassword(request.getEmail());
    }

    @PostMapping("/verify-reset-otp")
    public String verifyResetOtp(
            @Valid @RequestBody OtpVerifyRequest request
    ) {
        return authService.verifyResetOtp(
                request.getEmail(),
                request.getOtp()
        );
    }

    @PostMapping("/reset-password")
    public String resetPassword(
            @Valid @RequestBody ResetPasswordRequest request
    ) {
        return authService.resetPassword(
                request.getEmail(),
                request.getOtp(),
                request.getNewPassword()
        );
    }
}