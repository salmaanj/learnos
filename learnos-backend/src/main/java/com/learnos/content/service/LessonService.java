package com.learnos.content.service;

import com.learnos.auth.model.Role;
import com.learnos.auth.model.User;
import com.learnos.auth.repository.UserRepository;
import com.learnos.content.dto.CourseProgressResponse;
import com.learnos.content.dto.LessonRequest;
import com.learnos.content.dto.LessonResponse;
import com.learnos.content.dto.ProgressRequest;
import com.learnos.content.dto.ProgressResponse;
import com.learnos.content.model.Lesson;
import com.learnos.content.model.LessonProgress;
import com.learnos.content.model.LessonType;
import com.learnos.content.repository.LessonProgressRepository;
import com.learnos.content.repository.LessonRepository;
import com.learnos.course.model.Course;
import com.learnos.course.model.CourseModule;
import com.learnos.course.model.EnrollmentStatus;
import com.learnos.course.repository.EnrollmentRepository;
import com.learnos.course.repository.ModuleRepository;
import com.learnos.storage.service.S3StorageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.Resource;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class LessonService {

    private static final int MEDIA_COMPLETION_PERCENT = 90;

    private final LessonRepository lessonRepository;
    private final LessonProgressRepository progressRepository;
    private final UserRepository userRepository;
    private final ModuleRepository moduleRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final S3StorageService storageService;

    @Transactional
    public LessonResponse addLesson(UUID moduleId, LessonRequest request) {
        CourseModule module = moduleRepository.findById(moduleId)
                .orElseThrow(() -> new RuntimeException("Module not found: " + moduleId));

        Lesson lesson = Lesson.builder()
                .module(module)
                .title(request.getTitle())
                .description(request.getDescription())
                .type(request.getType())
                .displayOrder(request.getDisplayOrder())
                .isPreview(request.isPreview())
                .isPublished(request.isPublished())
                .downloadable(request.isDownloadable())
                .durationSeconds(request.getDurationSeconds())
                .contentUrl(request.getContentUrl())
                .streamingUrl(request.getStreamingUrl())
                .thumbnailUrl(request.getThumbnailUrl())
                .textContent(request.getTextContent())
                .build();

        if (request.getType() == LessonType.TEXT) {
            lesson.setContentUrl(null);
            lesson.setStreamingUrl(null);
        }

        Lesson saved = lessonRepository.save(lesson);
        log.info("Lesson added: {} to module {}", saved.getTitle(), moduleId);
        return mapToResponse(saved);
    }

    @Transactional
    public LessonResponse updateLesson(UUID lessonId, LessonRequest request) {
        Lesson lesson = lessonRepository.findById(lessonId)
                .orElseThrow(() -> new RuntimeException("Lesson not found: " + lessonId));

        lesson.setTitle(request.getTitle());
        lesson.setDescription(request.getDescription());
        lesson.setType(request.getType());
        lesson.setDisplayOrder(request.getDisplayOrder());
        lesson.setPreview(request.isPreview());
        lesson.setPublished(request.isPublished());
        lesson.setDownloadable(request.isDownloadable());
        lesson.setDurationSeconds(request.getDurationSeconds());
        lesson.setStreamingUrl(request.getStreamingUrl());
        lesson.setThumbnailUrl(request.getThumbnailUrl());

        if (request.getType() == LessonType.TEXT) {
            lesson.setContentUrl(null);
            lesson.setStreamingUrl(null);
            lesson.setTextContent(request.getTextContent());
        } else {
            lesson.setTextContent(request.getTextContent());
            if (request.getContentUrl() != null) {
                lesson.setContentUrl(request.getContentUrl());
            }
        }

        Lesson saved = lessonRepository.save(lesson);
        log.info("Lesson updated: {}", saved.getId());
        return mapToResponse(saved);
    }

    @Transactional
    public LessonResponse uploadContent(UUID lessonId, MultipartFile file) throws IOException {
        Lesson lesson = lessonRepository.findById(lessonId)
                .orElseThrow(() -> new RuntimeException("Lesson not found: " + lessonId));

        String mimeType = file.getContentType();
        String folder = storageService.getFolder(mimeType);
        String url = storageService.uploadFile(file, folder);

        lesson.setContentUrl(url);
        lesson.setMimeType(mimeType);
        lesson.setOriginalFileName(file.getOriginalFilename());
        lesson.setFileSizeBytes(file.getSize());

        if (mimeType != null) {
            if (mimeType.startsWith("video/")) {
                lesson.setType(LessonType.VIDEO);
                lesson.setStreamingUrl(url);
            } else if (mimeType.startsWith("audio/")) {
                lesson.setType(LessonType.AUDIO);
            } else if ("application/pdf".equals(mimeType)) {
                lesson.setType(LessonType.PDF);
            } else if (mimeType.contains("presentation") || mimeType.contains("powerpoint")) {
                lesson.setType(LessonType.SLIDES);
            }
        }

        Lesson saved = lessonRepository.save(lesson);
        log.info("Content uploaded for lesson {}: {}", lessonId, url);
        return mapToResponse(saved);
    }

    @Transactional(readOnly = true)
    public List<LessonResponse> getLessonsByModule(UUID moduleId) {
        User currentUser = getCurrentUserOrNull();
        return lessonRepository.findByModuleIdOrderByDisplayOrderAsc(moduleId)
                .stream()
                .map(lesson -> mapToResponseForUser(lesson, currentUser))
                .toList();
    }

    @Transactional(readOnly = true)
    public LessonResponse getLessonById(UUID lessonId) {
        Lesson lesson = lessonRepository.findById(lessonId)
                .orElseThrow(() -> new RuntimeException("Lesson not found: " + lessonId));
        return mapToResponseForUser(lesson, getCurrentUserOrNull());
    }

    @Transactional(readOnly = true)
    public Lesson getAuthorizedLessonForAi(String userEmail, UUID lessonId) {
        User user = getUser(userEmail);

        Lesson lesson = lessonRepository.findById(lessonId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Lesson not found: " + lessonId
                ));

        try {
            assertLearnerCanAccessLesson(user, lesson);
        } catch (RuntimeException ex) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    ex.getMessage(),
                    ex
            );
        }

        if (!lesson.isPublished() && user.getRole() == Role.LEARNER) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "This lesson is not published."
            );
        }

        return lesson;
    }

    public record LessonDownload(Resource resource, String fileName, String contentType) {}

    @Transactional(readOnly = true)
    public LessonDownload getLessonDownload(String userEmail, UUID lessonId) {
        User user = getUser(userEmail);
        Lesson lesson = lessonRepository.findById(lessonId)
                .orElseThrow(() -> new RuntimeException("Lesson not found: " + lessonId));

        if (!lesson.isDownloadable()) {
            throw new RuntimeException("Downloads are not enabled for this lesson.");
        }

        String contentUrl = lesson.getContentUrl();
        if (lesson.getType() == LessonType.TEXT || contentUrl == null || contentUrl.isBlank()) {
            throw new RuntimeException("This lesson has no downloadable file.");
        }

        // Learners must be actively enrolled (preview access is not enough to download).
        if (user.getRole() == Role.LEARNER) {
            Course course = getCourseForLesson(lesson);
            boolean enrolled = course != null && enrollmentRepository
                    .findByUserIdAndCourseId(user.getId(), course.getId())
                    .map(enrollment -> enrollment.getStatus() == EnrollmentStatus.ACTIVE)
                    .orElse(false);
            if (!enrolled) {
                throw new RuntimeException("Enroll in this course to download this lesson.");
            }
        }

        Resource resource = storageService.loadAsResource(contentUrl);

        String fileName = lesson.getOriginalFileName();
        if (fileName == null || fileName.isBlank()) {
            int dot = contentUrl.lastIndexOf('.');
            String extension = dot > contentUrl.lastIndexOf('/') ? contentUrl.substring(dot) : "";
            String baseName = lesson.getTitle() == null ? "lesson" : lesson.getTitle().replaceAll("[^a-zA-Z0-9_-]+", "_");
            fileName = baseName + extension;
        }

        String contentType = lesson.getMimeType() == null || lesson.getMimeType().isBlank()
                ? "application/octet-stream"
                : lesson.getMimeType();

        return new LessonDownload(resource, fileName, contentType);
    }

    @Transactional
    public ProgressResponse updateProgress(String userEmail, ProgressRequest request) {
        User user = getUser(userEmail);
        Lesson lesson = lessonRepository.findById(request.getLessonId())
                .orElseThrow(() -> new RuntimeException("Lesson not found: " + request.getLessonId()));
        assertLearnerCanAccessLesson(user, lesson);

        LessonProgress progress = progressRepository.findByUserIdAndLessonId(user.getId(), lesson.getId())
                .orElseGet(() -> LessonProgress.builder().user(user).lesson(lesson).watchedSeconds(0).completed(false).build());

        int watchedSeconds = Math.max(progress.getWatchedSeconds(), request.getWatchedSeconds() == null ? 0 : request.getWatchedSeconds());
        progress.setWatchedSeconds(watchedSeconds);

        boolean shouldComplete = request.isCompleted() || shouldAutoCompleteMediaLesson(lesson, watchedSeconds);
        if (shouldComplete && !progress.isCompleted()) {
            progress.setCompleted(true);
            progress.setCompletedAt(LocalDateTime.now());
        }

        LessonProgress saved = progressRepository.save(progress);
        updateEnrollmentProgress(user, getCourseIdForLesson(lesson));
        return mapToProgressResponse(saved);
    }

    @Transactional
    public ProgressResponse markLessonCompleted(String userEmail, UUID lessonId) {
        User user = getUser(userEmail);
        Lesson lesson = lessonRepository.findById(lessonId)
                .orElseThrow(() -> new RuntimeException("Lesson not found: " + lessonId));
        assertLearnerCanAccessLesson(user, lesson);

        LessonProgress progress = progressRepository.findByUserIdAndLessonId(user.getId(), lessonId)
                .orElseGet(() -> LessonProgress.builder().user(user).lesson(lesson).watchedSeconds(0).completed(false).build());

        if (lesson.getDurationSeconds() != null) {
            progress.setWatchedSeconds(Math.max(progress.getWatchedSeconds(), lesson.getDurationSeconds()));
        }
        if (!progress.isCompleted()) {
            progress.setCompleted(true);
            progress.setCompletedAt(LocalDateTime.now());
        }

        LessonProgress saved = progressRepository.save(progress);
        updateEnrollmentProgress(user, getCourseIdForLesson(lesson));
        return mapToProgressResponse(saved);
    }

    @Transactional(readOnly = true)
    public List<ProgressResponse> getMyProgress(String userEmail) {
        User user = getUser(userEmail);
        return progressRepository.findDetailedByUserId(user.getId()).stream().map(this::mapToProgressResponse).toList();
    }

    @Transactional(readOnly = true)
    public CourseProgressResponse getCourseProgress(String userEmail, UUID courseId) {
        User user = getUser(userEmail);
        assertLearnerCanAccessCourse(user, courseId);

        int totalLessons = Math.toIntExact(progressRepository.countPublishedLessonsForCourse(courseId));
        int completedLessons = Math.toIntExact(progressRepository.countCompletedLessonsForCourse(user.getId(), courseId));
        int progressPercent = totalLessons == 0 ? 0 : (int) Math.round(completedLessons * 100.0 / totalLessons);
        boolean contentCompleted = totalLessons > 0 && completedLessons >= totalLessons;

        List<LessonProgress> progressRecords = progressRepository.findDetailedByUserIdAndCourseId(user.getId(), courseId);
        LessonProgress resumeProgress = findResumeProgress(progressRecords);

        return CourseProgressResponse.builder()
                .courseId(courseId)
                .totalLessons(totalLessons)
                .completedLessons(completedLessons)
                .progressPercent(progressPercent)
                .contentCompleted(contentCompleted)
                .assessmentUnlocked(contentCompleted)
                .resumeLessonId(resumeProgress == null ? null : resumeProgress.getLesson().getId())
                .resumePositionSeconds(resumeProgress == null ? 0 : resumeProgress.getWatchedSeconds())
                .lessons(progressRecords.stream().map(this::mapToProgressResponse).toList())
                .build();
    }

    @Transactional(readOnly = true)
    public CourseProgressResponse getAssessmentAccess(String userEmail, UUID courseId) {
        return getCourseProgress(userEmail, courseId);
    }

    @Transactional
    public void deleteLesson(UUID lessonId) {
        Lesson lesson = lessonRepository.findById(lessonId)
                .orElseThrow(() -> new RuntimeException("Lesson not found: " + lessonId));
        if (lesson.getContentUrl() != null) storageService.deleteFile(lesson.getContentUrl());
        lessonRepository.delete(lesson);
        log.info("Lesson deleted: {}", lessonId);
    }

    private void assertLearnerCanAccessLesson(User user, Lesson lesson) {
        if (user == null || lesson == null) throw new RuntimeException("Access denied.");
        if (user.getRole() != Role.LEARNER) return;

        Course course = getCourseForLesson(lesson);
        if (course == null) throw new RuntimeException("Access denied.");

        boolean enrolled = enrollmentRepository.findByUserIdAndCourseId(user.getId(), course.getId())
                .map(enrollment -> enrollment.getStatus() == EnrollmentStatus.ACTIVE)
                .orElse(false);

        if (!enrolled && !lesson.isPreview()) {
            throw new RuntimeException("Enroll in this course to access this lesson.");
        }
    }

    private void assertLearnerCanAccessCourse(User user, UUID courseId) {
        if (user == null || courseId == null) throw new RuntimeException("Access denied.");
        if (user.getRole() != Role.LEARNER) return;

        boolean enrolled = enrollmentRepository.findByUserIdAndCourseId(user.getId(), courseId)
                .map(enrollment -> enrollment.getStatus() == EnrollmentStatus.ACTIVE)
                .orElse(false);

        if (!enrolled) throw new RuntimeException("Enroll in this course to access learner progress.");
    }

    private boolean canViewFullLessonContent(Lesson lesson, User currentUser) {
        if (lesson == null) return false;
        if (currentUser == null) return lesson.isPreview();
        if (currentUser.getRole() != Role.LEARNER) return true;

        Course course = getCourseForLesson(lesson);
        if (course == null) return false;

        boolean enrolled = enrollmentRepository.findByUserIdAndCourseId(currentUser.getId(), course.getId())
                .map(enrollment -> enrollment.getStatus() == EnrollmentStatus.ACTIVE)
                .orElse(false);

        return enrolled || lesson.isPreview();
    }

    private Course getCourseForLesson(Lesson lesson) {
        if (lesson.getModule() == null || lesson.getModule().getCourse() == null) return null;
        return lesson.getModule().getCourse();
    }

    private void updateEnrollmentProgress(User user, UUID courseId) {
        if (courseId == null) return;

        enrollmentRepository.findByUserIdAndCourseId(user.getId(), courseId).ifPresent(enrollment -> {
            Double calculatedProgress = progressRepository.calculateCourseCompletionPercent(user.getId(), courseId);
            int progressPercent = calculatedProgress == null ? 0 : (int) Math.round(calculatedProgress);
            enrollment.setProgressPercent(Math.max(0, Math.min(100, progressPercent)));
            enrollmentRepository.save(enrollment);
        });
    }

    private UUID getCourseIdForLesson(Lesson lesson) {
        Course course = getCourseForLesson(lesson);
        return course != null ? course.getId() : null;
    }

    private User getUser(String userEmail) {
        return userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }

    private User getCurrentUserOrNull() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || authentication.getName() == null || authentication.getName().isBlank()) return null;
        return userRepository.findByEmail(authentication.getName()).orElse(null);
    }

    private boolean shouldAutoCompleteMediaLesson(Lesson lesson, int watchedSeconds) {
        if (lesson.getType() != LessonType.VIDEO && lesson.getType() != LessonType.AUDIO) return false;
        Integer durationSeconds = lesson.getDurationSeconds();
        if (durationSeconds == null || durationSeconds <= 0) return false;
        int watchedPercent = (int) Math.floor(watchedSeconds * 100.0 / durationSeconds);
        return watchedPercent >= MEDIA_COMPLETION_PERCENT;
    }

    private LessonProgress findResumeProgress(List<LessonProgress> progressRecords) {
        return progressRecords.stream()
                .filter(progress -> !progress.isCompleted())
                .max(Comparator.comparing(LessonProgress::getUpdatedAt, Comparator.nullsLast(Comparator.naturalOrder())))
                .orElseGet(() -> progressRecords.stream()
                        .max(Comparator.comparing(LessonProgress::getUpdatedAt, Comparator.nullsLast(Comparator.naturalOrder())))
                        .orElse(null));
    }

    private ProgressResponse mapToProgressResponse(LessonProgress progress) {
        Lesson lesson = progress.getLesson();
        return ProgressResponse.builder()
                .lessonId(lesson.getId())
                .moduleId(lesson.getModule().getId())
                .courseId(lesson.getModule().getCourse().getId())
                .completed(progress.isCompleted())
                .watchedSeconds(progress.getWatchedSeconds())
                .durationSeconds(lesson.getDurationSeconds())
                .progressPercent(calculateLessonProgressPercent(progress, lesson))
                .completedAt(progress.getCompletedAt())
                .lastAccessedAt(progress.getUpdatedAt())
                .build();
    }

    private int calculateLessonProgressPercent(LessonProgress progress, Lesson lesson) {
        if (progress.isCompleted()) return 100;
        Integer durationSeconds = lesson.getDurationSeconds();
        if (durationSeconds == null || durationSeconds <= 0) return progress.getWatchedSeconds() > 0 ? 1 : 0;
        return Math.min(100, (int) Math.floor(progress.getWatchedSeconds() * 100.0 / durationSeconds));
    }

    private LessonResponse mapToResponseForUser(Lesson lesson, User currentUser) {
        boolean fullAccess = canViewFullLessonContent(lesson, currentUser);

        return LessonResponse.builder()
                .id(lesson.getId())
                .title(lesson.getTitle())
                .description(lesson.getDescription())
                .type(lesson.getType())
                .contentUrl(fullAccess ? lesson.getContentUrl() : null)
                .streamingUrl(fullAccess ? lesson.getStreamingUrl() : null)
                .thumbnailUrl(lesson.getThumbnailUrl())
                .textContent(fullAccess ? lesson.getTextContent() : null)
                .mimeType(lesson.getMimeType())
                .originalFileName(fullAccess ? lesson.getOriginalFileName() : null)
                .fileSizeBytes(fullAccess ? lesson.getFileSizeBytes() : 0)
                .durationSeconds(fullAccess ? lesson.getDurationSeconds() : null)
                .order(lesson.getDisplayOrder())
                .isPreview(lesson.isPreview())
                .isPublished(lesson.isPublished())
                .downloadable(lesson.isDownloadable())
                .moduleId(lesson.getModule() != null ? lesson.getModule().getId() : null)
                .moduleTitle(lesson.getModule() != null ? lesson.getModule().getTitle() : null)
                .createdAt(lesson.getCreatedAt())
                .build();
    }

    private LessonResponse mapToResponse(Lesson lesson) {
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
                .downloadable(lesson.isDownloadable())
                .moduleId(lesson.getModule().getId())
                .moduleTitle(lesson.getModule().getTitle())
                .createdAt(lesson.getCreatedAt())
                .build();
    }
}
