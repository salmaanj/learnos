package com.learnos.coursepayment.service;

import com.learnos.coursepayment.dto.CoursePaymentOrderResponse;
import com.learnos.coursepayment.dto.CreateCoursePaymentOrderRequest;
import com.learnos.coursepayment.dto.VerifyCoursePaymentRequest;

public interface CoursePaymentService {

    CoursePaymentOrderResponse createOrder(
            CreateCoursePaymentOrderRequest request
    );

    String verifyPayment(
            VerifyCoursePaymentRequest request
    );
}
