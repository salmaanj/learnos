import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  HttpClient,
  HttpHeaders,
  HttpClientModule
} from '@angular/common/http';
import { FormsModule } from '@angular/forms';

interface Certificate {
  id: string;
  certificateNumber: string;
  verificationCode: string;
  learnerId: string;
  learnerName: string;
  courseId: string;
  courseTitle: string;
  companyId?: string | null;
  companyName?: string | null;
  quizScorePercent?: number | null;
  status: string;
  issuedAt: string;
  revokedAt?: string | null;
  revocationReason?: string | null;
}

interface CertificateVerification {
  valid: boolean;
  certificateNumber?: string | null;
  learnerName?: string | null;
  courseTitle?: string | null;
  companyName?: string | null;
  quizScorePercent?: number | null;
  status?: string | null;
  issuedAt?: string | null;
  message?: string | null;
}

@Component({
  selector: 'app-certifications',
  standalone: true,
  imports: [CommonModule, HttpClientModule, FormsModule],
  templateUrl: './certifications.html',
  styleUrl: './certifications.scss'
})
export class Certifications implements OnInit {
  certificates: Certificate[] = [];
  todayCertificates: Certificate[] = [];

  loading = true;
  error = '';

  searchTerm = '';
  selectedCertificateId = '';

  downloadingCertificateId = '';
  revokingCertificateId = '';

  verificationCode = '';
  verificationLoading = false;
  verificationResult: CertificateVerification | null = null;
  verificationError = '';

  private readonly baseUrl = 'http://localhost:8080/api/v1';

  constructor(
    private http: HttpClient,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    this.loadCertificates();
  }

  get filteredCertificates(): Certificate[] {
    const term = this.searchTerm.trim().toLowerCase();

    if (!term) {
      return this.certificates;
    }

    return this.certificates.filter(certificate =>
      [
        certificate.learnerName,
        certificate.courseTitle,
        certificate.companyName,
        certificate.certificateNumber,
        certificate.verificationCode,
        certificate.status
      ]
        .filter(Boolean)
        .some(value => String(value).toLowerCase().includes(term))
    );
  }

  get selectedCertificate(): Certificate | null {
    return this.certificates.find(
      certificate => certificate.id === this.selectedCertificateId
    ) || this.certificates[0] || null;
  }

  get issuedCount(): number {
    return this.certificates.filter(
      certificate => this.isIssued(certificate)
    ).length;
  }

  get revokedCount(): number {
    return this.certificates.filter(
      certificate => !this.isIssued(certificate)
    ).length;
  }

  loadCertificates(): void {
    this.loading = true;
    this.error = '';

    this.http.get<any>(`${this.baseUrl}/certificates`, {
      headers: this.getHeaders()
    }).subscribe({
      next: (response) => {
        const data = response?.data ?? response ?? [];

        this.certificates = Array.isArray(data)
          ? data
              .map((certificate: any) => this.mapCertificate(certificate))
              .sort((left, right) =>
                this.toDate(right.issuedAt) - this.toDate(left.issuedAt)
              )
          : [];

        if (
          !this.selectedCertificateId &&
          this.certificates.length > 0
        ) {
          this.selectedCertificateId = this.certificates[0].id;
        }

        this.loadTodayCertificates();
      },
      error: (err) => {
        console.error('Failed to load certificates', err);

        this.error =
          err?.error?.message ||
          err?.error?.error ||
          'Unable to load certificate records.';

        this.certificates = [];
        this.todayCertificates = [];
        this.loading = false;
        this.cdr.detectChanges();
      }
    });
  }

  loadTodayCertificates(): void {
    this.http.get<any>(`${this.baseUrl}/certificates/today`, {
      headers: this.getHeaders()
    }).subscribe({
      next: (response) => {
        const data = response?.data ?? response ?? [];

        this.todayCertificates = Array.isArray(data)
          ? data.map((certificate: any) => this.mapCertificate(certificate))
          : [];

        this.loading = false;
        this.cdr.detectChanges();
      },
      error: () => {
        this.todayCertificates = [];
        this.loading = false;
        this.cdr.detectChanges();
      }
    });
  }

  selectCertificate(certificate: Certificate): void {
    this.selectedCertificateId = certificate.id;
  }

