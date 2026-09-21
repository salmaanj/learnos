package com.learnos.contentlibrary.service;

import com.learnos.auth.model.User;
import com.learnos.auth.repository.UserRepository;
import com.learnos.company.entity.Company;
import com.learnos.company.repository.CompanyRepository;
import com.learnos.contentlibrary.dto.ContentLibraryCreateRequest;
import com.learnos.contentlibrary.dto.ContentLibraryResponse;
import com.learnos.contentlibrary.dto.ContentLibraryUpdateRequest;
import com.learnos.contentlibrary.model.ContentLibraryItem;
import com.learnos.contentlibrary.model.ContentLibraryItemType;
import com.learnos.contentlibrary.model.ContentLibraryStatus;
import com.learnos.contentlibrary.repository.ContentLibraryRepository;
import com.learnos.storage.service.S3StorageService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional
public class ContentLibraryService {

    private final ContentLibraryRepository contentLibraryRepository;
    private final CompanyRepository companyRepository;
    private final UserRepository userRepository;
    private final S3StorageService storageService;

    @Transactional(readOnly = true)
    public Page<ContentLibraryResponse> getItems(
            String query,
            ContentLibraryItemType type,
            ContentLibraryStatus status,
            PageRequest pageRequest,
            String username
    ) {
        User currentUser = requireCurrentUser(username);

        ContentLibraryStatus effectiveStatus =
                status != null
                        ? status
                        : ContentLibraryStatus.ACTIVE;

        String normalizedQuery = blankToNull(query);

        Page<ContentLibraryItem> page;

        if (isSuperAdmin(currentUser)) {
            if (normalizedQuery != null && type != null) {
                page = contentLibraryRepository
                        .findByTypeAndStatusAndTitleContainingIgnoreCase(
                                type,
                                effectiveStatus,
                                normalizedQuery,
                                pageRequest
                        );
            } else if (normalizedQuery != null) {
                page = contentLibraryRepository
                        .findByStatusAndTitleContainingIgnoreCase(
                                effectiveStatus,
                                normalizedQuery,
                                pageRequest
                        );
            } else if (type != null) {
                page = contentLibraryRepository
                        .findByTypeAndStatus(
                                type,
                                effectiveStatus,
                                pageRequest
                        );
            } else {
                page = contentLibraryRepository
                        .findByStatus(
                                effectiveStatus,
                                pageRequest
                        );
            }
        } else {
            Company company = requireCompany(currentUser);

            if (normalizedQuery != null && type != null) {
                page = contentLibraryRepository
                        .findByCompany_IdAndTypeAndStatusAndTitleContainingIgnoreCase(
                                company.getId(),
                                type,
                                effectiveStatus,
                                normalizedQuery,
                                pageRequest
                        );
            } else if (normalizedQuery != null) {
                page = contentLibraryRepository
                        .findByCompany_IdAndStatusAndTitleContainingIgnoreCase(
                                company.getId(),
                                effectiveStatus,
                                normalizedQuery,
                                pageRequest
                        );
            } else if (type != null) {
                page = contentLibraryRepository
                        .findByCompany_IdAndTypeAndStatus(
                                company.getId(),
                                type,
                                effectiveStatus,
                                pageRequest
                        );
            } else {
                page = contentLibraryRepository
                        .findByCompany_IdAndStatus(
                                company.getId(),
                                effectiveStatus,
                                pageRequest
                        );
            }
        }

        return page.map(this::mapToResponse);
    }

    @Transactional(readOnly = true)
    public ContentLibraryResponse getItem(
            UUID id,
            String username
    ) {
        User currentUser = requireCurrentUser(username);
        ContentLibraryItem item = getItemOrThrow(id);

        assertCanAccessItem(currentUser, item);

        return mapToResponse(item);
    }

