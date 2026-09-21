package com.learnos.storage.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@Service
@Slf4j
public class S3StorageService {

    @Value("${storage.local.base-path:uploads}")
    private String basePath;

    @Value("${storage.local.base-url:http://localhost:8080/files}")
    private String baseUrl;

    public String uploadFile(MultipartFile file, String folder) throws IOException {
        Path uploadDir = Paths.get(basePath, folder);
        Files.createDirectories(uploadDir);

        String originalName = file.getOriginalFilename();
        String extension = originalName != null && originalName.contains(".")
                ? originalName.substring(originalName.lastIndexOf("."))
                : "";
        String fileName = UUID.randomUUID() + extension;

        Path filePath = uploadDir.resolve(fileName);
        Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

        // NOTE: intentionally relative, not baseUrl + "/" + folder + "/" + fileName.
        // "localhost" only resolves correctly on the same machine as the
        // backend (i.e. a browser). The Android emulator needs 10.0.2.2 to
        // reach the same machine, and a real device on the LAN needs the
        // machine's actual IP. Baking in one absolute host broke it for
        // every client except a browser on the backend's own machine. Each
        // client (web/mobile) now prepends whichever host it already uses
        // successfully to reach the API.
        String url = "/files/" + folder + "/" + fileName;
        log.info("File uploaded locally: {}", url);
        return url;
    }

    // ✅ Added getFolder — auto-detects folder from mime type
    public String getFolder(String mimeType) {
        if (mimeType == null) return "misc";
        if (mimeType.startsWith("video/")) return "lessons";
        if (mimeType.startsWith("audio/")) return "audio";
        if (mimeType.startsWith("image/")) return "thumbnails";
        if (mimeType.equals("application/pdf")) return "documents";
        if (mimeType.contains("presentation") || mimeType.contains("powerpoint")) return "slides";
        return "misc";
    }

    public void deleteFile(String fileUrl) {
        try {
            // Handles both new-style relative paths ("/files/folder/x.ext")
            // and old-style absolute URLs that predate this fix.
            int idx = fileUrl.indexOf("/files/");
            String afterFiles = idx != -1
                    ? fileUrl.substring(idx + "/files/".length())
                    : fileUrl;
            Path filePath = Paths.get(basePath, afterFiles);
            Files.deleteIfExists(filePath);
            log.info("File deleted: {}", filePath);
        } catch (IOException e) {
            log.warn("Could not delete file: {}", fileUrl, e);
        }
    }
}