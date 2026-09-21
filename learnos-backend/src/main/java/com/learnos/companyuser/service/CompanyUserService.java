package com.learnos.companyuser.service;

import com.learnos.auth.dto.UserCreateRequest;
import com.learnos.auth.dto.UserUpdateRequest;
import com.learnos.companyuser.dto.CompanyUserResponse;

import java.util.List;
import java.util.UUID;

public interface CompanyUserService {
    CompanyUserResponse createCompanyUser(UserCreateRequest request);
    CompanyUserResponse updateCompanyUser(UUID id, UserUpdateRequest request);
    List<CompanyUserResponse> getAllCompanyUsers();
    CompanyUserResponse getCompanyUserById(UUID id);
}