package com.learnos.liveclass.service;

import com.learnos.auth.model.Role;
import com.learnos.auth.model.User;
import com.learnos.auth.repository.UserRepository;
import com.learnos.company.entity.Company;
import com.learnos.company.repository.CompanyRepository;
import com.learnos.course.model.Course;
import com.learnos.course.repository.CourseRepository;
import com.learnos.liveclass.dto.LiveClassRequest;
import com.learnos.liveclass.dto.LiveClassResponse;
import com.learnos.liveclass.model.LiveClass;
import com.learnos.liveclass.model.LiveClassStatus;
import com.learnos.liveclass.repository.LiveClassRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional
public class LiveClassService {

    private final LiveClassRepository liveClassRepository;
    private final CompanyRepository companyRepository;
    private final CourseRepository courseRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public Page<LiveClassResponse> getLiveClasses(
            String query,
            LiveClassStatus status,
            Pageable pageable,
            String username
    ) {
        User currentUser =
                requireCurrentUser(username);

        String normalizedQuery =
                blankToNull(query);

        Page<LiveClass> liveClasses;

        if (isSuperAdmin(currentUser)) {
            liveClasses =
                    findForSuperAdmin(
                            normalizedQuery,
                            status,
                            pageable
                    );
        } else if (isTutor(currentUser)) {
            liveClasses =
                    findForTutor(
                            currentUser.getId(),
                            normalizedQuery,
                            status,
                            pageable
                    );
        } else {
            Company company =
                    requireCompany(currentUser);

            liveClasses =
                    findForCompany(
                            company.getId(),
                            normalizedQuery,
                            status,
                            pageable
                    );
        }

        return liveClasses.map(
                this::mapToResponse
        );
    }

    @Transactional(readOnly = true)
    public LiveClassResponse getLiveClass(
            UUID id,
            String username
    ) {
        User currentUser =
                requireCurrentUser(username);

        LiveClass liveClass =
                getLiveClassOrThrow(id);

        assertCanAccessLiveClass(
                currentUser,
                liveClass
        );

        return mapToResponse(liveClass);
    }

    public LiveClassResponse createLiveClass(
            LiveClassRequest request,
            String username
    ) {
        User currentUser =
                requireCurrentUser(username);

        assertCanManageLiveClasses(
                currentUser
        );

        Company company =
                resolveCompanyForCreate(
                        currentUser,
                        request.companyId()
                );

        Course course =
                resolveCourse(
                        request.courseId(),
                        company
                );

        User instructor =
                resolveInstructor(
                        request.instructorId(),
                        company
                );

        validateRequest(request);

        LiveClass liveClass =
                LiveClass.builder()
                        .company(company)
                        .course(course)
                        .instructor(instructor)
                        .title(
                                request.title()
                                        .trim()
                        )
                        .description(
                                blankToNull(
                                        request.description()
                                )
                        )
                        .startAt(
                                request.startAt()
                        )
                        .endAt(
                                request.endAt()
                        )
                        .timezone(
                                request.timezone()
                                        .trim()
                        )
                        .provider(
                                request.provider()
                        )
                        .meetingUrl(
                                request.meetingUrl()
                                        .trim()
                        )
                        .meetingPassword(
                                blankToNull(
                                        request.meetingPassword()
                                )
                        )
                        .capacity(
                                request.capacity()
                        )
                        .thumbnailUrl(
                                blankToNull(
                                        request.thumbnailUrl()
                                )
                        )
                        .recordingUrl(
                                blankToNull(
                                        request.recordingUrl()
                                )
                        )
                        .status(
                                request.status() != null
                                        ? request.status()
                                        : LiveClassStatus.DRAFT
                        )
                        .createdBy(currentUser)
                        .build();

        return mapToResponse(
                liveClassRepository.save(
                        liveClass
                )
        );
    }

