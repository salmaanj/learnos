package com.learnos.company.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "companies")
public class Company {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private String name;

    private String subdomain;

    @Column(name = "logo_url")
    private String logoUrl;

    @Column(name = "primary_color")
    private String primaryColor;

    @Column(name = "secondary_color")
    private String secondaryColor;

    @Column(name = "accent_color")
    private String accentColor;

    private String industry;

    @Column(name = "company_code", unique = true, nullable = false)
    private String companyCode;

    private String email;
    private String phone;

    @Column(name = "contact_phone")
    private String contactPhone;

    private String domain;

    @Column(columnDefinition = "TEXT")
    private String address;

    private String city;
    private String state;

    @Column(name = "pin_code")
    private String pinCode;

    private String country;

    @Column(name = "gst_number", length = 15)
    private String gstNumber;

    @Column(name = "pan_number", length = 10)
    private String panNumber;

    @Column(name = "cin_number")
    private String cinNumber;

    @Column(name = "plan_code")
    private String planCode;

    @Column(name = "plan_start_date")
    private LocalDate planStartDate;

    @Column(name = "plan_expiry_date")
    private LocalDate planExpiryDate;

    @Column(nullable = false)
    private String status;

    @Column(name = "max_learners", nullable = false)
    private Integer maxLearners = 10000;

    @Column(name = "max_courses", nullable = false)
    private Integer maxCourses = 1000;

    @Column(name = "can_create_courses", nullable = false)
    private Boolean canCreateCourses = true;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    public Company() {
    }

    @PrePersist
    protected void onCreate() {
        LocalDateTime now = LocalDateTime.now();

        if (this.createdAt == null) {
            this.createdAt = now;
        }

        this.updatedAt = now;

        if (this.primaryColor == null || this.primaryColor.isBlank()) {
            this.primaryColor = "#1E3A8A";
        }

        if (this.secondaryColor == null || this.secondaryColor.isBlank()) {
            this.secondaryColor = "#F97316";
        }

        if (this.accentColor == null || this.accentColor.isBlank()) {
            this.accentColor = "#2563EB";
        }

        applyPlanLimits();

        if (this.canCreateCourses == null) {
            this.canCreateCourses = true;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
        applyPlanLimits();
    }

    private void applyPlanLimits() {
        if (this.planCode == null || this.planCode.isBlank()) {
            if (this.maxLearners == null) {
                this.maxLearners = 10000;
            }

            if (this.maxCourses == null) {
                this.maxCourses = 1000;
            }

            return;
        }

        switch (this.planCode.trim().toUpperCase()) {
            case "BASIC":
                this.maxLearners = 25;
                this.maxCourses = 5;
                break;

            case "PRO":
                this.maxLearners = 250;
                this.maxCourses = 50;
                break;

            case "ENTERPRISE":
                this.maxLearners = 1000;
                this.maxCourses = 250;
                break;

            default:
                if (this.maxLearners == null) {
                    this.maxLearners = 10000;
                }

                if (this.maxCourses == null) {
                    this.maxCourses = 1000;
                }
                break;
        }
    }

    public boolean isPlanExpired() {
        return planExpiryDate != null
                && planExpiryDate.isBefore(LocalDate.now());
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getSubdomain() {
        return subdomain;
    }

    public void setSubdomain(String subdomain) {
        this.subdomain = subdomain;
    }

    public String getLogoUrl() {
        return logoUrl;
    }

    public void setLogoUrl(String logoUrl) {
        this.logoUrl = logoUrl;
    }

    public String getPrimaryColor() {
        return primaryColor;
    }

    public void setPrimaryColor(String primaryColor) {
        this.primaryColor = primaryColor;
    }

    public String getSecondaryColor() {
        return secondaryColor;
    }

    public void setSecondaryColor(String secondaryColor) {
        this.secondaryColor = secondaryColor;
    }

    public String getAccentColor() {
        return accentColor;
    }

    public void setAccentColor(String accentColor) {
        this.accentColor = accentColor;
    }

    public String getIndustry() {
        return industry;
    }

    public void setIndustry(String industry) {
        this.industry = industry;
    }

    public String getCompanyCode() {
        return companyCode;
    }

    public void setCompanyCode(String companyCode) {
        this.companyCode = companyCode;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getContactPhone() {
        return contactPhone;
    }

    public void setContactPhone(String contactPhone) {
        this.contactPhone = contactPhone;
    }

    public String getDomain() {
        return domain;
    }

    public void setDomain(String domain) {
        this.domain = domain;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public String getPinCode() {
        return pinCode;
    }

    public void setPinCode(String pinCode) {
        this.pinCode = pinCode;
    }

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }

    public String getGstNumber() {
        return gstNumber;
    }

    public void setGstNumber(String gstNumber) {
        this.gstNumber = gstNumber;
    }

    public String getPanNumber() {
        return panNumber;
    }

    public void setPanNumber(String panNumber) {
        this.panNumber = panNumber;
    }

    public String getCinNumber() {
        return cinNumber;
    }

    public void setCinNumber(String cinNumber) {
        this.cinNumber = cinNumber;
    }

    public String getPlanCode() {
        return planCode;
    }

    public void setPlanCode(String planCode) {
        this.planCode = planCode;
    }

    public LocalDate getPlanStartDate() {
        return planStartDate;
    }

    public void setPlanStartDate(LocalDate planStartDate) {
        this.planStartDate = planStartDate;
    }

    public LocalDate getPlanExpiryDate() {
        return planExpiryDate;
    }

    public void setPlanExpiryDate(LocalDate planExpiryDate) {
        this.planExpiryDate = planExpiryDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getMaxLearners() {
        return maxLearners;
    }

    public void setMaxLearners(Integer maxLearners) {
        this.maxLearners = maxLearners;
    }

    public Integer getMaxCourses() {
        return maxCourses;
    }

    public void setMaxCourses(Integer maxCourses) {
        this.maxCourses = maxCourses;
    }

    public Boolean getCanCreateCourses() {
        return canCreateCourses;
    }

    public void setCanCreateCourses(Boolean canCreateCourses) {
        this.canCreateCourses = canCreateCourses;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}