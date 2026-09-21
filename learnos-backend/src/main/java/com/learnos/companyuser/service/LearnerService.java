package com.learnos.companyuser.service;

import com.learnos.auth.model.Role;
import com.learnos.auth.model.User;
import com.learnos.auth.repository.UserRepository;
import com.learnos.certificate.model.CertificateStatus;
import com.learnos.certificate.repository.CertificateRepository;
import com.learnos.company.entity.Company;
import com.learnos.companyuser.dto.LearnerEnrollmentResponse;
import com.learnos.companyuser.dto.LearnerResponse;
import com.learnos.companyuser.entity.CompanyUser;
import com.learnos.companyuser.repository.CompanyUserRepository;
import com.learnos.content.repository.LessonProgressRepository;
import com.learnos.course.model.Enrollment;
import com.learnos.course.model.EnrollmentStatus;
import com.learnos.course.repository.EnrollmentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class LearnerService {

    private final CompanyUserRepository companyUserRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final LessonProgressRepository lessonProgressRepository;
    private final CertificateRepository certificateRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public List<LearnerResponse> getLearners() {
        User currentUser = getCurrentUser();

        List<CompanyUser> companyUsers;

        if (isSuperAdmin(currentUser)) {
            companyUsers = companyUserRepository.findAll();
        } else if (
                currentUser != null
                        && currentUser.getCompany() != null
        ) {
            companyUsers = companyUserRepository.findByCompany_Id(
                    currentUser.getCompany().getId()
            );
        } else {
            companyUsers = List.of();
        }

        return companyUsers.stream()
                .filter(this::isLearnerCompanyUser)
                .map(this::toLearnerResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<LearnerEnrollmentResponse> getLearnerEnrollments(
            UUID learnerId
    ) {
        User currentUser = requireCurrentUser();

        User learner = userRepository.findById(learnerId)
                .orElseThrow(
                        () -> new RuntimeException("Learner not found.")
                );

        if (learner.getRole() != Role.LEARNER) {
            throw new RuntimeException(
                    "The selected user is not a learner."
            );
        }

        assertCanAccessLearner(currentUser, learner);

        return enrollmentRepository.findByUserId(learnerId)
                .stream()
                .filter(
                        enrollment ->
                                enrollment.getCourse() != null
                )
                .map(this::toLearnerEnrollmentResponse)
                .toList();
    }

    private boolean isLearnerCompanyUser(
            CompanyUser companyUser
    ) {
        return companyUser.getRole() == null
                || Role.LEARNER.name()
                .equalsIgnoreCase(companyUser.getRole());
    }

    private LearnerResponse toLearnerResponse(
            CompanyUser companyUser
    ) {
        User user = companyUser.getUser();
        Company company = companyUser.getCompany();

        List<Enrollment> enrollments = user == null
                ? List.of()
                : enrollmentRepository.findByUserId(user.getId())
                .stream()
                .filter(
                        enrollment ->
                                enrollment.getCourse() != null
                )
                .toList();

        List<Integer> courseProgressValues = user == null
                ? List.of()
                : enrollments.stream()
                .map(
                        enrollment ->
                                getActualProgressPercent(
                                        user.getId(),
                                        enrollment
                                )
                )
                .toList();

        int coursesEnrolled = enrollments.size();

        int avgProgress = courseProgressValues.isEmpty()
                ? 0
                : (int) Math.round(
                courseProgressValues.stream()
                        .mapToInt(Integer::intValue)
                        .average()
                        .orElse(0)
        );

        LocalDateTime lastActive = user != null
                ? user.getLastLoginAt()
                : null;

        String status = calculateLearnerStatus(
                user,
                enrollments,
                courseProgressValues,
                coursesEnrolled,
                avgProgress,
                lastActive
        );

        return new LearnerResponse(
                companyUser.getId(),
                user != null ? user.getId() : null,
                user != null ? user.getFullName() : null,
                user != null ? user.getEmail() : null,
                user != null ? user.getPhone() : null,
                company != null ? company.getId() : null,
                company != null ? company.getName() : null,
                coursesEnrolled,
                avgProgress,
                lastActive,
                status
        );
    }

    private LearnerEnrollmentResponse toLearnerEnrollmentResponse(
            Enrollment enrollment
    ) {
        var course = enrollment.getCourse();

        UUID learnerId = enrollment.getUser() != null
                ? enrollment.getUser().getId()
                : null;

        int actualProgress = getActualProgressPercent(
                learnerId,
                enrollment
        );

        String displayStatus = getCourseDisplayStatus(
                enrollment,
                actualProgress
        );

        return new LearnerEnrollmentResponse(
                enrollment.getId(),
                learnerId,
                course.getId().toString(),
                course.getTitle(),
                course.getCategory() != null
                        ? course.getCategory().getName()
                        : null,
                displayStatus,
                actualProgress,
                enrollment.getEnrolledAt(),
                getEffectiveCompletedAt(
                        enrollment,
                        actualProgress
                )
        );
    }

    private int getActualProgressPercent(
            UUID userId,
            Enrollment enrollment
    ) {
        if (
                userId == null
                        || enrollment == null
                        || enrollment.getCourse() == null
                        || enrollment.getCourse().getId() == null
        ) {
            return 0;
        }

        Double calculatedProgress =
                lessonProgressRepository
                        .calculateCourseCompletionPercent(
                                userId,
                                enrollment.getCourse().getId()
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

    private String getCourseDisplayStatus(
            Enrollment enrollment,
            int actualProgress
    ) {
        if (enrollment == null) {
            return "In progress";
        }

        if (enrollment.getStatus() == EnrollmentStatus.CANCELLED) {
            return "Cancelled";
        }

        UUID learnerId = enrollment.getUser() != null
                ? enrollment.getUser().getId()
                : null;

        UUID courseId = enrollment.getCourse() != null
                ? enrollment.getCourse().getId()
                : null;

        if (hasIssuedCertificate(learnerId, courseId)) {
            return "Certified";
        }

        if (actualProgress >= 100) {
            return "Completed";
        }

        return "In progress";
    }

    private boolean hasIssuedCertificate(
            UUID learnerId,
            UUID courseId
    ) {
        if (learnerId == null || courseId == null) {
            return false;
        }

        return certificateRepository
                .findByUser_IdAndCourse_Id(learnerId, courseId)
                .map(
                        certificate ->
                                certificate.getStatus()
                                        == CertificateStatus.ISSUED
                )
                .orElse(false);
    }

    private LocalDateTime getEffectiveCompletedAt(
            Enrollment enrollment,
            int actualProgress
    ) {
        if (enrollment == null) {
            return null;
        }

        if (enrollment.getCompletedAt() != null) {
            return enrollment.getCompletedAt();
        }

        if (actualProgress >= 100) {
            return enrollment.getUpdatedAt();
        }

        return null;
    }

    private String calculateLearnerStatus(
            User user,
            List<Enrollment> enrollments,
            List<Integer> courseProgressValues,
            int coursesEnrolled,
            int avgProgress,
            LocalDateTime lastActive
    ) {
        if (user != null && !user.isActive()) {
            return "Inactive";
        }

        boolean allCoursesCompleted =
                !courseProgressValues.isEmpty()
                        && courseProgressValues.stream()
                        .allMatch(progress -> progress >= 100);

        boolean allCoursesCertified =
                allCoursesCompleted
                        && user != null
                        && enrollments.size()
                        == courseProgressValues.size()
                        && enrollments.stream()
                        .allMatch(
                                enrollment ->
                                        enrollment.getCourse() != null
                                                && hasIssuedCertificate(
                                                user.getId(),
                                                enrollment
                                                        .getCourse()
                                                        .getId()
                                        )
                        );

        if (allCoursesCertified) {
            return "Certified";
        }

        if (allCoursesCompleted) {
            return "Completed";
        }

        if (
                lastActive != null
                        && lastActive.isBefore(
                        LocalDateTime.now().minusDays(7)
                )
        ) {
            return "At risk";
        }

        if (
                coursesEnrolled > 0
                        && avgProgress < 30
                        && (
                        lastActive == null
                                || lastActive.isBefore(
                                LocalDateTime.now()
                                        .minusDays(3)
                        )
                )
        ) {
            return "At risk";
        }

        return "Active";
    }

    private void assertCanAccessLearner(
            User currentUser,
            User learner
    ) {
        if (isSuperAdmin(currentUser)) {
            return;
        }

        if (
                currentUser.getCompany() == null
                        || learner.getCompany() == null
                        || !currentUser.getCompany().getId().equals(
                        learner.getCompany().getId()
                )
        ) {
            throw new RuntimeException("Access denied.");
        }
    }

    private User requireCurrentUser() {
        User currentUser = getCurrentUser();

        if (currentUser == null) {
            throw new RuntimeException("Not authenticated.");
        }

        return currentUser;
    }

    private User getCurrentUser() {
        Authentication auth = SecurityContextHolder
                .getContext()
                .getAuthentication();

        if (
                auth == null
                        || auth.getName() == null
                        || auth.getName().isBlank()
        ) {
            return null;
        }

        return userRepository.findByEmail(auth.getName())
                .orElse(null);
    }

    private boolean isSuperAdmin(User user) {
        return user != null
                && user.getEmail() != null
                && user.getEmail()
                .equalsIgnoreCase("admin@blute.co.in");
    }
}