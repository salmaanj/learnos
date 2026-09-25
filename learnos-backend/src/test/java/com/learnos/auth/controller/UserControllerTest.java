package com.learnos.auth.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.learnos.auth.dto.UserResponse;
import com.learnos.auth.dto.UserUpdateRequest;
import com.learnos.auth.security.JwtUtil;
import com.learnos.auth.service.UserManagementService;
import com.learnos.config.CustomUserDetailsService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(controllers = UserController.class)
@AutoConfigureMockMvc(addFilters = false)
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private UserManagementService userManagementService;

    @MockBean
    private JwtUtil jwtUtil;

    @MockBean
    private CustomUserDetailsService customUserDetailsService;

    @Test
    void updateUserReturns200() throws Exception {
        UUID userId = UUID.randomUUID();

        UserUpdateRequest updateRequest = new UserUpdateRequest(
                "Updated",
                "User",
                "updated@example.com",
                null,
                "9999999999",
                "USER",
                null,
                "ACTIVE"
        );

        UserResponse response = new UserResponse(
                userId,
                "Updated",
                "User",
                "updated@example.com",
                "USER",
                "9999999999",
                "ACTIVE"
        );

        when(userManagementService.updateUser(
                eq(userId),
                any(UserUpdateRequest.class)))
                .thenReturn(response);

        mockMvc.perform(put("/users/{id}", userId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updateRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(userId.toString()))
                .andExpect(jsonPath("$.firstName").value("Updated"))
                .andExpect(jsonPath("$.lastName").value("User"))
                .andExpect(jsonPath("$.email").value("updated@example.com"))
                .andExpect(jsonPath("$.role").value("USER"))
                .andExpect(jsonPath("$.phone").value("9999999999"))
                .andExpect(jsonPath("$.status").value("ACTIVE"));
    }
}
