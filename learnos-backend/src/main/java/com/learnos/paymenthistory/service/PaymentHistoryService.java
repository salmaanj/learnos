package com.learnos.paymenthistory.service;

import com.learnos.paymenthistory.dto.PaymentHistoryResponse;

import java.util.List;
import java.util.UUID;

public interface PaymentHistoryService {

    List<PaymentHistoryResponse> getMyPaymentHistory();

    List<PaymentHistoryResponse> getCompanyPaymentHistory(UUID companyId);
}