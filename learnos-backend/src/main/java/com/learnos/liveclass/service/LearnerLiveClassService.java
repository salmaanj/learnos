package com.learnos.liveclass.service;

import com.learnos.auth.model.Role;
import com.learnos.auth.model.User;
import com.learnos.auth.repository.UserRepository;
import com.learnos.course.model.Enrollment;
import com.learnos.course.model.EnrollmentStatus;
import com.learnos.course.repository.EnrollmentRepository;
import com.learnos.liveclass.dto.LearnerLiveClassResponse;
import com.learnos.liveclass.dto.LiveClassJoinResponse;
import com.learnos.liveclass.model.LiveClass;
import com.learnos.liveclass.model.LiveClassAttendance;
import com.learnos.liveclass.model.LiveClassAttendanceStatus;
import com.learnos.liveclass.model.LiveClassStatus;
import com.learnos.liveclass.repository.LiveClassAttendanceRepository;
import com.learnos.liveclass.repository.LiveClassRepository;
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
@Transactional
public class LearnerLiveClassService {

    private final LiveClassRepository liveClassRepository;
    private final LiveClassAttendanceRepository
            attendanceRepository;
    private final EnrollmentRepository enrollmentRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public List<LearnerLiveClassResponse> getUpcoming(
            String username
    ) {
        User learner = requireLearner(username);
        LocalDateTime now = LocalDateTime.now();

        return liveClassRepository
                .findAll()
                .stream()
                .filter(
                        liveClass ->
                                isVisibleToLearner(
                                        liveClass,
                                        learner
                                )
                )
                .filter(
                        liveClass ->
                                liveClass.getEndAt() != null
                                        && liveClass
                                        .getEndAt()
                                        .isAfter(now)
                )
                .sorted(
                        (first, second) ->
                                first.getStartAt()
                                        .compareTo(
                                                second.getStartAt()
                                        )
                )
                .map(
                        liveClass ->
                                mapToResponse(
                                        liveClass,
                                        learner,
                                        now
                                )
                )
                .toList();
    }

    @Transactional(readOnly = true)
    public List<LearnerLiveClassResponse> getHistory(
            String username
    ) {
        User learner = requireLearner(username);
        LocalDateTime now = LocalDateTime.now();

        return liveClassRepository
                .findAll()
                .stream()
                .filter(
                        liveClass ->
                                isVisibleToLearner(
                                        liveClass,
                                        learner
                                )
                )
                .filter(
                        liveClass ->
                                liveClass.getEndAt() != null
                                        && !liveClass
                                        .getEndAt()
                                        .isAfter(now)
                )
                .sorted(
                        (first, second) ->
                                second.getStartAt()
                                        .compareTo(
                                                first.getStartAt()
                                        )
                )
                .map(
                        liveClass ->
                                mapToResponse(
                                        liveClass,
                                        learner,
                                        now
                                )
                )
                .toList();
    }

    @Transactional(readOnly = true)
    public LearnerLiveClassResponse getDetails(
            UUID liveClassId,
            String username
    ) {
        User learner = requireLearner(username);

        LiveClass liveClass = getLiveClassOrThrow(
                liveClassId
        );

        assertLearnerCanView(
                liveClass,
                learner
        );

        return mapToResponse(
                liveClass,
                learner,
                LocalDateTime.now()
        );
    }

    public LiveClassJoinResponse join(
            UUID liveClassId,
            String username
    ) {
        User learner = requireLearner(username);

        LiveClass liveClass = getLiveClassOrThrow(
                liveClassId
        );

        assertLearnerCanView(
                liveClass,
                learner
        );

        LocalDateTime now = LocalDateTime.now();

        if (!isJoinWindowOpen(liveClass, now)) {
            throw new RuntimeException(
                    "Joining is available from 15 minutes before the class until 30 minutes after it ends"
            );
        }

        LiveClassAttendance attendance =
                attendanceRepository
                        .findByLiveClassIdAndLearnerId(
                                liveClassId,
                                learner.getId()
                        )
                        .orElseGet(
                                () ->
                                        LiveClassAttendance
                                                .builder()
                                                .liveClass(liveClass)
                                                .learner(learner)
                                                .attendanceStatus(
                                                        LiveClassAttendanceStatus
                                                                .REGISTERED
                                                )
                                                .minutesAttended(0)
                                                .build()
                        );

        if (attendance.getJoinAt() == null) {
            attendance.setJoinAt(now);
        }

        attendance.setAttendanceStatus(
                LiveClassAttendanceStatus.ATTENDED
        );

        attendanceRepository.save(attendance);

        return new LiveClassJoinResponse(
                liveClass.getId(),
                liveClass.getTitle(),
                liveClass.getProvider(),
                liveClass.getMeetingUrl(),
                liveClass.getMeetingPassword(),
                attendance.getJoinAt()
        );
    }

