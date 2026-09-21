package com.learnos.analytics.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public record AnalyticsResponse(
        Summary summary,
        List<CompanyRow> companies,
        CompanyDetail selectedCompany
) {

    public record Summary(
            long totalCompanies,
            long totalLearners,
            long totalCourses,
            BigDecimal subscriptionRevenue,
            BigDecimal courseRevenue,
            long successfulPayments,
            long pendingPayments,
            long failedPayments
    ) {
    }

    public record CompanyRow(
            UUID companyId,
            String companyName,
            long totalLearners,
            long totalCourses,
            BigDecimal courseRevenue,
            String subscriptionStatus,
            String planName,
            LocalDate expiryDate
    ) {
    }

    public record CompanyDetail(
            UUID companyId,
            String companyName,
            long totalLearners,
            long totalCourses,
            BigDecimal courseRevenue,
            String subscriptionStatus,
            String planName,
            LocalDate expiryDate,
            long successfulPaymentCount,
            String logoUrl
    ) {
    }
}
