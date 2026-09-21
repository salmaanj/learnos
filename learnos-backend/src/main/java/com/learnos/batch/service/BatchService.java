package com.learnos.batch.service;

import com.learnos.auth.model.Role;
import com.learnos.auth.model.User;
import com.learnos.auth.repository.UserRepository;
import com.learnos.batch.dto.BatchMemberResponse;
import com.learnos.batch.dto.BatchRequest;
import com.learnos.batch.dto.BatchResponse;
import com.learnos.batch.model.Batch;
import com.learnos.batch.model.BatchDeliveryMode;
import com.learnos.batch.model.BatchMemberStatus;
import com.learnos.batch.model.BatchMembership;
import com.learnos.batch.model.BatchStatus;
import com.learnos.batch.repository.BatchMembershipRepository;
import com.learnos.batch.repository.BatchRepository;
import com.learnos.company.entity.Company;
import com.learnos.company.repository.CompanyRepository;
import com.learnos.course.model.Course;
import com.learnos.course.model.Enrollment;
import com.learnos.course.model.EnrollmentStatus;
import com.learnos.course.repository.CourseRepository;
import com.learnos.course.repository.EnrollmentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional
public class BatchService {

    private final BatchRepository batchRepository;
    private final BatchMembershipRepository batchMembershipRepository;
    private final CourseRepository courseRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final CompanyRepository companyRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public List<BatchResponse> getBatches() {
        User currentUser = requireCurrentUser();

        List<Batch> batches;

        if (isSuperAdmin(currentUser)) {
            batches = batchRepository.findAll()
                    .stream()
                    .sorted(
                            Comparator.comparing(
                                    Batch::getCreatedAt,
                                    Comparator.nullsLast(
                                            Comparator.reverseOrder()
                                    )
                            )
                    )
                    .toList();
        } else if (currentUser.getCompany() != null) {
            batches = batchRepository.findByCompany_IdOrderByCreatedAtDesc(
                    currentUser.getCompany().getId()
            );
        } else {
            batches = List.of();
        }

        return batches.stream()
                .map(this::toBatchResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public BatchResponse getBatch(UUID batchId) {
        Batch batch = findBatchOrThrow(batchId);

        assertCanAccessBatch(
                requireCurrentUser(),
                batch
        );

        return toBatchResponse(batch);
    }

    public BatchResponse createBatch(BatchRequest request) {
        User currentUser = requireCurrentUser();

        validateBatchRequest(request);

        Company company = resolveCompanyForWrite(
                currentUser,
                request.companyId()
        );

        Course course = courseRepository.findById(request.courseId())
                .orElseThrow(
                        () -> new RuntimeException("Course not found.")
                );

        assertCourseBelongsToCompany(course, company);

        String code = normalizedCode(request.code());

        if (batchRepository.existsByCompany_IdAndCodeIgnoreCase(
                company.getId(),
                code
        )) {
            throw new RuntimeException(
                    "A batch with this code already exists for this company."
            );
        }

        User instructor = resolveInstructor(
                request.instructorId(),
                company
        );

        LocalDate startDate = request.startDate();
        LocalDate endDate = request.endDate();

        validateDates(startDate, endDate);

        Batch batch = Batch.builder()
                .name(request.name().trim())
                .code(code)
                .description(blankToNull(request.description()))
                .course(course)
                .company(company)
                .instructor(instructor)
                .deliveryMode(
                        request.deliveryMode() != null
                                ? request.deliveryMode()
                                : BatchDeliveryMode.SELF_PACED
                )
                .status(
                        request.status() != null
                                ? request.status()
                                : BatchStatus.DRAFT
                )
                .startDate(startDate)
                .endDate(endDate)
                .maxLearners(
                        request.maxLearners() != null
                                ? request.maxLearners()
                                : 100
                )
                .build();

        return toBatchResponse(
                batchRepository.save(batch)
        );
    }

    public BatchResponse updateBatch(
            UUID batchId,
            BatchRequest request
    ) {
        User currentUser = requireCurrentUser();

        validateBatchRequest(request);

        Batch batch = findBatchOrThrow(batchId);

        assertCanAccessBatch(currentUser, batch);

        Company company = isSuperAdmin(currentUser)
                ? resolveCompanyForWrite(
                currentUser,
                request.companyId()
        )
                : batch.getCompany();

        if (company == null) {
            throw new RuntimeException(
                    "A company is required for this batch."
            );
        }

        Course course = courseRepository.findById(request.courseId())
                .orElseThrow(
                        () -> new RuntimeException("Course not found.")
                );

        assertCourseBelongsToCompany(course, company);

        long currentMemberCount = batchMembershipRepository
                .countByBatch_IdAndStatus(
                        batchId,
                        BatchMemberStatus.ACTIVE
                );

        if (
                batch.getCourse() != null
                        && !batch.getCourse().getId().equals(course.getId())
                        && currentMemberCount > 0
        ) {
            throw new RuntimeException(
                    "The course cannot be changed after learners have been added. "
                            + "Create a new batch instead."
            );
        }

        String code = normalizedCode(request.code());

        if (batchRepository.existsByCompany_IdAndCodeIgnoreCaseAndIdNot(
                company.getId(),
                code,
                batchId
        )) {
            throw new RuntimeException(
                    "A batch with this code already exists for this company."
            );
        }

        User instructor = resolveInstructor(
                request.instructorId(),
                company
        );

        LocalDate startDate = request.startDate();
        LocalDate endDate = request.endDate();

        validateDates(startDate, endDate);

        batch.setName(request.name().trim());
        batch.setCode(code);
        batch.setDescription(blankToNull(request.description()));
        batch.setCompany(company);
        batch.setCourse(course);
        batch.setInstructor(instructor);
        batch.setDeliveryMode(
                request.deliveryMode() != null
                        ? request.deliveryMode()
                        : BatchDeliveryMode.SELF_PACED
        );
        batch.setStatus(
                request.status() != null
                        ? request.status()
                        : BatchStatus.DRAFT
        );
        batch.setStartDate(startDate);
        batch.setEndDate(endDate);
        batch.setMaxLearners(
                request.maxLearners() != null
                        ? request.maxLearners()
                        : 100
        );

        return toBatchResponse(
                batchRepository.save(batch)
        );
    }

    public BatchResponse archiveBatch(UUID batchId) {
        Batch batch = findBatchOrThrow(batchId);

        assertCanAccessBatch(
                requireCurrentUser(),
                batch
        );

        batch.setStatus(BatchStatus.ARCHIVED);

        return toBatchResponse(
                batchRepository.save(batch)
        );
    }

    @Transactional(readOnly = true)
    public List<BatchMemberResponse> getBatchMembers(UUID batchId) {
        Batch batch = findBatchOrThrow(batchId);

        assertCanAccessBatch(
                requireCurrentUser(),
                batch
        );

        return batchMembershipRepository
                .findByBatch_IdOrderByJoinedAtAsc(batchId)
                .stream()
                .filter(
                        membership ->
                                membership.getStatus()
                                        != BatchMemberStatus.REMOVED
                )
                .map(
                        membership -> toMemberResponse(
                                membership,
                                batch.getCourse()
                        )
                )
                .toList();
    }

    public BatchMemberResponse addMember(
            UUID batchId,
            UUID learnerId
    ) {
        Batch batch = findBatchOrThrow(batchId);

        assertCanAccessBatch(
                requireCurrentUser(),
                batch
        );

        if (batch.getStatus() == BatchStatus.ARCHIVED) {
            throw new RuntimeException(
                    "Archived batches cannot receive new learners."
            );
        }

        long activeMemberCount = batchMembershipRepository
                .countByBatch_IdAndStatus(
                        batchId,
                        BatchMemberStatus.ACTIVE
                );

        User learner = userRepository.findById(learnerId)
                .orElseThrow(
                        () -> new RuntimeException("Learner not found.")
                );

        if (learner.getRole() != Role.LEARNER) {
            throw new RuntimeException(
                    "Only learner accounts can be added to a batch."
            );
        }

        assertLearnerBelongsToBatchCompany(
                learner,
                batch
        );

        Course course = batch.getCourse();

        if (course == null) {
            throw new RuntimeException(
                    "This batch does not have a course assigned."
            );
        }

        Enrollment enrollment = enrollmentRepository
                .findByUserIdAndCourseId(
                        learner.getId(),
                        course.getId()
                )
                .orElseThrow(
                        () -> new RuntimeException(
                                "This learner is not enrolled in the selected course. "
                                        + "Enroll the learner in the course before "
                                        + "adding them to this batch."
                        )
                );

        if (enrollment.getStatus() != EnrollmentStatus.ACTIVE) {
            throw new RuntimeException(
                    "This learner's enrollment in the selected course is not active."
            );
        }

        BatchMembership membership = batchMembershipRepository
                .findByBatch_IdAndUser_Id(
                        batchId,
                        learnerId
                )
                .orElse(null);

        if (membership != null) {
            if (membership.getStatus() != BatchMemberStatus.REMOVED) {
                throw new RuntimeException(
                        "This learner is already assigned to the batch."
                );
            }

            if (
                    batch.getMaxLearners() != null
                            && activeMemberCount >= batch.getMaxLearners()
            ) {
                throw new RuntimeException(
                        "This batch has reached its maximum learner capacity."
                );
            }

            membership.setStatus(BatchMemberStatus.ACTIVE);
            membership.setJoinedAt(LocalDateTime.now());
            membership.setCompletedAt(null);

            BatchMembership reactivated =
                    batchMembershipRepository.save(membership);

            return toMemberResponse(reactivated, course);
        }

        if (
                batch.getMaxLearners() != null
                        && activeMemberCount >= batch.getMaxLearners()
        ) {
            throw new RuntimeException(
                    "This batch has reached its maximum learner capacity."
            );
        }

        BatchMembership newMembership = BatchMembership.builder()
                .batch(batch)
                .user(learner)
                .status(BatchMemberStatus.ACTIVE)
                .joinedAt(LocalDateTime.now())
                .build();

        BatchMembership saved =
                batchMembershipRepository.save(newMembership);

        return toMemberResponse(saved, course);
    }

    public void removeMember(
            UUID batchId,
            UUID learnerId
    ) {
        Batch batch = findBatchOrThrow(batchId);

        assertCanAccessBatch(
                requireCurrentUser(),
                batch
        );

        BatchMembership membership = batchMembershipRepository
                .findByBatch_IdAndUser_Id(
                        batchId,
                        learnerId
                )
                .orElseThrow(
                        () -> new RuntimeException(
                                "The learner is not in this batch."
                        )
                );

        membership.setStatus(BatchMemberStatus.REMOVED);
        membership.setCompletedAt(null);

        batchMembershipRepository.save(membership);

        // The course enrollment remains active.
        // Removing a learner from a batch does not remove course access.
    }

    private Batch findBatchOrThrow(UUID batchId) {
        return batchRepository.findById(batchId)
                .orElseThrow(
                        () -> new RuntimeException("Batch not found.")
                );
    }

    private void validateBatchRequest(BatchRequest request) {
        if (request == null) {
            throw new RuntimeException(
                    "Batch details are required."
            );
        }

        if (
                request.name() == null
                        || request.name().isBlank()
        ) {
            throw new RuntimeException(
                    "Batch name is required."
            );
        }

        if (
                request.code() == null
                        || request.code().isBlank()
        ) {
            throw new RuntimeException(
                    "Batch code is required."
            );
        }

        if (request.courseId() == null) {
            throw new RuntimeException(
                    "A course is required."
            );
        }

        if (
                request.maxLearners() != null
                        && request.maxLearners() < 1
        ) {
            throw new RuntimeException(
                    "Maximum learners must be at least 1."
            );
        }
    }

    private void validateDates(
            LocalDate startDate,
            LocalDate endDate
    ) {
        if (
                startDate != null
                        && endDate != null
                        && endDate.isBefore(startDate)
        ) {
            throw new RuntimeException(
                    "The end date cannot be before the start date."
            );
        }
    }

    private Company resolveCompanyForWrite(
            User currentUser,
            UUID requestedCompanyId
    ) {
        if (!isSuperAdmin(currentUser)) {
            if (currentUser.getCompany() == null) {
                throw new RuntimeException(
                        "Your account is not associated with a company."
                );
            }

            return currentUser.getCompany();
        }

        if (requestedCompanyId == null) {
            throw new RuntimeException(
                    "Company is required when creating a batch as super admin."
            );
        }

        return companyRepository.findById(requestedCompanyId)
                .orElseThrow(
                        () -> new RuntimeException("Company not found.")
                );
    }

    private User resolveInstructor(
            UUID instructorId,
            Company company
    ) {
        if (instructorId == null) {
            return null;
        }

        User instructor = userRepository.findById(instructorId)
                .orElseThrow(
                        () -> new RuntimeException("Instructor not found.")
                );

        if (
                instructor.getCompany() == null
                        || company == null
                        || !company.getId().equals(
                        instructor.getCompany().getId()
                )
        ) {
            throw new RuntimeException(
                    "The instructor must belong to the batch company."
            );
        }

        if (
                instructor.getRole() != Role.TUTOR
                        && instructor.getRole() != Role.USER
                        && instructor.getRole() != Role.ADMIN
        ) {
            throw new RuntimeException(
                    "Select a Tutor, User, or Admin account as the instructor."
            );
        }

        return instructor;
    }

    private void assertCourseBelongsToCompany(
            Course course,
            Company company
    ) {
        if (
                course.getCompany() == null
                        || company == null
                        || !company.getId().equals(
                        course.getCompany().getId()
                )
        ) {
            throw new RuntimeException(
                    "The selected course must belong to the batch company."
            );
        }
    }

    private void assertLearnerBelongsToBatchCompany(
            User learner,
            Batch batch
    ) {
        if (
                learner.getCompany() == null
                        || batch.getCompany() == null
                        || !batch.getCompany().getId().equals(
                        learner.getCompany().getId()
                )
        ) {
            throw new RuntimeException(
                    "The learner must belong to the batch company."
            );
        }
    }

    private void assertCanAccessBatch(
            User currentUser,
            Batch batch
    ) {
        if (isSuperAdmin(currentUser)) {
            return;
        }

        if (
                currentUser == null
                        || currentUser.getCompany() == null
                        || batch.getCompany() == null
                        || !currentUser.getCompany().getId().equals(
                        batch.getCompany().getId()
                )
        ) {
            throw new RuntimeException("Access denied.");
        }
    }

    private BatchResponse toBatchResponse(Batch batch) {
        long learnerCount = batchMembershipRepository
                .countByBatch_IdAndStatus(
                        batch.getId(),
                        BatchMemberStatus.ACTIVE
                );

        Double averageProgress = batchMembershipRepository
                .findAverageCourseProgressForBatch(
                        batch.getId(),
                        BatchMemberStatus.ACTIVE,
                        EnrollmentStatus.ACTIVE
                );

        int averageProgressPercent = averageProgress == null
                ? 0
                : (int) Math.round(averageProgress);

        long completedLearnerCount = batchMembershipRepository
                .countCompletedMembersForBatch(
                        batch.getId(),
                        BatchMemberStatus.ACTIVE,
                        EnrollmentStatus.ACTIVE
                );

        return new BatchResponse(
                batch.getId(),
                batch.getName(),
                batch.getCode(),
                batch.getDescription(),
                batch.getCourse() != null
                        ? batch.getCourse().getId()
                        : null,
                batch.getCourse() != null
                        ? batch.getCourse().getTitle()
                        : null,
                batch.getCompany() != null
                        ? batch.getCompany().getId()
                        : null,
                batch.getCompany() != null
                        ? batch.getCompany().getName()
                        : null,
                batch.getInstructor() != null
                        ? batch.getInstructor().getId()
                        : null,
                batch.getInstructor() != null
                        ? batch.getInstructor().getFullName()
                        : null,
                batch.getDeliveryMode(),
                batch.getStatus(),
                batch.getStartDate(),
                batch.getEndDate(),
                batch.getMaxLearners(),
                learnerCount,
                averageProgressPercent,
                completedLearnerCount,
                batch.getCreatedAt(),
                batch.getUpdatedAt()
        );
    }

    private BatchMemberResponse toMemberResponse(
            BatchMembership membership,
            Course course
    ) {
        User learner = membership.getUser();

        Enrollment enrollment = learner != null && course != null
                ? enrollmentRepository.findByUserIdAndCourseId(
                learner.getId(),
                course.getId()
        ).orElse(null)
                : null;

        return new BatchMemberResponse(
                membership.getId(),
                learner != null ? learner.getId() : null,
                learner != null
                        ? learner.getFullName()
                        : "Learner",
                learner != null
                        ? learner.getEmail()
                        : "",
                learner != null && learner.getCompany() != null
                        ? learner.getCompany().getName()
                        : null,
                membership.getStatus(),
                enrollment != null
                        ? enrollment.getProgressPercent()
                        : 0,
                membership.getJoinedAt(),
                membership.getCompletedAt()
        );
    }

    private User requireCurrentUser() {
        Authentication authentication = SecurityContextHolder
                .getContext()
                .getAuthentication();

        if (
                authentication == null
                        || authentication.getName() == null
                        || authentication.getName().isBlank()
        ) {
            throw new RuntimeException("Not authenticated.");
        }

        return userRepository.findByEmail(authentication.getName())
                .orElseThrow(
                        () -> new RuntimeException("User not found.")
                );
    }

    private boolean isSuperAdmin(User user) {
        return user != null
                && user.getEmail() != null
                && user.getEmail().equalsIgnoreCase(
                "admin@blute.co.in"
        );
    }

    private String normalizedCode(String value) {
        String code = value == null
                ? ""
                : value.trim().toUpperCase();

        if (code.isBlank()) {
            throw new RuntimeException(
                    "Batch code is required."
            );
        }

        return code;
    }

    private String blankToNull(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }

        return value.trim();
    }
}