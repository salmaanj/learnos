package com.learnos.auth.controller;

import com.learnos.auth.dto.PermissionResponse;
import com.learnos.auth.dto.RoleResponse;
import com.learnos.auth.service.RoleManagementService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequiredArgsConstructor
@RequestMapping("/roles")
@PreAuthorize("hasRole('SUPER_ADMIN')")
public class RoleManagementController {

    private final RoleManagementService roleManagementService;

    @GetMapping
    public ResponseEntity<List<RoleResponse>> getRoles() {
        return ResponseEntity.ok(
                roleManagementService.getRoles()
        );
    }

    @GetMapping("/{id}")
    public ResponseEntity<RoleResponse> getRole(
            @PathVariable UUID id
    ) {
        return ResponseEntity.ok(
                roleManagementService.getRole(id)
        );
    }

    @GetMapping("/permissions")
    public ResponseEntity<List<PermissionResponse>> getPermissions() {
        return ResponseEntity.ok(
                roleManagementService.getPermissions()
        );
    }
}