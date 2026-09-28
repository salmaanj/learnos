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

    private String contentUrl;
    private String streamingUrl;
    private String thumbnailUrl;

    @Column(columnDefinition = "TEXT")
    private String textContent;

    private Integer durationSeconds;

    @Builder.Default
    private boolean isPreview = false;

    @Builder.Default
    private boolean isPublished = true;

    @Builder.Default
    @Column(nullable = false)
    private boolean downloadable = false;

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
