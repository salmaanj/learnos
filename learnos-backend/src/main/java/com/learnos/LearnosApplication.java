package com.learnos;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration;

@SpringBootApplication(exclude = {SecurityAutoConfiguration.class})
public class LearnosApplication {

    public static void main(String[] args) {
        SpringApplication.run(LearnosApplication.class, args);
    }
}