  downloadPdf(certificate: Certificate): void {
    if (
      !certificate.id ||
      !this.isIssued(certificate) ||
      this.downloadingCertificateId
    ) {
      return;
    }

    this.downloadingCertificateId = certificate.id;
    this.error = '';

    this.http.get(
      `${this.baseUrl}/certificates/${certificate.id}/download`,
      {
        headers: this.getHeaders(),
        responseType: 'blob',
        observe: 'response'
      }
    ).subscribe({
      next: response => {
        const pdf = response.body;

        if (!pdf) {
          this.error = 'The certificate PDF was empty.';
          this.downloadingCertificateId = '';
          this.cdr.detectChanges();
          return;
        }

        const fileName =
          this.fileNameFromHeaders(
            response.headers.get('content-disposition')
          ) || this.defaultFileName(certificate);

        const url = window.URL.createObjectURL(pdf);
        const anchor = document.createElement('a');

        anchor.href = url;
        anchor.download = fileName;
        anchor.style.display = 'none';

        document.body.appendChild(anchor);
        anchor.click();
        document.body.removeChild(anchor);

        window.URL.revokeObjectURL(url);

        this.downloadingCertificateId = '';
        this.cdr.detectChanges();
      },
      error: err => {
        console.error('Failed to download certificate', err);

        this.error =
          err?.error?.message ||
          'Unable to download the certificate PDF.';

        this.downloadingCertificateId = '';
        this.cdr.detectChanges();
      }
    });
  }

  revokeCertificate(certificate: Certificate): void {
    if (
      !certificate.id ||
      !this.isIssued(certificate) ||
      this.revokingCertificateId
    ) {
      return;
    }

    const confirmed = confirm(
      `Revoke the certificate for "${certificate.learnerName}" in "${certificate.courseTitle}"?`
    );

    if (!confirmed) {
      return;
    }

    const reasonInput = prompt(
      'Optional revocation reason:',
      'Certificate revoked by an administrator.'
    );

    this.revokingCertificateId = certificate.id;
    this.error = '';

    this.http.post<any>(
      `${this.baseUrl}/certificates/${certificate.id}/revoke`,
      {
        reason: reasonInput?.trim() || 'Certificate revoked by an administrator.'
      },
      {
        headers: this.getHeaders()
      }
    ).subscribe({
      next: response => {
        const saved = this.mapCertificate(response?.data ?? response);

        this.certificates = this.certificates.map(existing =>
          existing.id === saved.id ? saved : existing
        );

        this.todayCertificates = this.todayCertificates.map(existing =>
          existing.id === saved.id ? saved : existing
        );

        this.revokingCertificateId = '';
        this.cdr.detectChanges();
      },
      error: err => {
        console.error('Failed to revoke certificate', err);

        this.error =
          err?.error?.message ||
          err?.error?.error ||
          'Unable to revoke this certificate.';

        this.revokingCertificateId = '';
        this.cdr.detectChanges();
      }
    });
  }

  verifyCertificate(): void {
    const code = this.verificationCode.trim();

    if (!code || this.verificationLoading) {
      return;
    }

    this.verificationLoading = true;
    this.verificationResult = null;
    this.verificationError = '';

    this.http.get<any>(
      `${this.baseUrl}/certificates/verify/${encodeURIComponent(code)}`,
      {
        headers: this.getHeaders()
      }
    ).subscribe({
      next: response => {
        const data = response?.data ?? response ?? {};

        this.verificationResult = {
          valid: Boolean(data?.valid),
          certificateNumber: data?.certificateNumber ?? null,
          learnerName: data?.learnerName ?? null,
          courseTitle: data?.courseTitle ?? null,
          companyName: data?.companyName ?? null,
          quizScorePercent:
            data?.quizScorePercent !== null &&
            data?.quizScorePercent !== undefined
              ? Number(data.quizScorePercent)
              : null,
          status: data?.status ?? null,
          issuedAt: data?.issuedAt ?? null,
          message: data?.message ?? null
        };

        this.verificationLoading = false;
        this.cdr.detectChanges();
      },
      error: err => {
        console.error('Certificate verification failed', err);

        this.verificationError =
          err?.error?.message ||
          err?.error?.error ||
          'Unable to verify this certificate.';

        this.verificationLoading = false;
        this.cdr.detectChanges();
      }
    });
  }

  clearVerification(): void {
    this.verificationCode = '';
    this.verificationResult = null;
    this.verificationError = '';
  }

