package com.learnos.auth.repository;

import com.learnos.auth.model.DynamicRole;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface DynamicRoleRepository extends JpaRepository<DynamicRole, UUID> {

    Optional<DynamicRole> findByNameIgnoreCase(String name);
}
