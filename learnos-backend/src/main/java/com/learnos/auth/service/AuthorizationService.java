package com.learnos.auth.service;

import com.learnos.auth.model.User;
import com.learnos.auth.repository.UserRoleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthorizationService {

    private static final String SUPER_ADMIN_ROLE = "SUPER_ADMIN";

    private final UserRoleRepository userRoleRepository;

    public boolean isSuperAdmin(User user) {
        if (user == null || user.getId() == null) {
            return false;
        }

        return userRoleRepository.findRolesByUserId(user.getId())
                .stream()
                .anyMatch(userRole ->
                        SUPER_ADMIN_ROLE.equalsIgnoreCase(
                                userRole.getRole().getName()
                        )
                );
    }
}