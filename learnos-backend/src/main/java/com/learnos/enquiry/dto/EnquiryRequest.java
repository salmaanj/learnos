package com.learnos.enquiry.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class EnquiryRequest {

    @NotBlank
    @Size(max = 120)
    private String name;

    @NotBlank
    @Size(max = 180)
    private String organization;

    @NotBlank
    @Email
    @Size(max = 254)
    private String email;

    @Size(max = 40)
    private String phone;

    @NotBlank
    @Size(max = 40)
    private String audience;

    @NotBlank
    @Size(max = 180)
    private String subject;

    @NotBlank
    @Size(max = 5000)
    private String message;
}
