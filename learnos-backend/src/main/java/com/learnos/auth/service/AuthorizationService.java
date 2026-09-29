package com.learnos.auth.service;

import com.learnos.auth.model.DynamicRole;
import com.learnos.auth.model.Permission;
import com.learnos.auth.model.RolePermission;
import com.learnos.auth.model.User;
import com.learnos.auth.model.UserRole;
import com.learnos.auth.repository.UserRepository;
import com.learnos.auth.repository.UserRoleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

import java.util.Locale;
import java.util.Objects;

@Service("authorizationService")
@RequiredArgsConstructor
public class AuthorizationService {

    private static final String SUPER_ADMIN_ROLE = "SUPER_ADMIN";
    private static final String ADMIN_ROLE = "ADMIN";

    private final UserRepository userRepository;
    private final UserRoleRepository userRoleRepository;

    public boolean isSuperAdmin(User user) {
        return hasRole(user, SUPER_ADMIN_ROLE);
    }

    public boolean hasPermission(
            Authentication authentication,
            String permission
    ) {
        if (authentication == null
                || authentication.getName() == null
                || authentication.getName().isBlank()
                || permission == null
                || permission.isBlank()) {
            return false;
        }

        String email = authentication.getName()
                .toLowerCase(Locale.ROOT)
                .trim();

        User user = userRepository
                .findByEmail(email)
                .orElse(null);

        if (user == null || user.getId() == null) {
            return false;
        }

        if (hasRole(user, ADMIN_ROLE) || isSuperAdmin(user)) {
            return true;
        }
        if (
                user.getRole() != null
                        && user.getRole().name()
                        .equalsIgnoreCase("LEARNER")
        ) {
            return normalize(permission)
                    .equals("COURSES_VIEW");
        }
        String requestedPermission = normalize(permission);

        return userRoleRepository
                .findRolesByUserId(user.getId())
                .stream()
                .filter(Objects::nonNull)
                .map(UserRole::getRole)
                .filter(Objects::nonNull)
                .flatMap(role -> {
                    if (role.getRolePermissions() == null) {
                        return java.util.stream.Stream.empty();
                    }

                    return role.getRolePermissions().stream();
                })
                .filter(Objects::nonNull)
                .map(RolePermission::getPermission)
                .filter(Objects::nonNull)
                .map(Permission::getCode)
                .filter(Objects::nonNull)
                .map(this::normalize)
                .anyMatch(requestedPermission::equals);
    }

    private boolean hasRole(User user, String expectedRole) {
        if (user == null || user.getId() == null) {
            return false;
        }

        return userRoleRepository
                .findRolesByUserId(user.getId())
                .stream()
                .filter(Objects::nonNull)
                .map(UserRole::getRole)
                .filter(Objects::nonNull)
                .map(DynamicRole::getName)
                .filter(Objects::nonNull)
                .map(this::normalize)
                .anyMatch(expectedRole::equals);
    }

    private String normalize(String value) {
        return value.trim()
                .toUpperCase(Locale.ROOT);
    }
}