package com.learnos.storage.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.MalformedURLException;
import java.nio.file.Path;
import java.nio.file.Paths;

@RestController
@RequestMapping("/files")
public class FileController {

    @Value("${storage.local.base-path:uploads}")
    private String basePath;

    @GetMapping("/{folder}/{filename}")
    public ResponseEntity<Resource> serveFile(
            @PathVariable String folder,
            @PathVariable String filename) throws MalformedURLException {

        Path filePath = Paths.get(basePath, folder, filename);
        Resource resource = new UrlResource(filePath.toUri());

        if (!resource.exists() || !resource.isReadable()) {
            return ResponseEntity.notFound().build();
        }

        String contentType = "application/octet-stream";
        if (filename.endsWith(".mp4")) contentType = "video/mp4";
        else if (filename.endsWith(".pdf")) contentType = "application/pdf";
        else if (filename.endsWith(".jpg") || filename.endsWith(".jpeg")) contentType = "image/jpeg";
        else if (filename.endsWith(".png")) contentType = "image/png";

        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(contentType))
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        "inline; filename=\"" + filename + "\"")
                .body(resource);
    }
}