import {
  ChangeDetectorRef,
  Component,
  OnInit,
  inject
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { finalize } from 'rxjs';

interface AnalyticsSummary {
  totalCompanies: number;
  totalLearners: number;
  totalCourses: number;
  subscriptionRevenue: number;
  courseRevenue: number;
  successfulPayments: number;
  pendingPayments: number;
  failedPayments: number;
}

interface CompanyAnalyticsRow {
  companyId: string;
  companyName: string;
  totalLearners: number;
  totalCourses: number;
  courseRevenue: number;
  subscriptionStatus: string;
  planName: string | null;
  expiryDate: string | null;
}

interface CompanyAnalyticsDetail extends CompanyAnalyticsRow {
  successfulPaymentCount: number;
  logoUrl?: string | null;
}

interface AnalyticsResponse {
  summary: AnalyticsSummary;
  companies: CompanyAnalyticsRow[];
  selectedCompany: CompanyAnalyticsDetail | null;
}

@Component({
  selector: 'app-analytics',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './analytics.html',
  styleUrl: './analytics.scss'
})
export class Analytics implements OnInit {
  private readonly http = inject(HttpClient);
  private readonly cd = inject(ChangeDetectorRef);

  private readonly baseUrl = 'http://localhost:8080/api/v1';

  loading = true;
  error = '';

  isSuperAdmin = false;
  selectedCompanyId = '';

  analytics: AnalyticsResponse | null = null;
  selectedCompany: CompanyAnalyticsDetail | null = null;

  ngOnInit(): void {
    this.isSuperAdmin = this.resolveSuperAdmin();
    this.loadAnalytics();
  }

  get summary(): AnalyticsSummary | null {
    return this.analytics?.summary || null;
  }

  get companies(): CompanyAnalyticsRow[] {
    return this.analytics?.companies || [];
  }

  loadAnalytics(): void {
    this.loading = true;
    this.error = '';

    const token = localStorage.getItem('accessToken') || '';

    const headers = new HttpHeaders({
      Authorization: `Bearer ${token}`
    });

    let url = `${this.baseUrl}/analytics`;

    if (this.isSuperAdmin && this.selectedCompanyId) {
      url += `?companyId=${encodeURIComponent(
        this.selectedCompanyId
      )}`;
    }

    this.http
      .get<AnalyticsResponse>(url, { headers })
      .pipe(
        finalize(() => {
          this.loading = false;
          this.cd.detectChanges();
        })
      )
      .subscribe({
        next: response => {
          this.analytics = response;
          this.selectedCompany =
            response.selectedCompany || null;
        },
        error: err => {
          console.error('Unable to load analytics', err);

          this.analytics = null;
          this.selectedCompany = null;

          this.error =
            err?.error?.message ||
            err?.error?.error ||
            'Unable to load analytics.';
        }
      });
  }

  onCompanyChange(): void {
    this.loadAnalytics();
  }

  refresh(): void {
    this.loadAnalytics();
  }

  selectCompany(companyId: string): void {
    if (!this.isSuperAdmin) {
      return;
    }

    this.selectedCompanyId = companyId;
    this.loadAnalytics();
  }

  get revenueLabel(): string {
    return this.isSuperAdmin
      ? 'Subscription Revenue'
      : 'Course Revenue';
  }

  get revenueAmount(): number {
    if (!this.summary) {
      return 0;
    }

    return this.isSuperAdmin
      ? Number(this.summary.subscriptionRevenue || 0)
      : Number(this.summary.courseRevenue || 0);
  }

  formatRevenue(value: number | null | undefined): string {
    return new Intl.NumberFormat('en-IN', {
      style: 'currency',
      currency: 'INR',
      maximumFractionDigits: 2
    }).format(Number(value || 0));
  }

  formatDate(value: string | null | undefined): string {
    if (!value) {
      return '—';
    }

    const date = new Date(value);

    if (Number.isNaN(date.getTime())) {
      return '—';
    }

    return new Intl.DateTimeFormat('en-IN', {
      day: '2-digit',
      month: 'short',
      year: 'numeric'
    }).format(date);
  }

  statusLabel(status: string | null | undefined): string {
    const value = String(status || '')
      .trim()
      .toUpperCase();

    if (value === 'PENDING_PAYMENT') {
      return 'Pending';
    }

    if (value === 'PAYMENT_FAILED') {
      return 'Payment failed';
    }

    if (value === 'CANCELLED') {
      return 'Cancelled';
    }

    if (value === 'EXPIRED') {
      return 'Expired';
    }

    if (value === 'ACTIVE') {
      return 'Active';
    }

    return value || 'Unknown';
  }

  statusClass(status: string | null | undefined): string {
    const value = String(status || '')
      .trim()
      .toUpperCase();

    if (value === 'ACTIVE') {
      return 'status-active';
    }

    if (value === 'PENDING_PAYMENT') {
      return 'status-pending';
    }

    if (value === 'PAYMENT_FAILED') {
      return 'status-failed';
    }

    if (value === 'EXPIRED') {
      return 'status-expired';
    }

    if (value === 'CANCELLED') {
      return 'status-cancelled';
    }

    return 'status-default';
  }

  companyInitials(name: string | null | undefined): string {
    const words = String(name || '')
      .trim()
      .split(/\s+/)
      .filter(Boolean)
      .slice(0, 2);

    if (!words.length) {
      return 'C';
    }

    return words
      .map(word => word.charAt(0).toUpperCase())
      .join('');
  }

  trackByCompanyId(
    _: number,
    company: CompanyAnalyticsRow
  ): string {
    return company.companyId;
  }

  private resolveSuperAdmin(): boolean {
    const currentUser = JSON.parse(
      localStorage.getItem('currentUser') || '{}'
    );

    const role = String(
      currentUser?.role ||
      currentUser?.userRole ||
      currentUser?.authorities?.[0]?.authority ||
      ''
    ).toUpperCase();

    const email = String(
      currentUser?.email || ''
    ).toLowerCase();

    return email === 'admin@blute.co.in'
      || role === 'SUPER_ADMIN';
  }
}