package com.learnos.subscription.controller;

import com.learnos.plan.entity.Plan;
import com.learnos.subscription.dto.CompanySubscriptionResponse;
import com.learnos.subscription.dto.CreateCompanySubscriptionRequest;
import com.learnos.subscription.dto.CreateRazorpayOrderRequest;
import com.learnos.subscription.dto.RazorpayOrderResponse;
import com.learnos.subscription.dto.VerifyRazorpayPaymentRequest;
import com.learnos.subscription.service.CompanySubscriptionService;
import com.learnos.subscription.service.RazorpayPaymentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/company-subscriptions")
@RequiredArgsConstructor
@PreAuthorize("isAuthenticated()")
public class CompanySubscriptionController {

    private final CompanySubscriptionService subscriptionService;
    private final RazorpayPaymentService razorpayPaymentService;

    @GetMapping("/my")
    public ResponseEntity<CompanySubscriptionResponse>
    getMySubscription() {
        return ResponseEntity.ok(
                subscriptionService.getMySubscription()
        );
    }

    @GetMapping("/my/upgrade-options")
    public ResponseEntity<List<Plan>> getMyUpgradeOptions() {
        return ResponseEntity.ok(
                subscriptionService.getMyUpgradeOptions()
        );
    }

    @GetMapping("/company/{companyId}")
    public ResponseEntity<CompanySubscriptionResponse>
    getSubscriptionByCompanyId(
            @PathVariable UUID companyId
    ) {
        return ResponseEntity.ok(
                subscriptionService.getSubscriptionByCompanyId(
                        companyId
                )
        );
    }

    @PostMapping
    public ResponseEntity<CompanySubscriptionResponse>
    createSubscription(
            @Valid
            @RequestBody
            CreateCompanySubscriptionRequest request
    ) {
        return ResponseEntity.ok(
                subscriptionService.createSubscription(request)
        );
    }

    @PostMapping("/payment-order")
    public ResponseEntity<RazorpayOrderResponse>
    createPaymentOrder(
            @Valid
            @RequestBody
            CreateRazorpayOrderRequest request
    ) {
        return ResponseEntity.ok(
                razorpayPaymentService.createOrder(request)
        );
    }

    @PostMapping("/verify-payment")
    public ResponseEntity<CompanySubscriptionResponse>
    verifyPayment(
            @Valid
            @RequestBody
            VerifyRazorpayPaymentRequest request
    ) {
        return ResponseEntity.ok(
                razorpayPaymentService.verifyPayment(request)
        );
    }
}
