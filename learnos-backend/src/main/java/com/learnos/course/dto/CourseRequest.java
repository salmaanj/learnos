package com.learnos.course.dto;

import com.learnos.course.model.CourseLevel;
import com.learnos.course.model.CourseStatus;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;


@Data
public class CourseRequest {

    @NotBlank(message = "Title is required")
    private String title;

    private String description;
    private String shortDescription;
    private UUID categoryId;
    private UUID instructorId;
    private UUID companyId;
    private CourseLevel level;
    private CourseStatus status;
    private boolean isPaid;
    private boolean featured;
    private BigDecimal price;
    private String language;
    private Integer durationMinutes;
    private List<String> tags;
    private List<String> prerequisites;
    private List<String> learningOutcomes;
}