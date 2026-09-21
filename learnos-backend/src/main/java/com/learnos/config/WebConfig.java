package com.learnos.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Value("${app.upload-dir:uploads}")
    private String uploadDir;

    @Override
    public void addResourceHandlers(
            ResourceHandlerRegistry registry
    ) {
        Path uploadPath = resolveUploadPath();

        registry
                .addResourceHandler("/files/**")
                .addResourceLocations(
                        uploadPath.toUri().toString()
                );
    }

    private Path resolveUploadPath() {
        Path configuredPath = Paths.get(uploadDir)
                .toAbsolutePath()
                .normalize();

        if (Files.exists(configuredPath)) {
            return configuredPath;
        }

        Path projectPath = Paths.get(
                System.getProperty("user.dir"),
                "uploads"
        ).toAbsolutePath().normalize();

        if (Files.exists(projectPath)) {
            return projectPath;
        }

        throw new IllegalStateException(
                "Upload directory does not exist. Checked: "
                        + configuredPath
                        + " and "
                        + projectPath
        );
    }
}
