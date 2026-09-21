package com.learnos.content.controller;

import com.learnos.common.response.ApiResponse;
import com.learnos.content.dto.CourseProgressResponse;
import com.learnos.content.dto.LessonRequest;
import com.learnos.content.dto.LessonResponse;
import com.learnos.content.dto.ProgressRequest;
import com.learnos.content.dto.ProgressResponse;
import com.learnos.content.service.LessonService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/lessons")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@Tag(
        name = "Lessons & Content",
        description = "Lesson management, file upload and learner progress tracking"
)
public class LessonController {

    private final LessonService lessonService;

    @PostMapping("/module/{moduleId}")
    @PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
    @Operation(summary = "Add a lesson to a module")
    public ResponseEntity<ApiResponse<LessonResponse>> addLesson(
            @PathVariable UUID moduleId,
            @Valid @RequestBody LessonRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(
                        lessonService.addLesson(moduleId, request),
                        "Lesson added successfully"
                ));
    }

    @PutMapping("/{lessonId}")
    @PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
    @Operation(summary = "Update a lesson")
    public ResponseEntity<ApiResponse<LessonResponse>> updateLesson(
            @PathVariable UUID lessonId,
            @Valid @RequestBody LessonRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                lessonService.updateLesson(lessonId, request),
                "Lesson updated successfully"
        ));
    }

    @PostMapping(
            value = "/{lessonId}/upload",
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    @PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
    @Operation(summary = "Upload a PDF, video, audio, or slides file for a lesson")
    public ResponseEntity<ApiResponse<LessonResponse>> uploadContent(
            @PathVariable UUID lessonId,
            @RequestParam("file") MultipartFile file
    ) throws IOException {
        return ResponseEntity.ok(ApiResponse.success(
                lessonService.uploadContent(lessonId, file),
                "Content uploaded successfully"
        ));
    }

    @GetMapping("/module/{moduleId}")
    @Operation(summary = "Get all lessons in a module")
    public ResponseEntity<ApiResponse<List<LessonResponse>>> getLessonsByModule(
            @PathVariable UUID moduleId
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                lessonService.getLessonsByModule(moduleId)
        ));
    }

    @GetMapping("/{lessonId}")
    @Operation(summary = "Get lesson details by ID")
    public ResponseEntity<ApiResponse<LessonResponse>> getLesson(
            @PathVariable UUID lessonId
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                lessonService.getLessonById(lessonId)
        ));
    }

    @PostMapping("/progress")
    @PreAuthorize("hasRole('LEARNER')")
    @Operation(summary = "Save watched position and/or mark a lesson completed")
    public ResponseEntity<ApiResponse<ProgressResponse>> updateProgress(
            @Valid @RequestBody ProgressRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                lessonService.updateProgress(currentUserEmail(), request),
                "Progress updated"
        ));
    }

    @PostMapping("/{lessonId}/complete")
    @PreAuthorize("hasRole('LEARNER')")
    @Operation(summary = "Manually mark a text, PDF, or slides lesson as completed")
    public ResponseEntity<ApiResponse<ProgressResponse>> markLessonCompleted(
            @PathVariable UUID lessonId
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                lessonService.markLessonCompleted(currentUserEmail(), lessonId),
                "Lesson marked as completed"
        ));
    }

    @GetMapping("/progress/my")
    @PreAuthorize("hasRole('LEARNER')")
    @Operation(summary = "Get my progress across all courses")
    public ResponseEntity<ApiResponse<List<ProgressResponse>>> getMyProgress() {
        return ResponseEntity.ok(ApiResponse.success(
                lessonService.getMyProgress(currentUserEmail())
        ));
    }

    @GetMapping("/progress/course/{courseId}")
    @PreAuthorize("hasRole('LEARNER')")
    @Operation(summary = "Get lesson progress, resume location, and completion status for one course")
    public ResponseEntity<ApiResponse<CourseProgressResponse>> getCourseProgress(
            @PathVariable UUID courseId
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                lessonService.getCourseProgress(currentUserEmail(), courseId)
        ));
    }

    @GetMapping("/progress/course/{courseId}/resume")
    @PreAuthorize("hasRole('LEARNER')")
    @Operation(summary = "Get the learner's resume lesson and saved playback position")
    public ResponseEntity<ApiResponse<CourseProgressResponse>> getResumeProgress(
            @PathVariable UUID courseId
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                lessonService.getCourseProgress(currentUserEmail(), courseId)
        ));
    }

    @GetMapping("/progress/course/{courseId}/assessment-access")
    @PreAuthorize("hasRole('LEARNER')")
    @Operation(summary = "Check whether course content completion unlocks assessment access")
    public ResponseEntity<ApiResponse<CourseProgressResponse>> getAssessmentAccess(
            @PathVariable UUID courseId
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                lessonService.getAssessmentAccess(currentUserEmail(), courseId)
        ));
    }

    @DeleteMapping("/{lessonId}")
    @PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
    @Operation(summary = "Delete a lesson and its content from storage")
    public ResponseEntity<ApiResponse<String>> deleteLesson(
            @PathVariable UUID lessonId
    ) {
        lessonService.deleteLesson(lessonId);

        return ResponseEntity.ok(
                ApiResponse.success("Lesson deleted successfully")
        );
    }

    private String currentUserEmail() {
        return SecurityContextHolder.getContext()
                .getAuthentication()
                .getName();
    }
}