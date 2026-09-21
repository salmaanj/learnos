package com.learnos.subscription.repository;

import com.learnos.subscription.entity.CompanySubscription;
import com.learnos.subscription.entity.SubscriptionStatus;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface CompanySubscriptionRepository
        extends JpaRepository<CompanySubscription, UUID> {

    Optional<CompanySubscription>
    findTopByCompany_IdOrderByCreatedAtDesc(UUID companyId);

    List<CompanySubscription>
    findByCompany_IdOrderByCreatedAtDesc(UUID companyId);

    Optional<CompanySubscription>
    findByRazorpayOrderId(String razorpayOrderId);

    boolean existsByCompany_IdAndStatus(
            UUID companyId,
            SubscriptionStatus status
    );

    @Query("""
            select coalesce(sum(subscription.amount), 0)
            from CompanySubscription subscription
            where subscription.company.id = :companyId
              and subscription.status = :status
            """)
    BigDecimal sumAmountByCompanyIdAndStatus(
            @Param("companyId") UUID companyId,
            @Param("status") SubscriptionStatus status
    );

    @Query("""
            select coalesce(sum(subscription.amount), 0)
            from CompanySubscription subscription
            where subscription.status = :status
            """)
    BigDecimal sumAmountByStatus(
            @Param("status") SubscriptionStatus status
    );

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("""
            select subscription
            from CompanySubscription subscription
            where subscription.id = :id
            """)
    Optional<CompanySubscription> findByIdForUpdate(
            @Param("id") UUID id
    );
}