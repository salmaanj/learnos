package com.learnos.contentlibrary.model;

import com.learnos.auth.model.User;
import com.learnos.company.entity.Company;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(
        name = "content_library_items",
        indexes = {
                @Index(
                        name = "idx_content_library_company",
                        columnList = "company_id"
                ),
                @Index(
                        name = "idx_content_library_status",
                        columnList = "status"
                ),
                @Index(
                        name = "idx_content_library_type",
                        columnList = "content_type"
                )
        }
)
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ContentLibraryItem {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "company_id", nullable = false)
    private Company company;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(length = 3000)
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(name = "content_type", nullable = false, length = 30)
    private ContentLibraryItemType type;

    @Column(name = "content_url", length = 2000)
    private String contentUrl;

    @Column(name = "streaming_url", length = 2000)
    private String streamingUrl;

    @Column(name = "thumbnail_url", length = 2000)
    private String thumbnailUrl;

    @Column(length = 1000)
    private String tags;

    @Column(name = "duration_seconds")
    private Integer durationSeconds;

    @Column(name = "file_size_bytes")
    private Long fileSizeBytes;

    @Column(name = "original_file_name", length = 500)
    private String originalFileName;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private ContentLibraryStatus status = ContentLibraryStatus.ACTIVE;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by_user_id")
    private User createdBy;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    void onCreate() {
        LocalDateTime now = LocalDateTime.now();
        createdAt = now;
        updatedAt = now;

        if (status == null) {
            status = ContentLibraryStatus.ACTIVE;
        }
    }

    @PreUpdate
    void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}