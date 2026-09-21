package com.learnos.company.controller;

import com.learnos.company.dto.CompanyDto;
import com.learnos.company.service.CompanyService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/companies")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class CompanyController {

    private final CompanyService companyService;

    @GetMapping
    public List<CompanyDto> getAll() {
        return companyService.getAllCompanies();
    }

    @GetMapping("/{id}")
    public CompanyDto getById(@PathVariable String id) {
        return companyService.getCompanyById(id);
    }

    @PostMapping
    public CompanyDto create(@RequestBody CompanyDto dto) {
        return companyService.createCompany(dto);
    }

    @PutMapping("/{id}")
    public CompanyDto update(
            @PathVariable String id,
            @RequestBody CompanyDto dto
    ) {
        return companyService.updateCompany(id, dto);
    }

    @PostMapping(
            value = "/{id}/logo",
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    public CompanyDto uploadLogo(
            @PathVariable String id,
            @RequestParam("file") MultipartFile file
    ) {
        return companyService.uploadLogo(id, file);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable String id) {
        companyService.deleteCompany(id);
    }
}