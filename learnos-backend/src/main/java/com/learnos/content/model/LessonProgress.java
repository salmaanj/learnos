package com.learnos.content.model;

import com.learnos.auth.model.User;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "lesson_progress",
    uniqueConstraints = @UniqueConstraint(columnNames = {"user_id","lesson_id"}))
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LessonProgress {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "lesson_id", nullable = false)
    private Lesson lesson;

    @Builder.Default
    private boolean completed = false;

    @Builder.Default
    private int watchedSeconds = 0;

    private LocalDateTime completedAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;
}
