package com.learnos.auth.service;

import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmailService {

    private final JavaMailSender mailSender;

    @Value("${app.mail-from:noreply@learnos.in}")
    private String mailFrom;

    @Async
    public void sendOtpEmail(String to, String name, String otp) {
        String subject = "LearnOS — Verify Your Email";

        String body = buildOtpEmailHtml(
                name,
                otp,
                "Email Verification",
                "Use the OTP below to verify your LearnOS account:"
        );

        sendHtmlEmail(to, subject, body);
    }

    @Async
    public void sendPasswordResetEmail(String to, String name, String otp) {
        String subject = "LearnOS — Password Reset OTP";

        String body = buildOtpEmailHtml(
                name,
                otp,
                "Password Reset",
                "Use the OTP below to reset your LearnOS password:"
        );

        sendHtmlEmail(to, subject, body);
    }

    @Async
    public void sendWelcomeEmail(String to, String name) {
        String subject = "Welcome to LearnOS!";

        String body = """
            <div style="font-family:Calibri,sans-serif;max-width:560px;margin:0 auto;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 4px 16px rgba(0,0,0,.1)">
              <div style="background:#01696f;padding:32px 24px;text-align:center">
                <h1 style="color:#fff;margin:0;font-size:28px">LearnOS</h1>
                <p style="color:rgba(255,255,255,.8);margin:8px 0 0">Learn. Grow. Achieve.</p>
              </div>
              <div style="padding:32px 24px">
                <h2 style="color:#1a202c">Welcome aboard, %s!</h2>
                <p style="color:#64748b">Your account has been verified. Start exploring courses today.</p>
                <a href="#" style="display:inline-block;background:#01696f;color:#fff;padding:14px 28px;border-radius:10px;text-decoration:none;font-weight:600;margin-top:16px">Browse Courses</a>
              </div>
            </div>
            """.formatted(safeName(name));

        sendHtmlEmail(to, subject, body);
    }

    private void sendHtmlEmail(String to, String subject, String body) {
        try {
            MimeMessage message = mailSender.createMimeMessage();

            MimeMessageHelper helper = new MimeMessageHelper(
                    message,
                    true,
                    "UTF-8"
            );

            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(body, true);
            helper.setFrom(mailFrom);

            mailSender.send(message);

            log.info("Email sent to: {}", to);
        } catch (Exception exception) {
            log.error(
                    "Failed to send email to {}: {}",
                    to,
                    exception.getMessage(),
                    exception
            );
        }
    }

    private String buildOtpEmailHtml(
            String name,
            String otp,
            String title,
            String subtitle
    ) {
        return """
            <div style="font-family:Calibri,sans-serif;max-width:560px;margin:0 auto;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 4px 16px rgba(0,0,0,.1)">
              <div style="background:#01696f;padding:32px 24px;text-align:center">
                <h1 style="color:#fff;margin:0;font-size:28px">LearnOS</h1>
                <p style="color:rgba(255,255,255,.8);margin:8px 0 0">%s</p>
              </div>
              <div style="padding:32px 24px">
                <h2 style="color:#1a202c">Hi %s,</h2>
                <p style="color:#64748b;line-height:1.6">%s</p>
                <div style="background:#e0f0f1;border-radius:12px;padding:24px;text-align:center;margin:24px 0">
                  <p style="color:#64748b;margin:0 0 8px;font-size:13px">Your OTP Code</p>
                  <h1 style="color:#01696f;margin:0;font-size:40px;letter-spacing:12px;font-family:monospace">%s</h1>
                  <p style="color:#94a3b8;margin:8px 0 0;font-size:12px">Valid for 10 minutes</p>
                </div>
                <p style="color:#94a3b8;font-size:12px">If you did not request this, please ignore this email.</p>
              </div>
            </div>
            """.formatted(
                title,
                safeName(name),
                subtitle,
                otp
        );
    }

    private String safeName(String name) {
        if (name == null || name.isBlank()) {
            return "there";
        }

        return name.trim();
    }
}