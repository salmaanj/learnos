import { CommonModule } from '@angular/common';
import {
  ChangeDetectorRef,
  Component
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';

import {
  AuthService,
  ForgotPasswordRequest,
  ResetPasswordRequest,
  VerifyResetOtpRequest
} from '../../../core/auth.service';

type ResetStep = 'email' | 'otp' | 'password' | 'success';

@Component({
  selector: 'app-forgot-password',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule
  ],
  templateUrl: './forgot-password.html',
  styleUrl: './forgot-password.scss'
})
export class ForgotPassword {

  step: ResetStep = 'email';

  email = '';
  otp = '';
  newPassword = '';
  confirmPassword = '';

  showNewPassword = false;
  showConfirmPassword = false;

  loading = false;
  error = '';
  message = '';

  constructor(
    private authService: AuthService,
    private router: Router,
    private cdr: ChangeDetectorRef
  ) {}

  sendOtp(): void {
    const email = this.email.trim().toLowerCase();

    if (!email || this.loading) {
      return;
    }

    this.loading = true;
    this.error = '';
    this.message = '';

    const payload: ForgotPasswordRequest = {
      email
    };

    this.authService.forgotPassword(payload).subscribe({
      next: (response) => {
        this.email = email;
        this.loading = false;
        this.step = 'otp';
        this.message =
          response ||
          'An OTP has been generated. Check the backend terminal for the temporary development OTP.';

        this.cdr.detectChanges();
      },

      error: (err) => {
        this.loading = false;
        this.error =
          err?.error?.message ||
          err?.error?.error ||
          'Unable to generate an OTP. Please check the email address and try again.';

        this.cdr.detectChanges();
      }
    });
  }

  verifyOtp(): void {
    const otp = this.otp.replace(/\D/g, '').trim();

    if (otp.length !== 6 || this.loading) {
      return;
    }

    this.loading = true;
    this.error = '';
    this.message = '';

    const payload: VerifyResetOtpRequest = {
      email: this.email,
      otp
    };

    this.authService.verifyResetOtp(payload).subscribe({
      next: (response) => {
        this.otp = otp;
        this.loading = false;
        this.step = 'password';
        this.message = response || 'OTP verified. You can now create a new password.';

        this.cdr.detectChanges();
      },

      error: (err) => {
        this.loading = false;
        this.error =
          err?.error?.message ||
          err?.error?.error ||
          'The OTP is invalid or has expired. Please try again.';

        this.cdr.detectChanges();
      }
    });
  }

  resetPassword(): void {
    if (this.loading) {
      return;
    }

    if (this.newPassword.length < 8) {
      this.error = 'Your new password must contain at least 8 characters.';
      this.cdr.detectChanges();
      return;
    }

    if (this.newPassword !== this.confirmPassword) {
      this.error = 'New password and confirm password do not match.';
      this.cdr.detectChanges();
      return;
    }

    this.loading = true;
    this.error = '';
    this.message = '';

    const payload: ResetPasswordRequest = {
      email: this.email,
      otp: this.otp,
      newPassword: this.newPassword
    };

    this.authService.resetPassword(payload).subscribe({
      next: (response) => {
        this.loading = false;
        this.step = 'success';
        this.message =
          response ||
          'Your password has been reset successfully. You can now log in.';

        this.newPassword = '';
        this.confirmPassword = '';

        this.cdr.detectChanges();
      },

      error: (err) => {
        this.loading = false;
        this.error =
          err?.error?.message ||
          err?.error?.error ||
          'Unable to reset your password. Please request a new OTP and try again.';

        this.cdr.detectChanges();
      }
    });
  }

  resendOtp(): void {
    this.otp = '';
    this.newPassword = '';
    this.confirmPassword = '';
    this.step = 'email';
    this.error = '';
    this.message = '';

    this.cdr.detectChanges();
  }

  backToLogin(): void {
    this.router.navigate(['/login']);
  }

  backToPreviousStep(): void {
    this.error = '';
    this.message = '';

    if (this.step === 'otp') {
      this.step = 'email';
    } else if (this.step === 'password') {
      this.step = 'otp';
    } else {
      this.backToLogin();
      return;
    }

    this.cdr.detectChanges();
  }

  normalizeOtp(): void {
    this.otp = this.otp
      .replace(/\D/g, '')
      .slice(0, 6);
  }

  toggleNewPasswordVisibility(): void {
    this.showNewPassword = !this.showNewPassword;
  }

  toggleConfirmPasswordVisibility(): void {
    this.showConfirmPassword = !this.showConfirmPassword;
  }
}