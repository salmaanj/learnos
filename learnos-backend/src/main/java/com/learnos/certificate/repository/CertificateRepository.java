package com.learnos.certificate.repository;

import com.learnos.certificate.model.Certificate;
import com.learnos.certificate.model.CertificateStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface CertificateRepository extends JpaRepository<Certificate, UUID> {

    boolean existsByUser_IdAndCourse_Id(UUID userId, UUID courseId);

    Optional<Certificate> findByUser_IdAndCourse_Id(UUID userId, UUID courseId);

    Optional<Certificate> findByVerificationCode(String verificationCode);

    Optional<Certificate> findByCertificateNumber(String certificateNumber);

    List<Certificate> findByUser_IdOrderByIssuedAtDesc(UUID userId);

    List<Certificate> findByCompany_IdOrderByIssuedAtDesc(UUID companyId);

    List<Certificate> findByIssuedAtBetweenOrderByIssuedAtDesc(
            LocalDateTime start,
            LocalDateTime end
    );

    long countByStatus(CertificateStatus status);

    long countByCompany_IdAndStatus(UUID companyId, CertificateStatus status);
}