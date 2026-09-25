package com.learnos.config;

import com.learnos.auth.model.User;
import com.learnos.auth.model.UserRole;
import com.learnos.auth.repository.UserRepository;
import com.learnos.auth.repository.UserRoleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CustomUserDetailsService
        implements UserDetailsService {

    private static final String SUPER_ADMIN = "SUPER_ADMIN";

    private final UserRepository userRepository;
    private final UserRoleRepository userRoleRepository;

    @Override
    public UserDetails loadUserByUsername(String username)
            throws UsernameNotFoundException {

        User user = userRepository
                .findByEmail(username.toLowerCase().trim())
                .orElseThrow(() ->
                        new UsernameNotFoundException(
                                "User not found: " + username
                        )
                );

        List<SimpleGrantedAuthority> authorities =
                new ArrayList<>();

        List<UserRole> dynamicRoles =
                userRoleRepository.findRolesByUserId(user.getId());

        boolean superAdmin = dynamicRoles.stream()
                .anyMatch(userRole ->
                        SUPER_ADMIN.equalsIgnoreCase(
                                userRole.getRole().getName()
                        )
                );

        for (UserRole userRole : dynamicRoles) {
            authorities.add(
                    new SimpleGrantedAuthority(
                            "ROLE_" + userRole.getRole().getName()
                    )
            );

            userRole.getRole()
                    .getRolePermissions()
                    .forEach(rolePermission ->
                            authorities.add(
                                    new SimpleGrantedAuthority(
                                            rolePermission
                                                    .getPermission()
                                                    .getCode()
                                    )
                            )
                    );
        }

        if (superAdmin) {
            authorities.add(
                    new SimpleGrantedAuthority("ROLE_ADMIN")
            );
            authorities.add(
                    new SimpleGrantedAuthority("ROLE_USER")
            );
            authorities.add(
                    new SimpleGrantedAuthority("ROLE_TUTOR")
            );
        }

        if (authorities.isEmpty()) {
            authorities.add(
                    new SimpleGrantedAuthority(
                            "ROLE_" + user.getRole().name()
                    )
            );
        }

        return org.springframework.security.core.userdetails.User
                .builder()
                .username(user.getEmail())
                .password(user.getPassword())
                .authorities(authorities)
                .disabled(!user.isEnabled())
                .build();
    }
}