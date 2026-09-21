package com.learnos.company.service;

import com.learnos.auth.model.User;
import com.learnos.auth.repository.UserRepository;
import com.learnos.company.dto.CompanyDto;
import com.learnos.company.entity.Company;
import com.learnos.company.repository.CompanyRepository;
import com.learnos.companyuser.repository.CompanyUserRepository;
import com.learnos.course.repository.CourseRepository;
import com.learnos.coursepayment.model.CoursePaymentStatus;
import com.learnos.coursepayment.repository.CoursePaymentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CompanyServiceImpl implements CompanyService {

    private static final long MAX_LOGO_SIZE_BYTES = 5 * 1024 * 1024;

    private static final Set<String> ALLOWED_LOGO_TYPES = Set.of(
            "image/png",
            "image/jpeg",
            "image/webp",
            "image/svg+xml"
    );

    private final CompanyRepository companyRepository;
    private final UserRepository userRepository;
    private final CompanyUserRepository companyUserRepository;
    private final CourseRepository courseRepository;
    private final CoursePaymentRepository coursePaymentRepository;

    @Value("${app.upload-dir:uploads}")
    private String uploadDir;

    @Override
    public List<CompanyDto> getAllCompanies() {
        User currentUser = getCurrentUser();

        if (isSuperAdmin(currentUser)) {
            return companyRepository.findAll()
                    .stream()
                    .map(this::mapToDto)
                    .toList();
        }

        if (currentUser != null && currentUser.getCompany() != null) {
            return companyRepository.findById(currentUser.getCompany().getId())
                    .map(company -> List.of(mapToDto(company)))
                    .orElse(List.of());
        }

        return List.of();
    }

    @Override
    public CompanyDto getCompanyById(String id) {
        User currentUser = getCurrentUser();

        Company company = findCompany(id);
        ensureCanAccessCompany(currentUser, company);

        return mapToDto(company);
    }

    @Override
    public CompanyDto createCompany(CompanyDto dto) {
        User currentUser = getCurrentUser();

        if (!isSuperAdmin(currentUser)) {
            throw new RuntimeException("Access denied");
        }

        Company company = new Company();

        applyCompanyDetails(company, dto, true);

        Company saved = companyRepository.save(company);
        return mapToDto(saved);
    }

    @Override
    public CompanyDto updateCompany(String id, CompanyDto dto) {
        User currentUser = getCurrentUser();
        Company company = findCompany(id);

        ensureCanAccessCompany(currentUser, company);

        applyCompanyDetails(company, dto, isSuperAdmin(currentUser));

        Company saved = companyRepository.save(company);
        return mapToDto(saved);
    }

    @Override
    public CompanyDto uploadLogo(String id, MultipartFile file) {
        User currentUser = getCurrentUser();
        Company company = findCompany(id);

        ensureCanAccessCompany(currentUser, company);
        validateLogoFile(file);

        try {
            Path logoDirectory = Paths.get(uploadDir, "company-logos")
                    .toAbsolutePath()
                    .normalize();

            Files.createDirectories(logoDirectory);

            String extension = getFileExtension(file.getOriginalFilename());
            String fileName = company.getId()
                    + "-"
                    + System.currentTimeMillis()
                    + extension;

            Path destination = logoDirectory.resolve(fileName).normalize();

            if (!destination.startsWith(logoDirectory)) {
                throw new RuntimeException("Invalid logo file path");
            }

            Files.copy(
                    file.getInputStream(),
                    destination,
                    StandardCopyOption.REPLACE_EXISTING
            );

            String oldLogoUrl = company.getLogoUrl();
            company.setLogoUrl("/files/company-logos/" + fileName);

            Company saved = companyRepository.save(company);

            deleteOldLocalLogo(oldLogoUrl);

            return mapToDto(saved);
        } catch (IOException exception) {
            throw new RuntimeException("Could not save company logo", exception);
        }
    }

    @Override
    public void deleteCompany(String id) {
        User currentUser = getCurrentUser();

        if (!isSuperAdmin(currentUser)) {
            throw new RuntimeException("Access denied");
        }

        companyRepository.deleteById(UUID.fromString(id));
    }

    private void applyCompanyDetails(
            Company company,
            CompanyDto dto,
            boolean canChangeAdministrativeFields
    ) {
        company.setName(dto.getName());
        company.setIndustry(dto.getIndustry());
        company.setEmail(dto.getEmail());
        company.setPhone(dto.getPhone());
        company.setContactPhone(dto.getContactPhone());
        company.setDomain(dto.getDomain());

        company.setAddress(dto.getAddress());
        company.setCity(dto.getCity());
        company.setState(dto.getState());
        company.setPinCode(dto.getPinCode());
        company.setCountry(dto.getCountry());

        company.setGstNumber(normalizeUpperCase(dto.getGstNumber()));
        company.setPanNumber(normalizeUpperCase(dto.getPanNumber()));
        company.setCinNumber(normalizeUpperCase(dto.getCinNumber()));

        company.setPrimaryColor(dto.getPrimaryColor());
        company.setSecondaryColor(dto.getSecondaryColor());
        company.setAccentColor(dto.getAccentColor());

        if (canChangeAdministrativeFields) {
            company.setCompanyCode(dto.getCompanyCode());
            company.setStatus(dto.getStatus());

            company.setPlanCode(normalizeUpperCase(dto.getPlanCode()));
            company.setPlanStartDate(dto.getPlanStartDate());
            company.setPlanExpiryDate(dto.getPlanExpiryDate());

            if (dto.getCanCreateCourses() != null) {
                company.setCanCreateCourses(dto.getCanCreateCourses());
            }
        }
    }

    private CompanyDto mapToDto(Company company) {
        CompanyDto dto = new CompanyDto(
                company.getId().toString(),
                company.getName(),
                company.getIndustry(),
                company.getCompanyCode(),
                company.getEmail(),
                company.getPhone(),
                company.getDomain(),
                company.getStatus()
        );

        dto.setContactPhone(company.getContactPhone());

        dto.setAddress(company.getAddress());
        dto.setCity(company.getCity());
        dto.setState(company.getState());
        dto.setPinCode(company.getPinCode());
        dto.setCountry(company.getCountry());

        dto.setGstNumber(company.getGstNumber());
        dto.setPanNumber(company.getPanNumber());
        dto.setCinNumber(company.getCinNumber());

        dto.setLogoUrl(company.getLogoUrl());

        dto.setPrimaryColor(company.getPrimaryColor());
        dto.setSecondaryColor(company.getSecondaryColor());
        dto.setAccentColor(company.getAccentColor());

        dto.setPlanCode(company.getPlanCode());
        dto.setPlanStartDate(company.getPlanStartDate());
        dto.setPlanExpiryDate(company.getPlanExpiryDate());

        dto.setMaxLearners(company.getMaxLearners());
        dto.setMaxCourses(company.getMaxCourses());
        dto.setCanCreateCourses(company.getCanCreateCourses());

        long learnerCount = companyUserRepository
                .findByCompany_Id(company.getId())
                .stream()
                .filter(companyUser ->
                        companyUser.getRole() == null
                                || "LEARNER".equalsIgnoreCase(
                                companyUser.getRole()
                        )
                )
                .count();

        dto.setLearnerCount(learnerCount);
        dto.setCourseCount(courseRepository.countByCompanyId(company.getId()));

        BigDecimal courseRevenue =
                coursePaymentRepository
                        .sumAmountByCompanyIdAndStatus(
                                company.getId(),
                                CoursePaymentStatus.ACTIVE
                        );

        dto.setCourseRevenue(
                courseRevenue != null
                        ? courseRevenue
                        : BigDecimal.ZERO
        );

        dto.setCreatedAt(company.getCreatedAt());

        return dto;
    }

    private Company findCompany(String id) {
        return companyRepository.findById(UUID.fromString(id))
                .orElseThrow(() -> new RuntimeException("Company not found"));
    }

    private void ensureCanAccessCompany(User currentUser, Company company) {
        if (isSuperAdmin(currentUser)) {
            return;
        }

        if (
                currentUser == null
                        || currentUser.getCompany() == null
                        || !currentUser.getCompany().getId().equals(company.getId())
        ) {
            throw new RuntimeException("Access denied");
        }
    }

    private void validateLogoFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new RuntimeException("Please select a logo file");
        }

        if (file.getSize() > MAX_LOGO_SIZE_BYTES) {
            throw new RuntimeException("Logo file size must be 5 MB or less");
        }

        String contentType = file.getContentType();

        if (contentType == null || !ALLOWED_LOGO_TYPES.contains(contentType)) {
            throw new RuntimeException(
                    "Only PNG, JPG, WebP, and SVG logo files are allowed"
            );
        }
    }

    private String getFileExtension(String originalFileName) {
        if (originalFileName == null || !originalFileName.contains(".")) {
            return ".png";
        }

        String extension = originalFileName
                .substring(originalFileName.lastIndexOf('.'))
                .toLowerCase();

        if (
                !extension.equals(".png")
                        && !extension.equals(".jpg")
                        && !extension.equals(".jpeg")
                        && !extension.equals(".webp")
                        && !extension.equals(".svg")
        ) {
            return ".png";
        }

        return extension;
    }

    private void deleteOldLocalLogo(String logoUrl) {
        if (
                logoUrl == null
                        || !logoUrl.startsWith("/files/company-logos/")
        ) {
            return;
        }

        try {
            String fileName = logoUrl.substring(
                    "/files/company-logos/".length()
            );

            Path oldLogoPath = Paths.get(
                    uploadDir,
                    "company-logos",
                    fileName
            ).toAbsolutePath().normalize();

            Files.deleteIfExists(oldLogoPath);
        } catch (IOException ignored) {
            // The replacement logo was saved successfully.
        }
    }

    private String normalizeUpperCase(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }

        return value.trim().toUpperCase();
    }

    private User getCurrentUser() {
        Authentication auth = SecurityContextHolder
                .getContext()
                .getAuthentication();

        if (auth == null || auth.getName() == null) {
            return null;
        }

        return userRepository.findByEmail(auth.getName()).orElse(null);
    }

    private boolean isSuperAdmin(User user) {
        return user != null
                && user.getEmail() != null
                && user.getEmail().equalsIgnoreCase("admin@blute.co.in");
    }
}