    public LearnerLiveClassResponse leave(
            UUID liveClassId,
            String username
    ) {
        User learner = requireLearner(username);

        LiveClass liveClass = getLiveClassOrThrow(
                liveClassId
        );

        assertLearnerCanView(
                liveClass,
                learner
        );

        LiveClassAttendance attendance =
                attendanceRepository
                        .findByLiveClassIdAndLearnerId(
                                liveClassId,
                                learner.getId()
                        )
                        .orElseThrow(
                                () ->
                                        new RuntimeException(
                                                "Join the live class before leaving it"
                                        )
                        );

        LocalDateTime now = LocalDateTime.now();

        if (attendance.getLeaveAt() == null) {
            attendance.setLeaveAt(now);
        }

        if (
                attendance.getJoinAt() != null
                        && attendance.getLeaveAt() != null
        ) {
            long minutes = java.time.Duration
                    .between(
                            attendance.getJoinAt(),
                            attendance.getLeaveAt()
                    )
                    .toMinutes();

            attendance.setMinutesAttended(
                    Math.max(
                            0,
                            Math.toIntExact(minutes)
                    )
            );
        }

        attendance.setAttendanceStatus(
                LiveClassAttendanceStatus.ATTENDED
        );

        LiveClassAttendance saved =
                attendanceRepository.save(attendance);

        return mapToResponse(
                liveClass,
                learner,
                now
        );
    }

    private LearnerLiveClassResponse mapToResponse(
            LiveClass liveClass,
            User learner,
            LocalDateTime now
    ) {
        LiveClassAttendance attendance =
                attendanceRepository
                        .findByLiveClassIdAndLearnerId(
                                liveClass.getId(),
                                learner.getId()
                        )
                        .orElse(null);

        return new LearnerLiveClassResponse(
                liveClass.getId(),
                liveClass.getTitle(),
                liveClass.getDescription(),

                liveClass.getCourse() != null
                        ? liveClass.getCourse().getId()
                        : null,

                liveClass.getCourse() != null
                        ? liveClass.getCourse().getTitle()
                        : null,

                liveClass.getInstructor() != null
                        ? liveClass.getInstructor().getFullName()
                        : null,

                liveClass.getStartAt(),
                liveClass.getEndAt(),
                liveClass.getTimezone(),

                liveClass.getProvider(),

                liveClass.getCapacity(),
                liveClass.getStatus(),

                liveClass.getThumbnailUrl(),
                liveClass.getRecordingUrl(),

                true,
                isJoinWindowOpen(liveClass, now),

                attendance != null
                        ? attendance.getAttendanceStatus()
                        : null,

                attendance != null
                        ? attendance.getJoinAt()
                        : null,

                attendance != null
                        ? attendance.getLeaveAt()
                        : null,

                attendance != null
                        ? attendance.getMinutesAttended()
                        : 0
        );
    }

    private boolean isVisibleToLearner(
            LiveClass liveClass,
            User learner
    ) {
        if (liveClass == null) {
            return false;
        }

        if (
                liveClass.getStatus() == LiveClassStatus.CANCELLED
                        || liveClass.getStatus()
                        == LiveClassStatus.DRAFT
        ) {
            return false;
        }

        if (
                learner.getCompany() == null
                        || liveClass.getCompany() == null
                        || !learner.getCompany().getId().equals(
                        liveClass.getCompany().getId()
                )
        ) {
            return false;
        }

        if (liveClass.getCourse() == null) {
            return true;
        }

        return hasActiveEnrollment(
                learner,
                liveClass.getCourse().getId()
        );
    }

    private void assertLearnerCanView(
            LiveClass liveClass,
            User learner
    ) {
        if (!isVisibleToLearner(liveClass, learner)) {
            throw new RuntimeException(
                    "You are not eligible to access this live class"
            );
        }
    }

    private boolean hasActiveEnrollment(
            User learner,
            UUID courseId
    ) {
        return enrollmentRepository
                .findByUserIdAndCourseId(
                        learner.getId(),
                        courseId
                )
                .map(
                        enrollment ->
                                enrollment.getStatus()
                                        == EnrollmentStatus.ACTIVE
                                        || enrollment.getStatus()
                                        == EnrollmentStatus.COMPLETED
                )
                .orElse(false);
    }

    private boolean isJoinWindowOpen(
            LiveClass liveClass,
            LocalDateTime now
    ) {
        if (
                liveClass.getStartAt() == null
                        || liveClass.getEndAt() == null
        ) {
            return false;
        }

        if (
                liveClass.getStatus() == LiveClassStatus.CANCELLED
                        || liveClass.getStatus()
                        == LiveClassStatus.DRAFT
                        || liveClass.getStatus()
                        == LiveClassStatus.COMPLETED
        ) {
            return false;
        }

        LocalDateTime joinStart =
                liveClass.getStartAt().minusMinutes(15);

        LocalDateTime joinEnd =
                liveClass.getEndAt().plusMinutes(30);

        return !now.isBefore(joinStart)
                && !now.isAfter(joinEnd);
    }

    private LiveClass getLiveClassOrThrow(
            UUID liveClassId
    ) {
        return liveClassRepository
                .findById(liveClassId)
                .orElseThrow(
                        () ->
                                new RuntimeException(
                                        "Live class not found"
                                )
                );
    }

    private User requireLearner(String username) {
        User learner = getCurrentUser(username);

        if (learner == null) {
            throw new RuntimeException("User not found");
        }

        if (learner.getRole() != Role.LEARNER) {
            throw new RuntimeException(
                    "Only learners can access learner live classes"
            );
        }

        return learner;
    }

    private User getCurrentUser(String username) {
        String email = username;

        if (email == null || email.isBlank()) {
            Authentication authentication =
                    SecurityContextHolder
                            .getContext()
                            .getAuthentication();

            if (authentication != null) {
                email = authentication.getName();
            }
        }

        if (email == null || email.isBlank()) {
            return null;
        }

        return userRepository.findByEmail(email)
                .orElse(null);
    }
}