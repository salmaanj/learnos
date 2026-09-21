package com.learnos.subscription.service;

import com.learnos.subscription.dto.CreateRazorpayOrderRequest;
import com.learnos.subscription.dto.RazorpayOrderResponse;
import com.learnos.subscription.dto.VerifyRazorpayPaymentRequest;
import com.learnos.subscription.dto.CompanySubscriptionResponse;

public interface RazorpayPaymentService {

    RazorpayOrderResponse createOrder(
            CreateRazorpayOrderRequest request
    );

    CompanySubscriptionResponse verifyPayment(
            VerifyRazorpayPaymentRequest request
    );
}