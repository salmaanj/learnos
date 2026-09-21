package com.learnos.liveclass.controller;

import com.learnos.auth.model.User;
import com.learnos.auth.repository.UserRepository;
import com.learnos.common.response.ApiResponse;
import com.learnos.liveclass.dto.LiveClassJoinResponse;
import com.learnos.liveclass.dto.LiveClassResponse;
import com.learnos.liveclass.model.LiveClass;
import com.learnos.liveclass.model.LiveClassStatus;
import com.learnos.liveclass.repository.LiveClassRepository;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/live-classes/tutor")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@Tag(
        name = "Tutor Live Classes",
        description = "Live classes assigned to tutors"
)
@PreAuthorize("hasRole('TUTOR')")
public class TutorLiveClassController {

    private final LiveClassRepository liveClassRepository;
    private final UserRepository userRepository;

    @GetMapping("/upcoming")
    public ResponseEntity<
            ApiResponse<List<LiveClassResponse>>
            > getUpcoming(
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        User tutor = getCurrentTutor(userDetails);
        LocalDateTime now = LocalDateTime.now();

        List<LiveClassResponse> classes =
                liveClassRepository.findAll()
                        .stream()
                        .filter(liveClass ->
                                liveClass.getInstructor() != null
                                        && liveClass.getInstructor()
                                        .getId()
                                        .equals(tutor.getId())
                        )
                        .filter(liveClass ->
                                liveClass.getEndAt() != null
                                        && liveClass.getEndAt()
                                        .isAfter(now)
                        )
                        .filter(liveClass ->
                                liveClass.getStatus() != null
                                        && liveClass.getStatus()
                                        != LiveClassStatus.DRAFT
                                        && liveClass.getStatus()
                                        != LiveClassStatus.CANCELLED
                        )
                        .sorted((first, second) ->
                                first.getStartAt()
                                        .compareTo(second.getStartAt())
                        )
                        .map(this::toResponse)
                        .toList();

        return ResponseEntity.ok(
                ApiResponse.success(classes)
        );
    }

    @PostMapping("/{id}/join")
    public ResponseEntity<
            ApiResponse<LiveClassJoinResponse>
            > joinClass(
            @PathVariable UUID id,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        User tutor = getCurrentTutor(userDetails);

        LiveClass liveClass = liveClassRepository
                .findById(id)
                .orElseThrow(() ->
                        new RuntimeException(
                                "Live class not found"
                        )
                );

        if (
                liveClass.getInstructor() == null
                        || !liveClass.getInstructor()
                        .getId()
                        .equals(tutor.getId())
        ) {
            throw new RuntimeException(
                    "You are not assigned to this live class"
            );
        }

        if (
                liveClass.getStatus() == LiveClassStatus.DRAFT
                        || liveClass.getStatus()
                        == LiveClassStatus.CANCELLED
        ) {
            throw new RuntimeException(
                    "This live class is not available"
            );
        }

        LocalDateTime now = LocalDateTime.now();

        if (
                now.isBefore(
                        liveClass.getStartAt().minusMinutes(15)
                )
                        || now.isAfter(
                        liveClass.getEndAt().plusMinutes(30)
                )
        ) {
            throw new RuntimeException(
                    "Joining is available from 15 minutes before the class until 30 minutes after it ends"
            );
        }

        LiveClassJoinResponse response =
                new LiveClassJoinResponse(
                        liveClass.getId(),
                        liveClass.getTitle(),
                        liveClass.getProvider(),
                        liveClass.getMeetingUrl(),
                        liveClass.getMeetingPassword(),
                        now
                );

        return ResponseEntity.ok(
                ApiResponse.success(
                        response,
                        "Tutor joined the live class"
                )
        );
    }

    private User getCurrentTutor(
            UserDetails userDetails
    ) {
        if (userDetails == null) {
            throw new RuntimeException(
                    "Tutor authentication is required"
            );
        }

        return userRepository
                .findByEmail(userDetails.getUsername())
                .orElseThrow(() ->
                        new RuntimeException(
                                "Tutor not found"
                        )
                );
    }

    private LiveClassResponse toResponse(
            LiveClass liveClass
    ) {
        return new LiveClassResponse(
                liveClass.getId(),

                liveClass.getCompany() != null
                        ? liveClass.getCompany().getId()
                        : null,

                liveClass.getCompany() != null
                        ? liveClass.getCompany().getName()
                        : null,

                liveClass.getCourse() != null
                        ? liveClass.getCourse().getId()
                        : null,

                liveClass.getCourse() != null
                        ? liveClass.getCourse().getTitle()
                        : null,

                liveClass.getInstructor() != null
                        ? liveClass.getInstructor().getId()
                        : null,

                liveClass.getInstructor() != null
                        ? liveClass.getInstructor().getFullName()
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

                liveClass.getCreatedBy() != null
                        ? liveClass.getCreatedBy().getId()
                        : null,

                liveClass.getCreatedBy() != null
                        ? liveClass.getCreatedBy().getFullName()
                        : null,

                liveClass.getCreatedAt(),
                liveClass.getUpdatedAt()
        );
    }
}