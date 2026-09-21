package com.learnos.content.repository;

import com.learnos.content.model.Lesson;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.UUID;

@Repository
public interface LessonRepository extends JpaRepository<Lesson, UUID> {
    List<Lesson> findByModuleIdOrderByDisplayOrderAsc(UUID moduleId);
    long countByModuleId(UUID moduleId);
    long countByModule_Course_IdAndIsPublishedTrue(
            UUID courseId
    );
}
