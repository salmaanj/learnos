import { CommonModule, DatePipe } from '@angular/common';
import {
  ChangeDetectorRef,
  Component
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import {
  HttpClient,
  HttpClientModule
} from '@angular/common/http';

interface CertificateVerifyResponse {
  valid: boolean;
  certificateNumber: string | null;
  learnerName: string | null;
  courseTitle: string | null;
  companyName: string | null;
  quizScorePercent: number | null;
  status: string | null;
  issuedAt: string | null;
  message: string;
}

@Component({
  selector: 'app-verify-certificate',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    HttpClientModule,
    DatePipe
  ],
  templateUrl: './verify-certificate.html',
  styleUrl: './verify-certificate.scss'
})
export class VerifyCertificate {

  verificationCode = '';
  loading = false;
  attempted = false;
  error = '';

  result: CertificateVerifyResponse | null = null;

  private readonly apiBaseUrl =
    'http://localhost:8080/api/v1';

  constructor(
    private http: HttpClient,
    private router: Router,
    private cdr: ChangeDetectorRef
  ) {}

  verifyCertificate(): void {
    const verificationCode = this.verificationCode
      .trim()
      .toUpperCase();

    if (!verificationCode || this.loading) {
      return;
    }

    this.verificationCode = verificationCode;
    this.loading = true;
    this.attempted = true;
    this.error = '';
    this.result = null;

    this.cdr.detectChanges();

    const encodedCode = encodeURIComponent(verificationCode);

    this.http
      .get<CertificateVerifyResponse>(
        `${this.apiBaseUrl}/certificates/verify/${encodedCode}`
      )
      .subscribe({
        next: (response) => {
          this.loading = false;
          this.result = response;
          this.error = '';

          this.cdr.detectChanges();
        },

        error: (err) => {
          this.loading = false;
          this.result = null;

          this.error =
            err?.error?.message ||
            err?.error?.error ||
            'Certificate verification failed. Please check the code and try again.';

          this.cdr.detectChanges();
        }
      });
  }

  normalizeCode(): void {
    this.verificationCode = this.verificationCode
      .toUpperCase()
      .replace(/\s+/g, '');
  }

  verifyAnother(): void {
    this.verificationCode = '';
    this.result = null;
    this.error = '';
    this.attempted = false;
    this.loading = false;

    this.cdr.detectChanges();
  }

  backToLogin(): void {
    this.router.navigate(['/login']);
  }

  get isRevoked(): boolean {
    return this.result?.status === 'REVOKED';
  }

  get isVerified(): boolean {
    return this.result?.valid === true && !this.isRevoked;
  }
}