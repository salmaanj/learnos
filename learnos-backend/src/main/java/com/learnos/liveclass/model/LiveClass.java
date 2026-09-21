package com.learnos.liveclass.model;

import com.learnos.auth.model.User;
import com.learnos.company.entity.Company;
import com.learnos.course.model.Course;
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
        name = "live_classes",
        indexes = {
                @Index(
                        name = "idx_live_classes_company",
                        columnList = "company_id"
                ),
                @Index(
                        name = "idx_live_classes_course",
                        columnList = "course_id"
                ),
                @Index(
                        name = "idx_live_classes_status",
                        columnList = "status"
                ),
                @Index(
                        name = "idx_live_classes_start_at",
                        columnList = "start_at"
                )
        }
)
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LiveClass {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "company_id", nullable = false)
    private Company company;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id")
    private Course course;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "instructor_id")
    private User instructor;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(length = 3000)
    private String description;

    @Column(name = "start_at", nullable = false)
    private LocalDateTime startAt;

    @Column(name = "end_at", nullable = false)
    private LocalDateTime endAt;

    @Column(nullable = false, length = 64)
    @Builder.Default
    private String timezone = "Asia/Kolkata";

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    @Builder.Default
    private MeetingProvider provider =
            MeetingProvider.GOOGLE_MEET;

    @Column(name = "meeting_url", nullable = false, length = 2000)
    private String meetingUrl;

    @Column(name = "meeting_password", length = 255)
    private String meetingPassword;

    @Column
    private Integer capacity;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private LiveClassStatus status = LiveClassStatus.DRAFT;

    @Column(name = "thumbnail_url", length = 2000)
    private String thumbnailUrl;

    @Column(name = "recording_url", length = 2000)
    private String recordingUrl;

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

        if (timezone == null || timezone.isBlank()) {
            timezone = "Asia/Kolkata";
        }

        if (provider == null) {
            provider = MeetingProvider.GOOGLE_MEET;
        }

        if (status == null) {
            status = LiveClassStatus.DRAFT;
        }
    }

    @PreUpdate
    void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}