  copyCode(code: string): void {
    if (!code) {
      return;
    }

    if (navigator.clipboard?.writeText) {
      navigator.clipboard.writeText(code).catch(() => {
        this.copyWithFallback(code);
      });
      return;
    }

    this.copyWithFallback(code);
  }

  isIssued(certificate: Certificate): boolean {
    return String(certificate.status || '').toUpperCase() === 'ISSUED';
  }

  isDownloading(certificate: Certificate): boolean {
    return this.downloadingCertificateId === certificate.id;
  }

  isRevoking(certificate: Certificate): boolean {
    return this.revokingCertificateId === certificate.id;
  }

  statusLabel(status: string): string {
    const normalized = String(status || '').toUpperCase();

    if (normalized === 'ISSUED') {
      return 'Issued';
    }

    if (normalized === 'REVOKED') {
      return 'Revoked';
    }

    return normalized || 'Unknown';
  }

  statusClass(status: string): string {
    return String(status || '').toUpperCase() === 'ISSUED'
      ? 'issued'
      : 'revoked';
  }

  formatDate(value: string | null | undefined): string {
    if (!value) {
      return '—';
    }

    const date = new Date(value);

    if (Number.isNaN(date.getTime())) {
      return value;
    }

    return date.toLocaleDateString('en-GB', {
      day: 'numeric',
      month: 'short',
      year: 'numeric'
    });
  }

  formatTodayLabel(value: string): string {
    const date = new Date(value);

    if (Number.isNaN(date.getTime())) {
      return this.formatDate(value);
    }

    const now = new Date();

    const sameDay =
      date.getFullYear() === now.getFullYear() &&
      date.getMonth() === now.getMonth() &&
      date.getDate() === now.getDate();

    return sameDay ? 'Today' : this.formatDate(value);
  }

  private getHeaders(): HttpHeaders {
    const token = localStorage.getItem('accessToken') || '';

    return new HttpHeaders({
      Authorization: `Bearer ${token}`
    });
  }

  private mapCertificate(certificate: any): Certificate {
    return {
      id: String(certificate?.id || ''),
      certificateNumber: String(certificate?.certificateNumber || '—'),
      verificationCode: String(certificate?.verificationCode || ''),
      learnerId: String(certificate?.learnerId || ''),
      learnerName: String(certificate?.learnerName || 'Learner'),
      courseId: String(certificate?.courseId || ''),
      courseTitle: String(certificate?.courseTitle || 'Course'),
      companyId: certificate?.companyId ?? null,
      companyName: certificate?.companyName ?? null,
      quizScorePercent:
        certificate?.quizScorePercent !== null &&
        certificate?.quizScorePercent !== undefined
          ? Number(certificate.quizScorePercent)
          : null,
      status: String(certificate?.status || ''),
      issuedAt: String(certificate?.issuedAt || ''),
      revokedAt: certificate?.revokedAt ?? null,
      revocationReason: certificate?.revocationReason ?? null
    };
  }

  private toDate(value: string): number {
    const date = new Date(value || 0).getTime();
    return Number.isNaN(date) ? 0 : date;
  }

  private fileNameFromHeaders(
    contentDisposition: string | null
  ): string | null {
    if (!contentDisposition) {
      return null;
    }

    const encodedMatch = contentDisposition.match(
      /filename\*=UTF-8''([^;]+)/i
    );

    if (encodedMatch?.[1]) {
      return decodeURIComponent(encodedMatch[1]);
    }

    const standardMatch = contentDisposition.match(
      /filename="?([^"]+)"?/i
    );

    return standardMatch?.[1] || null;
  }

  private defaultFileName(certificate: Certificate): string {
    return `LearnOS-${this.safeFilePart(certificate.courseTitle)}-${this.safeFilePart(certificate.learnerName)}.pdf`;
  }

  private safeFilePart(value: string): string {
    const cleaned = String(value || '')
      .trim()
      .replace(/[^a-zA-Z0-9]+/g, '-')
      .replace(/^-+|-+$/g, '');

    return cleaned || 'Certificate';
  }

  private copyWithFallback(value: string): void {
    const textarea = document.createElement('textarea');

    textarea.value = value;
    textarea.style.position = 'fixed';
    textarea.style.opacity = '0';

    document.body.appendChild(textarea);
    textarea.focus();
    textarea.select();

    try {
      document.execCommand('copy');
    } finally {
      document.body.removeChild(textarea);
    }
  }
}