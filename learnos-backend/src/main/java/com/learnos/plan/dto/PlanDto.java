package com.learnos.plan.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class PlanDto {

    private String id;
    private String code;
    private String name;
    private BigDecimal price;
    private String currency;
    private Integer durationMonths;
    private Integer maxLearners;
    private Integer maxCourses;
    private String description;
    private Boolean active;
    private Integer displayOrder;
    private LocalDateTime createdAt;

    public PlanDto() {
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public Integer getDurationMonths() {
        return durationMonths;
    }

    public void setDurationMonths(Integer durationMonths) {
        this.durationMonths = durationMonths;
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

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Boolean getActive() {
        return active;
    }

    public void setActive(Boolean active) {
        this.active = active;
    }

    public Integer getDisplayOrder() {
        return displayOrder;
    }

    public void setDisplayOrder(Integer displayOrder) {
        this.displayOrder = displayOrder;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}