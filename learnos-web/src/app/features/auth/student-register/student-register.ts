import { CommonModule } from '@angular/common';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { ChangeDetectorRef, Component, inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { environment } from '../../../../environments/environment';

interface RegisterForm {
  firstName: string;
  lastName: string;
  email: string;
  phone: string;
  password: string;
  confirmPassword: string;
  companyCode: string;
  termsAccepted: boolean;
}

interface ApiResponse {
  message?: unknown;
  error?: unknown;
  detail?: unknown;
  title?: unknown;
  success?: boolean;
  data?: unknown;
}

@Component({
  selector: 'app-student-register',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './student-register.html',
  styleUrl: './student-register.scss'
})
export class StudentRegister {
  private readonly http = inject(HttpClient);
  private readonly router = inject(Router);
  private readonly cdr = inject(ChangeDetectorRef);

  readonly apiUrl = environment.apiUrl;

  loading = false;
  submitted = false;
  errorMessage = '';
  successMessage = '';

  form: RegisterForm = {
    firstName: '',
    lastName: '',
    email: '',
    phone: '',
    password: '',
    confirmPassword: '',
    companyCode: '',
    termsAccepted: false
  };

  get passwordsMatch(): boolean {
    return (
      this.form.password.length > 0 &&
      this.form.password === this.form.confirmPassword
    );
  }

  get formIsValid(): boolean {
    return (
      this.form.firstName.trim().length > 0 &&
      this.form.lastName.trim().length > 0 &&
      this.isValidEmail(this.form.email) &&
      this.form.phone.trim().length > 0 &&
      this.form.companyCode.trim().length > 0 &&
      this.form.password.length >= 8 &&
      this.passwordsMatch &&
      this.form.termsAccepted
    );
  }

  isValidEmailForTemplate(): boolean {
    return this.isValidEmail(this.form.email);
  }

  register(): void {
    this.submitted = true;
    this.errorMessage = '';
    this.successMessage = '';

    if (!this.formIsValid || this.loading) {
      return;
    }

    this.loading = true;

    const normalizedEmail = this.form.email.trim().toLowerCase();
    const payload = {
      firstName: this.form.firstName.trim(),
      lastName: this.form.lastName.trim(),
      email: normalizedEmail,
      phone: this.form.phone.trim(),
      password: this.form.password,
      companyCode: this.form.companyCode.trim()
    };

    this.http.post<ApiResponse>(
      `${this.apiUrl}/auth/register`,
      payload
    ).subscribe({
      next: (response) => {
        this.handleRegisterSuccess(response, normalizedEmail);
      },
      error: (error: HttpErrorResponse) => {
        // A 2xx status here always means the account was actually created
        // — real failures come back as 4xx/5xx. Angular only routes a 2xx
        // response to this handler when it couldn't parse the response
        // body as JSON (e.g. it's empty or not valid JSON), so treat any
        // 2xx as success rather than showing an error for a working signup.
        if (this.isSuccessStatus(error.status)) {
          this.handleRegisterSuccess(null, normalizedEmail);
          return;
        }

        this.loading = false;
        this.errorMessage = this.getErrorMessage(error);
        this.cdr.detectChanges();
      }
    });
  }

  private handleRegisterSuccess(
    response: ApiResponse | null,
    normalizedEmail: string
  ): void {
    this.loading = false;
    this.successMessage = this.extractMessage(response) ??
      'Student registered successfully. Please log in to begin your journey.';
    this.form.password = '';
    this.form.confirmPassword = '';
    this.cdr.detectChanges();

    window.setTimeout(() => {
      void this.router.navigate(['/login'], {
        queryParams: {
          audience: 'students',
          email: normalizedEmail
        }
      });
    }, 1800);
  }

  private isSuccessStatus(status: number): boolean {
    return status >= 200 && status < 300;
  }

  goToLogin(): void {
    void this.router.navigate(['/login'], {
      queryParams: {
        audience: 'students',
        email: this.form.email.trim().toLowerCase()
      }
    });
  }

  private isValidEmail(email: string): boolean {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim());
  }

  private extractMessage(response: ApiResponse | null | undefined): string | null {
    if (!response) {
      return null;
    }

    const values = [response.message, response.error, response.detail, response.title];
    const message = values.find(
      (value): value is string => typeof value === 'string' && value.trim().length > 0
    );

    return message?.trim() ?? null;
  }

  private getErrorMessage(error: HttpErrorResponse): string {
    if (error.status === 409) {
      return 'A user already exists with this email. Please log in.';
    }

    if (error.status === 0) {
      return 'Unable to connect to LearnOS. Please check that the backend is running.';
    }

    const body = error.error as ApiResponse | string | null | undefined;

    if (typeof body === 'string' && body.trim()) {
      return /already exists|already registered|duplicate/i.test(body)
        ? 'A user already exists with this email. Please log in.'
        : body.trim();
    }

    if (body && typeof body === 'object') {
      const message = this.extractMessage(body);

      if (message) {
        return /already exists|already registered|duplicate/i.test(message)
          ? 'A user already exists with this email. Please log in.'
          : message;
      }
    }

    if (error.status === 400) {
      return 'The registration details or company code were rejected. Please verify all fields.';
    }

    return `Registration failed with status ${error.status}. Please try again.`;
  }
}