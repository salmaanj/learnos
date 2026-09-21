package com.learnos.companyuser.repository;

import com.learnos.companyuser.entity.CompanyUser;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface CompanyUserRepository extends JpaRepository<CompanyUser, UUID> {

    List<CompanyUser> findByCompany_Id(UUID companyId);

    List<CompanyUser> findByCompany_IdAndRoleIgnoreCaseAndStatusIgnoreCaseOrderByIdAsc(
            UUID companyId,
            String role,
            String status
    );
}