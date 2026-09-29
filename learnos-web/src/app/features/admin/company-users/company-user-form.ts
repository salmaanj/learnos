import { ChangeDetectorRef, Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  ReactiveFormsModule,
  FormBuilder,
  Validators,
  AbstractControl,
  ValidationErrors
} from '@angular/forms';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { CompanyUsersService } from './company-users.service';
import { AuthService } from '../../../core/auth.service';
import { Role, RoleService } from '../roles/role.service';

function passwordsMatchValidator(
  group: AbstractControl
): ValidationErrors | null {
  const password = group.get('password')?.value;
  const confirmPassword = group.get('confirmPassword')?.value;

  if (!password && !confirmPassword) {
    return null;
  }

  return password === confirmPassword
    ? null
    : { passwordMismatch: true };
}

@Component({
  selector: 'app-company-user-form',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterModule],
  templateUrl: './company-user-form.html',
  styleUrl: './company-user-form.scss'
})
export class CompanyUserForm implements OnInit {
  private readonly fb = inject(FormBuilder);
  private readonly companyUsersService = inject(CompanyUsersService);
  private readonly roleService = inject(RoleService);
  private readonly authService = inject(AuthService);
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly cd = inject(ChangeDetectorRef);

  showPassword = false;
  showConfirmPassword = false;
  isLearnerForm = false;
  roles: Role[] = [];
  companies: any[] = [];
  loading = false;
  rolesLoading = false;
  error = '';
  success = '';
  isEdit = false;
  userId = '';

  get restrictToLearnerOnly(): boolean {
    const actingUserRole = (
      this.authService.getCurrentUser()?.role ||
      this.authService.getUserRole() ||
      ''
    )
      .trim()
      .toUpperCase();

    return actingUserRole === 'USER' || this.isLearnerForm;
  }

  get canCreateSuperAdmin(): boolean {
    return this.authService.isSuperAdmin();
  }

  userForm = this.fb.group(
    {
      firstName: ['', Validators.required],
      lastName: ['', Validators.required],
      email: ['', [Validators.required, Validators.email]],
      password: [''],
      confirmPassword: [''],
      phone: [''],
      role: [''],
      roleId: [''],
      companyId: ['', Validators.required],
      status: ['ACTIVE']
    },
    { validators: passwordsMatchValidator }
  );

  ngOnInit(): void {
    this.isLearnerForm =
      this.route.snapshot.queryParamMap.get('role') === 'LEARNER';

    this.loadCompanies();

    const id = this.route.snapshot.paramMap.get('id');

    if (id) {
      this.isEdit = true;
      this.userId = id;
    }

    if (this.isLearnerForm) {
      this.userForm.patchValue({
        role: 'LEARNER',
        roleId: ''
      });
    }

    if (id || !this.isLearnerForm) {
      this.loadRoles();
    }

    const passwordControl = this.userForm.get('password');

    if (id) {
      passwordControl?.clearValidators();
    } else {
      passwordControl?.setValidators([Validators.required]);
    }

    passwordControl?.updateValueAndValidity();
  }

  loadRoles(): void {
    this.rolesLoading = true;
    this.error = '';
    this.cd.detectChanges();

    this.roleService.getRoles().subscribe({
      next: roles => {
        const isSuperAdmin = this.authService.isSuperAdmin();

        this.roles = roles.filter(role => {
          const roleName = String(role.name ?? '')
            .trim()
            .toUpperCase();

          if (roleName === 'LEARNER') {
            return false;
          }

          if (roleName === 'SUPER_ADMIN' && !isSuperAdmin) {
            return false;
          }

          return true;
        });

        this.rolesLoading = false;

        if (this.isEdit && this.userId) {
          this.loadUser(this.userId);
        }

        this.cd.detectChanges();
      },
      error: error => {
        console.error('Unable to load roles', error);
        this.roles = [];
        this.rolesLoading = false;
        this.error = 'Unable to load roles.';
        this.cd.detectChanges();
      }
    });
  }

