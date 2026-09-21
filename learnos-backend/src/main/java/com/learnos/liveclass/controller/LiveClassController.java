package com.learnos.liveclass.controller;

import com.learnos.common.response.ApiResponse;
import com.learnos.liveclass.dto.LiveClassRequest;
import com.learnos.liveclass.dto.LiveClassResponse;
import com.learnos.liveclass.dto.LiveClassStatusRequest;
import com.learnos.liveclass.model.LiveClassStatus;
import com.learnos.liveclass.service.LiveClassService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Set;
import java.util.UUID;

@RestController
@RequestMapping("/live-classes")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@Tag(
        name = "Live Classes",
        description = "Company live class scheduling and management"
)
public class LiveClassController {

    private static final Set<String> ALLOWED_SORT_FIELDS = Set.of(
            "title",
            "startAt",
            "endAt",
            "createdAt",
            "updatedAt",
            "status"
    );

    private final LiveClassService liveClassService;

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
    public ResponseEntity<ApiResponse<Page<LiveClassResponse>>> getLiveClasses(
            @RequestParam(required = false) String q,
            @RequestParam(required = false) LiveClassStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "12") int size,
            @RequestParam(defaultValue = "startAt") String sortBy,
            @RequestParam(defaultValue = "ASC") Sort.Direction direction,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        int safePage = Math.max(0, page);
        int safeSize = Math.min(Math.max(1, size), 100);

        String safeSortBy = ALLOWED_SORT_FIELDS.contains(sortBy)
                ? sortBy
                : "startAt";

        return ResponseEntity.ok(
                ApiResponse.success(
                        liveClassService.getLiveClasses(
                                q,
                                status,
                                PageRequest.of(
                                        safePage,
                                        safeSize,
                                        Sort.by(direction, safeSortBy)
                                ),
                                username(userDetails)
                        )
                )
        );
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
    public ResponseEntity<ApiResponse<LiveClassResponse>> getLiveClass(
            @PathVariable UUID id,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        liveClassService.getLiveClass(
                                id,
                                username(userDetails)
                        )
                )
        );
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
    public ResponseEntity<ApiResponse<LiveClassResponse>> createLiveClass(
            @Valid @RequestBody LiveClassRequest request,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(
                        ApiResponse.success(
                                liveClassService.createLiveClass(
                                        request,
                                        username(userDetails)
                                ),
                                "Live class created"
                        )
                );
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
    public ResponseEntity<ApiResponse<LiveClassResponse>> updateLiveClass(
            @PathVariable UUID id,
            @Valid @RequestBody LiveClassRequest request,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        liveClassService.updateLiveClass(
                                id,
                                request,
                                username(userDetails)
                        ),
                        "Live class updated"
                )
        );
    }

    @PatchMapping("/{id}/status")
    @PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
    public ResponseEntity<ApiResponse<LiveClassResponse>> updateStatus(
            @PathVariable UUID id,
            @Valid @RequestBody LiveClassStatusRequest request,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        liveClassService.updateStatus(
                                id,
                                request.status(),
                                username(userDetails)
                        ),
                        "Live class status updated"
                )
        );
    }

    private String username(UserDetails userDetails) {
        return userDetails != null
                ? userDetails.getUsername()
                : null;
    }
}