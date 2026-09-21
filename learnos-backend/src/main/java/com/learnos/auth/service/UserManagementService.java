package com.learnos.auth.service;

import com.learnos.auth.dto.UserCreateRequest;
import com.learnos.auth.dto.UserResponse;
import com.learnos.auth.model.User;
import com.learnos.auth.repository.UserRepository;
import com.learnos.company.entity.Company;
import com.learnos.company.repository.CompanyRepository;
import com.learnos.companyuser.entity.CompanyUser;
import com.learnos.companyuser.repository.CompanyUserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserManagementService {

    private final UserRepository userRepository;
    private final CompanyRepository companyRepository;
    private final CompanyUserRepository companyUserRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public UserResponse createUser(UserCreateRequest request) {
        if (userRepository.existsByEmail(request.email())) {
            throw new IllegalArgumentException("Email already exists");
        }

        User user = User.builder()
                .firstName(request.firstName())
                .lastName(request.lastName())
                .email(request.email())
                .password(passwordEncoder.encode(request.password()))
                .phone(request.phone())
                .role(com.learnos.auth.model.Role.valueOf(request.role()))
                .enabled(true)
                .emailVerified(true)
                .active(true)
                .build();

        User savedUser = userRepository.save(user);

        if (request.companyId() != null) {
            Company company = companyRepository.findById(request.companyId())
                    .orElseThrow(() -> new IllegalArgumentException("Company not found"));

            CompanyUser companyUser = CompanyUser.builder()
                    .user(savedUser)
                    .company(company)
                    .role(request.companyRole() != null ? request.companyRole() : request.role())
                    .status(request.status() != null ? request.status() : "Active")
                    .build();

            companyUserRepository.save(companyUser);
        }

        return new UserResponse(
                savedUser.getId(),
                savedUser.getFirstName(),
                savedUser.getLastName(),
                savedUser.getEmail(),
                savedUser.getRole().name()
        );
    }
}