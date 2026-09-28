package com.learnos.auth.controller;

import com.learnos.auth.dto.CreateRoleRequest;
import com.learnos.auth.dto.PermissionResponse;
import com.learnos.auth.dto.RoleResponse;
import com.learnos.auth.dto.UpdateRoleRequest;
import com.learnos.auth.service.RoleManagementService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequiredArgsConstructor
@RequestMapping("/roles")
public class RoleManagementController {

    private final RoleManagementService roleManagementService;

    @GetMapping
    @PreAuthorize("hasAnyRole('SUPER_ADMIN', 'ADMIN')")
    public ResponseEntity<List<RoleResponse>> getRoles() {
        return ResponseEntity.ok(
                roleManagementService.getRoles()
        );
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('SUPER_ADMIN', 'ADMIN')")
    public ResponseEntity<RoleResponse> getRole(
            @PathVariable UUID id
    ) {
        return ResponseEntity.ok(
                roleManagementService.getRole(id)
        );
    }

    @GetMapping("/permissions")
    @PreAuthorize("hasAnyRole('SUPER_ADMIN', 'ADMIN')")
    public ResponseEntity<List<PermissionResponse>> getPermissions() {
        return ResponseEntity.ok(
                roleManagementService.getPermissions()
        );
    }

    @PostMapping
    @PreAuthorize("hasAuthority('ROLE_CREATE')")
    public ResponseEntity<RoleResponse> createRole(
            @Valid @RequestBody CreateRoleRequest request
    ) {
        return ResponseEntity.status(201)
                .body(roleManagementService.createRole(request));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAuthority('ROLE_UPDATE')")
    public ResponseEntity<RoleResponse> updateRole(
            @PathVariable UUID id,
            @Valid @RequestBody UpdateRoleRequest request
    ) {
        return ResponseEntity.ok(
                roleManagementService.updateRole(id, request)
        );
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('ROLE_DELETE')")
    public ResponseEntity<Void> deleteRole(
            @PathVariable UUID id
    ) {
        roleManagementService.deleteRole(id);
        return ResponseEntity.noContent().build();
    }
}