import {
  ChangeDetectorRef,
  Component,
  OnInit,
  inject
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { finalize } from 'rxjs';

import {
  LearnerLiveClass,
  LearnerLiveClassesService
} from './live-classes.service';

type LiveClassTab = 'UPCOMING' | 'HISTORY';

@Component({
  selector: 'app-learner-live-classes',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule
  ],
  templateUrl: './live-classes.html',
  styleUrl: './live-classes.scss'
})
export class LearnerLiveClasses implements OnInit {
  private service = inject(LearnerLiveClassesService);
  private cd = inject(ChangeDetectorRef);

  activeTab: LiveClassTab = 'UPCOMING';

  upcoming: LearnerLiveClass[] = [];
  history: LearnerLiveClass[] = [];

  loading = true;
  error = '';

  ngOnInit(): void {
    this.loadUpcoming();
  }

  get visibleClasses(): LearnerLiveClass[] {
    return this.activeTab === 'UPCOMING'
      ? this.upcoming
      : this.history;
  }

  selectTab(tab: LiveClassTab): void {
    if (this.activeTab === tab) {
      return;
    }

    this.activeTab = tab;

    if (tab === 'UPCOMING' && this.upcoming.length === 0) {
      this.loadUpcoming();
    }

    if (tab === 'HISTORY' && this.history.length === 0) {
      this.loadHistory();
    }
  }

  loadUpcoming(): void {
    this.loading = true;
    this.error = '';

    this.service
      .getUpcoming()
      .pipe(
        finalize(() => {
          this.loading = false;
          this.cd.detectChanges();
        })
      )
      .subscribe({
        next: (response: any) => {
          const data = response?.data || response || [];

          this.upcoming = Array.isArray(data)
            ? data
            : [];

          this.cd.detectChanges();
        },
        error: (err: any) => {
          this.error =
            err?.error?.message ||
            err?.error?.error ||
            'Could not load upcoming live classes.';

          this.cd.detectChanges();
        }
      });
  }

  loadHistory(): void {
    this.loading = true;
    this.error = '';

    this.service
      .getHistory()
      .pipe(
        finalize(() => {
          this.loading = false;
          this.cd.detectChanges();
        })
      )
      .subscribe({
        next: (response: any) => {
          const data = response?.data || response || [];

          this.history = Array.isArray(data)
            ? data
            : [];

          this.cd.detectChanges();
        },
        error: (err: any) => {
          this.error =
            err?.error?.message ||
            err?.error?.error ||
            'Could not load live-class history.';

          this.cd.detectChanges();
        }
      });
  }

  statusLabel(
    status: LearnerLiveClass['status']
  ): string {
    switch (status) {
      case 'SCHEDULED':
        return 'Scheduled';

      case 'LIVE':
        return 'Live now';

      case 'COMPLETED':
        return 'Completed';

      case 'CANCELLED':
        return 'Cancelled';

      default:
        return status;
    }
  }

  providerLabel(
    provider: LearnerLiveClass['provider']
  ): string {
    switch (provider) {
      case 'GOOGLE_MEET':
        return 'Google Meet';

      case 'ZOOM':
        return 'Zoom';

      case 'MICROSOFT_TEAMS':
        return 'Microsoft Teams';

      case 'CUSTOM':
        return 'Online meeting';

      default:
        return provider;
    }
  }

  formatDate(value: string): string {
    const date = new Date(value);

    if (Number.isNaN(date.getTime())) {
      return 'Date unavailable';
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

  formatTime(value: string): string {
    const date = new Date(value);

    if (Number.isNaN(date.getTime())) {
      return 'Time unavailable';
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

    return remainingMinutes === 0
      ? `${hours} hr`
      : `${hours} hr ${remainingMinutes} min`;
  }

  trackById(
    _: number,
    item: LearnerLiveClass
  ): string {
    return item.id;
  }
}