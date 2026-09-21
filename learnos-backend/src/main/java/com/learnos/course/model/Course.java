package com.learnos.course.model;

import com.learnos.auth.model.User;
import com.learnos.company.entity.Company;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "courses")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id")
public class Course {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(columnDefinition = "TEXT")
    private String shortDescription;

    private String thumbnailUrl;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id")
    private Category category;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "instructor_id")
    private User instructor;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "company_id")
    private Company company;

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private CourseLevel level = CourseLevel.BEGINNER;

    @Enumerated(EnumType.STRING)
    @Builder.Default
    private CourseStatus status = CourseStatus.DRAFT;

    @Builder.Default
    private boolean paid = false;        // ← renamed from isPaid
    private boolean featured = false;

    @Builder.Default
    private BigDecimal price = BigDecimal.ZERO;

    private String language;

    private Integer durationMinutes;

    @Builder.Default
    private double rating = 0.0;

    @Builder.Default
    private int totalEnrollments = 0;

    @Builder.Default
    private int totalLessons = 0;

    @OneToMany(mappedBy = "course", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("displayOrder ASC")
    @Builder.Default
    private List<CourseModule> modules = new ArrayList<>();

    @ElementCollection
    @CollectionTable(name = "course_tags", joinColumns = @JoinColumn(name = "course_id"))
    @Column(name = "tag")
    @Builder.Default
    private List<String> tags = new ArrayList<>();

    @ElementCollection
    @CollectionTable(name = "course_prerequisites", joinColumns = @JoinColumn(name = "course_id"))
    @Column(name = "prerequisite")
    @Builder.Default
    private List<String> prerequisites = new ArrayList<>();

    @ElementCollection
    @CollectionTable(name = "course_outcomes", joinColumns = @JoinColumn(name = "course_id"))
    @Column(name = "outcome")
    @Builder.Default
    private List<String> learningOutcomes = new ArrayList<>();

    @CreationTimestamp
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;
}