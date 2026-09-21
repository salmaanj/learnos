package com.learnos.plan.service;

import com.learnos.plan.dto.PlanDto;

import java.util.List;

public interface PlanService {

    List<PlanDto> getAllPlans();

    List<PlanDto> getActivePlans();

    PlanDto getPlanById(String id);

    PlanDto createPlan(PlanDto dto);

    PlanDto updatePlan(String id, PlanDto dto);

    PlanDto togglePlanStatus(String id);

    void deletePlan(String id);
}