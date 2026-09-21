package com.learnos.course.repository;

import com.learnos.course.model.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface CategoryRepository extends JpaRepository<Category, UUID> {
    List<Category> findByActiveTrueOrderByDisplayOrderAsc();
    List<Category> findByCompany_IdAndActiveTrueOrderByDisplayOrderAsc(UUID companyId);
    boolean existsByName(String name);
    boolean existsByNameAndCompany_Id(String name, UUID companyId);
}