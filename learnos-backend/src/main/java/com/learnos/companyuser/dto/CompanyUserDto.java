package com.learnos.companyuser.dto;

public class CompanyUserDto {
    private String id;
    private String name;
    private String email;
    private String company;
    private String role;
    private String status;
    private String companyId;

    public CompanyUserDto() {
    }

    public CompanyUserDto(String id, String name, String email, String company, String role, String status, String companyId) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.company = company;
        this.role = role;
        this.status = status;
        this.companyId = companyId;
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

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getCompany() {
        return company;
    }

    public void setCompany(String company) {
        this.company = company;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getCompanyId() {
        return companyId;
    }

    public void setCompanyId(String companyId) {
        this.companyId = companyId;
    }
}