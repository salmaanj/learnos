package com.learnos.batch.repository;

import com.learnos.batch.model.Batch;
import com.learnos.batch.model.BatchStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface BatchRepository extends JpaRepository<Batch, UUID> {

    List<Batch> findByCompany_IdOrderByCreatedAtDesc(UUID companyId);

    List<Batch> findByCompany_IdAndStatusOrderByCreatedAtDesc(
            UUID companyId,
            BatchStatus status
    );

    Optional<Batch> findByCompany_IdAndCodeIgnoreCase(
            UUID companyId,
            String code
    );

    boolean existsByCompany_IdAndCodeIgnoreCase(
            UUID companyId,
            String code
    );

    boolean existsByCompany_IdAndCodeIgnoreCaseAndIdNot(
            UUID companyId,
            String code,
            UUID id
    );
}