    public LiveClassResponse updateLiveClass(
            UUID id,
            LiveClassRequest request,
            String username
    ) {
        User currentUser =
                requireCurrentUser(username);

        assertCanManageLiveClasses(
                currentUser
        );

        LiveClass liveClass =
                getLiveClassOrThrow(id);

        assertCanAccessLiveClass(
                currentUser,
                liveClass
        );

        Company company =
                resolveCompanyForUpdate(
                        currentUser,
                        request.companyId(),
                        liveClass.getCompany()
                );

        Course course =
                resolveCourse(
                        request.courseId(),
                        company
                );

        User instructor =
                resolveInstructor(
                        request.instructorId(),
                        company
                );

        validateRequest(request);

        liveClass.setCompany(company);
        liveClass.setCourse(course);
        liveClass.setInstructor(instructor);
        liveClass.setTitle(
                request.title().trim()
        );
        liveClass.setDescription(
                blankToNull(
                        request.description()
                )
        );
        liveClass.setStartAt(
                request.startAt()
        );
        liveClass.setEndAt(
                request.endAt()
        );
        liveClass.setTimezone(
                request.timezone().trim()
        );
        liveClass.setProvider(
                request.provider()
        );
        liveClass.setMeetingUrl(
                request.meetingUrl().trim()
        );
        liveClass.setMeetingPassword(
                blankToNull(
                        request.meetingPassword()
                )
        );
        liveClass.setCapacity(
                request.capacity()
        );
        liveClass.setThumbnailUrl(
                blankToNull(
                        request.thumbnailUrl()
                )
        );
        liveClass.setRecordingUrl(
                blankToNull(
                        request.recordingUrl()
                )
        );
        liveClass.setStatus(
                request.status() != null
                        ? request.status()
                        : liveClass.getStatus()
        );

        return mapToResponse(
                liveClassRepository.save(
                        liveClass
                )
        );
    }

    public LiveClassResponse updateStatus(
            UUID id,
            LiveClassStatus status,
            String username
    ) {
        if (status == null) {
            throw new RuntimeException(
                    "Status is required"
            );
        }

        User currentUser =
                requireCurrentUser(username);

        assertCanManageLiveClasses(
                currentUser
        );

        LiveClass liveClass =
                getLiveClassOrThrow(id);

        assertCanAccessLiveClass(
                currentUser,
                liveClass
        );

        liveClass.setStatus(status);

        return mapToResponse(
                liveClassRepository.save(
                        liveClass
                )
        );
    }

    private void assertCanManageLiveClasses(
            User currentUser
    ) {
        if (isSuperAdmin(currentUser)) {
            return;
        }

        if (
                currentUser.getRole() != Role.ADMIN
                        && currentUser.getRole() != Role.USER
                        && currentUser.getRole() != Role.TUTOR
        ) {
            throw new RuntimeException(
                    "Only an admin, user, or tutor can manage live classes"
            );
        }

        if (
                !isTutor(currentUser)
                        && currentUser.getCompany() == null
        ) {
            throw new RuntimeException(
                    "Your user account is not assigned to a company"
            );
        }
    }

    private Page<LiveClass> findForSuperAdmin(
            String query,
            LiveClassStatus status,
            Pageable pageable
    ) {
        if (
                query != null
                        && status != null
        ) {
            return liveClassRepository
                    .findByStatusAndTitleContainingIgnoreCase(
                            status,
                            query,
                            pageable
                    );
        }

        if (query != null) {
            return liveClassRepository
                    .findByTitleContainingIgnoreCase(
                            query,
                            pageable
                    );
        }

        if (status != null) {
            return liveClassRepository
                    .findByStatus(
                            status,
                            pageable
                    );
        }

        return liveClassRepository.findAll(
                pageable
        );
    }

    private Page<LiveClass> findForTutor(
            UUID tutorId,
            String query,
            LiveClassStatus status,
            Pageable pageable
    ) {
        if (
                query != null
                        && status != null
        ) {
            return liveClassRepository
                    .findByInstructor_IdAndStatusAndTitleContainingIgnoreCase(
                            tutorId,
                            status,
                            query,
                            pageable
                    );
        }

        if (query != null) {
            return liveClassRepository
                    .findByInstructor_IdAndTitleContainingIgnoreCase(
                            tutorId,
                            query,
                            pageable
                    );
        }

        if (status != null) {
            return liveClassRepository
                    .findByInstructor_IdAndStatus(
                            tutorId,
                            status,
                            pageable
                    );
        }

        return liveClassRepository
                .findByInstructor_Id(
                        tutorId,
                        pageable
                );
    }

