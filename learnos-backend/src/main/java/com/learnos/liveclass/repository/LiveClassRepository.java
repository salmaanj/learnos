package com.learnos.liveclass.repository;

import com.learnos.liveclass.model.LiveClass;
import com.learnos.liveclass.model.LiveClassStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface LiveClassRepository
        extends JpaRepository<LiveClass, UUID> {

    Page<LiveClass> findByCompany_Id(
            UUID companyId,
            Pageable pageable
    );

    Page<LiveClass> findByCompany_IdAndStatus(
            UUID companyId,
            LiveClassStatus status,
            Pageable pageable
    );

    Page<LiveClass> findByCompany_IdAndTitleContainingIgnoreCase(
            UUID companyId,
            String title,
            Pageable pageable
    );

    Page<LiveClass> findByCompany_IdAndStatusAndTitleContainingIgnoreCase(
            UUID companyId,
            LiveClassStatus status,
            String title,
            Pageable pageable
    );

    Page<LiveClass> findByInstructor_Id(
            UUID instructorId,
            Pageable pageable
    );

    Page<LiveClass> findByInstructor_IdAndStatus(
            UUID instructorId,
            LiveClassStatus status,
            Pageable pageable
    );

    Page<LiveClass> findByInstructor_IdAndTitleContainingIgnoreCase(
            UUID instructorId,
            String title,
            Pageable pageable
    );

    Page<LiveClass> findByInstructor_IdAndStatusAndTitleContainingIgnoreCase(
            UUID instructorId,
            LiveClassStatus status,
            String title,
            Pageable pageable
    );

    Page<LiveClass> findByStatus(
            LiveClassStatus status,
            Pageable pageable
    );

    Page<LiveClass> findByTitleContainingIgnoreCase(
            String title,
            Pageable pageable
    );

    Page<LiveClass> findByStatusAndTitleContainingIgnoreCase(
            LiveClassStatus status,
            String title,
            Pageable pageable
    );
}