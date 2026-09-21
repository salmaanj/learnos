package com.learnos.companyuser.controller;

import com.learnos.auth.dto.UserCreateRequest;
import com.learnos.auth.dto.UserUpdateRequest;
import com.learnos.companyuser.dto.CompanyUserResponse;
import com.learnos.companyuser.service.CompanyUserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/company-users")
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('ADMIN','USER')")
public class CompanyUserController {

    private final CompanyUserService companyUserService;

    @GetMapping
    public ResponseEntity<List<CompanyUserResponse>> getAll() {
        return ResponseEntity.ok(companyUserService.getAllCompanyUsers());
    }

    @GetMapping("/{id}")
    public ResponseEntity<CompanyUserResponse> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(companyUserService.getCompanyUserById(id));
    }

    @PostMapping
    public ResponseEntity<CompanyUserResponse> create(@Valid @RequestBody UserCreateRequest request) {
        return ResponseEntity.ok(companyUserService.createCompanyUser(request));
    }

    @PutMapping("/{id}")
    public ResponseEntity<CompanyUserResponse> update(
            @PathVariable UUID id,
            @Valid @RequestBody UserUpdateRequest request
    ) {
        return ResponseEntity.ok(companyUserService.updateCompanyUser(id, request));
    }
}