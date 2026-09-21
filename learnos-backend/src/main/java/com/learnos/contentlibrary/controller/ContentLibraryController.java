package com.learnos.contentlibrary.controller;

import com.learnos.common.response.ApiResponse;
import com.learnos.contentlibrary.dto.ContentLibraryCreateRequest;
import com.learnos.contentlibrary.dto.ContentLibraryResponse;
import com.learnos.contentlibrary.dto.ContentLibraryUpdateRequest;
import com.learnos.contentlibrary.model.ContentLibraryItemType;
import com.learnos.contentlibrary.model.ContentLibraryStatus;
import com.learnos.contentlibrary.service.ContentLibraryService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Set;
import java.util.UUID;

@RestController
@RequestMapping("/content-library")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@Tag(
        name = "Content Library",
        description = "Reusable company learning assets"
)
public class ContentLibraryController {

    private static final Set<String> ALLOWED_SORT_FIELDS = Set.of(
            "title",
            "createdAt",
            "updatedAt",
            "durationSeconds",
            "fileSizeBytes",
            "type",
            "status"
    );

    private final ContentLibraryService contentLibraryService;

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
    public ResponseEntity<ApiResponse<Page<ContentLibraryResponse>>> getItems(
            @RequestParam(required = false) String q,
            @RequestParam(required = false) ContentLibraryItemType type,
            @RequestParam(required = false) ContentLibraryStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "12") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "DESC") Sort.Direction direction,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        int safePage = Math.max(0, page);
        int safeSize = Math.min(Math.max(1, size), 100);
        String safeSortBy = ALLOWED_SORT_FIELDS.contains(sortBy)
                ? sortBy
                : "createdAt";

        return ResponseEntity.ok(
                ApiResponse.success(
                        contentLibraryService.getItems(
                                q,
                                type,
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
    public ResponseEntity<ApiResponse<ContentLibraryResponse>> getItem(
            @PathVariable UUID id,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        contentLibraryService.getItem(
                                id,
                                username(userDetails)
                        )
                )
        );
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
    public ResponseEntity<ApiResponse<ContentLibraryResponse>> createItem(
            @Valid @RequestBody ContentLibraryCreateRequest request,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(
                        ApiResponse.success(
                                contentLibraryService.createItem(
                                        request,
                                        username(userDetails)
                                ),
                                "Content library item created"
                        )
                );
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
    public ResponseEntity<ApiResponse<ContentLibraryResponse>> updateItem(
            @PathVariable UUID id,
            @Valid @RequestBody ContentLibraryUpdateRequest request,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        contentLibraryService.updateItem(
                                id,
                                request,
                                username(userDetails)
                        ),
                        "Content library item updated"
                )
        );
    }

    @PostMapping(
            value = "/{id}/upload",
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    @PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
    public ResponseEntity<ApiResponse<ContentLibraryResponse>> uploadFile(
            @PathVariable UUID id,
            @RequestParam("file") MultipartFile file,
            @AuthenticationPrincipal UserDetails userDetails
    ) throws IOException {
        return ResponseEntity.ok(
                ApiResponse.success(
                        contentLibraryService.uploadFile(
                                id,
                                file,
                                username(userDetails)
                        ),
                        "File uploaded"
                )
        );
    }

    @PatchMapping("/{id}/archive")
    @PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
    public ResponseEntity<ApiResponse<ContentLibraryResponse>> archiveItem(
            @PathVariable UUID id,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        contentLibraryService.archiveItem(
                                id,
                                username(userDetails)
                        ),
                        "Content library item archived"
                )
        );
    }

    @PatchMapping("/{id}/restore")
    @PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
    public ResponseEntity<ApiResponse<ContentLibraryResponse>> restoreItem(
            @PathVariable UUID id,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        contentLibraryService.restoreItem(
                                id,
                                username(userDetails)
                        ),
                        "Content library item restored"
                )
        );
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
    public ResponseEntity<ApiResponse<Void>> deleteItem(
            @PathVariable UUID id,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        contentLibraryService.deleteItem(id, username(userDetails));

        return ResponseEntity.ok(
                ApiResponse.success(
                        null,
                        "Content library item deleted"
                )
        );
    }

    private String username(UserDetails userDetails) {
        return userDetails != null
                ? userDetails.getUsername()
                : null;
    }
}