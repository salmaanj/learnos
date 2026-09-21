import {
  ChangeDetectorRef,
  Component,
  OnInit
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import {
  CompaniesService,
  Company
} from '../services/companies.service';

@Component({
  selector: 'app-companies-list',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './companies-list.html',
  styleUrl: './companies-list.scss'
})
export class CompaniesList implements OnInit {
  companies: Company[] = [];

  constructor(
    private service: CompaniesService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    this.loadCompanies();
  }

  loadCompanies(): void {
    this.service.getCompanies().subscribe({
      next: (data: Company[]) => {
        this.companies = data.map(
          (company: Company, index: number) => ({
            ...company,
            logoUrl: this.service.getLogoUrl(company.logoUrl),
            initials: this.getInitials(company.name),
            brandClass: `brand-${index % 4}`,
            learners: company.learnerCount ?? 0,
            courses: company.courseCount ?? 0,
            revenue: this.formatRevenue(company.courseRevenue),
            joined: company.createdAt
              ? new Date(company.createdAt).toLocaleDateString(
                  'en-IN',
                  {
                    month: 'short',
                    year: 'numeric'
                  }
                )
              : '—'
          })
        );

        this.cdr.detectChanges();
      },
      error: (err) => {
        console.error('Company API error', err);
        this.companies = [];
        this.cdr.detectChanges();
      }
    });
  }

  getStatusClass(status: Company['status']): string {
    if (status === 'Active') {
      return 'badge-success';
    }

    if (status === 'Pending') {
      return 'badge-warning';
    }

    return 'badge-danger';
  }

  getPlanLabel(company: Company): string {
    switch (company.planCode) {
      case 'BASIC':
        return 'Basic Plan';
      case 'PRO':
        return 'Pro Plan';
      case 'ENTERPRISE':
        return 'Enterprise Plan';
      default:
        return company.status === 'Active'
          ? 'Active plan'
          : company.status;
    }
  }

  onLogoError(company: Company): void {
    company.logoUrl = null;
  }

  private formatRevenue(value?: number): string {
    return new Intl.NumberFormat('en-IN', {
      style: 'currency',
      currency: 'INR',
      maximumFractionDigits: 2
    }).format(value ?? 0);
  }

  private getInitials(name?: string): string {
    if (!name?.trim()) {
      return 'CO';
    }

    const words = name.trim().split(/\s+/);

    if (words.length === 1) {
      return words[0].slice(0, 2).toUpperCase();
    }

    return `${words[0][0]}${words[1][0]}`.toUpperCase();
  }
}
