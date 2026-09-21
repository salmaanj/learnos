package com.learnos.course.repository;

import com.learnos.course.model.CourseModule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ModuleRepository extends JpaRepository<CourseModule, UUID> {
    List<CourseModule> findByCourseIdOrderByDisplayOrderAsc(UUID courseId);

}