  loadCompanies(): void {
    fetch('http://localhost:8080/api/v1/companies', {
      headers: {
        Authorization:
          `Bearer ${localStorage.getItem('accessToken') || ''}`
      }
    })
      .then(response => response.json())
      .then(data => {
        this.companies = Array.isArray(data)
          ? data
          : data?.content ?? [];
        this.cd.detectChanges();
      })
      .catch(error => {
        console.error('Unable to load companies', error);
        this.companies = [];
        this.cd.detectChanges();
      });
  }

  loadUser(id: string): void {
    this.loading = true;
    this.error = '';
    this.cd.detectChanges();

    this.companyUsersService.getUserById(id).subscribe({
      next: (result: any) => {
        const user = result?.data ?? result;

        const fullName = String(user.name ?? '').trim();
        const nameParts = fullName
          ? fullName.split(/\s+/)
          : [];

        const roleName = String(
          user.role ?? user.companyRole ?? user.roleName ?? ''
        )
          .trim()
          .toUpperCase();

        const matchingRole = this.roles.find(
          role =>
            String(role.name ?? '')
              .trim()
              .toUpperCase() === roleName
        );

        if (roleName === 'LEARNER') {
          this.isLearnerForm = true;
        }

        this.userForm.patchValue({
          firstName: user.firstName ?? nameParts[0] ?? '',
          lastName: user.lastName
            ?? nameParts.slice(1).join(' ')
            ?? '',
          email: user.email ?? '',
          phone: user.phone ?? '',
          companyId: user.companyId
            ?? user.company?.id
            ?? '',
          status: user.status ?? 'ACTIVE',
          role: roleName === 'LEARNER' ? 'LEARNER' : '',
          roleId: roleName === 'LEARNER'
            ? ''
            : matchingRole?.id ?? user.roleId ?? ''
        });

        this.loading = false;
        this.cd.detectChanges();
      },
      error: error => {
        console.error(error);
        this.error =
          error?.error?.message || 'Failed to load user';
        this.loading = false;
        this.cd.detectChanges();
      }
    });
  }

  saveUser(): void {
    this.success = '';
    this.error = '';

    if (this.userForm.invalid) {
      this.userForm.markAllAsTouched();
      return;
    }

    const raw = this.userForm.getRawValue();

    if (!this.isLearnerForm && !raw.roleId) {
      this.error = 'Please select a staff role.';
      return;
    }

    this.loading = true;
    this.cd.detectChanges();

    const payload: any = {
      firstName: raw.firstName!,
      lastName: raw.lastName!,
      email: raw.email!,
      phone: raw.phone || '',
      companyId: raw.companyId || null,
      status: raw.status || 'ACTIVE'
    };

    if (this.isLearnerForm) {
      payload.role = 'LEARNER';
    } else {
      payload.role = 'USER';
      payload.roleId = raw.roleId;
      payload.companyRole = this.roles.find(
        role => role.id === raw.roleId
      )?.name || '';
    }

    if (!this.isEdit || raw.password) {
      payload.password = raw.password || '';
    }

    const request = this.isEdit
      ? this.companyUsersService.updateUser(this.userId, payload)
      : this.companyUsersService.createUser(payload);

    request.subscribe({
      next: () => {
        this.success = this.isLearnerForm
          ? this.isEdit
            ? 'Learner updated successfully'
            : 'Learner created successfully'
          : this.isEdit
            ? 'User updated successfully'
            : 'User created successfully';

        this.loading = false;
        this.cd.detectChanges();
        this.navigateAfterSave();
      },
      error: error => {
        console.error(error);
        this.error =
          error?.error?.message || 'Failed to save user';
        this.loading = false;
        this.cd.detectChanges();
      }
    });
  }

  private navigateAfterSave(): void {
    this.router.navigate(
      this.isLearnerForm
        ? ['/admin/learners']
        : ['/admin/companies/users']
    );
  }

  cancel(): void {
    this.navigateAfterSave();
  }

  togglePasswordVisibility(): void {
    this.showPassword = !this.showPassword;
  }

  toggleConfirmPasswordVisibility(): void {
    this.showConfirmPassword = !this.showConfirmPassword;
  }
}