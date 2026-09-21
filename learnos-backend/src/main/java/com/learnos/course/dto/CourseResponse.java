package com.learnos.course.dto;

import com.learnos.course.model.CourseLevel;
import com.learnos.course.model.CourseStatus;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Data
@Builder
public class CourseResponse {

    private UUID id;
    private String title;
    private String description;
    private String shortDescription;
    private String thumbnailUrl;

    private String categoryName;
    private UUID categoryId;

    private String instructorName;
    private UUID instructorId;

    private UUID companyId;
    private String companyName;

    private CourseLevel level;
    private CourseStatus status;

    private boolean isPaid;
    private boolean featured;

    private BigDecimal price;
    private String language;
    private Integer durationMinutes;

    // Existing compatibility fields.
    private double rating;
    private int totalEnrollments;
    private int totalLessons;

    // Admin and learner course statistics.
    private long enrolledCount;
    private int completionRate;

    // Aggregated learner ratings.
    private double averageRating;
    private long ratingCount;

    // Rating submitted by the currently authenticated learner.
    private Integer myRating;

    private List<String> tags;
    private List<String> prerequisites;
    private List<String> learningOutcomes;

    // Populated for an enrolled learner.
    private Integer progressPercent;

    private LocalDateTime createdAt;
}