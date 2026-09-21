package com.learnos.paymenthistory.controller;

import com.learnos.paymenthistory.dto.PaymentHistoryResponse;
import com.learnos.paymenthistory.service.PaymentHistoryService;
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
@RequiredArgsConstructor
@RequestMapping("/payment-history")
@PreAuthorize("isAuthenticated()")
public class PaymentHistoryController {

    private final PaymentHistoryService paymentHistoryService;

    @GetMapping("/my")
    public ResponseEntity<List<PaymentHistoryResponse>>
    getMyPaymentHistory() {
        return ResponseEntity.ok(
                paymentHistoryService.getMyPaymentHistory()
        );
    }

    @GetMapping("/company/{companyId}")
    public ResponseEntity<List<PaymentHistoryResponse>>
    getCompanyPaymentHistory(
            @PathVariable UUID companyId
    ) {
        return ResponseEntity.ok(
                paymentHistoryService.getCompanyPaymentHistory(companyId)
        );
    }
}