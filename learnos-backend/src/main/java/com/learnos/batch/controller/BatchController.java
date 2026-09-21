package com.learnos.batch.controller;

import com.learnos.batch.dto.BatchMemberResponse;
import com.learnos.batch.dto.BatchRequest;
import com.learnos.batch.dto.BatchResponse;
import com.learnos.batch.service.BatchService;
import com.learnos.common.response.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/batches")
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
public class BatchController {

    private final BatchService batchService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<BatchResponse>>> getBatches() {
        return ResponseEntity.ok(
                ApiResponse.success(batchService.getBatches())
        );
    }

    @GetMapping("/{batchId}")
    public ResponseEntity<ApiResponse<BatchResponse>> getBatch(
            @PathVariable UUID batchId
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(batchService.getBatch(batchId))
        );
    }

    @PostMapping
    public ResponseEntity<ApiResponse<BatchResponse>> createBatch(
            @RequestBody BatchRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(
                        ApiResponse.success(
                                batchService.createBatch(request),
                                "Batch created successfully."
                        )
                );
    }

    @PutMapping("/{batchId}")
    public ResponseEntity<ApiResponse<BatchResponse>> updateBatch(
            @PathVariable UUID batchId,
            @RequestBody BatchRequest request
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        batchService.updateBatch(batchId, request),
                        "Batch updated successfully."
                )
        );
    }

    @DeleteMapping("/{batchId}")
    public ResponseEntity<ApiResponse<BatchResponse>> archiveBatch(
            @PathVariable UUID batchId
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        batchService.archiveBatch(batchId),
                        "Batch archived successfully."
                )
        );
    }

    @GetMapping("/{batchId}/members")
    public ResponseEntity<ApiResponse<List<BatchMemberResponse>>> getMembers(
            @PathVariable UUID batchId
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        batchService.getBatchMembers(batchId)
                )
        );
    }

    @PostMapping("/{batchId}/members/{learnerId}")
    public ResponseEntity<ApiResponse<BatchMemberResponse>> addMember(
            @PathVariable UUID batchId,
            @PathVariable UUID learnerId
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(
                        ApiResponse.success(
                                batchService.addMember(
                                        batchId,
                                        learnerId
                                ),
                                "Learner added to batch."
                        )
                );
    }

    @DeleteMapping("/{batchId}/members/{learnerId}")
    public ResponseEntity<ApiResponse<String>> removeMember(
            @PathVariable UUID batchId,
            @PathVariable UUID learnerId
    ) {
        batchService.removeMember(batchId, learnerId);

        return ResponseEntity.ok(
                ApiResponse.success(
                        "Learner removed from batch."
                )
        );
    }
}