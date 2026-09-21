package com.learnos.certificate.service;

import com.learnos.certificate.model.Certificate;
import com.learnos.companyuser.entity.CompanyUser;
import com.learnos.companyuser.repository.CompanyUserRepository;
import com.lowagie.text.Document;
import com.lowagie.text.Element;
import com.lowagie.text.Image;
import com.lowagie.text.PageSize;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.PdfWriter;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CertificatePdfService {

    private static final Color NAVY = new Color(11, 45, 94);
    private static final Color NAVY_DEEP = new Color(5, 27, 65);
    private static final Color NAVY_MID = new Color(22, 68, 130);
    private static final Color GOLD = new Color(191, 151, 62);
    private static final Color GOLD_LIGHT = new Color(224, 196, 128);
    private static final Color TEXT_GRAY = new Color(80, 88, 99);
    private static final Color WHITE = Color.WHITE;

    private static final DateTimeFormatter DATE_FORMAT =
            DateTimeFormatter.ofPattern("dd-MM-yyyy");

    private final CompanyUserRepository companyUserRepository;

    @Value("${app.upload-dir:uploads}")
    private String uploadDir;

    public byte[] generate(Certificate certificate) {
        if (certificate == null) {
            throw new RuntimeException("Certificate not found.");
        }

        try (ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {
            Rectangle pageSize = PageSize.A4.rotate();

            Document document = new Document(pageSize, 0, 0, 0, 0);
            PdfWriter writer = PdfWriter.getInstance(document, outputStream);

            document.open();

            PdfContentByte canvas = writer.getDirectContent();

            float width = pageSize.getWidth();
            float height = pageSize.getHeight();

            drawPageBackground(canvas, width, height);
            drawInnerFrame(canvas, width, height);
            drawTopBranding(canvas, certificate, width, height);
            drawMainCertificate(canvas, certificate, width, height);
            drawBottomSection(canvas, certificate, width, height);

            document.close();

            return outputStream.toByteArray();
        } catch (Exception exception) {
            throw new RuntimeException(
                    "Unable to generate certificate PDF.",
                    exception
            );
        }
    }

    private void drawPageBackground(
            PdfContentByte canvas,
            float width,
            float height
    ) {
        canvas.saveState();

        canvas.setColorFill(WHITE);
        canvas.rectangle(0, 0, width, height);
        canvas.fill();

        canvas.setColorFill(new Color(250, 251, 253));
        canvas.rectangle(18, 18, width - 36, height - 36);
        canvas.fill();

        drawCornerDecoration(canvas, 0, height, 1, -1);
        drawCornerDecoration(canvas, width, height, -1, -1);
        drawCornerDecoration(canvas, 0, 0, 1, 1);
        drawCornerDecoration(canvas, width, 0, -1, 1);

        canvas.restoreState();
    }

    private void drawCornerDecoration(
            PdfContentByte canvas,
            float x,
            float y,
            float horizontalDirection,
            float verticalDirection
    ) {
        canvas.saveState();

        float outer = 84f;
        float inner = 51f;

        canvas.setColorFill(NAVY_DEEP);
        canvas.moveTo(x, y);
        canvas.lineTo(x + outer * horizontalDirection, y);
        canvas.lineTo(x, y + outer * verticalDirection);
        canvas.closePath();
        canvas.fill();

        canvas.setColorFill(NAVY_MID);
        canvas.moveTo(x, y + 18f * verticalDirection);
        canvas.lineTo(
                x + inner * horizontalDirection,
                y + 53f * verticalDirection
        );
        canvas.lineTo(x, y + 122f * verticalDirection);
        canvas.closePath();
        canvas.fill();

        canvas.setColorStroke(GOLD);
        canvas.setLineWidth(1.2f);
        canvas.moveTo(
                x + 13f * horizontalDirection,
                y + 13f * verticalDirection
        );
        canvas.lineTo(
                x + 57f * horizontalDirection,
                y + 57f * verticalDirection
        );
        canvas.stroke();

        canvas.restoreState();
    }

    private void drawInnerFrame(
            PdfContentByte canvas,
            float width,
            float height
    ) {
        canvas.saveState();

        canvas.setLineWidth(2.1f);
        canvas.setColorStroke(GOLD);
        canvas.rectangle(17, 17, width - 34, height - 34);
        canvas.stroke();

        canvas.setLineWidth(0.7f);
        canvas.setColorStroke(GOLD_LIGHT);
        canvas.rectangle(26, 26, width - 52, height - 52);
        canvas.stroke();

        canvas.restoreState();
    }

    private void drawTopBranding(
            PdfContentByte canvas,
            Certificate certificate,
            float width,
            float height
    ) {
        float topCenterY = height - 67;

        drawLearnOsLogo(
                canvas,
                126,
                topCenterY,
                150,
                62
        );

        drawCompanyLogo(
                canvas,
                certificate,
                width - 126,
                topCenterY,
                140,
                58
        );

        canvas.saveState();
        canvas.setLineWidth(0.6f);
        canvas.setColorStroke(new Color(216, 221, 228));
        canvas.moveTo(width / 2f, height - 94);
        canvas.lineTo(width / 2f, height - 48);
        canvas.stroke();
        canvas.restoreState();
    }

    private void drawLearnOsLogo(
            PdfContentByte canvas,
            float centerX,
            float centerY,
            float maxWidth,
            float maxHeight
    ) {
        try (InputStream inputStream = new ClassPathResource(
                "static/certificate-assets/learnos-logo.png"
        ).getInputStream()) {
            Image logo = Image.getInstance(inputStream.readAllBytes());

            logo.scaleToFit(maxWidth, maxHeight);

            logo.setAbsolutePosition(
                    centerX - logo.getScaledWidth() / 2f,
                    centerY - logo.getScaledHeight() / 2f
            );

            canvas.addImage(logo);
        } catch (Exception ignored) {
            drawText(
                    canvas,
                    "LearnOS",
                    BaseFont.HELVETICA_BOLD,
                    18,
                    NAVY,
                    centerX,
                    centerY,
                    Element.ALIGN_CENTER
            );
        }
    }

    private void drawCompanyLogo(
            PdfContentByte canvas,
            Certificate certificate,
            float centerX,
            float centerY,
            float maxWidth,
            float maxHeight
    ) {
        Path logoPath = resolveCompanyLogoPath(certificate);

        if (logoPath == null || !Files.exists(logoPath)) {
            drawText(
                    canvas,
                    companyName(certificate),
                    BaseFont.HELVETICA_BOLD,
                    14,
                    NAVY,
                    centerX,
                    centerY,
                    Element.ALIGN_CENTER
            );
            return;
        }

        try {
            Image logo = Image.getInstance(logoPath.toAbsolutePath().toString());

            logo.scaleToFit(maxWidth, maxHeight);

            logo.setAbsolutePosition(
                    centerX - logo.getScaledWidth() / 2f,
                    centerY - logo.getScaledHeight() / 2f
            );

            canvas.addImage(logo);
        } catch (Exception ignored) {
            drawText(
                    canvas,
                    companyName(certificate),
                    BaseFont.HELVETICA_BOLD,
                    14,
                    NAVY,
                    centerX,
                    centerY,
                    Element.ALIGN_CENTER
            );
        }
    }

    private void drawMainCertificate(
            PdfContentByte canvas,
            Certificate certificate,
            float width,
            float height
    ) {
        String learnerName = safeText(
                certificate.getLearnerName(),
                "Learner"
        );

        String courseTitle = safeText(
                certificate.getCourseTitle(),
                "Course"
        );

        String shortDescription = courseShortDescription(certificate);

        drawText(
                canvas,
                "CERTIFICATE",
                BaseFont.TIMES_BOLD,
                42,
                NAVY,
                width / 2f,
                height - 155,
                Element.ALIGN_CENTER
        );

        float completionY = height - 184;

        drawText(
                canvas,
                "OF COMPLETION",
                BaseFont.HELVETICA,
                16,
                TEXT_GRAY,
                width / 2f,
                completionY,
                Element.ALIGN_CENTER
        );

        drawCompletionLines(
                canvas,
                width / 2f,
                completionY + 5f
        );

        drawText(
                canvas,
                "THIS IS TO CERTIFY THAT",
                BaseFont.HELVETICA_BOLD,
                10,
                TEXT_GRAY,
                width / 2f,
                height - 223,
                Element.ALIGN_CENTER
        );

        float learnerFontSize = fitFontSize(
                learnerName,
                BaseFont.TIMES_ITALIC,
                39,
                23,
                width - 210
        );

        drawText(
                canvas,
                learnerName,
                BaseFont.TIMES_ITALIC,
                learnerFontSize,
                NAVY,
                width / 2f,
                height - 287,
                Element.ALIGN_CENTER
        );

        drawNameRule(
                canvas,
                width / 2f,
                height - 306
        );

        drawText(
                canvas,
                "HAS SUCCESSFULLY COMPLETED THE COURSE",
                BaseFont.HELVETICA_BOLD,
                10,
                TEXT_GRAY,
                width / 2f,
                height - 337,
                Element.ALIGN_CENTER
        );

        float courseFontSize = fitFontSize(
                courseTitle,
                BaseFont.HELVETICA_BOLD,
                25,
                16,
                width - 250
        );

        drawText(
                canvas,
                courseTitle,
                BaseFont.HELVETICA_BOLD,
                courseFontSize,
                NAVY,
                width / 2f,
                height - 371,
                Element.ALIGN_CENTER
        );

        drawWrappedCenteredText(
                canvas,
                shortDescription,
                BaseFont.HELVETICA,
                9.5f,
                TEXT_GRAY,
                width / 2f,
                height - 399,
                width - 270,
                13
        );
    }

    private void drawBottomSection(
            PdfContentByte canvas,
            Certificate certificate,
            float width,
            float height
    ) {
        String issuedDate = certificate.getIssuedAt() != null
                ? certificate.getIssuedAt().format(DATE_FORMAT)
                : "—";

        String score = certificate.getQuizScorePercent() != null
                ? certificate.getQuizScorePercent() + "%"
                : "Passed";

        String companyHead = findCompanyHeadName(certificate);

        drawHeadBlock(
                canvas,
                companyHead,
                companyName(certificate),
                155,
                128
        );

        drawCompletionBlock(
                canvas,
                issuedDate,
                width / 2f,
                128
        );

        drawSilverEmblem(
                canvas,
                width - 132,
                87,
                112,
                92
        );

        drawDetailBlock(
                canvas,
                certificate,
                width,
                42,
                score
        );
    }

    private void drawHeadBlock(
            PdfContentByte canvas,
            String headName,
            String companyName,
            float x,
            float y
    ) {
        canvas.saveState();
        canvas.setLineWidth(0.8f);
        canvas.setColorStroke(GOLD);
        canvas.moveTo(x - 70, y);
        canvas.lineTo(x + 70, y);
        canvas.stroke();
        canvas.restoreState();

        drawText(
                canvas,
                headName,
                BaseFont.HELVETICA_BOLD,
                fitFontSize(
                        headName,
                        BaseFont.HELVETICA_BOLD,
                        11,
                        8,
                        170
                ),
                NAVY,
                x,
                y - 17,
                Element.ALIGN_CENTER
        );

        drawText(
                canvas,
                "Head - Learning Initiatives",
                BaseFont.HELVETICA,
                8,
                TEXT_GRAY,
                x,
                y - 31,
                Element.ALIGN_CENTER
        );

        drawText(
                canvas,
                companyName,
                BaseFont.HELVETICA,
                8,
                TEXT_GRAY,
                x,
                y - 44,
                Element.ALIGN_CENTER
        );
    }

    private void drawCompletionBlock(
            PdfContentByte canvas,
            String issuedDate,
            float centerX,
            float y
    ) {
        drawText(
                canvas,
                "DATE OF COMPLETION",
                BaseFont.HELVETICA_BOLD,
                8,
                TEXT_GRAY,
                centerX,
                y - 10,
                Element.ALIGN_CENTER
        );

        drawText(
                canvas,
                issuedDate,
                BaseFont.HELVETICA_BOLD,
                13,
                NAVY,
                centerX,
                y - 29,
                Element.ALIGN_CENTER
        );

        drawText(
                canvas,
                "CERTIFIED BY LEARNOS",
                BaseFont.HELVETICA,
                7.5f,
                TEXT_GRAY,
                centerX,
                y - 43,
                Element.ALIGN_CENTER
        );
    }

    private void drawSilverEmblem(
            PdfContentByte canvas,
            float centerX,
            float centerY,
            float maxWidth,
            float maxHeight
    ) {
        try (InputStream inputStream = new ClassPathResource(
                "static/certificate-assets/learnos-silver-emblem.png"
        ).getInputStream()) {
            Image emblem = Image.getInstance(inputStream.readAllBytes());

            emblem.scaleToFit(maxWidth, maxHeight);

            emblem.setAbsolutePosition(
                    centerX - emblem.getScaledWidth() / 2f,
                    centerY - emblem.getScaledHeight() / 2f
            );

            canvas.addImage(emblem);
        } catch (Exception ignored) {
            // The emblem is optional at runtime.
            // Do not render a circle, check mark, or large "L" placeholder.
        }
    }

    private void drawDetailBlock(
            PdfContentByte canvas,
            Certificate certificate,
            float width,
            float y,
            String score
    ) {
        String certificateNumber = safeText(
                certificate.getCertificateNumber(),
                "—"
        );

        String verificationCode = safeText(
                certificate.getVerificationCode(),
                "—"
        );

        float textCenterX = width / 2f;
        float availableWidth = width - 330;

        String firstLine = "ASSESSMENT SCORE  " + score
                + "      |      CERTIFICATE NO.  "
                + certificateNumber;

        float fontSize = fitFontSize(
                firstLine,
                BaseFont.HELVETICA_BOLD,
                7.5f,
                6.2f,
                availableWidth
        );

        drawText(
                canvas,
                firstLine,
                BaseFont.HELVETICA_BOLD,
                fontSize,
                TEXT_GRAY,
                textCenterX,
                y + 13,
                Element.ALIGN_CENTER
        );

        drawText(
                canvas,
                "VERIFICATION CODE  " + verificationCode,
                BaseFont.HELVETICA_BOLD,
                7.2f,
                TEXT_GRAY,
                textCenterX,
                y,
                Element.ALIGN_CENTER
        );
    }

    private void drawCompletionLines(
            PdfContentByte canvas,
            float centerX,
            float y
    ) {
        canvas.saveState();

        canvas.setColorStroke(GOLD);
        canvas.setLineWidth(0.7f);

        canvas.moveTo(centerX - 190, y);
        canvas.lineTo(centerX - 72, y);
        canvas.stroke();

        canvas.moveTo(centerX + 72, y);
        canvas.lineTo(centerX + 190, y);
        canvas.stroke();

        canvas.restoreState();
    }

    private void drawNameRule(
            PdfContentByte canvas,
            float centerX,
            float y
    ) {
        canvas.saveState();

        canvas.setColorStroke(GOLD_LIGHT);
        canvas.setLineWidth(0.8f);

        canvas.moveTo(centerX - 185, y);
        canvas.lineTo(centerX - 12, y);
        canvas.stroke();

        canvas.moveTo(centerX + 12, y);
        canvas.lineTo(centerX + 185, y);
        canvas.stroke();

        canvas.setColorFill(GOLD);
        canvas.circle(centerX, y, 4.5f);
        canvas.fill();

        canvas.restoreState();
    }

    private String findCompanyHeadName(Certificate certificate) {
        if (certificate.getCompany() == null
                || certificate.getCompany().getId() == null) {
            return companyName(certificate);
        }

        UUID companyId = certificate.getCompany().getId();

        List<CompanyUser> admins = companyUserRepository
                .findByCompany_IdAndRoleIgnoreCaseAndStatusIgnoreCaseOrderByIdAsc(
                        companyId,
                        "ADMIN",
                        "ACTIVE"
                );

        if (!admins.isEmpty()
                && admins.get(0).getUser() != null
                && admins.get(0).getUser().getFullName() != null
                && !admins.get(0).getUser().getFullName().isBlank()) {
            return admins.get(0).getUser().getFullName().trim();
        }

        return companyName(certificate);
    }

    private Path resolveCompanyLogoPath(Certificate certificate) {
        if (certificate.getCompany() == null) {
            return null;
        }

        String logoUrl = certificate.getCompany().getLogoUrl();

        if (logoUrl == null || logoUrl.isBlank()) {
            return null;
        }

        String normalized = logoUrl.trim().replace("\\", "/");

        if (!normalized.startsWith("/files/")) {
            return null;
        }

        String relativePath = normalized.substring("/files/".length());

        Path uploadBase = Paths.get(uploadDir)
                .toAbsolutePath()
                .normalize();

        Path logoPath = uploadBase
                .resolve(relativePath)
                .normalize();

        if (!logoPath.startsWith(uploadBase)) {
            return null;
        }

        return logoPath;
    }

    private String courseShortDescription(Certificate certificate) {
        if (certificate.getCourse() != null
                && certificate.getCourse().getShortDescription() != null
                && !certificate.getCourse().getShortDescription().isBlank()) {
            return certificate.getCourse()
                    .getShortDescription()
                    .trim();
        }

        return "This certificate recognizes successful completion of the course and its required assessment.";
    }

    private String companyName(Certificate certificate) {
        if (certificate.getCompany() != null
                && certificate.getCompany().getName() != null
                && !certificate.getCompany().getName().isBlank()) {
            return certificate.getCompany().getName().trim();
        }

        return safeText(
                certificate.getCompanyName(),
                "LearnOS"
        );
    }

    private void drawWrappedCenteredText(
            PdfContentByte canvas,
            String text,
            String fontName,
            float fontSize,
            Color color,
            float centerX,
            float startY,
            float maxWidth,
            float lineGap
    ) {
        String[] words = safeText(text, "").split("\\s+");

        StringBuilder line = new StringBuilder();
        float currentY = startY;

        for (String word : words) {
            String candidate = line.isEmpty()
                    ? word
                    : line + " " + word;

            if (textWidth(candidate, fontName, fontSize) > maxWidth
                    && !line.isEmpty()) {
                drawText(
                        canvas,
                        line.toString(),
                        fontName,
                        fontSize,
                        color,
                        centerX,
                        currentY,
                        Element.ALIGN_CENTER
                );

                currentY -= lineGap;
                line = new StringBuilder(word);

                if (currentY < 177) {
                    break;
                }
            } else {
                line = new StringBuilder(candidate);
            }
        }

        if (!line.isEmpty() && currentY >= 177) {
            drawText(
                    canvas,
                    line.toString(),
                    fontName,
                    fontSize,
                    color,
                    centerX,
                    currentY,
                    Element.ALIGN_CENTER
            );
        }
    }

    private void drawText(
            PdfContentByte canvas,
            String text,
            String fontName,
            float size,
            Color color,
            float x,
            float y,
            int alignment
    ) {
        try {
            BaseFont font = BaseFont.createFont(
                    fontName,
                    BaseFont.WINANSI,
                    BaseFont.EMBEDDED
            );

            canvas.saveState();
            canvas.beginText();
            canvas.setFontAndSize(font, size);
            canvas.setColorFill(color);
            canvas.showTextAligned(
                    alignment,
                    safeText(text, ""),
                    x,
                    y,
                    0
            );
            canvas.endText();
            canvas.restoreState();
        } catch (Exception exception) {
            throw new RuntimeException(
                    "Unable to render certificate text.",
                    exception
            );
        }
    }

    private float fitFontSize(
            String text,
            String fontName,
            float preferredSize,
            float minimumSize,
            float maximumWidth
    ) {
        float size = preferredSize;

        while (size > minimumSize
                && textWidth(text, fontName, size) > maximumWidth) {
            size -= 1f;
        }

        return size;
    }

    private float textWidth(
            String text,
            String fontName,
            float size
    ) {
        try {
            BaseFont font = BaseFont.createFont(
                    fontName,
                    BaseFont.WINANSI,
                    BaseFont.EMBEDDED
            );

            return font.getWidthPoint(
                    safeText(text, ""),
                    size
            );
        } catch (Exception exception) {
            return Float.MAX_VALUE;
        }
    }

    private String safeText(
            String value,
            String fallback
    ) {
        if (value == null || value.isBlank()) {
            return fallback;
        }

        return value.trim();
    }
}