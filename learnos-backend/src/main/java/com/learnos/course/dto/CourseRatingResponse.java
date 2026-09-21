package com.learnos.course.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class CourseRatingResponse {

    private String courseId;
    private double averageRating;
    private long ratingCount;
    private Integer myRating;
}