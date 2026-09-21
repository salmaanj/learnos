package com.learnos.analytics.service;

import com.learnos.analytics.dto.AnalyticsResponse;

import java.util.UUID;

public interface AnalyticsService {

    AnalyticsResponse getAnalytics(UUID companyId);
}