    private Page<LiveClass> findForCompany(
            UUID companyId,
            String query,
            LiveClassStatus status,
            Pageable pageable
    ) {
        if (
                query != null
                        && status != null
        ) {
            return liveClassRepository
                    .findByCompany_IdAndStatusAndTitleContainingIgnoreCase(
                            companyId,
                            status,
                            query,
                            pageable
                    );
        }

        if (query != null) {
            return liveClassRepository
                    .findByCompany_IdAndTitleContainingIgnoreCase(
                            companyId,
                            query,
                            pageable
                    );
        }

        if (status != null) {
            return liveClassRepository
                    .findByCompany_IdAndStatus(
                            companyId,
                            status,
                            pageable
                    );
        }

        return liveClassRepository.findByCompany_Id(
                companyId,
                pageable
        );
    }

    private LiveClass getLiveClassOrThrow(
            UUID id
    ) {
        return liveClassRepository
                .findById(id)
                .orElseThrow(() ->
                        new RuntimeException(
                                "Live class not found"
                        )
                );
    }

    private Company resolveCompanyForCreate(
            User currentUser,
            UUID requestedCompanyId
    ) {
        if (!isSuperAdmin(currentUser)) {
            return requireCompany(currentUser);
        }

        if (requestedCompanyId == null) {
            throw new RuntimeException(
                    "Company is required for live classes"
            );
        }

        return companyRepository
                .findById(requestedCompanyId)
                .orElseThrow(() ->
                        new RuntimeException(
                                "Company not found"
                        )
                );
    }

    private Company resolveCompanyForUpdate(
            User currentUser,
            UUID requestedCompanyId,
            Company existingCompany
    ) {
        if (!isSuperAdmin(currentUser)) {
            return requireCompany(currentUser);
        }

        if (requestedCompanyId == null) {
            return existingCompany;
        }

        return companyRepository
                .findById(requestedCompanyId)
                .orElseThrow(() ->
                        new RuntimeException(
                                "Company not found"
                        )
                );
    }

    private Course resolveCourse(
            UUID courseId,
            Company company
    ) {
        if (courseId == null) {
            return null;
        }

        Course course =
                courseRepository
                        .findById(courseId)
                        .orElseThrow(() ->
                                new RuntimeException(
                                        "Course not found"
                                )
                        );

        if (
                course.getCompany() == null
                        || company == null
                        || !course.getCompany()
                        .getId()
                        .equals(company.getId())
        ) {
            throw new RuntimeException(
                    "The selected course does not belong to this company"
            );
        }

        return course;
    }

    private User resolveInstructor(
            UUID instructorId,
            Company company
    ) {
        if (instructorId == null) {
            return null;
        }

        User instructor =
                userRepository
                        .findById(instructorId)
                        .orElseThrow(() ->
                                new RuntimeException(
                                        "Instructor not found"
                                )
                        );

        if (
                instructor.getCompany() == null
                        || company == null
                        || !instructor
                        .getCompany()
                        .getId()
                        .equals(company.getId())
        ) {
            throw new RuntimeException(
                    "The selected instructor does not belong to this company"
            );
        }

        return instructor;
    }

    private void validateRequest(
            LiveClassRequest request
    ) {
        if (
                request.startAt() == null
                        || request.endAt() == null
                        || !request.endAt()
                        .isAfter(
                                request.startAt()
                        )
        ) {
            throw new RuntimeException(
                    "End date and time must be after start date and time"
            );
        }

        if (
                request.capacity() != null
                        && request.capacity() < 1
        ) {
            throw new RuntimeException(
                    "Capacity must be at least 1"
            );
        }

        if (
                !isHttpUrl(
                        request.meetingUrl()
                )
        ) {
            throw new RuntimeException(
                    "Meeting URL must start with http:// or https://"
            );
        }
    }

