package com.learnos.enquiry.dto;

import com.learnos.enquiry.model.EnquiryStatus;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
public class EnquiryResponse {

    private UUID id;
    private String name;
    private String organization;
    private String email;
    private String phone;
    private String audience;
    private String subject;
    private String message;
    private EnquiryStatus status;
    private boolean read;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