    /**
     * Creates the metadata record first.
     *
     * A URL is NOT required here when an Angular user has selected a local file:
     * the URL does not exist until the next uploadFile(...) call stores the file
     * in S3 and returns its uploaded URL.
     *
     * LINK items are the only exception: they must have a content URL because
     * they do not use file upload.
     */
    public ContentLibraryResponse createItem(
            ContentLibraryCreateRequest request,
            String username
    ) {
        User currentUser = requireCurrentUser(username);

        Company company = resolveCompanyForCreateOrUpdate(
                currentUser,
                request.companyId()
        );

        validateCreateRequest(
                request.type(),
                request.contentUrl(),
                request.streamingUrl()
        );

        ContentLibraryItem item = ContentLibraryItem.builder()
                .company(company)
                .title(request.title().trim())
                .description(blankToNull(request.description()))
                .type(request.type())
                .contentUrl(blankToNull(request.contentUrl()))
                .streamingUrl(blankToNull(request.streamingUrl()))
                .thumbnailUrl(blankToNull(request.thumbnailUrl()))
                .tags(blankToNull(request.tags()))
                .durationSeconds(
                        normalizeNonNegative(
                                request.durationSeconds()
                        )
                )
                .fileSizeBytes(
                        normalizeNonNegative(
                                request.fileSizeBytes()
                        )
                )
                .originalFileName(
                        blankToNull(request.originalFileName())
                )
                .status(ContentLibraryStatus.ACTIVE)
                .createdBy(currentUser)
                .build();

        return mapToResponse(
                contentLibraryRepository.save(item)
        );
    }

    /**
     * Updates metadata or an existing URL-based item.
     *
     * For non-link items, an existing uploaded file URL can be omitted only
     * while the user is about to upload a replacement file immediately after
     * this update. Existing content URLs are preserved when the request field
     * is blank, which prevents accidental loss of a stored S3 file URL.
     */
    public ContentLibraryResponse updateItem(
            UUID id,
            ContentLibraryUpdateRequest request,
            String username
    ) {
        User currentUser = requireCurrentUser(username);

        ContentLibraryItem item = getItemOrThrow(id);

        assertCanAccessItem(currentUser, item);

        Company company = resolveCompanyForUpdate(
                currentUser,
                request.companyId(),
                item.getCompany()
        );

        String requestedContentUrl =
                blankToNull(request.contentUrl());

        String requestedStreamingUrl =
                blankToNull(request.streamingUrl());

        validateUpdateRequest(
                request.type(),
                requestedContentUrl,
                requestedStreamingUrl,
                item.getContentUrl(),
                item.getStreamingUrl()
        );

        item.setCompany(company);
        item.setTitle(request.title().trim());
        item.setDescription(blankToNull(request.description()));
        item.setType(request.type());

        if (requestedContentUrl != null) {
            item.setContentUrl(requestedContentUrl);
        }

        if (requestedStreamingUrl != null) {
            item.setStreamingUrl(requestedStreamingUrl);
        }

        item.setThumbnailUrl(
                blankToNull(request.thumbnailUrl())
        );
        item.setTags(blankToNull(request.tags()));
        item.setDurationSeconds(
                normalizeNonNegative(
                        request.durationSeconds()
                )
        );

        if (request.fileSizeBytes() != null) {
            item.setFileSizeBytes(
                    normalizeNonNegative(
                            request.fileSizeBytes()
                    )
            );
        }

        if (blankToNull(request.originalFileName()) != null) {
            item.setOriginalFileName(
                    blankToNull(request.originalFileName())
            );
        }

        item.setStatus(request.status());

        return mapToResponse(
                contentLibraryRepository.save(item)
        );
    }

    public ContentLibraryResponse archiveItem(
            UUID id,
            String username
    ) {
        User currentUser = requireCurrentUser(username);

        ContentLibraryItem item = getItemOrThrow(id);

        assertCanAccessItem(currentUser, item);

        item.setStatus(ContentLibraryStatus.ARCHIVED);

        return mapToResponse(
                contentLibraryRepository.save(item)
        );
    }

    public ContentLibraryResponse restoreItem(
            UUID id,
            String username
    ) {
        User currentUser = requireCurrentUser(username);

        ContentLibraryItem item = getItemOrThrow(id);

        assertCanAccessItem(currentUser, item);

        item.setStatus(ContentLibraryStatus.ACTIVE);

        return mapToResponse(
                contentLibraryRepository.save(item)
        );
    }

    public void deleteItem(
            UUID id,
            String username
    ) {
        User currentUser = requireCurrentUser(username);

        ContentLibraryItem item = getItemOrThrow(id);

        assertCanAccessItem(currentUser, item);

        /*
         * Phase 1 behavior:
         * Delete only the database record.
         *
         * Do not delete the physical S3 file yet. Once content-library items
         * can be linked to lessons or live classes, add usage checks first and
         * delete S3 storage only when there are no remaining references.
         */
        contentLibraryRepository.delete(item);
    }

