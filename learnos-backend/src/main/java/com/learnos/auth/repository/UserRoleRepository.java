package com.learnos.auth.repository;

import com.learnos.auth.model.UserRole;
import com.learnos.auth.model.UserRoleId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface UserRoleRepository
        extends JpaRepository<UserRole, UserRoleId> {

    @Query("""
        SELECT DISTINCT ur
        FROM UserRole ur
        JOIN FETCH ur.role r
        LEFT JOIN FETCH r.rolePermissions rp
        LEFT JOIN FETCH rp.permission p
        WHERE ur.user.id = :userId
    """)
    List<UserRole> findRolesByUserId(
            @Param("userId") UUID userId
    );
}