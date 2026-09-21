package com.learnos.quiz.dto;

public record OptionRequest(
        String text,
        boolean correct
) {}
