package com.learnos.auth.service;

import com.learnos.auth.dto.UserCreateRequest;
import com.learnos.auth.dto.UserResponse;
import com.learnos.auth.model.Role;
import com.learnos.auth.model.User;
import com.learnos.auth.repository.UserRepository;
import com.learnos.company.entity.Company;
import com.learnos.company.repository.CompanyRepository;
import com.learnos.companyuser.entity.CompanyUser;
import com.learnos.companyuser.repository.CompanyUserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.learnos.auth.dto.UserUpdateRequest;
import java.util.NoSuchElementException;


import java.util.List;
import java.util.NoSuchElementException;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UserManagementService {

    private final UserRepository userRepository;
    private final CompanyRepository companyRepository;
    private final CompanyUserRepository companyUserRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public UserResponse createUser(UserCreateRequest request) {
        String email = request.email().toLowerCase().trim();

        if (userRepository.existsByEmail(email)) {
            throw new IllegalArgumentException("Email already exists");
        }

        User currentUser = getCurrentUser();
        Company company = resolveCompanyForCreate(currentUser, request.companyId());
        Role role = resolveRole(request.role());

        User user = User.builder()
                .firstName(request.firstName())
                .lastName(request.lastName())
                .email(email)
                .password(passwordEncoder.encode(request.password()))
                .phone(request.phone())
                .role(role)
                .company(company)
                .build();

        User savedUser = userRepository.save(user);

        CompanyUser companyUser = CompanyUser.builder()
                .user(savedUser)
                .company(company)
                .role(request.companyRole() != null
                        && !request.companyRole().isBlank()
                        ? request.companyRole().trim()
                        : role.name())
                .status(request.status() != null
                        && !request.status().isBlank()
                        ? request.status().trim()
                        : "ACTIVE")
                .build();

        companyUserRepository.save(companyUser);

        return toUserResponse(savedUser);
    }

    @Transactional(readOnly = true)
    public List<UserResponse> getUsers() {
        User currentUser = getCurrentUser();

        if (isPlatformAdmin(currentUser)) {
            return userRepository.findAll()
                    .stream()
                    .map(this::toUserResponse)
                    .toList();
        }

        if (currentUser.getCompany() == null) {
            throw new IllegalStateException("User is not assigned to a company");
        }

        return userRepository.findByCompanyId(currentUser.getCompany().getId())
                .stream()
                .map(this::toUserResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public UserResponse getUserById(UUID id) {
        User currentUser = getCurrentUser();

        User requestedUser = userRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("User not found"));

        if (!isPlatformAdmin(currentUser)) {
            if (currentUser.getCompany() == null
                    || requestedUser.getCompany() == null
                    || !currentUser.getCompany().getId()
                    .equals(requestedUser.getCompany().getId())) {
                throw new AccessDeniedException(
                        "You cannot access a user from another company");
            }
        }

        return toUserResponse(requestedUser);
    }
    @Transactional
    public UserResponse updateUser(UUID id, UserUpdateRequest request) {
        User currentUser = getCurrentUser();

        User user = userRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("User not found"));

        assertSameCompanyOrPlatformAdmin(currentUser, user);

        String email = request.email().toLowerCase().trim();

        if (!email.equalsIgnoreCase(user.getEmail())
                && userRepository.existsByEmail(email)) {
            throw new IllegalArgumentException("Email already exists");
        }

        Company company = resolveCompanyForUpdate(currentUser, request.companyId());
        Role role = resolveRole(request.role());

        user.setFirstName(request.firstName());
        user.setLastName(request.lastName());
        user.setEmail(email);
        user.setRole(role);
        user.setCompany(company);
        user.setPhone(request.phone());

        if (request.password() != null && !request.password().isBlank()) {
            user.setPassword(passwordEncoder.encode(request.password()));
        }

        User savedUser = userRepository.save(user);

        CompanyUser companyUser = companyUserRepository.findByUser_Id(id)
                .orElseThrow(() -> new NoSuchElementException(
                        "Company user record not found"));

        companyUser.setCompany(company);
        companyUser.setRole(role.name());
        companyUser.setStatus(request.status() != null
                && !request.status().isBlank()
                ? request.status().trim()
                : companyUser.getStatus());

        companyUserRepository.save(companyUser);

        return toUserResponse(savedUser);
    }

    private void assertSameCompanyOrPlatformAdmin(
            User currentUser,
            User targetUser) {
        if (isPlatformAdmin(currentUser)) {
            return;
        }

        if (currentUser.getCompany() == null
                || targetUser.getCompany() == null
                || !currentUser.getCompany().getId()
                .equals(targetUser.getCompany().getId())) {
            throw new AccessDeniedException(
                    "You cannot access a user from another company");
        }
    }

    private Company resolveCompanyForUpdate(
            User currentUser,
            String requestedCompanyId) {
        if (isPlatformAdmin(currentUser)) {
            if (requestedCompanyId == null
                    || requestedCompanyId.isBlank()) {
                return currentUser.getCompany();
            }

            UUID companyId;
            try {
                companyId = UUID.fromString(requestedCompanyId.trim());
            } catch (IllegalArgumentException ex) {
                throw new IllegalArgumentException("Invalid companyId");
            }

            return companyRepository.findById(companyId)
                    .orElseThrow(() -> new NoSuchElementException(
                            "Company not found"));
        }

        if (currentUser.getCompany() == null) {
            throw new IllegalStateException(
                    "User is not assigned to a company");
        }

        if (requestedCompanyId != null
                && !requestedCompanyId.isBlank()
                && !currentUser.getCompany().getId().toString()
                .equalsIgnoreCase(requestedCompanyId.trim())) {
            throw new AccessDeniedException(
                    "You cannot move a user to another company");
        }

        return currentUser.getCompany();
    }

    private Company resolveCompanyForCreate(User currentUser, UUID requestedCompanyId) {
        if (isPlatformAdmin(currentUser)) {
            if (requestedCompanyId == null) {
                throw new IllegalArgumentException(
                        "companyId is required for platform-admin user creation");
            }

            return companyRepository.findById(requestedCompanyId)
                    .orElseThrow(() -> new IllegalArgumentException("Company not found"));
        }

        if (currentUser.getCompany() == null) {
            throw new IllegalStateException("User is not assigned to a company");
        }

        UUID currentCompanyId = currentUser.getCompany().getId();

        if (requestedCompanyId != null
                && !currentCompanyId.equals(requestedCompanyId)) {
            throw new IllegalArgumentException(
                    "You cannot create a user for another company");
        }

        return currentUser.getCompany();
    }

    private Role resolveRole(String requestedRole) {
        if (requestedRole == null || requestedRole.isBlank()) {
            return Role.LEARNER;
        }

        try {
            return Role.valueOf(requestedRole.trim().toUpperCase());
        } catch (IllegalArgumentException ex) {
            throw new IllegalArgumentException("Invalid role: " + requestedRole);
        }
    }

    private User getCurrentUser() {
        Authentication authentication =
                SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || !authentication.isAuthenticated()) {
            throw new IllegalStateException("Authentication is required");
        }

        return userRepository.findByEmail(authentication.getName())
                .orElseThrow(() -> new IllegalStateException("Authenticated user not found"));
    }

    private boolean isPlatformAdmin(User user) {
        return user != null
                && user.getEmail() != null
                && user.getEmail().equalsIgnoreCase("admin@blute.co.in");
    }

    private UserResponse toUserResponse(User user) {
        return new UserResponse(
                user.getId(),
                user.getFirstName(),
                user.getLastName(),
                user.getEmail(),
                user.getRole().name(),
                user.getPhone(),
                companyUserRepository.findByUser_Id(user.getId())
                        .map(CompanyUser::getStatus)
                        .orElse(null)
        );
    }
}
