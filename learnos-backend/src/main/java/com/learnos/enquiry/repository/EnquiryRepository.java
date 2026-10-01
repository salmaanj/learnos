package com.learnos.enquiry.repository;

import com.learnos.enquiry.model.Enquiry;
import com.learnos.enquiry.model.EnquiryStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface EnquiryRepository
        extends JpaRepository<Enquiry, UUID> {

    Page<Enquiry> findAllByOrderByCreatedAtDesc(
            Pageable pageable
    );

    Page<Enquiry> findByStatusOrderByCreatedAtDesc(
            EnquiryStatus status,
            Pageable pageable
    );
}
