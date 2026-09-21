package com.learnos.auth.service;

import com.learnos.auth.dto.AuthResponse;
import com.learnos.auth.dto.LoginRequest;
import com.learnos.auth.dto.RefreshTokenRequest;
import com.learnos.auth.dto.RegisterRequest;
import com.learnos.auth.model.Role;
import com.learnos.auth.model.User;
import com.learnos.auth.repository.UserRepository;
import com.learnos.auth.security.JwtUtil;
import com.learnos.company.entity.Company;
import com.learnos.company.repository.CompanyRepository;
import com.learnos.companyuser.entity.CompanyUser;
import com.learnos.companyuser.repository.CompanyUserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Locale;

@Service
@RequiredArgsConstructor
public class AuthService {

    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    private final UserRepository userRepository;
    private final CompanyRepository companyRepository;
    private final CompanyUserRepository companyUserRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;
    private final JwtUtil jwtUtil;

    @Value("${app.otp-expiry-minutes:10}")
    private long otpExpiryMinutes;

    public String register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already exists");
        }

        Company company = null;

        if (request.getCompanyCode() != null
                && !request.getCompanyCode().isBlank()) {
            company = companyRepository
                    .findByCompanyCode(request.getCompanyCode())
                    .orElseThrow(() ->
                            new RuntimeException("Company not found"));
        }

        User user = User.builder()
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .phone(request.getPhone())
                .role(Role.LEARNER)
                .company(company)
                .enabled(true)
                .emailVerified(true)
                .active(true)
                .build();

        User savedUser = userRepository.save(user);

        if (company != null) {
            CompanyUser companyUser = CompanyUser.builder()
                    .user(savedUser)
                    .company(company)
                    .role(savedUser.getRole().name())
                    .status("Active")
                    .build();

            companyUserRepository.save(companyUser);
        }

        return "User registered successfully";
    }

    public AuthResponse login(LoginRequest request) {
        User user = userRepository
                .findByEmail(request.getEmail())
                .orElseThrow(() ->
                        new RuntimeException("Invalid credentials"));

        if (!passwordEncoder.matches(
                request.getPassword(),
                user.getPassword()
        )) {
            throw new RuntimeException("Invalid credentials");
        }

        String accessToken = jwtUtil.generateAccessToken(
                user.getEmail(),
                user.getRole().name(),
                user.getCompany() != null
                        ? user.getCompany().getId().toString()
                        : null,
                user.getCompany() != null
                        ? user.getCompany().getName()
                        : null
        );

        String refreshToken = jwtUtil.generateRefreshToken(user.getEmail());

        user.setRefreshToken(refreshToken);
        user.setLastLoginAt(LocalDateTime.now());

        userRepository.save(user);

        return buildAuthResponse(user, accessToken, refreshToken);
    }

    public AuthResponse refreshToken(RefreshTokenRequest request) {
        User user = userRepository
                .findByRefreshToken(request.getRefreshToken())
                .orElseThrow(() ->
                        new RuntimeException("Invalid refresh token"));

        String accessToken = jwtUtil.generateAccessToken(
                user.getEmail(),
                user.getRole().name(),
                user.getCompany() != null
                        ? user.getCompany().getId().toString()
                        : null,
                user.getCompany() != null
                        ? user.getCompany().getName()
                        : null
        );

        String refreshToken = jwtUtil.generateRefreshToken(user.getEmail());

        user.setRefreshToken(refreshToken);
        userRepository.save(user);

        return buildAuthResponse(user, accessToken, refreshToken);
    }

    public String forgotPassword(String email) {
        String normalizedEmail = normalizeEmail(email);

        if (normalizedEmail == null) {
            throw new RuntimeException("A valid email address is required.");
        }

        User user = userRepository
                .findByEmail(normalizedEmail)
                .orElseThrow(() ->
                        new RuntimeException(
                                "No account was found for this email address."
                        ));

        if (!user.isActive() || !user.isEnabled()) {
            throw new RuntimeException(
                    "This account is not active. Please contact your administrator."
            );
        }

        String otp = generateOtp();

        user.setOtpCode(otp);
        user.setOtpExpiry(
                LocalDateTime.now().plusMinutes(otpExpiryMinutes)
        );

        userRepository.save(user);

        System.out.println(
                "DEVELOPMENT PASSWORD RESET OTP for "
                        + user.getEmail()
                        + ": "
                        + otp
        );
        return "A password reset OTP has been sent to your email address.";
    }

    public String verifyResetOtp(String email, String otp) {
        User user = findUserForPasswordReset(email);

        validateResetOtp(user, otp);

        return "OTP verified successfully.";
    }

    public String resetPassword(
            String email,
            String otp,
            String newPassword
    ) {
        User user = findUserForPasswordReset(email);

        validateResetOtp(user, otp);
        validateNewPassword(newPassword);

        user.setPassword(passwordEncoder.encode(newPassword.trim()));
        user.setOtpCode(null);
        user.setOtpExpiry(null);

        // Invalidates existing refresh-token sessions after the password reset.
        user.setRefreshToken(null);
        user.setLoginAttempts(0);

        userRepository.save(user);

        return "Password reset successfully. Please sign in with your new password.";
    }

    private User findUserForPasswordReset(String email) {
        String normalizedEmail = normalizeEmail(email);

        if (normalizedEmail == null) {
            throw new RuntimeException("A valid email address is required.");
        }

        return userRepository
                .findByEmail(normalizedEmail)
                .orElseThrow(() ->
                        new RuntimeException(
                                "No account was found for this email address."
                        ));
    }

    private void validateResetOtp(User user, String otp) {
        if (otp == null || otp.trim().isBlank()) {
            throw new RuntimeException("OTP is required.");
        }

        if (user.getOtpCode() == null
                || user.getOtpExpiry() == null) {
            throw new RuntimeException(
                    "No active password reset OTP was found. Please request a new OTP."
            );
        }

        if (LocalDateTime.now().isAfter(user.getOtpExpiry())) {
            user.setOtpCode(null);
            user.setOtpExpiry(null);
            userRepository.save(user);

            throw new RuntimeException(
                    "This OTP has expired. Please request a new OTP."
            );
        }

        if (!user.getOtpCode().equals(otp.trim())) {
            throw new RuntimeException("The OTP you entered is incorrect.");
        }
    }

    private void validateNewPassword(String newPassword) {
        if (newPassword == null || newPassword.trim().length() < 8) {
            throw new RuntimeException(
                    "Password must contain at least 8 characters."
            );
        }
    }

    private String generateOtp() {
        int value = 100000 + SECURE_RANDOM.nextInt(900000);
        return String.valueOf(value);
    }

    private String normalizeEmail(String email) {
        if (email == null || email.trim().isBlank()) {
            return null;
        }

        return email.trim().toLowerCase(Locale.ROOT);
    }

    private AuthResponse buildAuthResponse(
            User user,
            String accessToken,
            String refreshToken
    ) {
        Company company = user.getCompany();

        AuthResponse.UserInfo info = AuthResponse.UserInfo.builder()
                .id(user.getId())
                .email(user.getEmail())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .fullName(user.getFullName())
                .phone(user.getPhone())
                .role(user.getRole())
                .profileImageUrl(user.getProfileImageUrl())
                .companyId(
                        company != null
                                ? company.getId().toString()
                                : null
                )
                .companyName(
                        company != null
                                ? company.getName()
                                : null
                )
                .companyLogoUrl(
                        company != null
                                ? company.getLogoUrl()
                                : null
                )
                .companyPrimaryColor(
                        company != null
                                ? company.getPrimaryColor()
                                : null
                )
                .companySecondaryColor(
                        company != null
                                ? company.getSecondaryColor()
                                : null
                )
                .companyAccentColor(
                        company != null
                                ? company.getAccentColor()
                                : null
                )
                .build();

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .expiresIn(86400)
                .user(info)
                .build();
    }
}