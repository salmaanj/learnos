package com.learnos.auth.repository;

import com.learnos.auth.model.Role;
import com.learnos.auth.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserRepository extends JpaRepository<User, UUID> {

    Optional<User> findByEmail(String email);

    boolean existsByEmail(String email);

    Optional<User> findByRefreshToken(String refreshToken);

    List<User> findByCompanyId(UUID companyId);

    List<User> findByCompanyIdAndRole(UUID companyId, Role role);

    long countByCompanyId(UUID companyId);

    long countByCompanyIdAndRole(UUID companyId, Role role);

    @Modifying
    @Transactional
    @Query("UPDATE User u SET u.loginAttempts = u.loginAttempts + 1 WHERE u.email = :email")
    void incrementLoginAttempts(String email);

    @Modifying
    @Transactional
    @Query("UPDATE User u SET u.loginAttempts = 0, u.lastLoginAt = CURRENT_TIMESTAMP WHERE u.email = :email")
    void resetLoginAttempts(String email);

    @Modifying
    @Transactional
    @Query("UPDATE User u SET u.refreshToken = :token WHERE u.email = :email")
    void updateRefreshToken(String email, String token);
}
