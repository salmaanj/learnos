package com.learnos.coursepayment.controller;

import com.learnos.common.response.ApiResponse;
import com.learnos.coursepayment.dto.CoursePaymentOrderResponse;
import com.learnos.coursepayment.dto.CreateCoursePaymentOrderRequest;
import com.learnos.coursepayment.dto.VerifyCoursePaymentRequest;
import com.learnos.coursepayment.service.CoursePaymentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/course-payments")
public class CoursePaymentController {

    private final CoursePaymentService coursePaymentService;

    @PostMapping("/payment-order")
    @PreAuthorize("hasRole('LEARNER')")
    public ResponseEntity<ApiResponse<CoursePaymentOrderResponse>>
    createOrder(
            @Valid @RequestBody CreateCoursePaymentOrderRequest request
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        coursePaymentService.createOrder(request),
                        "Course payment order created"
                )
        );
    }

    @PostMapping("/verify-payment")
    @PreAuthorize("hasRole('LEARNER')")
    public ResponseEntity<ApiResponse<String>> verifyPayment(
            @Valid @RequestBody VerifyCoursePaymentRequest request
    ) {
        return ResponseEntity.ok(
                ApiResponse.success(
                        coursePaymentService.verifyPayment(request),
                        "Course payment verified"
                )
        );
    }
}

