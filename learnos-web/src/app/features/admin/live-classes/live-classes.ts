import {
  ChangeDetectorRef,
  Component,
  OnInit,
  inject
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { finalize } from 'rxjs';

import {
  LiveClass,
  LiveClassesService,
  LiveClassStatus,
  MeetingProvider
} from './live-classes.service';

type StatusOption = {
  value: LiveClassStatus;
  label: string;
};

@Component({
  selector: 'app-live-classes',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    RouterModule
  ],
  templateUrl: './live-classes.html',
  styleUrl: './live-classes.scss'
})
export class LiveClasses implements OnInit {
  private service = inject(LiveClassesService);
  private cd = inject(ChangeDetectorRef);

  readonly Math = Math;

  readonly statuses: StatusOption[] = [
    { value: 'DRAFT', label: 'Draft' },
    { value: 'SCHEDULED', label: 'Scheduled' },
    { value: 'LIVE', label: 'Live now' },
    { value: 'COMPLETED', label: 'Completed' },
    { value: 'CANCELLED', label: 'Cancelled' }
  ];

  items: LiveClass[] = [];

  loading = true;
  error = '';

  searchTerm = '';
  selectedStatus: LiveClassStatus | '' = '';

  page = 0;
  pageSize = 12;
  totalElements = 0;
  totalPages = 0;

  ngOnInit(): void {
    this.loadLiveClasses();
  }

  loadLiveClasses(resetPage = false): void {
    if (resetPage) {
      this.page = 0;
    }

    this.loading = true;
    this.error = '';

    this.service
      .getLiveClasses({
        q: this.searchTerm,
        status: this.selectedStatus,
        page: this.page,
        size: this.pageSize,
        sortBy: 'startAt',
        direction: 'ASC'
      })
      .pipe(
        finalize(() => {
          this.loading = false;
          this.cd.detectChanges();
        })
      )
      .subscribe({
        next: (response: any) => {
          const data = response?.data || response || {};

          this.items = Array.isArray(data.content)
            ? data.content
            : [];

          this.totalElements = Number(
            data.totalElements ?? this.items.length
          );

          this.totalPages = Number(
            data.totalPages ??
            (this.totalElements > 0 ? 1 : 0)
          );

          this.page = Number(data.number ?? this.page);

          this.cd.detectChanges();
        },
        error: (err: any) => {
          this.items = [];
          this.totalElements = 0;
          this.totalPages = 0;

          this.error =
            err?.error?.message ||
            err?.error?.error ||
            'Could not load live classes.';

          this.cd.detectChanges();
        }
      });
  }

  onSearchChange(): void {
    this.loadLiveClasses(true);
  }

  onFilterChange(): void {
    this.loadLiveClasses(true);
  }

  clearFilters(): void {
    this.searchTerm = '';
    this.selectedStatus = '';
    this.loadLiveClasses(true);
  }

  previousPage(): void {
    if (this.page <= 0 || this.loading) {
      return;
    }

    this.page -= 1;
    this.loadLiveClasses();
  }

  nextPage(): void {
    if (
      this.loading ||
      this.totalPages === 0 ||
      this.page >= this.totalPages - 1
    ) {
      return;
    }

    this.page += 1;
    this.loadLiveClasses();
  }

  statusLabel(status: LiveClassStatus): string {
    return (
      this.statuses.find(
        item => item.value === status
      )?.label || status
    );
  }

  providerLabel(provider: MeetingProvider): string {
    switch (provider) {
      case 'GOOGLE_MEET':
        return 'Google Meet';

      case 'MICROSOFT_TEAMS':
        return 'Microsoft Teams';

      case 'ZOOM':
        return 'Zoom';

      case 'CUSTOM':
        return 'Custom meeting';

      default:
        return provider;
    }
  }

  formatDate(value: string): string {
    if (!value) {
      return 'Date not set';
    }

    const date = new Date(value);

    if (Number.isNaN(date.getTime())) {
      return 'Date not set';
    }

    return new Intl.DateTimeFormat(
      'en-IN',
      {
        day: '2-digit',
        month: 'short',
        year: 'numeric'
      }
    ).format(date);
  }

  formatDay(value: string): string {
    if (!value) {
      return '—';
    }

    const date = new Date(value);

    if (Number.isNaN(date.getTime())) {
      return '—';
    }

    return new Intl.DateTimeFormat(
      'en-IN',
      {
        day: '2-digit'
      }
    ).format(date);
  }

  formatMonth(value: string): string {
    if (!value) {
      return '';
    }

    const date = new Date(value);

    if (Number.isNaN(date.getTime())) {
      return '';
    }

    return new Intl.DateTimeFormat(
      'en-IN',
      {
        month: 'short'
      }
    )
      .format(date)
      .toUpperCase();
  }

  formatTime(value: string): string {
    if (!value) {
      return 'Time not set';
    }

    const date = new Date(value);

    if (Number.isNaN(date.getTime())) {
      return 'Time not set';
    }

    return new Intl.DateTimeFormat(
      'en-IN',
      {
        hour: 'numeric',
        minute: '2-digit',
        hour12: true
      }
    ).format(date);
  }

  formatDuration(
    startAt: string,
    endAt: string
  ): string {
    const start = new Date(startAt).getTime();
    const end = new Date(endAt).getTime();

    if (
      Number.isNaN(start) ||
      Number.isNaN(end) ||
      end <= start
    ) {
      return '';
    }

    const minutes = Math.round(
      (end - start) / 60000
    );

    if (minutes < 60) {
      return `${minutes} min`;
    }

    const hours = Math.floor(minutes / 60);
    const remainingMinutes = minutes % 60;

    if (remainingMinutes === 0) {
      return `${hours} hr`;
    }

    return `${hours} hr ${remainingMinutes} min`;
  }

  trackById(
    _: number,
    item: LiveClass
  ): string {
    return item.id;
  }
}