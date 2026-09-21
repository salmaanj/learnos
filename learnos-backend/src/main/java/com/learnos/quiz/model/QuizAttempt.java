package com.learnos.quiz.model;

import com.learnos.auth.model.User;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Entity
@Table(name = "quiz_attempts")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id")
public class QuizAttempt {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "quiz_id", nullable = false)
    private Quiz quiz;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    private int totalQuestions;

    private int correctCount;

    private int scorePercent;

    private boolean passed;

    // questionId (as string) -> selected optionId (as string)
    @ElementCollection
    @CollectionTable(name = "quiz_attempt_answers", joinColumns = @JoinColumn(name = "attempt_id"))
    @MapKeyColumn(name = "question_id")
    @Column(name = "selected_option_id")
    @Builder.Default
    private Map<String, String> answers = new HashMap<>();

    @CreationTimestamp
    private LocalDateTime submittedAt;
}
