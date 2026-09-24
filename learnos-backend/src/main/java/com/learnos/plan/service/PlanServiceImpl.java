package com.learnos.plan.service;

import com.learnos.auth.model.User;
import com.learnos.auth.repository.UserRepository;
import com.learnos.plan.dto.PlanDto;
import com.learnos.plan.entity.Plan;
import com.learnos.plan.repository.PlanRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import com.learnos.auth.service.AuthorizationService;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PlanServiceImpl implements PlanService {

    private final PlanRepository planRepository;
    private final UserRepository userRepository;

    @Override
    public List<PlanDto> getAllPlans() {
        requireSuperAdmin();

        return planRepository.findAllByOrderByDisplayOrderAscNameAsc()
                .stream()
                .map(this::mapToDto)
                .toList();
    }

    @Override
    public List<PlanDto> getActivePlans() {
        return planRepository.findByActiveTrueOrderByDisplayOrderAscNameAsc()
                .stream()
                .map(this::mapToDto)
                .toList();
    }

    @Override
    public PlanDto getPlanById(String id) {
        requireSuperAdmin();
        return mapToDto(findPlan(id));
    }

    @Override
    public PlanDto createPlan(PlanDto dto) {
        requireSuperAdmin();
        validateCode(dto.getCode(), null);

        Plan plan = new Plan();
        applyPlanDetails(plan, dto);

        Plan saved = planRepository.save(plan);
        return mapToDto(saved);
    }

    @Override
    public PlanDto updatePlan(String id, PlanDto dto) {
        requireSuperAdmin();

        Plan plan = findPlan(id);
        validateCode(dto.getCode(), plan.getId());
        applyPlanDetails(plan, dto);

        Plan saved = planRepository.save(plan);
        return mapToDto(saved);
    }

    @Override
    public PlanDto togglePlanStatus(String id) {
        requireSuperAdmin();

        Plan plan = findPlan(id);
        plan.setActive(!Boolean.TRUE.equals(plan.getActive()));

        Plan saved = planRepository.save(plan);
        return mapToDto(saved);
    }

    @Override
    public void deletePlan(String id) {
        requireSuperAdmin();
        planRepository.deleteById(UUID.fromString(id));
    }

    private void applyPlanDetails(Plan plan, PlanDto dto) {
        plan.setCode(normalizeUpperCase(dto.getCode()));
        plan.setName(dto.getName());
        plan.setPrice(dto.getPrice());

        plan.setCurrency(
                (dto.getCurrency() == null || dto.getCurrency().isBlank())
                        ? "INR"
                        : dto.getCurrency().trim().toUpperCase()
        );

        plan.setDurationMonths(dto.getDurationMonths());
        plan.setMaxLearners(dto.getMaxLearners());
        plan.setMaxCourses(dto.getMaxCourses());
        plan.setDescription(dto.getDescription());
        plan.setDisplayOrder(dto.getDisplayOrder());

        if (dto.getActive() != null) {
            plan.setActive(dto.getActive());
        }
    }

    private void validateCode(String code, UUID currentPlanId) {
        if (code == null || code.isBlank()) {
            throw new RuntimeException("Plan code is required");
        }

        planRepository.findByCodeIgnoreCase(code.trim())
                .filter(existing -> !existing.getId().equals(currentPlanId))
                .ifPresent(existing -> {
                    throw new RuntimeException(
                            "A plan with code '" + code + "' already exists"
                    );
                });
    }

    private PlanDto mapToDto(Plan plan) {
        PlanDto dto = new PlanDto();

        dto.setId(plan.getId().toString());
        dto.setCode(plan.getCode());
        dto.setName(plan.getName());
        dto.setPrice(plan.getPrice());
        dto.setCurrency(plan.getCurrency());
        dto.setDurationMonths(plan.getDurationMonths());
        dto.setMaxLearners(plan.getMaxLearners());
        dto.setMaxCourses(plan.getMaxCourses());
        dto.setDescription(plan.getDescription());
        dto.setActive(plan.getActive());
        dto.setDisplayOrder(plan.getDisplayOrder());
        dto.setCreatedAt(plan.getCreatedAt());

        return dto;
    }

    private Plan findPlan(String id) {
        return planRepository.findById(UUID.fromString(id))
                .orElseThrow(() -> new RuntimeException("Plan not found"));
    }

    private void requireSuperAdmin() {
        if (!isSuperAdmin(getCurrentUser())) {
            throw new RuntimeException("Access denied");
        }
    }

    private String normalizeUpperCase(String value) {
        return value == null ? null : value.trim().toUpperCase();
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
    private final AuthorizationService authorizationService;

    private boolean isSuperAdmin(User user) {
        return authorizationService.isSuperAdmin(user);
    }
}