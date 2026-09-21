import { Component, OnInit, inject } from '@angular/core';
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

function passwordsMatchValidator(group: AbstractControl): ValidationErrors | null {
  const password = group.get('password')?.value;
  const confirmPassword = group.get('confirmPassword')?.value;

  if (!password && !confirmPassword) {
    return null;
  }

  return password === confirmPassword ? null : { passwordMismatch: true };
}

@Component({
  selector: 'app-company-user-form',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterModule],
  templateUrl: './company-user-form.html',
  styleUrl: './company-user-form.scss'
})
export class CompanyUserForm implements OnInit {
  private fb = inject(FormBuilder);
  private companyUsersService = inject(CompanyUsersService);
  private authService = inject(AuthService);
  private route = inject(ActivatedRoute);
  private router = inject(Router);

  showPassword = false;
  showConfirmPassword = false;

  /**
   * Identifies whether this form belongs to the Learners workflow.
   * It is true only when opened from Learners with ?role=LEARNER,
   * or when an existing loaded record is a learner.
   */
  isLearnerForm = false;

  get restrictToLearnerOnly(): boolean {
    const actingUserIsContentManager =
      (this.authService.getCurrentUser()?.role || '').toUpperCase() === 'USER';

    return actingUserIsContentManager || this.isLearnerForm;
  }

  companies: any[] = [];
  loading = false;
  error = '';
  success = '';
  isEdit = false;
  userId = '';

  userForm = this.fb.group(
    {
      firstName: ['', Validators.required],
      lastName: ['', Validators.required],
      email: ['', [Validators.required, Validators.email]],
      password: [''],
      confirmPassword: [''],
      phone: [''],
      role: ['LEARNER', Validators.required],
      companyId: ['', Validators.required],
      status: ['Active']
    },
    { validators: passwordsMatchValidator }
  );

  ngOnInit(): void {
    this.loadCompanies();

    this.isLearnerForm =
      this.route.snapshot.queryParamMap.get('role') === 'LEARNER';

    if (this.restrictToLearnerOnly) {
      this.userForm.patchValue({ role: 'LEARNER' });
    }

    const id = this.route.snapshot.paramMap.get('id');

    if (id) {
      this.isEdit = true;
      this.userId = id;

      this.userForm.get('password')?.clearValidators();
      this.userForm.get('password')?.updateValueAndValidity();

      this.loadUser(id);
    } else {
      this.userForm.get('password')?.setValidators([Validators.required]);
      this.userForm.get('password')?.updateValueAndValidity();
    }
  }

  loadCompanies(): void {
    fetch('http://localhost:8080/api/v1/companies', {
      headers: {
        Authorization: `Bearer ${localStorage.getItem('accessToken') || ''}`
      }
    })
      .then(response => response.json())
      .then(data => {
        this.companies = Array.isArray(data) ? data : (data?.content ?? []);
      })
      .catch(() => {
        this.companies = [];
      });
  }

  loadUser(id: string): void {
    this.loading = true;

    this.companyUsersService.getUserById(id).subscribe({
      next: (user: any) => {
        const role = (user.role || 'LEARNER').toUpperCase();

        // Existing learner records should use learner labels.
        if (role === 'LEARNER') {
          this.isLearnerForm = true;
        }

        this.userForm.patchValue({
          firstName: user.firstName ?? user.name?.split(' ')?.[0] ?? '',
          lastName: user.lastName ?? user.name?.split(' ')?.slice(1).join(' ') ?? '',
          email: user.email ?? '',
          phone: user.phone ?? '',
          role,
          companyId: user.companyId ?? user.company?.id ?? '',
          status: user.status ?? 'Active'
        });

        this.loading = false;
      },
      error: (err) => {
        console.error(err);
        this.error = err?.error?.message || 'Failed to load user';
        this.loading = false;
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

    this.loading = true;

    const raw = this.userForm.getRawValue();

    const payload: any = {
      firstName: raw.firstName!,
      lastName: raw.lastName!,
      email: raw.email!,
      phone: raw.phone || '',
      role: raw.role!,
      companyId: raw.companyId || null,
      status: raw.status || 'Active'
    };

    if (!this.isEdit && raw.password) {
      payload.password = raw.password;
    }

    const request = this.isEdit
      ? this.companyUsersService.updateUser(this.userId, payload)
      : this.companyUsersService.createUser({
          ...payload,
          password: raw.password || ''
        });

    request.subscribe({
      next: () => {
        this.success = this.isLearnerForm
          ? (this.isEdit
              ? 'Learner updated successfully'
              : 'Learner created successfully')
          : (this.isEdit
              ? 'User updated successfully'
              : 'User created successfully');

        this.loading = false;
        this.navigateAfterSave();
      },
      error: (err) => {
        console.error(err);
        this.error = err?.error?.message || 'Failed to save user';
        this.loading = false;
      }
    });
  }

  private navigateAfterSave(): void {
    if (this.isLearnerForm) {
      this.router.navigate(['/admin/learners']);
      return;
    }

    this.router.navigate(['/admin/companies/users']);
  }

  togglePasswordVisibility(): void {
    this.showPassword = !this.showPassword;
  }

  toggleConfirmPasswordVisibility(): void {
    this.showConfirmPassword = !this.showConfirmPassword;
  }

  cancel(): void {
    this.navigateAfterSave();
  }
}