import {
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  Component,
  OnInit
} from '@angular/core';

import {
  CommonModule
} from '@angular/common';

import {
  FormsModule
} from '@angular/forms';

import {
  EnquiriesService,
  Enquiry
} from './enquiries.service';

@Component({
  selector: 'app-enquiries',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule
  ],
  templateUrl: './enquiries.html',
  styleUrl: './enquiries.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class Enquiries implements OnInit {

  enquiries: Enquiry[] = [];
  filteredEnquiries: Enquiry[] = [];

  loading = false;
  error = '';

  searchTerm = '';
  selectedStatus = '';

  expandedEnquiryId: string | null = null;

  readonly statuses = [
    'NEW',
    'IN_PROGRESS',
    'RESOLVED',
    'CLOSED'
  ];

  constructor(
    private readonly enquiriesService: EnquiriesService,
    private readonly changeDetectorRef: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    this.loadEnquiries();
  }

  loadEnquiries(): void {
    this.loading = true;
    this.error = '';
    this.expandedEnquiryId = null;

    this.enquiriesService
      .list(
        0,
        100,
        this.selectedStatus || undefined
      )
      .subscribe({
        next: response => {
          this.enquiries = response.content;
          this.applyFilters();
          this.loading = false;
          this.changeDetectorRef.markForCheck();
        },

        error: error => {
          this.loading = false;
          this.error =
            error?.error?.message
            || 'Unable to load enquiries.';
          this.changeDetectorRef.markForCheck();
        }
      });
  }

  applyFilters(): void {
    const search =
      this.searchTerm.trim().toLowerCase();

    this.filteredEnquiries =
      this.enquiries.filter(enquiry => {
        if (!search) {
          return true;
        }

        return [
          enquiry.name,
          enquiry.organization,
          enquiry.email,
          enquiry.phone,
          enquiry.audience,
          enquiry.message,
          enquiry.status
        ]
          .filter(
            (
              value
            ): value is string =>
              typeof value === 'string'
          )
          .some(value =>
            value
              .toLowerCase()
              .includes(search)
          );
      });

    if (
      this.expandedEnquiryId
      && !this.filteredEnquiries.some(
        enquiry =>
          enquiry.id === this.expandedEnquiryId
      )
    ) {
      this.expandedEnquiryId = null;
    }
  }

  onSearchChange(): void {
    this.applyFilters();
  }

  onStatusChange(): void {
    this.loadEnquiries();
  }

  toggleExpanded(enquiry: Enquiry): void {
    this.expandedEnquiryId =
      this.expandedEnquiryId === enquiry.id
        ? null
        : enquiry.id;

    this.changeDetectorRef.markForCheck();
  }

  updateStatus(
    enquiry: Enquiry,
    status: string
  ): void {
    this.enquiriesService
      .updateStatus(
        enquiry.id,
        status
      )
      .subscribe({
        next: updated => {
          this.replaceEnquiry(updated);
        },

        error: error => {
          this.error =
            error?.error?.message
            || 'Unable to update status.';
          this.changeDetectorRef.markForCheck();
        }
      });
  }

  deleteEnquiry(enquiry: Enquiry): void {
    const confirmed = window.confirm(
      `Delete the enquiry from ${enquiry.name}?`
    );

    if (!confirmed) {
      return;
    }

    this.enquiriesService
      .delete(enquiry.id)
      .subscribe({
        next: () => {
          this.enquiries =
            this.enquiries.filter(
              item => item.id !== enquiry.id
            );

          if (
            this.expandedEnquiryId
            === enquiry.id
          ) {
            this.expandedEnquiryId = null;
          }

          this.applyFilters();
          this.changeDetectorRef.markForCheck();
        },

        error: error => {
          this.error =
            error?.error?.message
            || 'Unable to delete enquiry.';
          this.changeDetectorRef.markForCheck();
        }
      });
  }

  trackById(
    _index: number,
    enquiry: Enquiry
  ): string {
    return enquiry.id;
  }

  private replaceEnquiry(
    updated: Enquiry
  ): void {
    const index = this.enquiries.findIndex(
      item => item.id === updated.id
    );

    if (index >= 0) {
      this.enquiries[index] = updated;
    }

    this.applyFilters();
    this.changeDetectorRef.markForCheck();
  }
}