    /**
     * Uploads or replaces the real file after createItem(...) has created the
     * metadata record. This method writes the permanent S3 URL into contentUrl.
     */
    public ContentLibraryResponse uploadFile(
            UUID id,
            MultipartFile file,
            String username
    ) throws IOException {
        User currentUser = requireCurrentUser(username);

        ContentLibraryItem item = getItemOrThrow(id);

        assertCanAccessItem(currentUser, item);

        validateUpload(file, item.getType());

        String folder = "content-library/"
                + item.getCompany().getId();

        String uploadedUrl = storageService.uploadFile(
                file,
                folder
        );

        item.setContentUrl(uploadedUrl);
        item.setStreamingUrl(null);
        item.setOriginalFileName(
                blankToNull(file.getOriginalFilename())
        );
        item.setFileSizeBytes(file.getSize());

        return mapToResponse(
                contentLibraryRepository.save(item)
        );
    }

    private ContentLibraryItem getItemOrThrow(UUID id) {
        return contentLibraryRepository.findById(id)
                .orElseThrow(
                        () -> new RuntimeException(
                                "Content library item not found"
                        )
                );
    }

    private User requireCurrentUser(String username) {
        User currentUser = getCurrentUser(username);

        if (currentUser == null) {
            throw new RuntimeException("User not found");
        }

        return currentUser;
    }

    private Company requireCompany(User currentUser) {
        if (currentUser.getCompany() == null) {
            throw new RuntimeException(
                    "Your user account is not assigned to a company"
            );
        }

        return currentUser.getCompany();
    }

    private Company resolveCompanyForCreateOrUpdate(
            User currentUser,
            UUID requestedCompanyId
    ) {
        if (!isSuperAdmin(currentUser)) {
            return requireCompany(currentUser);
        }

        if (requestedCompanyId == null) {
            throw new RuntimeException(
                    "Company is required for content library items"
            );
        }

        return companyRepository.findById(requestedCompanyId)
                .orElseThrow(
                        () -> new RuntimeException(
                                "Company not found"
                        )
                );
    }

    private Company resolveCompanyForUpdate(
            User currentUser,
            UUID requestedCompanyId,
            Company existingCompany
    ) {
        if (!isSuperAdmin(currentUser)) {
            return requireCompany(currentUser);
        }

        if (requestedCompanyId == null) {
            return existingCompany;
        }

        return companyRepository.findById(requestedCompanyId)
                .orElseThrow(
                        () -> new RuntimeException(
                                "Company not found"
                        )
                );
    }

    private void assertCanAccessItem(
            User currentUser,
            ContentLibraryItem item
    ) {
        if (isSuperAdmin(currentUser)) {
            return;
        }

        if (
                currentUser.getCompany() == null
                        || item.getCompany() == null
                        || !currentUser.getCompany().getId().equals(
                        item.getCompany().getId()
                )
        ) {
            throw new RuntimeException("Access denied");
        }
    }

    /**
     * During initial creation, selected local files do not yet have S3 URLs.
     * Therefore only LINK records must contain a URL at this stage.
     */
    private void validateCreateRequest(
            ContentLibraryItemType type,
            String contentUrl,
            String streamingUrl
    ) {
        if (
                type == null
        ) {
            throw new RuntimeException(
                    "Content type is required"
            );
        }

        if (
                type == ContentLibraryItemType.LINK
                        && blankToNull(contentUrl) == null
        ) {
            throw new RuntimeException(
                    "A content URL is required for a link item"
            );
        }

        /*
         * VIDEO, AUDIO, PDF, SLIDES, DOCUMENT and IMAGE may be created
         * with no URL. The selected frontend file is uploaded afterwards
         * through POST /content-library/{id}/upload.
         */
    }

    /**
     * A Link always needs a URL. Other content types can retain their existing
     * URL, accept a new URL, or temporarily have no URL while a replacement
     * file is being uploaded immediately after the metadata update.
     */
    private void validateUpdateRequest(
            ContentLibraryItemType type,
            String requestedContentUrl,
            String requestedStreamingUrl,
            String existingContentUrl,
            String existingStreamingUrl
    ) {
        if (type == null) {
            throw new RuntimeException(
                    "Content type is required"
            );
        }

        if (type == ContentLibraryItemType.LINK) {
            String effectiveUrl = requestedContentUrl != null
                    ? requestedContentUrl
                    : blankToNull(existingContentUrl);

            if (effectiveUrl == null) {
                throw new RuntimeException(
                        "A content URL is required for a link item"
                );
            }

            return;
        }

        /*
         * Non-link items can be URL-based, S3-uploaded, or waiting for
         * a replacement upload. Do not reject a blank URL here.
         */
    }

