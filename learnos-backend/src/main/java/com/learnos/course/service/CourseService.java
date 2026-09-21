package com.learnos.course.service;

import com.learnos.auth.model.Role;
import com.learnos.auth.model.User;
import com.learnos.auth.repository.UserRepository;
import com.learnos.company.entity.Company;
import com.learnos.company.repository.CompanyRepository;
import com.learnos.content.dto.LessonRequest;
import com.learnos.content.dto.LessonResponse;
import com.learnos.content.model.Lesson;
import com.learnos.content.repository.LessonProgressRepository;
import com.learnos.content.repository.LessonRepository;
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
import com.learnos.course.model.Category;
import com.learnos.course.model.Course;
import com.learnos.course.model.CourseLevel;
import com.learnos.course.model.CourseModule;
import com.learnos.course.model.CourseRating;
import com.learnos.course.model.CourseStatus;
import com.learnos.course.model.Enrollment;
import com.learnos.course.model.EnrollmentStatus;
import com.learnos.course.repository.CategoryRepository;
import com.learnos.course.repository.CourseRatingRepository;
import com.learnos.course.repository.CourseRepository;
import com.learnos.course.repository.EnrollmentRepository;
import com.learnos.course.repository.ModuleRepository;
import com.learnos.storage.service.S3StorageService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class CourseService {

    private final CourseRepository courseRepository;
    private final CategoryRepository categoryRepository;
    private final ModuleRepository moduleRepository;
    private final LessonRepository lessonRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final CourseRatingRepository courseRatingRepository;
    private final CompanyRepository companyRepository;
    private final UserRepository userRepository;
    private final S3StorageService storageService;
    private final LessonProgressRepository lessonProgressRepository;

    public List<CategoryResponse> getAllCategories() {
        User currentUser = getCurrentUser(null);

        if (isSuperAdmin(currentUser)) {
            return categoryRepository.findAll()
                    .stream()
                    .map(this::mapCategoryToResponse)
                    .toList();
        }

        if (
                currentUser != null
                        && currentUser.getCompany() != null
        ) {
            return categoryRepository
                    .findByCompany_IdAndActiveTrueOrderByDisplayOrderAsc(
                            currentUser.getCompany().getId()
                    )
                    .stream()
                    .map(this::mapCategoryToResponse)
                    .toList();
        }

        return List.of();
    }

    public CategoryResponse createCategory(
            CategoryRequest request
    ) {
        User currentUser = getCurrentUser(null);

        if (currentUser == null) {
            throw new RuntimeException("User not found");
        }

        Category category = new Category();
        category.setName(request.name());
        category.setDescription(request.description());
        category.setIconUrl(request.iconUrl());
        category.setColor(request.color());
        category.setActive(
                request.active() == null || request.active()
        );
        category.setDisplayOrder(
                request.displayOrder() != null
                        ? request.displayOrder()
                        : 0
        );

        if (isSuperAdmin(currentUser)) {
            if (request.companyId() == null) {
                throw new RuntimeException(
                        "Company is required for category"
                );
            }

            category.setCompany(
                    companyRepository.findById(request.companyId())
                            .orElseThrow(
                                    () -> new RuntimeException(
                                            "Company not found"
                                    )
                            )
            );
        } else {
            category.setCompany(currentUser.getCompany());
        }

        return mapCategoryToResponse(
                categoryRepository.save(category)
        );
    }

    public CategoryResponse getCategoryById(UUID id) {
        Category category = categoryRepository.findById(id)
                .orElseThrow(
                        () -> new RuntimeException("Category not found")
                );

        User currentUser = getCurrentUser(null);

        if (!isSuperAdmin(currentUser)) {
            if (
                    currentUser == null
                            || currentUser.getCompany() == null
                            || category.getCompany() == null
                            || !currentUser.getCompany().getId().equals(
                            category.getCompany().getId()
                    )
            ) {
                throw new RuntimeException("Access denied");
            }
        }

        return mapCategoryToResponse(category);
    }

    public CategoryResponse updateCategory(
            UUID id,
            CategoryRequest request
    ) {
        Category existing = categoryRepository.findById(id)
                .orElseThrow(
                        () -> new RuntimeException("Category not found")
                );

        User currentUser = getCurrentUser(null);

        if (!isSuperAdmin(currentUser)) {
            if (
                    currentUser == null
                            || currentUser.getCompany() == null
                            || existing.getCompany() == null
                            || !currentUser.getCompany().getId().equals(
                            existing.getCompany().getId()
                    )
            ) {
                throw new RuntimeException("Access denied");
            }
        }

        existing.setName(request.name());
        existing.setDescription(request.description());
        existing.setIconUrl(request.iconUrl());
        existing.setColor(request.color());
        existing.setActive(
                request.active() == null || request.active()
        );
        existing.setDisplayOrder(
                request.displayOrder() != null
                        ? request.displayOrder()
                        : existing.getDisplayOrder()
        );

        if (
                isSuperAdmin(currentUser)
                        && request.companyId() != null
        ) {
            existing.setCompany(
                    companyRepository.findById(request.companyId())
                            .orElseThrow(
                                    () -> new RuntimeException(
                                            "Company not found"
                                    )
                            )
            );
        }

        return mapCategoryToResponse(
                categoryRepository.save(existing)
        );
    }

    public void deleteCategory(UUID id) {
        Category existing = categoryRepository.findById(id)
                .orElseThrow(
                        () -> new RuntimeException("Category not found")
                );

        User currentUser = getCurrentUser(null);

        if (!isSuperAdmin(currentUser)) {
            if (
                    currentUser == null
                            || currentUser.getCompany() == null
                            || existing.getCompany() == null
                            || !currentUser.getCompany().getId().equals(
                            existing.getCompany().getId()
                    )
            ) {
                throw new RuntimeException("Access denied");
            }
        }

        long coursesUsingCategory =
                courseRepository.countByCategory_Id(id);

        if (coursesUsingCategory > 0) {
            throw new RuntimeException(
                    "Cannot delete this category - "
                            + coursesUsingCategory
                            + " course(s) are still assigned to it. "
                            + "Move those courses to a different category first."
            );
        }

        categoryRepository.delete(existing);
    }

    public List<CourseResponse> getFeaturedCourses(
            String username
    ) {
        return getCompanyCourses(
                PageRequest.of(0, 100),
                username
        )
                .getContent()
                .stream()
                .filter(CourseResponse::isFeatured)
                .filter(
                        course ->
                                course.getStatus()
                                        == CourseStatus.PUBLISHED
                )
                .toList();
    }

    public Page<CourseResponse> getCompanyCourses(
            PageRequest pageRequest,
            String username
    ) {
        User currentUser = getCurrentUser(username);

        boolean learnerView =
                currentUser != null
                        && currentUser.getRole() == Role.LEARNER;

        if (isSuperAdmin(currentUser)) {
            return learnerView
                    ? courseRepository
                    .findByStatus(
                            CourseStatus.PUBLISHED,
                            pageRequest
                    )
                    .map(
                            course ->
                                    mapToResponse(
                                            course,
                                            currentUser
                                    )
                    )
                    : courseRepository
                    .findAll(pageRequest)
                    .map(
                            course ->
                                    mapToResponse(
                                            course,
                                            currentUser
                                    )
                    );
        }

        if (
                currentUser != null
                        && currentUser.getCompany() != null
        ) {
            return learnerView
                    ? courseRepository
                    .findByCompanyIdAndStatus(
                            currentUser.getCompany().getId(),
                            CourseStatus.PUBLISHED,
                            pageRequest
                    )
                    .map(
                            course ->
                                    mapToResponse(
                                            course,
                                            currentUser
                                    )
                    )
                    : courseRepository
                    .findByCompanyId(
                            currentUser.getCompany().getId(),
                            pageRequest
                    )
                    .map(
                            course ->
                                    mapToResponse(
                                            course,
                                            currentUser
                                    )
                    );
        }

        return Page.empty(pageRequest);
    }

    public Page<CourseResponse> searchCourses(
            String q,
            PageRequest pageRequest,
            String username
    ) {
        User currentUser = getCurrentUser(username);

        if (isSuperAdmin(currentUser)) {
            return courseRepository
                    .findByTitleContainingIgnoreCase(q, pageRequest)
                    .map(
                            course ->
                                    mapToResponse(
                                            course,
                                            currentUser
                                    )
                    );
        }

        if (
                currentUser != null
                        && currentUser.getCompany() != null
        ) {
            return courseRepository
                    .searchCoursesByCompany(
                            currentUser.getCompany().getId(),
                            q,
                            pageRequest
                    )
                    .map(
                            course ->
                                    mapToResponse(
                                            course,
                                            currentUser
                                    )
                    );
        }

        return Page.empty(pageRequest);
    }

    public Page<CourseResponse> getCoursesByCategory(
            UUID categoryId,
            PageRequest pageRequest,
            String username
    ) {
        User currentUser = getCurrentUser(username);

        if (isSuperAdmin(currentUser)) {
            return courseRepository
                    .findByCategory_Id(categoryId, pageRequest)
                    .map(
                            course ->
                                    mapToResponse(
                                            course,
                                            currentUser
                                    )
                    );
        }

        if (
                currentUser != null
                        && currentUser.getCompany() != null
        ) {
            return courseRepository
                    .findByCategoryIdAndStatusAndCompanyId(
                            categoryId,
                            currentUser.getCompany().getId(),
                            pageRequest
                    )
                    .map(
                            course ->
                                    mapToResponse(
                                            course,
                                            currentUser
                                    )
                    );
        }

        return Page.empty(pageRequest);
    }

    public List<CourseResponse> getMyEnrolledCourses(
            String username
    ) {
        User currentUser = getCurrentUser(username);

        if (currentUser == null) {
            return List.of();
        }

        return enrollmentRepository
                .findByUserId(currentUser.getId())
                .stream()
                .filter(
                        enrollment ->
                                enrollment.getCourse() != null
                )
                .filter(
                        enrollment ->
                                enrollment.getStatus()
                                        == EnrollmentStatus.ACTIVE
                )
                .map(
                        enrollment ->
                                mapToResponseWithProgress(
                                        enrollment.getCourse(),
                                        getActualCourseProgressPercent(
                                                currentUser.getId(),
                                                enrollment.getCourse().getId()
                                        ),
                                        currentUser
                                )
                )
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<CourseEnrollmentResponse> getCourseEnrollments(
            UUID courseId
    ) {
        User currentUser = getCurrentUser(null);

        if (currentUser == null) {
            throw new RuntimeException("User not found");
        }

        Course course = courseRepository.findById(courseId)
                .orElseThrow(
                        () -> new RuntimeException("Course not found")
                );

        assertCanManageCourse(currentUser, course);

        return enrollmentRepository
                .findLearnerEnrollmentsForCourse(
                        courseId,
                        EnrollmentStatus.ACTIVE,
                        Role.LEARNER
                )
                .stream()
                .map(
                        enrollment ->
                                toCourseEnrollmentResponse(
                                        enrollment,
                                        course
                                )
                )
                .toList();
    }

    public CourseEnrollmentResponse enrollLearner(
            UUID courseId,
            CourseEnrollmentRequest request
    ) {
        User currentUser = getCurrentUser(null);

        if (currentUser == null) {
            throw new RuntimeException("User not found");
        }

        if (request == null || request.learnerId() == null) {
            throw new RuntimeException("Learner is required");
        }

        Course course = courseRepository.findById(courseId)
                .orElseThrow(
                        () -> new RuntimeException("Course not found")
                );

        assertCanManageCourse(currentUser, course);

        User learner = userRepository.findById(request.learnerId())
                .orElseThrow(
                        () -> new RuntimeException("Learner not found")
                );

        if (learner.getRole() != Role.LEARNER) {
            throw new RuntimeException(
                    "Only learner accounts can be enrolled in a course"
            );
        }

        assertLearnerBelongsToCourseCompany(learner, course);

        Enrollment enrollment = enrollmentRepository
                .findByUserIdAndCourseId(
                        learner.getId(),
                        course.getId()
                )
                .orElse(null);

        if (enrollment == null) {
            enrollment = Enrollment.builder()
                    .user(learner)
                    .course(course)
                    .status(EnrollmentStatus.ACTIVE)
                    .progressPercent(0)
                    .build();

            enrollmentRepository.save(enrollment);

            course.setTotalEnrollments(
                    course.getTotalEnrollments() + 1
            );

            courseRepository.save(course);
        } else if (
                enrollment.getStatus()
                        != EnrollmentStatus.ACTIVE
        ) {
            enrollment.setStatus(EnrollmentStatus.ACTIVE);
            enrollmentRepository.save(enrollment);
        }

        return toCourseEnrollmentResponse(
                enrollment,
                course
        );
    }

    public void removeLearnerEnrollment(
            UUID courseId,
            UUID learnerId
    ) {
        User currentUser = getCurrentUser(null);

        if (currentUser == null) {
            throw new RuntimeException("User not found");
        }

        Course course = courseRepository.findById(courseId)
                .orElseThrow(
                        () -> new RuntimeException("Course not found")
                );

        assertCanManageCourse(currentUser, course);

        Enrollment enrollment = enrollmentRepository
                .findByUserIdAndCourseId(learnerId, courseId)
                .orElseThrow(
                        () -> new RuntimeException(
                                "This learner is not enrolled in the course"
                        )
                );

        enrollmentRepository.delete(enrollment);

        course.setTotalEnrollments(
                Math.max(
                        0,
                        course.getTotalEnrollments() - 1
                )
        );

        courseRepository.save(course);
    }

    public CourseResponse createCourse(
            CourseRequest request,
            String username
    ) {
        User currentUser = getCurrentUser(username);

        if (currentUser == null) {
            throw new RuntimeException("User not found");
        }

        Category category = categoryRepository
                .findById(request.getCategoryId())
                .orElseThrow(
                        () -> new RuntimeException("Category not found")
                );

        Company company;

        if (isSuperAdmin(currentUser)) {
            company = request.getCompanyId() != null
                    ? companyRepository
                    .findById(request.getCompanyId())
                    .orElse(null)
                    : null;
        } else {
            company = currentUser.getCompany();
        }

        User instructor = null;

        if (request.getInstructorId() != null) {
            instructor = userRepository
                    .findById(request.getInstructorId())
                    .orElse(null);
        }

        Course course = Course.builder()
                .title(request.getTitle())
                .description(request.getDescription())
                .shortDescription(request.getShortDescription())
                .category(category)
                .instructor(instructor)
                .level(
                        request.getLevel() != null
                                ? request.getLevel()
                                : CourseLevel.BEGINNER
                )
                .status(
                        request.getStatus() != null
                                ? request.getStatus()
                                : CourseStatus.DRAFT
                )
                .paid(request.isPaid())
                .featured(request.isFeatured())
                .price(
                        request.getPrice() != null
                                ? request.getPrice()
                                : java.math.BigDecimal.ZERO
                )
                .language(request.getLanguage())
                .durationMinutes(request.getDurationMinutes())
                .tags(
                        request.getTags() != null
                                ? request.getTags()
                                : new ArrayList<>()
                )
                .prerequisites(
                        request.getPrerequisites() != null
                                ? request.getPrerequisites()
                                : new ArrayList<>()
                )
                .learningOutcomes(
                        request.getLearningOutcomes() != null
                                ? request.getLearningOutcomes()
                                : new ArrayList<>()
                )
                .company(company)
                .build();

        return mapToResponse(
                courseRepository.save(course),
                currentUser
        );
    }

    public CourseResponse updateCourse(
            UUID id,
            CourseRequest request,
            String username
    ) {
        User currentUser = getCurrentUser(username);

        Course course = courseRepository.findById(id)
                .orElseThrow(
                        () -> new RuntimeException("Course not found")
                );

        assertCanManageCourse(currentUser, course);

        if (request.getCategoryId() != null) {
            course.setCategory(
                    categoryRepository.findById(request.getCategoryId())
                            .orElseThrow(
                                    () -> new RuntimeException(
                                            "Category not found"
                                    )
                            )
            );
        }

        course.setInstructor(
                request.getInstructorId() != null
                        ? userRepository
                        .findById(request.getInstructorId())
                        .orElse(null)
                        : null
        );

        course.setTitle(request.getTitle());
        course.setDescription(request.getDescription());
        course.setShortDescription(request.getShortDescription());
        course.setLevel(
                request.getLevel() != null
                        ? request.getLevel()
                        : course.getLevel()
        );
        course.setStatus(
                request.getStatus() != null
                        ? request.getStatus()
                        : course.getStatus()
        );
        course.setPaid(request.isPaid());
        course.setFeatured(request.isFeatured());
        course.setPrice(
                request.getPrice() != null
                        ? request.getPrice()
                        : course.getPrice()
        );
        course.setLanguage(request.getLanguage());
        course.setDurationMinutes(request.getDurationMinutes());
        course.setTags(
                request.getTags() != null
                        ? request.getTags()
                        : course.getTags()
        );
        course.setPrerequisites(
                request.getPrerequisites() != null
                        ? request.getPrerequisites()
                        : course.getPrerequisites()
        );
        course.setLearningOutcomes(
                request.getLearningOutcomes() != null
                        ? request.getLearningOutcomes()
                        : course.getLearningOutcomes()
        );

        if (
                isSuperAdmin(currentUser)
                        && request.getCompanyId() != null
        ) {
            course.setCompany(
                    companyRepository
                            .findById(request.getCompanyId())
                            .orElse(null)
            );
        }

        return mapToResponse(
                courseRepository.save(course),
                currentUser
        );
    }

    public CourseResponse publishCourse(UUID id) {
        Course course = courseRepository.findById(id)
                .orElseThrow(
                        () -> new RuntimeException("Course not found")
                );

        course.setStatus(CourseStatus.PUBLISHED);

        return mapToResponse(
                courseRepository.save(course),
                getCurrentUser(null)
        );
    }

    public String uploadThumbnail(
            UUID id,
            MultipartFile file
    ) throws IOException {
        Course course = courseRepository.findById(id)
                .orElseThrow(
                        () -> new RuntimeException("Course not found")
                );

        String url = storageService.uploadFile(file, "thumbnails");

        course.setThumbnailUrl(url);
        courseRepository.save(course);

        return course.getThumbnailUrl();
    }

    public List<ModuleResponse> getModulesByCourse(UUID courseId) {
        return moduleRepository
                .findByCourseIdOrderByDisplayOrderAsc(courseId)
                .stream()
                .map(this::mapModuleToResponse)
                .toList();
    }

    public ModuleResponse addModule(
            UUID courseId,
            ModuleRequest request
    ) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(
                        () -> new RuntimeException("Course not found")
                );

        CourseModule module = CourseModule.builder()
                .course(course)
                .title(request.getTitle())
                .description(request.getDescription())
                .displayOrder(request.getDisplayOrder())
                .isPreview(request.isPreview())
                .build();

        return mapModuleToResponse(
                moduleRepository.save(module)
        );
    }

    public ModuleResponse updateModule(
            UUID courseId,
            UUID moduleId,
            ModuleRequest request
    ) {
        CourseModule module = moduleRepository.findById(moduleId)
                .orElseThrow(
                        () -> new RuntimeException("Module not found")
                );

        if (
                module.getCourse() == null
                        || !module.getCourse().getId().equals(courseId)
        ) {
            throw new RuntimeException(
                    "Module does not belong to course"
            );
        }

        module.setTitle(request.getTitle());
        module.setDescription(request.getDescription());
        module.setDisplayOrder(request.getDisplayOrder());
        module.setPreview(request.isPreview());

        return mapModuleToResponse(
                moduleRepository.save(module)
        );
    }

    public void deleteModule(
            UUID courseId,
            UUID moduleId
    ) {
        CourseModule module = moduleRepository.findById(moduleId)
                .orElseThrow(
                        () -> new RuntimeException("Module not found")
                );

        if (
                module.getCourse() == null
                        || !module.getCourse().getId().equals(courseId)
        ) {
            throw new RuntimeException(
                    "Module does not belong to course"
            );
        }

        moduleRepository.delete(module);
    }

    public List<LessonResponse> getLessonsByCourse(
            UUID courseId,
            String username
    ) {
        List<CourseModule> modules =
                moduleRepository
                        .findByCourseIdOrderByDisplayOrderAsc(courseId);

        return modules.stream()
                .flatMap(
                        module ->
                                lessonRepository
                                        .findByModuleIdOrderByDisplayOrderAsc(
                                                module.getId()
                                        )
                                        .stream()
                )
                .map(this::mapLessonToResponse)
                .toList();
    }

    public List<LessonResponse> getLessonsByModule(
            UUID courseId,
            UUID moduleId
    ) {
        CourseModule module = moduleRepository.findById(moduleId)
                .orElseThrow(
                        () -> new RuntimeException("Module not found")
                );

        if (
                module.getCourse() == null
                        || !module.getCourse().getId().equals(courseId)
        ) {
            throw new RuntimeException(
                    "Module does not belong to course"
            );
        }

        return lessonRepository
                .findByModuleIdOrderByDisplayOrderAsc(moduleId)
                .stream()
                .map(this::mapLessonToResponse)
                .toList();
    }

    public LessonResponse addLesson(
            UUID moduleId,
            LessonRequest request
    ) {
        CourseModule module = moduleRepository.findById(moduleId)
                .orElseThrow(
                        () -> new RuntimeException("Module not found")
                );

        Lesson lesson = Lesson.builder()
                .module(module)
                .title(request.getTitle())
                .description(request.getDescription())
                .type(request.getType())
                .contentUrl(request.getContentUrl())
                .streamingUrl(request.getStreamingUrl())
                .thumbnailUrl(request.getThumbnailUrl())
                .textContent(request.getTextContent())
                .durationSeconds(request.getDurationSeconds())
                .isPreview(request.isPreview())
                .isPublished(request.isPublished())
                .displayOrder(request.getDisplayOrder())
                .build();

        if (
                request.getType() != null
                        && request.getType().name().equals("TEXT")
        ) {
            lesson.setContentUrl(null);
            lesson.setStreamingUrl(null);
        }

        return mapLessonToResponse(
                lessonRepository.save(lesson)
        );
    }

    public String enrollUser(
            UUID courseId,
            String username
    ) {
        User user = getCurrentUser(username);

        if (user == null) {
            throw new RuntimeException("User not found");
        }

        Course course = courseRepository.findById(courseId)
                .orElseThrow(
                        () -> new RuntimeException("Course not found")
                );

        if (
                enrollmentRepository.existsByUserIdAndCourseId(
                        user.getId(),
                        courseId
                )
        ) {
            return "Already enrolled in " + course.getTitle();
        }

        if (course.isPaid()) {
            throw new RuntimeException(
                    "This course requires payment before you can enroll"
            );
        }

        Enrollment enrollment = Enrollment.builder()
                .user(user)
                .course(course)
                .status(EnrollmentStatus.ACTIVE)
                .progressPercent(0)
                .build();

        enrollmentRepository.save(enrollment);

        course.setTotalEnrollments(
                course.getTotalEnrollments() + 1
        );

        courseRepository.save(course);

        return "Enrolled in " + course.getTitle();
    }

    public String unenrollUser(
            UUID courseId,
            String username
    ) {
        User user = getCurrentUser(username);

        if (user == null) {
            throw new RuntimeException("User not found");
        }

        Course course = courseRepository.findById(courseId)
                .orElseThrow(
                        () -> new RuntimeException("Course not found")
                );

        enrollmentRepository
                .findByUserIdAndCourseId(
                        user.getId(),
                        courseId
                )
                .ifPresent(
                        enrollment -> {
                            enrollmentRepository.delete(enrollment);

                            course.setTotalEnrollments(
                                    Math.max(
                                            0,
                                            course.getTotalEnrollments() - 1
                                    )
                            );

                            courseRepository.save(course);
                        }
                );

        return "Unenrolled from " + course.getTitle();
    }

    public CourseResponse getCourseById(UUID id) {
        User currentUser = getCurrentUser(null);

        return mapToResponse(
                courseRepository.findById(id)
                        .orElseThrow(
                                () -> new RuntimeException(
                                        "Course not found"
                                )
                        ),
                currentUser
        );
    }

    public List<CourseResponse> getAllCourses() {
        User currentUser = getCurrentUser(null);

        if (isSuperAdmin(currentUser)) {
            return courseRepository.findAll()
                    .stream()
                    .map(
                            course ->
                                    mapToResponse(
                                            course,
                                            currentUser
                                    )
                    )
                    .collect(Collectors.toList());
        }

        if (
                currentUser != null
                        && currentUser.getCompany() != null
        ) {
            return courseRepository
                    .findByCompanyId(
                            currentUser.getCompany().getId()
                    )
                    .stream()
                    .map(
                            course ->
                                    mapToResponse(
                                            course,
                                            currentUser
                                    )
                    )
                    .collect(Collectors.toList());
        }

        return List.of();
    }

    public void deleteCourse(UUID id) {
        courseRepository.deleteById(id);
    }

    public CourseRatingResponse getCourseRating(
            UUID courseId,
            String username
    ) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(
                        () -> new RuntimeException("Course not found")
                );

        User currentUser = getCurrentUser(username);

        return buildCourseRatingResponse(course, currentUser);
    }

    public CourseRatingResponse saveCourseRating(
            UUID courseId,
            CourseRatingRequest request,
            String username
    ) {
        User currentUser = getCurrentUser(username);

        if (currentUser == null) {
            throw new RuntimeException("User not found");
        }

        if (currentUser.getRole() != Role.LEARNER) {
            throw new RuntimeException(
                    "Only learners can rate courses"
            );
        }

        Course course = courseRepository.findById(courseId)
                .orElseThrow(
                        () -> new RuntimeException("Course not found")
                );

        Enrollment enrollment = enrollmentRepository
                .findByUserIdAndCourseId(
                        currentUser.getId(),
                        courseId
                )
                .orElseThrow(
                        () -> new RuntimeException(
                                "Enroll in this course before rating it"
                        )
                );

        if (
                enrollment.getStatus()
                        != EnrollmentStatus.ACTIVE
        ) {
            throw new RuntimeException(
                    "Only active learners can rate this course"
            );
        }

        int stars = request.getStars();

        CourseRating courseRating = courseRatingRepository
                .findByCourseIdAndUserId(
                        courseId,
                        currentUser.getId()
                )
                .orElseGet(
                        () -> CourseRating.builder()
                                .course(course)
                                .user(currentUser)
                                .build()
                );

        courseRating.setStars(stars);
        courseRatingRepository.save(courseRating);

        Double average = courseRatingRepository
                .findAverageRatingByCourseId(courseId);

        course.setRating(
                average == null
                        ? 0.0
                        : roundToOneDecimal(average)
        );

        courseRepository.save(course);

        return buildCourseRatingResponse(course, currentUser);
    }

    private CategoryResponse mapCategoryToResponse(
            Category category
    ) {
        return new CategoryResponse(
                category.getId(),
                category.getName(),
                category.getDescription(),
                category.getIconUrl(),
                category.getColor(),
                category.isActive(),
                category.getDisplayOrder(),
                category.getCompany() != null
                        ? category.getCompany().getId()
                        : null,
                category.getCompany() != null
                        ? category.getCompany().getName()
                        : null,
                courseRepository.countByCategory_Id(category.getId())
        );
    }

    private CourseResponse mapToResponseWithProgress(
            Course course,
            int progressPercent,
            User currentUser
    ) {
        CourseResponse base = mapToResponse(course, currentUser);
        base.setProgressPercent(progressPercent);
        return base;
    }

    private CourseResponse mapToResponse(
            Course course,
            User currentUser
    ) {
        long enrolledCount = enrollmentRepository
                .countByCourseIdAndStatus(
                        course.getId(),
                        EnrollmentStatus.ACTIVE
                );

        int completionRate;

        if (
                currentUser != null
                        && currentUser.getRole() == Role.LEARNER
        ) {
            completionRate = getActualCourseProgressPercent(
                    currentUser.getId(),
                    course.getId()
            );
        } else {
            Double averageProgress =
                    enrollmentRepository
                            .findAverageProgressByCourseIdAndStatus(
                                    course.getId(),
                                    EnrollmentStatus.ACTIVE
                            );

            completionRate = averageProgress == null
                    ? 0
                    : (int) Math.round(averageProgress);
        }

        Double averageRating =
                courseRatingRepository.findAverageRatingByCourseId(
                        course.getId()
                );

        double normalizedAverageRating = averageRating == null
                ? 0.0
                : roundToOneDecimal(averageRating);

        long ratingCount = courseRatingRepository
                .countByCourseId(course.getId());

        Integer myRating = null;

        if (currentUser != null) {
            myRating = courseRatingRepository
                    .findByCourseIdAndUserId(
                            course.getId(),
                            currentUser.getId()
                    )
                    .map(CourseRating::getStars)
                    .orElse(null);
        }

        return CourseResponse.builder()
                .id(course.getId())
                .title(course.getTitle())
                .description(course.getDescription())
                .shortDescription(course.getShortDescription())
                .thumbnailUrl(course.getThumbnailUrl())
                .categoryName(
                        course.getCategory() != null
                                ? course.getCategory().getName()
                                : null
                )
                .categoryId(
                        course.getCategory() != null
                                ? course.getCategory().getId()
                                : null
                )
                .instructorName(
                        course.getInstructor() != null
                                ? course.getInstructor().getFullName()
                                : null
                )
                .instructorId(
                        course.getInstructor() != null
                                ? course.getInstructor().getId()
                                : null
                )
                .companyId(
                        course.getCompany() != null
                                ? course.getCompany().getId()
                                : null
                )
                .companyName(
                        course.getCompany() != null
                                ? course.getCompany().getName()
                                : null
                )
                .level(course.getLevel())
                .status(course.getStatus())
                .isPaid(course.isPaid())
                .featured(course.isFeatured())
                .price(course.getPrice())
                .language(course.getLanguage())
                .durationMinutes(course.getDurationMinutes())
                .rating(normalizedAverageRating)
                .totalEnrollments(course.getTotalEnrollments())
                .totalLessons(
                        getPublishedLessonCount(course.getId())
                )
                .enrolledCount(enrolledCount)
                .completionRate(completionRate)
                .progressPercent(
                        currentUser != null
                                && currentUser.getRole() == Role.LEARNER
                                ? completionRate
                                : 0
                )
                .averageRating(normalizedAverageRating)
                .ratingCount(ratingCount)
                .myRating(myRating)
                .tags(course.getTags())
                .prerequisites(course.getPrerequisites())
                .learningOutcomes(course.getLearningOutcomes())
                .createdAt(course.getCreatedAt())
                .build();
    }
    private int getPublishedLessonCount(UUID courseId) {
        if (courseId == null) {
            return 0;
        }

        long count =
                lessonRepository
                        .countByModule_Course_IdAndIsPublishedTrue(
                                courseId
                        );

        return Math.toIntExact(count);
    }

    private int getActualCourseProgressPercent(
            UUID userId,
            UUID courseId
    ) {
        if (userId == null || courseId == null) {
            return 0;
        }

        Double calculatedProgress =
                lessonProgressRepository
                        .calculateCourseCompletionPercent(
                                userId,
                                courseId
                        );

        if (calculatedProgress == null) {
            return 0;
        }

        return Math.max(
                0,
                Math.min(
                        100,
                        (int) Math.round(calculatedProgress)
                )
        );
    }

    private CourseRatingResponse buildCourseRatingResponse(
            Course course,
            User currentUser
    ) {
        Double averageRating =
                courseRatingRepository.findAverageRatingByCourseId(
                        course.getId()
                );

        long ratingCount = courseRatingRepository
                .countByCourseId(course.getId());

        Integer myRating = null;

        if (currentUser != null) {
            myRating = courseRatingRepository
                    .findByCourseIdAndUserId(
                            course.getId(),
                            currentUser.getId()
                    )
                    .map(CourseRating::getStars)
                    .orElse(null);
        }

        return CourseRatingResponse.builder()
                .courseId(course.getId().toString())
                .averageRating(
                        averageRating == null
                                ? 0.0
                                : roundToOneDecimal(averageRating)
                )
                .ratingCount(ratingCount)
                .myRating(myRating)
                .build();
    }

    private CourseEnrollmentResponse toCourseEnrollmentResponse(
            Enrollment enrollment,
            Course course
    ) {
        User learner = enrollment.getUser();

        int actualProgress = 0;

        if (
                learner != null
                        && learner.getId() != null
                        && course != null
                        && course.getId() != null
        ) {
            actualProgress = getActualCourseProgressPercent(
                    learner.getId(),
                    course.getId()
            );
        }

        return new CourseEnrollmentResponse(
                enrollment.getId(),
                learner != null ? learner.getId() : null,
                learner != null ? learner.getFullName() : "Learner",
                learner != null ? learner.getEmail() : "",
                course.getId(),
                course.getTitle(),
                enrollment.getStatus(),
                actualProgress,
                enrollment.getEnrolledAt(),
                enrollment.getCompletedAt()
        );
    }

    private void assertCanManageCourse(
            User currentUser,
            Course course
    ) {
        if (currentUser == null) {
            throw new RuntimeException("User not found");
        }

        if (isSuperAdmin(currentUser)) {
            return;
        }

        if (
                currentUser.getCompany() == null
                        || course.getCompany() == null
                        || !currentUser.getCompany().getId().equals(
                        course.getCompany().getId()
                )
        ) {
            throw new RuntimeException("Access denied");
        }
    }

    private void assertLearnerBelongsToCourseCompany(
            User learner,
            Course course
    ) {
        if (
                learner.getCompany() == null
                        || course.getCompany() == null
                        || !learner.getCompany().getId().equals(
                        course.getCompany().getId()
                )
        ) {
            throw new RuntimeException(
                    "The learner must belong to the course company"
            );
        }
    }

    private double roundToOneDecimal(double value) {
        return Math.round(value * 10.0) / 10.0;
    }

    private ModuleResponse mapModuleToResponse(
            CourseModule module
    ) {
        return ModuleResponse.builder()
                .id(module.getId())
                .title(module.getTitle())
                .description(module.getDescription())
                .displayOrder(module.getDisplayOrder())
                .isPreview(module.isPreview())
                .createdAt(module.getCreatedAt())
                .build();
    }

    private LessonResponse mapLessonToResponse(
            Lesson lesson
    ) {
        return LessonResponse.builder()
                .id(lesson.getId())
                .title(lesson.getTitle())
                .description(lesson.getDescription())
                .type(lesson.getType())
                .contentUrl(lesson.getContentUrl())
                .streamingUrl(lesson.getStreamingUrl())
                .thumbnailUrl(lesson.getThumbnailUrl())
                .textContent(lesson.getTextContent())
                .mimeType(lesson.getMimeType())
                .originalFileName(lesson.getOriginalFileName())
                .fileSizeBytes(lesson.getFileSizeBytes())
                .durationSeconds(lesson.getDurationSeconds())
                .order(lesson.getDisplayOrder())
                .isPreview(lesson.isPreview())
                .isPublished(lesson.isPublished())
                .moduleId(
                        lesson.getModule() != null
                                ? lesson.getModule().getId()
                                : null
                )
                .moduleTitle(
                        lesson.getModule() != null
                                ? lesson.getModule().getTitle()
                                : null
                )
                .createdAt(lesson.getCreatedAt())
                .build();
    }

    private User getCurrentUser(String username) {
        String email = username;

        if (email == null || email.isBlank()) {
            Authentication auth = SecurityContextHolder
                    .getContext()
                    .getAuthentication();

            if (auth != null) {
                email = auth.getName();
            }
        }

        if (email == null || email.isBlank()) {
            return null;
        }

        return userRepository.findByEmail(email)
                .orElse(null);
    }

    private boolean isSuperAdmin(User user) {
        return user != null
                && user.getEmail() != null
                && user.getEmail()
                .equalsIgnoreCase("admin@blute.co.in");
    }
}