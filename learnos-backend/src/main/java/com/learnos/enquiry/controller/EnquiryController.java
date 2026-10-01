package com.learnos.enquiry.controller;

import com.learnos.enquiry.dto.EnquiryRequest;
import com.learnos.enquiry.dto.EnquiryResponse;
import com.learnos.enquiry.model.EnquiryStatus;
import com.learnos.enquiry.service.EnquiryService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/enquiries")
@RequiredArgsConstructor
public class EnquiryController {

    private final EnquiryService enquiryService;

    @PostMapping
    public ResponseEntity<EnquiryResponse> create(
            @Valid @RequestBody EnquiryRequest request
    ) {
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(
                        enquiryService.create(request)
                );
    }

    @GetMapping
    @PreAuthorize(
            "@authorizationService.isSuperAdmin(authentication)"
    )
    public ResponseEntity<Page<EnquiryResponse>> list(
            @RequestParam(
                    required = false
            )
            EnquiryStatus status,

            @RequestParam(
                    defaultValue = "0"
            )
            int page,

            @RequestParam(
                    defaultValue = "20"
            )
            int size
    ) {
        int safePage = Math.max(page, 0);
        int safeSize = Math.min(
                Math.max(size, 1),
                100
        );

        Pageable pageable = PageRequest.of(
                safePage,
                safeSize,
                Sort.by(
                        Sort.Direction.DESC,
                        "createdAt"
                )
        );

        return ResponseEntity.ok(
                enquiryService.list(
                        status,
                        pageable
                )
        );
    }

    @PatchMapping("/{id}/read")
    @PreAuthorize(
            "@authorizationService.isSuperAdmin(authentication)"
    )
    public ResponseEntity<EnquiryResponse> updateReadState(
            @PathVariable UUID id,
            @RequestParam boolean read
    ) {
        return ResponseEntity.ok(
                enquiryService.updateReadState(
                        id,
                        read
                )
        );
    }

    @PatchMapping("/{id}/status")
    @PreAuthorize(
            "@authorizationService.isSuperAdmin(authentication)"
    )
    public ResponseEntity<EnquiryResponse> updateStatus(
            @PathVariable UUID id,
            @RequestParam EnquiryStatus status
    ) {
        return ResponseEntity.ok(
                enquiryService.updateStatus(
                        id,
                        status
                )
        );
    }

    @DeleteMapping("/{id}")
    @PreAuthorize(
            "@authorizationService.isSuperAdmin(authentication)"
    )
    public ResponseEntity<Void> delete(
            @PathVariable UUID id
    ) {
        enquiryService.delete(id);

        return ResponseEntity.noContent().build();
    }
}