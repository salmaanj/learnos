package com.learnos.auth.repository;

import com.learnos.auth.model.RolePermission;
import com.learnos.auth.model.RolePermissionId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface RolePermissionRepository
        extends JpaRepository<RolePermission, RolePermissionId> {

    void deleteByRole_Id(UUID roleId);
}