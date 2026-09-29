package com.learnos.companyuser.controller;

import com.learnos.auth.service.AuthorizationService;
import com.learnos.companyuser.dto.LearnerEnrollmentResponse;
import com.learnos.companyuser.dto.LearnerResponse;
import com.learnos.companyuser.service.LearnerService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/learners")
@RequiredArgsConstructor
public class LearnerController {

    private final LearnerService learnerService;
    private final AuthorizationService authorizationService;

    @GetMapping
    @PreAuthorize("@authorizationService.hasPermission(authentication, 'LEARNERS_VIEW')")
    public ResponseEntity<List<LearnerResponse>> getAll() {
        return ResponseEntity.ok(learnerService.getLearners());
    }

    @GetMapping("/{learnerId}/enrollments")
    @PreAuthorize("@authorizationService.hasPermission(authentication, 'LEARNERS_VIEW')")
    public ResponseEntity<List<LearnerEnrollmentResponse>> getLearnerEnrollments(
            @PathVariable UUID learnerId
    ) {
        return ResponseEntity.ok(
                learnerService.getLearnerEnrollments(learnerId)
        );
    }
}