package com.learnos.companyuser.controller;

import com.learnos.auth.dto.UserCreateRequest;
import com.learnos.auth.dto.UserUpdateRequest;
import com.learnos.auth.service.AuthorizationService;
import com.learnos.companyuser.dto.CompanyUserResponse;
import com.learnos.companyuser.service.CompanyUserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/company-users")
@RequiredArgsConstructor
public class CompanyUserController {

    private final CompanyUserService companyUserService;
    private final AuthorizationService authorizationService;

    @GetMapping
    @PreAuthorize("@authorizationService.hasPermission(authentication, 'COMPANY_USERS_VIEW')")
    public ResponseEntity<List<CompanyUserResponse>> getAll() {
        return ResponseEntity.ok(companyUserService.getAllCompanyUsers());
    }

    @GetMapping("/{id}")
    @PreAuthorize("@authorizationService.hasPermission(authentication, 'COMPANY_USERS_VIEW')")
    public ResponseEntity<CompanyUserResponse> getById(
            @PathVariable UUID id
    ) {
        return ResponseEntity.ok(companyUserService.getCompanyUserById(id));
    }

    @PostMapping
    @PreAuthorize("@authorizationService.hasPermission(authentication, 'COMPANY_USERS_CREATE')")
    public ResponseEntity<CompanyUserResponse> create(
            @Valid @RequestBody UserCreateRequest request
    ) {
        return ResponseEntity.ok(companyUserService.createCompanyUser(request));
    }

    @PutMapping("/{id}")
    @PreAuthorize("@authorizationService.hasPermission(authentication, 'COMPANY_USERS_EDIT')")
    public ResponseEntity<CompanyUserResponse> update(
            @PathVariable UUID id,
            @Valid @RequestBody UserUpdateRequest request
    ) {
        return ResponseEntity.ok(
                companyUserService.updateCompanyUser(id, request)
        );
    }
}