    private void assertCanAccessLiveClass(
            User currentUser,
            LiveClass liveClass
    ) {
        if (isSuperAdmin(currentUser)) {
            return;
        }

        if (isTutor(currentUser)) {
            if (
                    liveClass.getInstructor() == null
                            || currentUser.getId() == null
                            || !currentUser.getId()
                            .equals(
                                    liveClass
                                            .getInstructor()
                                            .getId()
                            )
            ) {
                throw new RuntimeException(
                        "Tutors can only access their assigned live classes"
                );
            }

            return;
        }

        if (
                currentUser.getCompany() == null
                        || liveClass.getCompany() == null
                        || !currentUser
                        .getCompany()
                        .getId()
                        .equals(
                                liveClass
                                        .getCompany()
                                        .getId()
                        )
        ) {
            throw new RuntimeException(
                    "Access denied"
            );
        }
    }

    private User requireCurrentUser(
            String username
    ) {
        User currentUser =
                getCurrentUser(username);

        if (currentUser == null) {
            throw new RuntimeException(
                    "User not found"
            );
        }

        return currentUser;
    }

    private Company requireCompany(
            User currentUser
    ) {
        if (
                currentUser.getCompany() == null
        ) {
            throw new RuntimeException(
                    "Your user account is not assigned to a company"
            );
        }

        return currentUser.getCompany();
    }

    private User getCurrentUser(
            String username
    ) {
        String email = username;

        if (
                email == null
                        || email.isBlank()
        ) {
            Authentication authentication =
                    SecurityContextHolder
                            .getContext()
                            .getAuthentication();

            if (authentication != null) {
                email = authentication.getName();
            }
        }

        if (
                email == null
                        || email.isBlank()
        ) {
            return null;
        }

        return userRepository
                .findByEmail(email)
                .orElse(null);
    }

    private boolean isTutor(
            User user
    ) {
        return user != null
                && user.getRole() == Role.TUTOR;
    }

    private boolean isSuperAdmin(
            User user
    ) {
        return user != null
                && user.getEmail() != null
                && user.getEmail()
                .equalsIgnoreCase(
                        "admin@blute.co.in"
                );
    }

    private LiveClassResponse mapToResponse(
            LiveClass liveClass
    ) {
        Company company =
                liveClass.getCompany();

        Course course =
                liveClass.getCourse();

        User instructor =
                liveClass.getInstructor();

        User createdBy =
                liveClass.getCreatedBy();

        return new LiveClassResponse(
                liveClass.getId(),
                company != null
                        ? company.getId()
                        : null,
                company != null
                        ? company.getName()
                        : null,
                course != null
                        ? course.getId()
                        : null,
                course != null
                        ? course.getTitle()
                        : null,
                instructor != null
                        ? instructor.getId()
                        : null,
                instructor != null
                        ? instructor.getFullName()
                        : null,
                liveClass.getTitle(),
                liveClass.getDescription(),
                liveClass.getStartAt(),
                liveClass.getEndAt(),
                liveClass.getTimezone(),
                liveClass.getProvider(),
                liveClass.getMeetingUrl(),
                liveClass.getCapacity(),
                liveClass.getStatus(),
                liveClass.getThumbnailUrl(),
                liveClass.getRecordingUrl(),
                createdBy != null
                        ? createdBy.getId()
                        : null,
                createdBy != null
                        ? createdBy.getFullName()
                        : null,
                liveClass.getCreatedAt(),
                liveClass.getUpdatedAt()
        );
    }

    private String blankToNull(
            String value
    ) {
        if (
                value == null
                        || value.isBlank()
        ) {
            return null;
        }

        return value.trim();
    }

    private boolean isHttpUrl(
            String value
    ) {
        if (value == null) {
            return false;
        }

        String normalized =
                value.trim()
                        .toLowerCase();

        return normalized.startsWith(
                "http://"
        )
                || normalized.startsWith(
                "https://"
        );
    }
}