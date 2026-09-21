package com.learnos.liveclass.controller;

import com.learnos.common.response.ApiResponse;
import com.learnos.liveclass.dto.LearnerLiveClassResponse;
import com.learnos.liveclass.dto.LiveClassJoinResponse;
import com.learnos.liveclass.service.LearnerLiveClassService;
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

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/live-classes/learner")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@Tag(
        name = "Learner Live Classes",
        description = "Learner live class discovery, joining and attendance"
)
@PreAuthorize("hasRole('LEARNER')")
public class LearnerLiveClassController {

    private final LearnerLiveClassService learnerLiveClassService;

    @GetMapping("/upcoming")
    public ResponseEntity<
            ApiResponse<List<LearnerLiveClassResponse>>
            > getUpcoming(
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        learnerLiveClassService.getUpcoming(
                                username(userDetails)
                        )
                )
        );
    }

    @GetMapping("/history")
    public ResponseEntity<
            ApiResponse<List<LearnerLiveClassResponse>>
            > getHistory(
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        learnerLiveClassService.getHistory(
                                username(userDetails)
                        )
                )
        );
    }

    @GetMapping("/{id}")
    public ResponseEntity<
            ApiResponse<LearnerLiveClassResponse>
            > getDetails(
            @PathVariable UUID id,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        learnerLiveClassService.getDetails(
                                id,
                                username(userDetails)
                        )
                )
        );
    }

    @PostMapping("/{id}/join")
    public ResponseEntity<
            ApiResponse<LiveClassJoinResponse>
            > join(
            @PathVariable UUID id,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        learnerLiveClassService.join(
                                id,
                                username(userDetails)
                        ),
                        "Live class joined"
                )
        );
    }

    @PostMapping("/{id}/leave")
    public ResponseEntity<
            ApiResponse<LearnerLiveClassResponse>
            > leave(
            @PathVariable UUID id,
            @AuthenticationPrincipal UserDetails userDetails
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        learnerLiveClassService.leave(
                                id,
                                username(userDetails)
                        ),
                        "Live class attendance updated"
                )
        );
    }

    private String username(UserDetails userDetails) {
        return userDetails != null
                ? userDetails.getUsername()
                : null;
    }
}