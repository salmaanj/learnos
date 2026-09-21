package com.learnos.content.model;

import com.learnos.course.model.CourseModule;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "lessons")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id")
public class Lesson {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "module_id", nullable = false)
    private CourseModule module;

    @Column(nullable = false)
    private String title;

    private String description;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private LessonType type;

    // Content URLs (populated based on type)
    private String contentUrl;       // S3/CDN URL for video/audio/pdf/slides
    private String streamingUrl;     // HLS URL for video streaming
    private String thumbnailUrl;

    @Column(columnDefinition = "TEXT")
    private String textContent;      // for TEXT-type lessons

    // Video specific
    private Integer durationSeconds;

    // Common
    @Builder.Default
    private boolean isPreview = false;

    @Builder.Default
    private boolean isPublished = true;

    @Builder.Default
    private int displayOrder = 0;

    @Builder.Default
    private long fileSizeBytes = 0;

    private String mimeType;
    private String originalFileName;

    @CreationTimestamp
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;
}
