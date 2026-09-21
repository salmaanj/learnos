import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  HttpClient,
  HttpHeaders,
  HttpClientModule
} from '@angular/common/http';

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

@Component({
  selector: 'app-my-certificates',
  standalone: true,
  imports: [CommonModule, HttpClientModule],
  templateUrl: './my-certificates.html',
  styleUrl: './my-certificates.scss'
})
export class MyCertificates implements OnInit {
  certificates: Certificate[] = [];
  loading = true;
  error = '';
  downloadingCertificateId = '';

  private readonly baseUrl = 'http://localhost:8080/api/v1';

  constructor(
    private http: HttpClient,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    this.loadCertificates();
  }

  loadCertificates(): void {
    this.loading = true;
    this.error = '';

    this.http.get<any>(`${this.baseUrl}/certificates/my`, {
      headers: this.getHeaders()
    }).subscribe({
      next: (response) => {
        const data = response?.data ?? response ?? [];

        this.certificates = Array.isArray(data)
          ? data
              .map((certificate: any) => this.mapCertificate(certificate))
              .sort((left, right) => {
                const leftDate = new Date(left.issuedAt || 0).getTime();
                const rightDate = new Date(right.issuedAt || 0).getTime();

                return rightDate - leftDate;
              })
          : [];

        this.loading = false;
        this.cdr.detectChanges();
      },
      error: (err) => {
        console.error('Failed to load certificates', err);

        this.error =
          err?.error?.message ||
          err?.error?.error ||
          'Unable to load your certificates. Please try again.';

        this.certificates = [];
        this.loading = false;
        this.cdr.detectChanges();
      }
    });
  }

  downloadPdf(certificate: Certificate): void {
    if (
      !certificate.id ||
      certificate.status.toUpperCase() !== 'ISSUED' ||
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
      next: (response) => {
        const blob = response.body;

        if (!blob) {
          this.error = 'The certificate PDF was empty.';
          this.downloadingCertificateId = '';
          this.cdr.detectChanges();
          return;
        }

        const fileName =
          this.fileNameFromHeaders(response.headers.get('content-disposition')) ||
          this.defaultFileName(certificate);

        const downloadUrl = window.URL.createObjectURL(blob);
        const anchor = document.createElement('a');

        anchor.href = downloadUrl;
        anchor.download = fileName;
        anchor.style.display = 'none';

        document.body.appendChild(anchor);
        anchor.click();
        document.body.removeChild(anchor);

        window.URL.revokeObjectURL(downloadUrl);

        this.downloadingCertificateId = '';
        this.cdr.detectChanges();
      },
      error: (err) => {
        console.error('Failed to download certificate', err);

        this.error =
          err?.error?.message ||
          'Unable to download this certificate. Please try again.';

        this.downloadingCertificateId = '';
        this.cdr.detectChanges();
      }
    });
  }

  isDownloading(certificateId: string): boolean {
    return this.downloadingCertificateId === certificateId;
  }

  statusLabel(status: string): string {
    const normalized = String(status || '').trim().toUpperCase();

    if (normalized === 'ISSUED') {
      return 'Issued';
    }

    if (normalized === 'REVOKED') {
      return 'Revoked';
    }

    return normalized || 'Unknown';
  }

  statusClass(status: string): string {
    return String(status || '').trim().toUpperCase() === 'ISSUED'
      ? 'status-issued'
      : 'status-revoked';
  }

  formatDate(value: string): string {
    if (!value) {
      return '—';
    }

    const date = new Date(value);

    if (Number.isNaN(date.getTime())) {
      return value;
    }

    return date.toLocaleDateString('en-GB', {
      day: 'numeric',
      month: 'long',
      year: 'numeric'
    });
  }

  copyVerificationCode(code: string): void {
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
      learnerName: String(certificate?.learnerName || ''),
      courseId: String(certificate?.courseId || ''),
      courseTitle: String(
        certificate?.courseTitle || 'Course certificate'
      ),
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
    const course = this.sanitizeFilePart(certificate.courseTitle);
    const learner = this.sanitizeFilePart(certificate.learnerName);

    return `LearnOS-${course}-${learner}.pdf`;
  }

  private sanitizeFilePart(value: string): string {
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