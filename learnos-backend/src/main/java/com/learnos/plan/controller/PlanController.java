package com.learnos.plan.controller;

import com.learnos.plan.dto.PlanDto;
import com.learnos.plan.service.PlanService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/plans")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class PlanController {

    private final PlanService planService;

    @GetMapping
    public List<PlanDto> getAll() {
        return planService.getAllPlans();
    }

    @GetMapping("/active")
    public List<PlanDto> getActive() {
        return planService.getActivePlans();
    }

    @GetMapping("/{id}")
    public PlanDto getById(@PathVariable String id) {
        return planService.getPlanById(id);
    }

    @PostMapping
    public PlanDto create(@RequestBody PlanDto dto) {
        return planService.createPlan(dto);
    }

    @PutMapping("/{id}")
    public PlanDto update(
            @PathVariable String id,
            @RequestBody PlanDto dto
    ) {
        return planService.updatePlan(id, dto);
    }

    @PatchMapping("/{id}/toggle-status")
    public PlanDto toggleStatus(@PathVariable String id) {
        return planService.togglePlanStatus(id);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable String id) {
        planService.deletePlan(id);
    }
}