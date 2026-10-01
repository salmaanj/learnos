package com.learnos.enquiry.service;

import com.learnos.enquiry.dto.EnquiryRequest;
import com.learnos.enquiry.dto.EnquiryResponse;
import com.learnos.enquiry.model.Enquiry;
import com.learnos.enquiry.model.EnquiryStatus;
import com.learnos.enquiry.repository.EnquiryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class EnquiryService {

    private final EnquiryRepository enquiryRepository;

    @Transactional
    public EnquiryResponse create(
            EnquiryRequest request
    ) {
        Enquiry enquiry = Enquiry.builder()
                .name(
                        clean(request.getName())
                )
                .organization(
                        clean(
                                request.getOrganization()
                        )
                )
                .email(
                        clean(
                                request.getEmail()
                        ).toLowerCase()
                )
                .phone(
                        cleanNullable(
                                request.getPhone()
                        )
                )
                .audience(
                        clean(
                                request.getAudience()
                        )
                )
                .subject(
                        clean(
                                request.getSubject()
                        )
                )
                .message(
                        clean(
                                request.getMessage()
                        )
                )
                .status(
                        EnquiryStatus.NEW
                )
                .read(false)
                .build();

        return toResponse(
                enquiryRepository.save(enquiry)
        );
    }

    @Transactional(readOnly = true)
    public Page<EnquiryResponse> list(
            EnquiryStatus status,
            Pageable pageable
    ) {
        Page<Enquiry> enquiries =
                status == null
                        ? enquiryRepository
                        .findAllByOrderByCreatedAtDesc(
                                pageable
                        )
                        : enquiryRepository
                        .findByStatusOrderByCreatedAtDesc(
                                status,
                                pageable
                        );

        return enquiries.map(
                this::toResponse
        );
    }

    @Transactional
    public EnquiryResponse updateReadState(
            UUID id,
            boolean read
    ) {
        Enquiry enquiry = get(id);

        enquiry.setRead(read);

        return toResponse(
                enquiryRepository.save(enquiry)
        );
    }

    @Transactional
    public EnquiryResponse updateStatus(
            UUID id,
            EnquiryStatus status
    ) {
        Enquiry enquiry = get(id);

        enquiry.setStatus(status);

        return toResponse(
                enquiryRepository.save(enquiry)
        );
    }

    @Transactional
    public void delete(UUID id) {
        Enquiry enquiry = get(id);

        enquiryRepository.delete(enquiry);
    }

    private Enquiry get(UUID id) {
        return enquiryRepository
                .findById(id)
                .orElseThrow(() ->
                        new RuntimeException(
                                "Enquiry not found: " + id
                        )
                );
    }

    private EnquiryResponse toResponse(
            Enquiry enquiry
    ) {
        return EnquiryResponse.builder()
                .id(
                        enquiry.getId()
                )
                .name(
                        enquiry.getName()
                )
                .organization(
                        enquiry.getOrganization()
                )
                .email(
                        enquiry.getEmail()
                )
                .phone(
                        enquiry.getPhone()
                )
                .audience(
                        enquiry.getAudience()
                )
                .subject(
                        enquiry.getSubject()
                )
                .message(
                        enquiry.getMessage()
                )
                .status(
                        enquiry.getStatus()
                )
                .read(
                        enquiry.isRead()
                )
                .createdAt(
                        enquiry.getCreatedAt()
                )
                .updatedAt(
                        enquiry.getUpdatedAt()
                )
                .build();
    }

    private String clean(String value) {
        return value == null
                ? ""
                : value.trim();
    }

    private String cleanNullable(String value) {
        String cleaned = clean(value);

        return cleaned.isBlank()
                ? null
                : cleaned;
    }
}