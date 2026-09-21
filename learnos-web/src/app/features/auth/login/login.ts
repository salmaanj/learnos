import { ChangeDetectorRef, Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';

import {
  AuthService,
  LoginRequest
} from '../../../core/auth.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './login.html',
  styleUrl: './login.scss'
})
export class Login {

  email = '';
  password = '';

  error = '';
  loading = false;
  showPassword = false;

  constructor(
    private authService: AuthService,
    private router: Router,
    private cdr: ChangeDetectorRef
  ) {}

  togglePasswordVisibility(): void {
    this.showPassword = !this.showPassword;
  }

  openCertificateVerification(): void {
    this.router.navigate(['/verify-certificate']);
  }

  openForgotPassword(): void {
    this.router.navigate(['/forgot-password']);
  }

  login(): void {
    if (this.loading) {
      return;
    }

    this.error = '';
    this.loading = true;

    const payload: LoginRequest = {
      email: this.email.trim(),
      password: this.password
    };

    this.authService.login(payload).subscribe({
      next: () => {
        this.loading = false;
        this.router.navigate([this.authService.homeRoute()]);
      },

      error: (err) => {
        this.loading = false;

        this.error =
          err?.error?.error ||
          err?.error?.message ||
          'Either the Username does not exist or the Password is incorrect.';

        this.cdr.detectChanges();
      }
    });
  }
}