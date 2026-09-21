package com.learnos.subscription.service;

import com.learnos.subscription.dto.CompanySubscriptionResponse;
import com.learnos.subscription.dto.CreateCompanySubscriptionRequest;
import com.learnos.plan.entity.Plan;

import java.util.List;
import java.util.UUID;

public interface CompanySubscriptionService {

    CompanySubscriptionResponse getMySubscription();

    CompanySubscriptionResponse getSubscriptionByCompanyId(
            UUID companyId
    );

    CompanySubscriptionResponse createSubscription(
            CreateCompanySubscriptionRequest request
    );

    List<Plan> getMyUpgradeOptions();
}