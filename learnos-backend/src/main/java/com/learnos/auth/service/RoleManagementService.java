package com.learnos.auth.service;

import com.learnos.auth.dto.CreateRoleRequest;
import com.learnos.auth.dto.PermissionResponse;
import com.learnos.auth.dto.RoleResponse;
import com.learnos.auth.dto.UpdateRoleRequest;
import com.learnos.auth.model.DynamicRole;
import com.learnos.auth.model.Permission;
import com.learnos.auth.model.RolePermission;
import com.learnos.auth.model.RolePermissionId;
import com.learnos.auth.repository.DynamicRoleRepository;
import com.learnos.auth.repository.PermissionRepository;
import com.learnos.auth.repository.RolePermissionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class RoleManagementService {

    private final DynamicRoleRepository dynamicRoleRepository;
    private final PermissionRepository permissionRepository;
    private final RolePermissionRepository rolePermissionRepository;

    public List<RoleResponse> getRoles() {
        return dynamicRoleRepository.findAll()
                .stream()
                .map(this::toRoleResponse)
                .toList();
    }

    public RoleResponse getRole(UUID id) {
        return toRoleResponse(findRole(id));
    }

    public List<PermissionResponse> getPermissions() {
        return permissionRepository.findAll()
                .stream()
                .map(permission -> new PermissionResponse(
                        permission.getId(),
                        permission.getCode(),
                        permission.getDescription()
                ))
                .toList();
    }

    @Transactional
    public RoleResponse createRole(CreateRoleRequest request) {
        String name = request.name().trim();

        if (dynamicRoleRepository.findByNameIgnoreCase(name).isPresent()) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "Role name already exists"
            );
        }

        DynamicRole role = DynamicRole.builder()
                .name(name)
                .description(request.description())
                .systemRole(false)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        DynamicRole savedRole = dynamicRoleRepository.save(role);
        replacePermissions(savedRole, request.permissionIds());

        return toRoleResponse(savedRole);
    }

    @Transactional
    public RoleResponse updateRole(
            UUID id,
            UpdateRoleRequest request
    ) {
        DynamicRole role = findRole(id);
        ensureCustomRole(role);

        String name = request.name().trim();

        dynamicRoleRepository.findByNameIgnoreCase(name)
                .filter(existing -> !existing.getId().equals(id))
                .ifPresent(existing -> {
                    throw new ResponseStatusException(
                            HttpStatus.CONFLICT,
                            "Role name already exists"
                    );
                });

        role.setName(name);
        role.setDescription(request.description());
        role.setUpdatedAt(LocalDateTime.now());

        replacePermissions(role, request.permissionIds());

        return toRoleResponse(role);
    }

    @Transactional
    public void deleteRole(UUID id) {
        DynamicRole role = findRole(id);
        ensureCustomRole(role);

        rolePermissionRepository.deleteByRole_Id(id);
        rolePermissionRepository.flush();
        dynamicRoleRepository.delete(role);
    }

    private DynamicRole findRole(UUID id) {
        return dynamicRoleRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Role not found"
                ));
    }

    private void ensureCustomRole(DynamicRole role) {
        if (role.isSystemRole()) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "System roles cannot be modified"
            );
        }
    }

    private void replacePermissions(
            DynamicRole role,
            List<UUID> permissionIds
    ) {
        rolePermissionRepository.deleteByRole_Id(role.getId());
        rolePermissionRepository.flush();

        List<UUID> ids = permissionIds == null
                ? Collections.emptyList()
                : permissionIds.stream()
                .distinct()
                .toList();

        for (UUID permissionId : ids) {
            Permission permission = permissionRepository
                    .findById(permissionId)
                    .orElseThrow(() -> new ResponseStatusException(
                            HttpStatus.BAD_REQUEST,
                            "Permission not found: " + permissionId
                    ));

            RolePermission rolePermission = RolePermission.builder()
                    .id(new RolePermissionId(
                            role.getId(),
                            permission.getId()
                    ))
                    .role(role)
                    .permission(permission)
                    .build();

            rolePermissionRepository.save(rolePermission);
        }

        rolePermissionRepository.flush();

        role.getRolePermissions().clear();
        role.getRolePermissions().addAll(
                rolePermissionRepository.findAll()
                        .stream()
                        .filter(rolePermission ->
                                rolePermission.getRole()
                                        .getId()
                                        .equals(role.getId())
                        )
                        .toList()
        );
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