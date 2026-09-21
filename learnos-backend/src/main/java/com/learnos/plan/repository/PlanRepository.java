package com.learnos.plan.repository;

import com.learnos.plan.entity.Plan;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface PlanRepository extends JpaRepository<Plan, UUID> {

    Optional<Plan> findByCodeIgnoreCase(String code);

    List<Plan> findByActiveTrueOrderByDisplayOrderAscNameAsc();

    List<Plan> findAllByOrderByDisplayOrderAscNameAsc();
}
