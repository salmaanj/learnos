package com.learnos.course.controller;

import com.learnos.common.response.ApiResponse;
import com.learnos.content.dto.LessonRequest;
import com.learnos.content.dto.LessonResponse;
import com.learnos.course.dto.CategoryRequest;
import com.learnos.course.dto.CategoryResponse;
import com.learnos.course.dto.CourseEnrollmentRequest;
import com.learnos.course.dto.CourseEnrollmentResponse;
import com.learnos.course.dto.CourseRatingRequest;
import com.learnos.course.dto.CourseRatingResponse;
import com.learnos.course.dto.CourseRequest;
import com.learnos.course.dto.CourseResponse;
import com.learnos.course.dto.ModuleRequest;
import com.learnos.course.dto.ModuleResponse;
import com.learnos.course.service.CourseService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

@RestController
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@Tag(
        name = "Courses",
        description = "Course catalog, modules, lessons, enrollment management and ratings"
)
public class CourseController {

    private final CourseService courseService;

    @GetMapping("/categories")
    public ResponseEntity<ApiResponse<List<CategoryResponse>>> getCategories() {
        return ResponseEntity.ok(
                ApiResponse.success(courseService.getAllCategories())
        );
    }

    @PostMapping("/categories")
    @PreAuthorize("hasAnyRole('ADMIN','USER')")
    public ResponseEntity<ApiResponse<CategoryResponse>> createCategory(
            @RequestBody CategoryRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(
                        ApiResponse.success(
                                courseService.createCategory(request),
                                "Category created"
                        )
                );
    }

