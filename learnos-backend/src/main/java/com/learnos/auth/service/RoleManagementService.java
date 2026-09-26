package com.learnos.auth.service;

import com.learnos.auth.dto.PermissionResponse;
import com.learnos.auth.dto.RoleResponse;
import com.learnos.auth.model.DynamicRole;
import com.learnos.auth.repository.DynamicRoleRepository;
import com.learnos.auth.repository.PermissionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class RoleManagementService {

    private final DynamicRoleRepository dynamicRoleRepository;
    private final PermissionRepository permissionRepository;

    public List<RoleResponse> getRoles() {
        return dynamicRoleRepository.findAll()
                .stream()
                .map(this::toRoleResponse)
                .toList();
    }

    public RoleResponse getRole(UUID id) {
        DynamicRole role = dynamicRoleRepository.findById(id)
                .orElseThrow(() ->
                        new ResponseStatusException(
                                HttpStatus.NOT_FOUND,
                                "Role not found"
                        )
                );

        return toRoleResponse(role);
    }

    public List<PermissionResponse> getPermissions() {
        return permissionRepository.findAll()
                .stream()
                .map(permission ->
                        new PermissionResponse(
                                permission.getId(),
                                permission.getCode(),
                                permission.getDescription()
                        )
                )
                .toList();
    }

    private RoleResponse toRoleResponse(DynamicRole role) {
        List<String> permissions = role.getRolePermissions()
                .stream()
                .map(rolePermission ->
                        rolePermission
                                .getPermission()
                                .getCode()
                )
                .sorted()
                .toList();

        return new RoleResponse(
                role.getId(),
                role.getName(),
                role.getDescription(),
                role.isSystemRole(),
                permissions
        );
    }
}