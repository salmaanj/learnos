package com.learnos.content.dto;

import lombok.Builder;
import lombok.Data;

import java.util.List;
import java.util.UUID;

@Data
@Builder
public class CourseProgressResponse {

    private UUID courseId;

    private int totalLessons;
    private int completedLessons;
    private int progressPercent;

    private boolean contentCompleted;
    private boolean assessmentUnlocked;

    private UUID resumeLessonId;
    private int resumePositionSeconds;

    private List<ProgressResponse> lessons;
}