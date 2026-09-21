package com.learnos.company.service;

import com.learnos.company.dto.CompanyDto;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface CompanyService {

    List<CompanyDto> getAllCompanies();

    CompanyDto getCompanyById(String id);

    CompanyDto createCompany(CompanyDto dto);

    CompanyDto updateCompany(String id, CompanyDto dto);

    CompanyDto uploadLogo(String id, MultipartFile file);

    void deleteCompany(String id);
}