package com.learnos.config;

import com.learnos.auth.model.User;
import com.learnos.auth.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

@Service
@RequiredArgsConstructor
public class CustomUserDetailsService
        implements UserDetailsService {

    private final UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(
            String username
    ) throws UsernameNotFoundException {

        String email = username
                .toLowerCase(Locale.ROOT)
                .trim();

        User user = userRepository
                .findByEmail(email)
                .orElseThrow(
                        () -> new UsernameNotFoundException(
                                "User not found: "
                                        + username
                        )
                );

        List<SimpleGrantedAuthority> authorities =
                new ArrayList<>();

        if (user.getRole() != null) {
            String role =
                    user.getRole()
                            .name()
                            .trim()
                            .toUpperCase(Locale.ROOT)
                            .replace('-', '_')
                            .replace(' ', '_');

            authorities.add(
                    new SimpleGrantedAuthority(
                            "ROLE_" + role
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