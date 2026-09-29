package com.learnos.companyuser.service;

import com.learnos.auth.dto.UserCreateRequest;
import com.learnos.auth.dto.UserUpdateRequest;
import com.learnos.auth.model.DynamicRole;
import com.learnos.auth.model.Role;
import com.learnos.auth.model.User;
import com.learnos.auth.model.UserRole;
import com.learnos.auth.model.UserRoleId;
import com.learnos.auth.repository.DynamicRoleRepository;
import com.learnos.auth.repository.UserRepository;
import com.learnos.auth.repository.UserRoleRepository;
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

    private static final String LEARNER_ROLE = "LEARNER";

    private final CompanyUserRepository companyUserRepository;
    private final CompanyRepository companyRepository;
    private final UserRepository userRepository;
    private final DynamicRoleRepository dynamicRoleRepository;
    private final UserRoleRepository userRoleRepository;
    private final AuthorizationService authorizationService;
    private final PasswordEncoder passwordEncoder;

    @Override
    public CompanyUserResponse createCompanyUser(UserCreateRequest request) {
        User currentUser = getCurrentUser();
        ensureCanCreate(currentUser);

        String email = request.email().trim().toLowerCase();

        if (userRepository.existsByEmail(email)) {
            throw new IllegalArgumentException("Email already exists");
        }

        Company company = resolveCompany(currentUser, request.companyId());
        RoleResolution roleResolution = resolveRoleForCreate(currentUser, request);

        User user = User.builder()
                .firstName(request.firstName().trim())
                .lastName(request.lastName().trim())
                .email(email)
                .password(passwordEncoder.encode(request.password()))
                .phone(request.phone())
                .role(roleResolution.legacyRole())
                .company(company)
                .enabled(true)
                .emailVerified(true)
                .active(true)
                .build();

        User savedUser = userRepository.save(user);

        if (roleResolution.dynamicRole() != null) {
            saveDynamicRole(savedUser, roleResolution.dynamicRole());
        }

        CompanyUser companyUser = CompanyUser.builder()
                .user(savedUser)
                .company(company)
                .role(roleResolution.displayRole())
                .status(normalizeStatus(request.status()))
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
                .orElseThrow(() -> new IllegalArgumentException(
                        "Company user not found"
                ));

        ensureCanAccess(currentUser, companyUser);

        User user = companyUser.getUser();

        if (user == null) {
            throw new IllegalArgumentException("Associated user not found");
        }

        String email = request.email().trim().toLowerCase();

        if (!user.getEmail().equalsIgnoreCase(email)
                && userRepository.existsByEmail(email)) {
            throw new IllegalArgumentException("Email already exists");
        }

        RoleResolution roleResolution = resolveRoleForUpdate(
                currentUser,
                request,
                user
        );

        user.setFirstName(request.firstName().trim());
        user.setLastName(request.lastName().trim());
        user.setEmail(email);
        user.setPhone(request.phone());
        user.setRole(roleResolution.legacyRole());

        if (request.password() != null
                && !request.password().isBlank()) {
            user.setPassword(
                    passwordEncoder.encode(request.password())
            );
        }

        Company company = companyUser.getCompany();

        if (isSuperAdmin(currentUser)
                && request.companyId() != null
                && !request.companyId().isBlank()) {
            company = companyRepository.findById(
                    UUID.fromString(request.companyId().trim())
            ).orElseThrow(() -> new IllegalArgumentException(
                    "Company not found"
            ));
        }

        user.setCompany(company);
        User savedUser = userRepository.save(user);

        userRoleRepository.deleteAll(
                userRoleRepository.findRolesByUserId(savedUser.getId())
        );

        if (roleResolution.dynamicRole() != null) {
            saveDynamicRole(savedUser, roleResolution.dynamicRole());
        }

        companyUser.setCompany(company);
        companyUser.setRole(roleResolution.displayRole());

        if (request.status() != null
                && !request.status().isBlank()) {
            companyUser.setStatus(request.status().trim());
        }

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

        if (currentUser == null
                || currentUser.getCompany() == null) {
            return List.of();
        }

        return companyUserRepository
                .findByCompany_Id(currentUser.getCompany().getId())
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public CompanyUserResponse getCompanyUserById(UUID id) {
        User currentUser = getCurrentUser();

        CompanyUser companyUser = companyUserRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException(
                        "Company user not found"
                ));

        ensureCanAccess(currentUser, companyUser);
        return toResponse(companyUser);
    }

    private RoleResolution resolveRoleForCreate(
            User currentUser,
            UserCreateRequest request
    ) {
        if (isLearnerRequest(request)) {
            if (!isSuperAdmin(currentUser)
                    && currentUser.getRole() != Role.USER
                    && currentUser.getRole() != Role.ADMIN) {
                throw new IllegalArgumentException(
                        "Learner accounts must be created through the learner workflow"
                );
            }

            return new RoleResolution(
                    Role.LEARNER,
                    null,
                    LEARNER_ROLE
            );
        }

        if (request.roleId() == null) {
            throw new IllegalArgumentException(
                    "roleId is required for staff user creation"
            );
        }

        DynamicRole dynamicRole = findStaffRole(request.roleId());
        return toRoleResolution(dynamicRole);
    }

    private RoleResolution resolveRoleForUpdate(
            User currentUser,
            UserUpdateRequest request,
            User existingUser
    ) {
        if (isLearnerRequest(request)) {
            if (!isSuperAdmin(currentUser)
                    && currentUser.getRole() != Role.USER
                    && existingUser.getRole() != Role.LEARNER) {
                throw new IllegalArgumentException(
                        "Learner accounts must be managed through the learner workflow"
                );
            }

            return new RoleResolution(
                    Role.LEARNER,
                    null,
                    LEARNER_ROLE
            );
        }

        if (request.roleId() == null) {
            throw new IllegalArgumentException(
                    "roleId is required for staff user updates"
            );
        }

        DynamicRole dynamicRole = findStaffRole(request.roleId());
        return toRoleResolution(dynamicRole);
    }

    private boolean isLearnerRequest(UserCreateRequest request) {
        return request.roleId() == null
                && request.role() != null
                && LEARNER_ROLE.equalsIgnoreCase(
                request.role().trim()
        );
    }

    private boolean isLearnerRequest(UserUpdateRequest request) {
        return request.roleId() == null
                && request.role() != null
                && LEARNER_ROLE.equalsIgnoreCase(
                request.role().trim()
        );
    }

    private DynamicRole findStaffRole(UUID roleId) {
        DynamicRole role = dynamicRoleRepository.findById(roleId)
                .orElseThrow(() -> new IllegalArgumentException(
                        "Role not found"
                ));

        if (LEARNER_ROLE.equalsIgnoreCase(role.getName())) {
            throw new IllegalArgumentException(
                    "Learner accounts must use the learner workflow"
            );
        }

        return role;
    }

    private RoleResolution toRoleResolution(DynamicRole dynamicRole) {
        String dynamicName = dynamicRole.getName().trim();

        Role legacyRole;

        try {
            legacyRole = Role.valueOf(
                    dynamicName.toUpperCase()
            );
        } catch (IllegalArgumentException ex) {
            legacyRole = Role.USER;
        }

        return new RoleResolution(
                legacyRole,
                dynamicRole,
                dynamicName
        );
    }

    private void saveDynamicRole(User user, DynamicRole role) {
        userRoleRepository.save(
                UserRole.builder()
                        .id(new UserRoleId(
                                user.getId(),
                                role.getId()
                        ))
                        .user(user)
                        .role(role)
                        .build()
        );
    }

    private Company resolveCompany(
            User currentUser,
            UUID requestedCompanyId
    ) {
        if (isSuperAdmin(currentUser)) {
            if (requestedCompanyId == null) {
                throw new IllegalArgumentException("Company is required");
            }

            return companyRepository.findById(requestedCompanyId)
                    .orElseThrow(() -> new IllegalArgumentException(
                            "Company not found"
                    ));
        }

        if (currentUser == null
                || currentUser.getCompany() == null) {
            throw new IllegalArgumentException(
                    "User is not assigned to a company"
            );
        }

        if (requestedCompanyId != null
                && !currentUser.getCompany().getId()
                .equals(requestedCompanyId)) {
            throw new IllegalArgumentException(
                    "You cannot create a user for another company"
            );
        }

        return currentUser.getCompany();
    }

    private void ensureCanCreate(User currentUser) {
        if (currentUser == null) {
            throw new IllegalArgumentException("Access denied");
        }

        if (!isSuperAdmin(currentUser)
                && currentUser.getCompany() == null) {
            throw new IllegalArgumentException("Access denied");
        }
    }

    private void ensureCanAccess(
            User currentUser,
            CompanyUser companyUser
    ) {
        if (isSuperAdmin(currentUser)) {
            return;
        }

        if (currentUser == null
                || currentUser.getCompany() == null
                || companyUser.getCompany() == null
                || !currentUser.getCompany().getId()
                .equals(companyUser.getCompany().getId())) {
            throw new IllegalArgumentException("Access denied");
        }
    }

    private boolean isSuperAdmin(User user) {
        return authorizationService.isSuperAdmin(user);
    }

    private User getCurrentUser() {
        Authentication authentication =
                SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null
                || authentication.getName() == null
                || authentication.getName().isBlank()) {
            return null;
        }

        return userRepository.findByEmail(authentication.getName())
                .orElse(null);
    }

    private String normalizeStatus(String status) {
        return status == null || status.isBlank()
                ? "ACTIVE"
                : status.trim();
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

    private record RoleResolution(
            Role legacyRole,
            DynamicRole dynamicRole,
            String displayRole
    ) {
    }
}