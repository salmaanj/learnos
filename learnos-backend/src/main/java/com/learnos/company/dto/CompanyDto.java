package com.learnos.company.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class CompanyDto {

    private String id;
    private String name;
    private String industry;
    private String companyCode;
    private String email;
    private String phone;
    private String contactPhone;
    private String domain;
    private String status;

    private String address;
    private String city;
    private String state;
    private String pinCode;
    private String country;

    private String gstNumber;
    private String panNumber;
    private String cinNumber;

    private String logoUrl;

    private String primaryColor;
    private String secondaryColor;
    private String accentColor;

    private String planCode;
    private LocalDate planStartDate;
    private LocalDate planExpiryDate;

    private Integer maxLearners;
    private Integer maxCourses;
    private Boolean canCreateCourses;

    private long learnerCount;
    private long courseCount;
    private BigDecimal courseRevenue;
    private LocalDateTime createdAt;

    public CompanyDto() {
    }

    public CompanyDto(
            String id,
            String name,
            String industry,
            String companyCode,
            String email,
            String phone,
            String domain,
            String status
    ) {
        this.id = id;
        this.name = name;
        this.industry = industry;
        this.companyCode = companyCode;
        this.email = email;
        this.phone = phone;
        this.domain = domain;
        this.status = status;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
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

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
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

    public long getLearnerCount() {
        return learnerCount;
    }

    public void setLearnerCount(long learnerCount) {
        this.learnerCount = learnerCount;
    }

    public long getCourseCount() {
        return courseCount;
    }

    public void setCourseCount(long courseCount) {
        this.courseCount = courseCount;
    }

    public BigDecimal getCourseRevenue() {
        return courseRevenue;
    }

    public void setCourseRevenue(BigDecimal courseRevenue) {
        this.courseRevenue = courseRevenue;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}