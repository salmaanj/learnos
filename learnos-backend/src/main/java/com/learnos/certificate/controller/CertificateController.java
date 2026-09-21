package com.learnos.certificate.controller;

import com.learnos.certificate.dto.CertificateResponse;
import com.learnos.certificate.dto.CertificateVerifyResponse;
import com.learnos.certificate.service.CertificateService;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/certificates")
@RequiredArgsConstructor
public class CertificateController {

    private final CertificateService certificateService;

    @GetMapping("/my")
    @PreAuthorize("hasRole('LEARNER')")
    public ResponseEntity<List<CertificateResponse>> getMyCertificates() {
        return ResponseEntity.ok(certificateService.getMyCertificates());
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
    public ResponseEntity<List<CertificateResponse>> getCertificatesForAdmin() {
        return ResponseEntity.ok(certificateService.getCertificatesForAdmin());
    }

    @GetMapping("/today")
    @PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
    public ResponseEntity<List<CertificateResponse>> getCertificatesIssuedToday() {
        return ResponseEntity.ok(
                certificateService.getCertificatesIssuedTodayForAdmin()
        );
    }

    @GetMapping("/verify/{verificationCode}")
    public ResponseEntity<CertificateVerifyResponse> verify(
            @PathVariable String verificationCode
    ) {
        return ResponseEntity.ok(certificateService.verify(verificationCode));
    }

    @GetMapping("/{certificateId}/download")
    @PreAuthorize("hasAnyRole('LEARNER','ADMIN','USER','TUTOR')")
    public ResponseEntity<ByteArrayResource> downloadPdf(
            @PathVariable UUID certificateId
    ) {
        byte[] pdfBytes = certificateService
                .downloadCertificatePdf(certificateId);

        String fileName = certificateService
                .getDownloadFileName(certificateId);

        ContentDisposition contentDisposition = ContentDisposition
                .attachment()
                .filename(fileName, StandardCharsets.UTF_8)
                .build();

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_PDF)
                .contentLength(pdfBytes.length)
                .header(
                        HttpHeaders.CONTENT_DISPOSITION,
                        contentDisposition.toString()
                )
                .body(new ByteArrayResource(pdfBytes));
    }

    @PostMapping("/{certificateId}/revoke")
    @PreAuthorize("hasAnyRole('ADMIN','USER','TUTOR')")
    public ResponseEntity<CertificateResponse> revoke(
            @PathVariable UUID certificateId,
            @RequestBody(required = false) Map<String, String> body
    ) {
        String reason = body != null ? body.get("reason") : null;

        return ResponseEntity.ok(
                certificateService.revoke(certificateId, reason)
        );
    }
}