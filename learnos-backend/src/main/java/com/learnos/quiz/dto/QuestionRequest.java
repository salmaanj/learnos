package com.learnos.quiz.dto;

import java.util.List;

public record QuestionRequest(
        String text,
        String type, // "MCQ" or "TRUE_FALSE"
        List<OptionRequest> options
) {}