    private void validateUpload(
            MultipartFile file,
            ContentLibraryItemType type
    ) {
        if (file == null || file.isEmpty()) {
            throw new RuntimeException(
                    "Please choose a file to upload"
            );
        }

        if (type == ContentLibraryItemType.LINK) {
            throw new RuntimeException(
                    "Link items use a URL and cannot have an uploaded file"
            );
        }

        long maxFileSize = type == ContentLibraryItemType.VIDEO
                ? 500L * 1024 * 1024
                : 50L * 1024 * 1024;

        if (file.getSize() > maxFileSize) {
            throw new RuntimeException(
                    type == ContentLibraryItemType.VIDEO
                            ? "Video files must not exceed 500 MB"
                            : "Files must not exceed 50 MB"
            );
        }

        String extension = getExtension(
                file.getOriginalFilename()
        );

        boolean allowed = switch (type) {
            case VIDEO -> isOneOf(
                    extension,
                    "mp4",
                    "webm",
                    "mov"
            );
            case AUDIO -> isOneOf(
                    extension,
                    "mp3",
                    "wav",
                    "m4a",
                    "aac"
            );
            case PDF -> isOneOf(extension, "pdf");
            case SLIDES -> isOneOf(
                    extension,
                    "ppt",
                    "pptx"
            );
            case DOCUMENT -> isOneOf(
                    extension,
                    "doc",
                    "docx",
                    "xls",
                    "xlsx",
                    "csv",
                    "txt"
            );
            case IMAGE -> isOneOf(
                    extension,
                    "jpg",
                    "jpeg",
                    "png",
                    "webp"
            );
            case LINK -> false;
        };

        if (!allowed) {
            throw new RuntimeException(
                    "The selected file type does not match the content type"
            );
        }
    }

    private ContentLibraryResponse mapToResponse(
            ContentLibraryItem item
    ) {
        User createdBy = item.getCreatedBy();
        Company company = item.getCompany();

        return new ContentLibraryResponse(
                item.getId(),
                item.getTitle(),
                item.getDescription(),
                item.getType(),
                item.getContentUrl(),
                item.getStreamingUrl(),
                item.getThumbnailUrl(),
                item.getTags(),
                item.getDurationSeconds(),
                item.getFileSizeBytes(),
                item.getOriginalFileName(),
                item.getStatus(),
                company != null ? company.getId() : null,
                company != null ? company.getName() : null,
                createdBy != null ? createdBy.getId() : null,
                createdBy != null
                        ? createdBy.getFullName()
                        : null,
                item.getCreatedAt(),
                item.getUpdatedAt()
        );
    }

    private User getCurrentUser(String username) {
        String email = username;

        if (email == null || email.isBlank()) {
            Authentication authentication = SecurityContextHolder
                    .getContext()
                    .getAuthentication();

            if (authentication != null) {
                email = authentication.getName();
            }
        }

        if (email == null || email.isBlank()) {
            return null;
        }

        return userRepository.findByEmail(email)
                .orElse(null);
    }

    private boolean isSuperAdmin(User user) {
        return user != null
                && user.getEmail() != null
                && user.getEmail()
                .equalsIgnoreCase("admin@blute.co.in");
    }

    private String blankToNull(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }

        return value.trim();
    }

    private Integer normalizeNonNegative(Integer value) {
        if (value == null) {
            return null;
        }

        return Math.max(0, value);
    }

    private Long normalizeNonNegative(Long value) {
        if (value == null) {
            return null;
        }

        return Math.max(0L, value);
    }

    private String getExtension(String fileName) {
        if (fileName == null) {
            return "";
        }

        int lastDot = fileName.lastIndexOf('.');

        if (
                lastDot < 0
                        || lastDot == fileName.length() - 1
        ) {
            return "";
        }

        return fileName.substring(lastDot + 1)
                .toLowerCase();
    }

    private boolean isOneOf(
            String value,
            String... allowedValues
    ) {
        for (String allowedValue : allowedValues) {
            if (allowedValue.equalsIgnoreCase(value)) {
                return true;
            }
        }

        return false;
    }
}