package com.learnos.companyuser.service;

import com.learnos.auth.dto.UserCreateRequest;
import com.learnos.auth.dto.UserUpdateRequest;
import com.learnos.auth.model.Role;
import com.learnos.auth.model.User;
import com.learnos.auth.repository.UserRepository;
import com.learnos.auth.service.AuthorizationService;
import com.learnos.company.entity.Company;
import com.learnos.company.repository.CompanyRepository;
import com.learnos.companyuser.dto.CompanyUserResponse;
import com.learnos.companyuser.entity.CompanyUser;
import com.learnos.companyuser.repository.CompanyUserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional
public class CompanyUserServiceImpl implements CompanyUserService {

    private final CompanyUserRepository companyUserRepository;
    private final CompanyRepository companyRepository;
    private final UserRepository userRepository;
    private final AuthorizationService authorizationService;
    private final PasswordEncoder passwordEncoder;

    @Override
    public CompanyUserResponse createCompanyUser(
            UserCreateRequest request
    ) {
        User currentUser = getCurrentUser();

        if (
                !isSuperAdmin(currentUser)
                        && (
                        currentUser == null
                                || currentUser.getCompany() == null
                )
        ) {
            throw new IllegalArgumentException("Access denied");
        }

        if (userRepository.existsByEmail(request.email())) {
            throw new IllegalArgumentException("Email already exists");
        }

        Company company;

        if (isSuperAdmin(currentUser)) {
            if (request.companyId() == null) {
                throw new IllegalArgumentException("Company is required");
            }

            company = companyRepository.findById(request.companyId())
                    .orElseThrow(() ->
                            new IllegalArgumentException(
                                    "Company not found"
                            )
                    );
        } else {
            company = currentUser.getCompany();
        }

        Role role = request.role() != null
                ? Role.valueOf(request.role())
                : Role.LEARNER;

        /*
         * A legacy USER account may create Learners only.
         * This preserves the current privilege-escalation protection.
         */
        if (
                !isSuperAdmin(currentUser)
                        && currentUser.getRole() == Role.USER
                        && role != Role.LEARNER
        ) {
            throw new IllegalArgumentException(
                    "You can only create learner accounts"
            );
        }

        User user = User.builder()
                .firstName(request.firstName())
                .lastName(request.lastName())
                .email(request.email())
                .password(passwordEncoder.encode(request.password()))
                .phone(request.phone())
                .role(role)
                .company(company)
                .enabled(true)
                .emailVerified(true)
                .active(true)
                .build();

        User savedUser = userRepository.save(user);

        CompanyUser companyUser = CompanyUser.builder()
                .user(savedUser)
                .company(company)
                .role(
                        request.companyRole() != null
                                ? request.companyRole()
                                : role.name()
                )
                .status(
                        request.status() != null
                                ? request.status()
                                : "Active"
                )
                .build();

        return toResponse(companyUserRepository.save(companyUser));
    }

    @Override
    public CompanyUserResponse updateCompanyUser(
            UUID id,
            UserUpdateRequest request
    ) {
        User currentUser = getCurrentUser();

        CompanyUser companyUser = companyUserRepository.findById(id)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Company user not found"
                        )
                );

        if (!isSuperAdmin(currentUser)) {
            if (
                    currentUser == null
                            || currentUser.getCompany() == null
                            || companyUser.getCompany() == null
                            || !currentUser.getCompany()
                            .getId()
                            .equals(companyUser.getCompany().getId())
            ) {
                throw new IllegalArgumentException("Access denied");
            }
        }

        User user = companyUser.getUser();

        if (user == null) {
            throw new IllegalArgumentException(
                    "Associated user not found"
            );
        }

        if (
                !user.getEmail().equalsIgnoreCase(request.email())
                        && userRepository.existsByEmail(request.email())
        ) {
            throw new IllegalArgumentException("Email already exists");
        }

        user.setFirstName(request.firstName());
        user.setLastName(request.lastName());
        user.setEmail(request.email());
        user.setPhone(request.phone());

        if (request.role() != null && !request.role().isBlank()) {
            Role newRole = Role.valueOf(request.role());

            if (
                    !isSuperAdmin(currentUser)
                            && currentUser.getRole() == Role.USER
                            && newRole != Role.LEARNER
            ) {
                throw new IllegalArgumentException(
                        "You can only manage learner accounts"
                );
            }

            user.setRole(newRole);
        }

        if (
                request.password() != null
                        && !request.password().isBlank()
        ) {
            user.setPassword(
                    passwordEncoder.encode(request.password())
            );
        }

        Company company = companyUser.getCompany();

        if (
                isSuperAdmin(currentUser)
                        && request.companyId() != null
                        && !request.companyId().isBlank()
        ) {
            company = companyRepository.findById(
                            UUID.fromString(request.companyId())
                    )
                    .orElseThrow(() ->
                            new IllegalArgumentException(
                                    "Company not found"
                            )
                    );
        }

        user.setCompany(company);
        userRepository.save(user);

        companyUser.setCompany(company);

        if (request.role() != null && !request.role().isBlank()) {
            companyUser.setRole(request.role());
        }

        companyUser.setStatus(
                request.status() != null
                        ? request.status()
                        : "Active"
        );

        return toResponse(companyUserRepository.save(companyUser));
    }

    @Override
    @Transactional(readOnly = true)
    public List<CompanyUserResponse> getAllCompanyUsers() {
        User currentUser = getCurrentUser();

        if (isSuperAdmin(currentUser)) {
            return companyUserRepository.findAll()
                    .stream()
                    .map(this::toResponse)
                    .toList();
        }

        if (
                currentUser != null
                        && currentUser.getCompany() != null
        ) {
            return companyUserRepository
                    .findByCompany_Id(
                            currentUser.getCompany().getId()
                    )
                    .stream()
                    .map(this::toResponse)
                    .toList();
        }

        return List.of();
    }

    @Override
    @Transactional(readOnly = true)
    public CompanyUserResponse getCompanyUserById(UUID id) {
        User currentUser = getCurrentUser();

        CompanyUser companyUser = companyUserRepository.findById(id)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Company user not found"
                        )
                );

        if (!isSuperAdmin(currentUser)) {
            if (
                    currentUser == null
                            || currentUser.getCompany() == null
                            || companyUser.getCompany() == null
                            || !currentUser.getCompany()
                            .getId()
                            .equals(companyUser.getCompany().getId())
            ) {
                throw new IllegalArgumentException("Access denied");
            }
        }

        return toResponse(companyUser);
    }

    private CompanyUserResponse toResponse(
            CompanyUser companyUser
    ) {
        User user = companyUser.getUser();
        Company company = companyUser.getCompany();

        return new CompanyUserResponse(
                companyUser.getId(),
                user != null ? user.getId() : null,
                user != null ? user.getFullName() : null,
                user != null ? user.getEmail() : null,
                user != null ? user.getPhone() : null,
                company != null ? company.getId() : null,
                company != null ? company.getName() : null,
                companyUser.getRole(),
                companyUser.getStatus()
        );
    }

    private User getCurrentUser() {
        Authentication auth = SecurityContextHolder
                .getContext()
                .getAuthentication();

        if (auth == null || auth.getName() == null) {
            return null;
        }

        return userRepository
                .findByEmail(auth.getName())
                .orElse(null);
    }

    private boolean isSuperAdmin(User user) {
        return authorizationService.isSuperAdmin(user);
    }
}