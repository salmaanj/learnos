package com.learnos.auth.repository;

import com.learnos.auth.model.UserRole;
import com.learnos.auth.model.UserRoleId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.UUID;

public interface UserRoleRepository extends JpaRepository<UserRole, UserRoleId> {

    @Query("""
        SELECT ur
        FROM UserRole ur
        JOIN FETCH ur.role r
        WHERE ur.user.id = :userId
    """)
    List<UserRole> findRolesByUserId(UUID userId);
}