    @GetMapping("/courses")
    public ResponseEntity<ApiResponse<Page<CourseResponse>>> getCourses(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "12") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        courseService.getCompanyCourses(
                                PageRequest.of(
                                        page,
                                        size,
                                        Sort.by(Sort.Direction.DESC, sortBy)
                                ),
                                userDetails != null
                                        ? userDetails.getUsername()
                                        : null
                        )
                )
        );
    }

    @GetMapping("/courses/search")
    public ResponseEntity<ApiResponse<Page<CourseResponse>>> searchCourses(
            @RequestParam String q,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "12") int size,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        courseService.searchCourses(
                                q,
                                PageRequest.of(page, size),
                                userDetails != null
                                        ? userDetails.getUsername()
                                        : null
                        )
                )
        );
    }

    @GetMapping("/courses/category/{categoryId}")
    public ResponseEntity<ApiResponse<Page<CourseResponse>>> getCoursesByCategory(
            @PathVariable UUID categoryId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "12") int size,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        courseService.getCoursesByCategory(
                                categoryId,
                                PageRequest.of(page, size),
                                userDetails != null
                                        ? userDetails.getUsername()
                                        : null
                        )
                )
        );
    }

    @GetMapping("/courses/my-courses")
    @PreAuthorize("hasRole('LEARNER')")
    public ResponseEntity<ApiResponse<List<CourseResponse>>> getMyCourses(
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        courseService.getMyEnrolledCourses(
                                userDetails != null
                                        ? userDetails.getUsername()
                                        : null
                        )
                )
        );
    }

    @GetMapping("/courses/featured")
    public ResponseEntity<ApiResponse<List<CourseResponse>>> getFeaturedCourses(
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        courseService.getFeaturedCourses(
                                userDetails != null
                                        ? userDetails.getUsername()
                                        : null
                        )
                )
        );
    }

    @GetMapping("/courses/{courseId}/enrollments")
    @PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
    public ResponseEntity<ApiResponse<List<CourseEnrollmentResponse>>>
    getCourseEnrollments(
            @PathVariable UUID courseId
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        courseService.getCourseEnrollments(courseId)
                )
        );
    }

    @PostMapping("/courses/{courseId}/enrollments")
    @PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
    public ResponseEntity<ApiResponse<CourseEnrollmentResponse>>
    enrollLearner(
            @PathVariable UUID courseId,
            @RequestBody CourseEnrollmentRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(
                        ApiResponse.success(
                                courseService.enrollLearner(
                                        courseId,
                                        request
                                ),
                                "Learner enrolled in course"
                        )
                );
    }

    @DeleteMapping("/courses/{courseId}/enrollments/{learnerId}")
    @PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
    public ResponseEntity<ApiResponse<String>> removeLearnerEnrollment(
            @PathVariable UUID courseId,
            @PathVariable UUID learnerId
    ) {
        courseService.removeLearnerEnrollment(
                courseId,
                learnerId
        );

        return ResponseEntity.ok(
                ApiResponse.success(
                        "Learner removed from course"
                )
        );
    }

    @GetMapping("/courses/{id}")
    public ResponseEntity<ApiResponse<CourseResponse>> getCourse(
            @PathVariable UUID id
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(courseService.getCourseById(id))
        );
    }

    @GetMapping("/courses/{courseId}/rating")
    public ResponseEntity<ApiResponse<CourseRatingResponse>> getCourseRating(
            @PathVariable UUID courseId,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        courseService.getCourseRating(
                                courseId,
                                userDetails != null
                                        ? userDetails.getUsername()
                                        : null
                        )
                )
        );
    }

    @PutMapping("/courses/{courseId}/rating")
    @PreAuthorize("hasRole('LEARNER')")
    public ResponseEntity<ApiResponse<CourseRatingResponse>> saveCourseRating(
            @PathVariable UUID courseId,
            @Valid @RequestBody CourseRatingRequest request,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        courseService.saveCourseRating(
                                courseId,
                                request,
                                userDetails != null
                                        ? userDetails.getUsername()
                                        : null
                        ),
                        "Course rating saved"
                )
        );
    }

    @PostMapping("/courses")
    @PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
    public ResponseEntity<ApiResponse<CourseResponse>> createCourse(
            @Valid @RequestBody CourseRequest request,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(
                        ApiResponse.success(
                                courseService.createCourse(
                                        request,
                                        userDetails != null
                                                ? userDetails.getUsername()
                                                : null
                                ),
                                "Course created"
                        )
                );
    }

    @PutMapping("/courses/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
    public ResponseEntity<ApiResponse<CourseResponse>> updateCourse(
            @PathVariable UUID id,
            @Valid @RequestBody CourseRequest request,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        courseService.updateCourse(
                                id,
                                request,
                                userDetails != null
                                        ? userDetails.getUsername()
                                        : null
                        ),
                        "Course updated"
                )
        );
    }

    @PatchMapping("/courses/{id}/publish")
    @PreAuthorize("hasAnyRole('ADMIN','USER')")
    public ResponseEntity<ApiResponse<CourseResponse>> publishCourse(
            @PathVariable UUID id
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        courseService.publishCourse(id),
                        "Course published successfully"
                )
        );
    }

    @PostMapping(
            value = "/courses/{id}/thumbnail",
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    @PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
    public ResponseEntity<ApiResponse<String>> uploadThumbnail(
            @PathVariable UUID id,
            @RequestParam("file") MultipartFile file
    ) throws IOException {
        return ResponseEntity.ok(
                ApiResponse.success(
                        courseService.uploadThumbnail(id, file),
                        "Thumbnail uploaded"
                )
        );
    }

    @GetMapping("/courses/{courseId}/modules")
    public ResponseEntity<ApiResponse<List<ModuleResponse>>> getModules(
            @PathVariable UUID courseId
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        courseService.getModulesByCourse(courseId)
                )
        );
    }

    @PostMapping("/courses/{courseId}/modules")
    @PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
    public ResponseEntity<ApiResponse<ModuleResponse>> addModule(
            @PathVariable UUID courseId,
            @Valid @RequestBody ModuleRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(
                        ApiResponse.success(
                                courseService.addModule(courseId, request),
                                "Module added"
                        )
                );
    }

    @PutMapping("/courses/{courseId}/modules/{moduleId}")
    @PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
    public ResponseEntity<ApiResponse<ModuleResponse>> updateModule(
            @PathVariable UUID courseId,
            @PathVariable UUID moduleId,
            @Valid @RequestBody ModuleRequest request
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        courseService.updateModule(
                                courseId,
                                moduleId,
                                request
                        ),
                        "Module updated"
                )
        );
    }

    @DeleteMapping("/courses/{courseId}/modules/{moduleId}")
    @PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
    public ResponseEntity<ApiResponse<String>> deleteModule(
            @PathVariable UUID courseId,
            @PathVariable UUID moduleId
    ) {
        courseService.deleteModule(courseId, moduleId);

        return ResponseEntity.ok(
                ApiResponse.success("Module deleted successfully")
        );
    }

    @GetMapping("/courses/{courseId}/modules/{moduleId}/lessons")
    public ResponseEntity<ApiResponse<List<LessonResponse>>> getLessonsByModule(
            @PathVariable UUID courseId,
            @PathVariable UUID moduleId
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        courseService.getLessonsByModule(courseId, moduleId)
                )
        );
    }

    @GetMapping("/courses/{courseId}/lessons")
    public ResponseEntity<ApiResponse<List<LessonResponse>>> getLessonsByCourse(
            @PathVariable UUID courseId,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        courseService.getLessonsByCourse(
                                courseId,
                                userDetails != null
                                        ? userDetails.getUsername()
                                        : null
                        )
                )
        );
    }

    @PostMapping("/courses/{courseId}/modules/{moduleId}/lessons")
    @PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
    public ResponseEntity<ApiResponse<LessonResponse>> addLesson(
            @PathVariable UUID courseId,
            @PathVariable UUID moduleId,
            @Valid @RequestBody LessonRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(
                        ApiResponse.success(
                                courseService.addLesson(moduleId, request),
                                "Lesson added"
                        )
                );
    }

    @PostMapping("/courses/{courseId}/enroll")
    @PreAuthorize("hasRole('LEARNER')")
    public ResponseEntity<ApiResponse<String>> enroll(
            @PathVariable UUID courseId,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        courseService.enrollUser(
                                courseId,
                                userDetails != null
                                        ? userDetails.getUsername()
                                        : null
                        )
                )
        );
    }

    @DeleteMapping("/courses/{courseId}/enroll")
    @PreAuthorize("hasRole('LEARNER')")
    public ResponseEntity<ApiResponse<String>> unenroll(
            @PathVariable UUID courseId,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        courseService.unenrollUser(
                                courseId,
                                userDetails != null
                                        ? userDetails.getUsername()
                                        : null
                        )
                )
        );
    }

    @GetMapping("/categories/{id}")
    public ResponseEntity<ApiResponse<CategoryResponse>> getCategory(
            @PathVariable UUID id
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(courseService.getCategoryById(id))
        );
    }

    @PutMapping("/categories/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','USER')")
    public ResponseEntity<ApiResponse<CategoryResponse>> updateCategory(
            @PathVariable UUID id,
            @RequestBody CategoryRequest request
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        courseService.updateCategory(id, request),
                        "Category updated"
                )
        );
    }

    @DeleteMapping("/categories/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','USER')")
    public ResponseEntity<ApiResponse<Void>> deleteCategory(
            @PathVariable UUID id
    ) {
        courseService.deleteCategory(id);

        return ResponseEntity.ok(
                ApiResponse.success(null, "Category deleted")
        );
    }
}