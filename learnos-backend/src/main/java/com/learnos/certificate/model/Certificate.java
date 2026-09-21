package com.learnos.certificate.model;

import com.learnos.auth.model.User;
import com.learnos.company.entity.Company;
import com.learnos.course.model.Course;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(
        name = "certificates",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uk_certificate_user_course",
                        columnNames = {"user_id", "course_id"}
                ),
                @UniqueConstraint(
                        name = "uk_certificate_number",
                        columnNames = {"certificate_number"}
                ),
                @UniqueConstraint(
                        name = "uk_certificate_verification_code",
                        columnNames = {"verification_code"}
                )
        }
)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id")
public class Certificate {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "certificate_number", nullable = false, unique = true, length = 80)
    private String certificateNumber;

    @Column(name = "verification_code", nullable = false, unique = true, length = 80)
    private String verificationCode;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "company_id")
    private Company company;

    @Column(name = "learner_name", nullable = false)
    private String learnerName;

    @Column(name = "course_title", nullable = false)
    private String courseTitle;

    @Column(name = "company_name")
    private String companyName;

    @Column(name = "quiz_score_percent")
    private Integer quizScorePercent;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private CertificateStatus status = CertificateStatus.ISSUED;

    @CreationTimestamp
    @Column(name = "issued_at", nullable = false, updatable = false)
    private LocalDateTime issuedAt;

    @Column(name = "revoked_at")
    private LocalDateTime revokedAt;

    @Column(name = "revocation_reason", columnDefinition = "TEXT")
    private String revocationReason;
}