package com.learnos.coursepayment.repository;

import com.learnos.coursepayment.model.CoursePayment;
import com.learnos.coursepayment.model.CoursePaymentStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface CoursePaymentRepository
        extends JpaRepository<CoursePayment, UUID> {

    Optional<CoursePayment> findByRazorpayOrderId(
            String razorpayOrderId
    );

    Optional<CoursePayment> findByLearnerIdAndCourseIdAndStatus(
            UUID learnerId,
            UUID courseId,
            CoursePaymentStatus status
    );

    List<CoursePayment> findByLearnerIdOrderByCreatedAtDesc(
            UUID learnerId
    );

    List<CoursePayment> findByCompanyIdOrderByCreatedAtDesc(
            UUID companyId
    );

    long countByCompanyIdAndStatus(
            UUID companyId,
            CoursePaymentStatus status
    );

    @Query("""
            select coalesce(sum(payment.amount), 0)
            from CoursePayment payment
            where payment.company.id = :companyId
              and payment.status = :status
            """)
    BigDecimal sumAmountByCompanyIdAndStatus(
            @Param("companyId") UUID companyId,
            @Param("status") CoursePaymentStatus status
    );
}
