package com.learnos.course.repository;

import com.learnos.course.model.Category;
import com.learnos.course.model.Course;
import com.learnos.course.model.CourseStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface CourseRepository extends JpaRepository<Course, UUID> {

    Page<Course> findByStatus(CourseStatus status, Pageable pageable);
    Page<Course> findByCategoryIdAndStatus(UUID categoryId, CourseStatus status, Pageable pageable);
    Page<Course> findByInstructorId(UUID instructorId, Pageable pageable);
    Page<Course> findByCompanyId(UUID companyId, Pageable pageable);
    Page<Course> findByCompanyIdAndStatus(UUID companyId, CourseStatus status, Pageable pageable);

    Page<Course> findByTitleContainingIgnoreCase(String title, Pageable pageable);
    Page<Course> findByCategory_Id(UUID categoryId, Pageable pageable);

    @Query("SELECT c FROM Course c WHERE c.status = 'PUBLISHED' AND c.company.id = :companyId")
    Page<Course> findByStatusAndCompanyId(@Param("companyId") UUID companyId, Pageable pageable);

    @Query("""
        SELECT c FROM Course c WHERE c.status = 'PUBLISHED'
        AND c.company.id = :companyId
        AND (LOWER(c.title) LIKE LOWER(CONCAT('%',:query,'%'))
        OR LOWER(c.description) LIKE LOWER(CONCAT('%',:query,'%')))
        """)
    Page<Course> searchCoursesByCompany(@Param("companyId") UUID companyId,
                                        @Param("query") String query,
                                        Pageable pageable);

    @Query("""
        SELECT c FROM Course c WHERE c.status = 'PUBLISHED'
        AND c.company.id = :companyId AND c.category.id = :categoryId
        """)
    Page<Course> findByCategoryIdAndStatusAndCompanyId(@Param("categoryId") UUID categoryId,
                                                       @Param("companyId") UUID companyId,
                                                       Pageable pageable);

    List<Course> findByCompanyId(UUID companyId);
    long countByCompanyId(UUID companyId);
    long countByStatus(CourseStatus status);
    long countByCategory_Id(UUID categoryId);

    @Query("SELECT DISTINCT c FROM Course c LEFT JOIN FETCH c.modules WHERE c.id = :id")
    Optional<Course> findWithModulesById(@Param("id") UUID id);
}