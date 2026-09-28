import { CommonModule } from '@angular/common';
import { ChangeDetectorRef, Component, OnInit, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { finalize } from 'rxjs';
import { Permission, Role, RoleRequest } from './role.models';
import { RoleService } from './role.service';

@Component({
  selector: 'app-roles-page',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './roles-page.component.html',
  styleUrl: './roles-page.component.scss'
})
export class RolesPageComponent implements OnInit {
  private readonly formBuilder = inject(FormBuilder);
  private readonly roleService = inject(RoleService);
  private readonly cd = inject(ChangeDetectorRef);

  roles: Role[] = [];
  permissions: Permission[] = [];
  editingRole: Role | null = null;
  loading = false;
  saving = false;
  errorMessage = '';
  successMessage = '';

  readonly roleForm = this.formBuilder.nonNullable.group({
    name: ['', [Validators.required, Validators.maxLength(100)]],
    description: ['', [Validators.maxLength(500)]],
    permissionIds: this.formBuilder.nonNullable.control<string[]>([])
  });

  ngOnInit(): void {
    this.loadPage();
  }

  loadPage(): void {
    this.loading = true;
    this.errorMessage = '';
    this.cd.detectChanges();

    Promise.all([
      this.roleService.getRoles().toPromise(),
      this.roleService.getPermissions().toPromise()
    ])
      .then(([roles, permissions]) => {
        this.roles = roles ?? [];
        this.permissions = permissions ?? [];
      })
      .catch(error => {
        this.errorMessage = this.getErrorMessage(error, 'Unable to load roles.');
      })
      .finally(() => {
        this.loading = false;
        this.cd.detectChanges();
      });
  }

  startCreate(): void {
    this.editingRole = null;
    this.successMessage = '';
    this.errorMessage = '';
    this.roleForm.reset({
      name: '',
      description: '',
      permissionIds: []
    });
    this.cd.detectChanges();
  }

  startEdit(role: Role): void {
    this.editingRole = role;
    this.successMessage = '';
    this.errorMessage = '';
    this.roleForm.reset({
      name: role.name,
      description: role.description ?? '',
      permissionIds: this.permissionIdsForRole(role)
    });
    this.cd.detectChanges();
  }

  cancelEdit(): void {
    this.editingRole = null;
    this.roleForm.reset({
      name: '',
      description: '',
      permissionIds: []
    });
    this.cd.detectChanges();
  }

  isPermissionSelected(permissionId: string): boolean {
    return this.roleForm.controls.permissionIds.value.includes(permissionId);
  }

  togglePermission(permissionId: string, checked: boolean): void {
    const current = this.roleForm.controls.permissionIds.value;
    const next = checked
      ? [...new Set([...current, permissionId])]
      : current.filter(id => id !== permissionId);

    this.roleForm.controls.permissionIds.setValue(next);
    this.cd.detectChanges();
  }

  save(): void {
    this.successMessage = '';
    this.errorMessage = '';

    if (this.roleForm.invalid) {
      this.roleForm.markAllAsTouched();
      return;
    }

    const request: RoleRequest = {
      name: this.roleForm.controls.name.value.trim(),
      description: this.roleForm.controls.description.value.trim(),
      permissionIds: this.roleForm.controls.permissionIds.value
    };

    if (!request.name) {
      this.roleForm.controls.name.setErrors({ required: true });
      return;
    }

    this.saving = true;
    this.cd.detectChanges();

    const operation = this.editingRole
      ? this.roleService.updateRole(this.editingRole.id, request)
      : this.roleService.createRole(request);

    operation
      .pipe(
        finalize(() => {
          this.saving = false;
          this.cd.detectChanges();
        })
      )
      .subscribe({
        next: savedRole => {
          if (this.editingRole) {
            this.roles = this.roles.map(role =>
              role.id === savedRole.id ? savedRole : role
            );
            this.successMessage = 'Role updated successfully.';
          } else {
            this.roles = [...this.roles, savedRole];
            this.successMessage = 'Role created successfully.';
          }

          this.cancelEdit();
          this.cd.detectChanges();
        },
        error: error => {
          this.errorMessage = this.getErrorMessage(error, 'Unable to save role.');
          this.cd.detectChanges();
        }
      });
  }

  deleteRole(role: Role): void {
    if (role.systemRole) {
      return;
    }

    const confirmed = window.confirm(`Delete the role “${role.name}”?`);
    if (!confirmed) {
      return;
    }

    this.errorMessage = '';
    this.successMessage = '';

    this.roleService.deleteRole(role.id).subscribe({
      next: () => {
        this.roles = this.roles.filter(item => item.id !== role.id);
        if (this.editingRole?.id === role.id) {
          this.cancelEdit();
        }
        this.successMessage = 'Role deleted successfully.';
        this.cd.detectChanges();
      },
      error: error => {
        this.errorMessage = this.getErrorMessage(error, 'Unable to delete role.');
        this.cd.detectChanges();
      }
    });
  }

  trackById(_: number, item: Role | Permission): string {
    return item.id;
  }

  private permissionIdsForRole(role: Role): string[] {
    const permissionCodes = new Set(role.permissions);
    return this.permissions
      .filter(permission => permissionCodes.has(permission.code))
      .map(permission => permission.id);
  }

  private getErrorMessage(error: any, fallback: string): string {
    return error?.error?.message
      || error?.error?.error
      || error?.message
      || fallback;
  }
}