package com.learnos.certificate.service;

import com.learnos.auth.model.Role;
import com.learnos.auth.model.User;
import com.learnos.auth.repository.UserRepository;
import com.learnos.certificate.dto.CertificateResponse;
import com.learnos.certificate.dto.CertificateVerifyResponse;
import com.learnos.certificate.model.Certificate;
import com.learnos.certificate.model.CertificateStatus;
import com.learnos.certificate.repository.CertificateRepository;
import com.learnos.company.entity.Company;
import com.learnos.content.repository.LessonProgressRepository;
import com.learnos.course.model.Course;
import com.learnos.course.model.Enrollment;
import com.learnos.course.model.EnrollmentStatus;
import com.learnos.course.repository.EnrollmentRepository;
import com.learnos.quiz.model.Quiz;
import com.learnos.quiz.model.QuizAttempt;
import com.learnos.quiz.model.QuizStatus;
import com.learnos.quiz.repository.QuizAttemptRepository;
import com.learnos.quiz.repository.QuizRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CertificateService {

    private final CertificateRepository certificateRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final LessonProgressRepository lessonProgressRepository;
    private final QuizRepository quizRepository;
    private final QuizAttemptRepository quizAttemptRepository;
    private final UserRepository userRepository;
    private final CertificatePdfService certificatePdfService;

    @Transactional
    public CertificateResponse issueIfEligible(User learner, Course course) {
        if (learner == null || course == null) {
            return null;
        }

        if (learner.getRole() != Role.LEARNER) {
            return null;
        }

        Certificate existing = certificateRepository
                .findByUser_IdAndCourse_Id(learner.getId(), course.getId())
                .orElse(null);

        if (existing != null) {
            return toResponse(existing);
        }

        Enrollment enrollment = enrollmentRepository
                .findByUserIdAndCourseId(learner.getId(), course.getId())
                .orElse(null);

        if (enrollment == null || enrollment.getStatus() != EnrollmentStatus.ACTIVE) {
            return null;
        }

        long totalLessons = lessonProgressRepository
                .countPublishedLessonsForCourse(course.getId());

        if (totalLessons == 0) {
            return null;
        }

        long completedLessons = lessonProgressRepository
                .countCompletedLessonsForCourse(learner.getId(), course.getId());

        if (completedLessons < totalLessons) {
            return null;
        }

        List<Quiz> publishedQuizzes = quizRepository
                .findByCourse_Id(course.getId())
                .stream()
                .filter(quiz -> quiz.getStatus() == QuizStatus.PUBLISHED)
                .toList();

        if (publishedQuizzes.isEmpty()) {
            return null;
        }

        QuizAttempt bestPassingAttempt = publishedQuizzes.stream()
                .flatMap(quiz -> quizAttemptRepository
                        .findByQuiz_IdAndUser_Id(quiz.getId(), learner.getId())
                        .stream())
                .filter(QuizAttempt::isPassed)
                .max((left, right) -> {
                    int scoreComparison = Integer.compare(
                            left.getScorePercent(),
                            right.getScorePercent()
                    );

                    if (scoreComparison != 0) {
                        return scoreComparison;
                    }

                    LocalDateTime leftTime = left.getSubmittedAt();
                    LocalDateTime rightTime = right.getSubmittedAt();

                    if (leftTime == null && rightTime == null) {
                        return 0;
                    }

                    if (leftTime == null) {
                        return -1;
                    }

                    if (rightTime == null) {
                        return 1;
                    }

                    return leftTime.compareTo(rightTime);
                })
                .orElse(null);

        if (bestPassingAttempt == null) {
            return null;
        }

        Company company = course.getCompany() != null
                ? course.getCompany()
                : learner.getCompany();

        Certificate certificate = Certificate.builder()
                .certificateNumber(generateCertificateNumber())
                .verificationCode(generateVerificationCode())
                .user(learner)
                .course(course)
                .company(company)
                .learnerName(learner.getFullName())
                .courseTitle(course.getTitle())
                .companyName(company != null ? company.getName() : null)
                .quizScorePercent(bestPassingAttempt.getScorePercent())
                .status(CertificateStatus.ISSUED)
                .build();

        Certificate saved = certificateRepository.save(certificate);

        return toResponse(saved);
    }

    @Transactional(readOnly = true)
    public List<CertificateResponse> getMyCertificates() {
        User currentUser = requireCurrentUser();

        return certificateRepository
                .findByUser_IdOrderByIssuedAtDesc(currentUser.getId())
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<CertificateResponse> getCertificatesForAdmin() {
        User currentUser = requireCurrentUser();

        List<Certificate> certificates;

        if (isSuperAdmin(currentUser)) {
            certificates = certificateRepository.findAll()
                    .stream()
                    .sorted((left, right) -> {
                        LocalDateTime leftDate = left.getIssuedAt();
                        LocalDateTime rightDate = right.getIssuedAt();

                        if (leftDate == null && rightDate == null) {
                            return 0;
                        }

                        if (leftDate == null) {
                            return 1;
                        }

                        if (rightDate == null) {
                            return -1;
                        }

                        return rightDate.compareTo(leftDate);
                    })
                    .toList();
        } else if (currentUser.getCompany() != null) {
            certificates = certificateRepository
                    .findByCompany_IdOrderByIssuedAtDesc(
                            currentUser.getCompany().getId()
                    );
        } else {
            certificates = List.of();
        }

        return certificates.stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<CertificateResponse> getCertificatesIssuedTodayForAdmin() {
        User currentUser = requireCurrentUser();

        LocalDateTime start = LocalDate.now().atStartOfDay();
        LocalDateTime end = LocalDate.now().atTime(LocalTime.MAX);

        List<Certificate> certificates = certificateRepository
                .findByIssuedAtBetweenOrderByIssuedAtDesc(start, end);

        if (isSuperAdmin(currentUser)) {
            return certificates.stream()
                    .map(this::toResponse)
                    .toList();
        }

        if (currentUser.getCompany() == null) {
            return List.of();
        }

        UUID companyId = currentUser.getCompany().getId();

        return certificates.stream()
                .filter(certificate ->
                        certificate.getCompany() != null
                                && companyId.equals(certificate.getCompany().getId())
                )
                .map(this::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public CertificateVerifyResponse verify(String verificationCode) {
        if (verificationCode == null || verificationCode.isBlank()) {
            return new CertificateVerifyResponse(
                    false,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    "A certificate verification code is required."
            );
        }

        Certificate certificate = certificateRepository
                .findByVerificationCode(
                        verificationCode.trim().toUpperCase(Locale.ROOT)
                )
                .orElse(null);

        if (certificate == null) {
            return new CertificateVerifyResponse(
                    false,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    "Certificate not found."
            );
        }

        boolean valid = certificate.getStatus() == CertificateStatus.ISSUED;

        return new CertificateVerifyResponse(
                valid,
                certificate.getCertificateNumber(),
                certificate.getLearnerName(),
                certificate.getCourseTitle(),
                certificate.getCompanyName(),
                certificate.getQuizScorePercent(),
                certificate.getStatus().name(),
                certificate.getIssuedAt(),
                valid
                        ? "Certificate is valid."
                        : "Certificate has been revoked."
        );
    }

    @Transactional(readOnly = true)
    public byte[] downloadCertificatePdf(UUID certificateId) {
        User currentUser = requireCurrentUser();

        Certificate certificate = certificateRepository
                .findById(certificateId)
                .orElseThrow(() -> new RuntimeException("Certificate not found."));

        assertCanDownload(currentUser, certificate);

        if (certificate.getStatus() != CertificateStatus.ISSUED) {
            throw new RuntimeException(
                    "A revoked certificate cannot be downloaded."
            );
        }

        return certificatePdfService.generate(certificate);
    }

    @Transactional(readOnly = true)
    public String getDownloadFileName(UUID certificateId) {
        Certificate certificate = certificateRepository
                .findById(certificateId)
                .orElseThrow(() -> new RuntimeException("Certificate not found."));

        return "LearnOS-"
                + sanitizeFilePart(certificate.getCourseTitle())
                + "-"
                + sanitizeFilePart(certificate.getLearnerName())
                + ".pdf";
    }

    @Transactional
    public CertificateResponse revoke(UUID certificateId, String reason) {
        User currentUser = requireCurrentUser();

        if (currentUser.getRole() == Role.LEARNER) {
            throw new RuntimeException("Learners cannot revoke certificates.");
        }

        Certificate certificate = certificateRepository
                .findById(certificateId)
                .orElseThrow(() -> new RuntimeException("Certificate not found."));

        if (!isSuperAdmin(currentUser)) {
            if (currentUser.getCompany() == null
                    || certificate.getCompany() == null
                    || !currentUser.getCompany().getId()
                    .equals(certificate.getCompany().getId())) {
                throw new RuntimeException("Access denied.");
            }
        }

        certificate.setStatus(CertificateStatus.REVOKED);
        certificate.setRevokedAt(LocalDateTime.now());
        certificate.setRevocationReason(
                reason != null && !reason.isBlank()
                        ? reason.trim()
                        : "Certificate revoked by an administrator."
        );

        return toResponse(certificateRepository.save(certificate));
    }

    private void assertCanDownload(
            User currentUser,
            Certificate certificate
    ) {
        if (currentUser.getRole() == Role.LEARNER) {
            if (certificate.getUser() == null
                    || !currentUser.getId()
                    .equals(certificate.getUser().getId())) {
                throw new RuntimeException("Access denied.");
            }

            return;
        }

        if (isSuperAdmin(currentUser)) {
            return;
        }

        if (currentUser.getCompany() == null
                || certificate.getCompany() == null
                || !currentUser.getCompany().getId()
                .equals(certificate.getCompany().getId())) {
            throw new RuntimeException("Access denied.");
        }
    }

    private CertificateResponse toResponse(Certificate certificate) {
        return new CertificateResponse(
                certificate.getId(),
                certificate.getCertificateNumber(),
                certificate.getVerificationCode(),
                certificate.getUser() != null ? certificate.getUser().getId() : null,
                certificate.getLearnerName(),
                certificate.getCourse() != null ? certificate.getCourse().getId() : null,
                certificate.getCourseTitle(),
                certificate.getCompany() != null ? certificate.getCompany().getId() : null,
                certificate.getCompanyName(),
                certificate.getQuizScorePercent(),
                certificate.getStatus().name(),
                certificate.getIssuedAt(),
                certificate.getRevokedAt(),
                certificate.getRevocationReason()
        );
    }

    private User requireCurrentUser() {
        Authentication authentication = SecurityContextHolder
                .getContext()
                .getAuthentication();

        if (authentication == null
                || authentication.getName() == null
                || authentication.getName().isBlank()) {
            throw new RuntimeException("Not authenticated.");
        }

        return userRepository
                .findByEmail(authentication.getName())
                .orElseThrow(() -> new RuntimeException("User not found."));
    }

    private boolean isSuperAdmin(User user) {
        return user != null
                && user.getEmail() != null
                && user.getEmail().equalsIgnoreCase("admin@blute.co.in");
    }

    private String generateCertificateNumber() {
        return "LEARNOS-"
                + LocalDate.now().getYear()
                + "-"
                + UUID.randomUUID()
                .toString()
                .substring(0, 8)
                .toUpperCase(Locale.ROOT);
    }

    private String generateVerificationCode() {
        return UUID.randomUUID()
                .toString()
                .replace("-", "")
                .substring(0, 16)
                .toUpperCase(Locale.ROOT);
    }

    private String sanitizeFilePart(String value) {
        String cleaned = value == null
                ? ""
                : value.trim()
                .replaceAll("[^a-zA-Z0-9]+", "-")
                .replaceAll("^-+|-+$", "");

        if (cleaned.isBlank()) {
            return "Certificate";
        }

        return cleaned;
    }
}