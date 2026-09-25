package com.learnos.auth.repository;

import com.learnos.auth.model.Permission;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface PermissionRepository
        extends JpaRepository<Permission, UUID> {
}
