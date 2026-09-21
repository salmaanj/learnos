package com.learnos.analytics.controller;

import com.learnos.analytics.dto.AnalyticsResponse;
import com.learnos.analytics.service.AnalyticsService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequiredArgsConstructor
@RequestMapping("/analytics")
public class AnalyticsController {

    private final AnalyticsService analyticsService;

    @GetMapping
    public AnalyticsResponse getAnalytics(
            @RequestParam(required = false) UUID companyId
    ) {
        return analyticsService.getAnalytics(companyId);
    }
}
