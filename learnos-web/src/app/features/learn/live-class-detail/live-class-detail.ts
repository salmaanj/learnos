import {
  ChangeDetectorRef,
  Component,
  OnInit,
  inject
} from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  ActivatedRoute,
  Router,
  RouterModule
} from '@angular/router';
import { finalize } from 'rxjs';

import {
  LearnerLiveClass,
  LearnerLiveClassesService,
  LiveClassJoinResponse
} from '../live-classes/live-classes.service';

@Component({
  selector: 'app-live-class-detail',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule
  ],
  templateUrl: './live-class-detail.html',
  styleUrl: './live-class-detail.scss'
})
export class LiveClassDetail implements OnInit {
  private route = inject(ActivatedRoute);
  private router = inject(Router);
  private service = inject(LearnerLiveClassesService);
  private cd = inject(ChangeDetectorRef);

  liveClassId = '';
  liveClass: LearnerLiveClass | null = null;
  joinResponse: LiveClassJoinResponse | null = null;

  loading = true;
  joining = false;
  leaving = false;
  error = '';
  actionError = '';

  ngOnInit(): void {
    this.liveClassId =
      this.route.snapshot.paramMap.get('id') || '';

    if (!this.liveClassId) {
      this.error = 'Live class ID is missing.';
      this.loading = false;
      return;
    }

    this.loadDetails();
  }

  loadDetails(): void {
    this.loading = true;
    this.error = '';

    this.service
      .getDetails(this.liveClassId)
      .pipe(
        finalize(() => {
          this.loading = false;
          this.cd.detectChanges();
        })
      )
      .subscribe({
        next: (response: any) => {
          this.liveClass = (
            response?.data ||
            response
          ) as LearnerLiveClass;

          this.cd.detectChanges();
        },
        error: (err: any) => {
          this.error =
            err?.error?.message ||
            err?.error?.error ||
            'Could not load this live class.';

          this.cd.detectChanges();
        }
      });
  }

  joinClass(): void {
    if (
      !this.liveClassId ||
      this.joining ||
      !this.liveClass?.joinAvailable
    ) {
      return;
    }

    this.joining = true;
    this.actionError = '';

    this.service
      .join(this.liveClassId)
      .pipe(
        finalize(() => {
          this.joining = false;
          this.cd.detectChanges();
        })
      )
      .subscribe({
        next: (response: any) => {
          this.joinResponse = (
            response?.data ||
            response
          ) as LiveClassJoinResponse;

          this.liveClass = {
            ...this.liveClass!,
            attendanceStatus: 'ATTENDED',
            joinAt: this.joinResponse.joinedAt
          };

          this.cd.detectChanges();

          if (this.joinResponse.meetingUrl) {
            window.open(
              this.joinResponse.meetingUrl,
              '_blank',
              'noopener,noreferrer'
            );
          }
        },
        error: (err: any) => {
          this.actionError =
            err?.error?.message ||
            err?.error?.error ||
            'Could not join this live class.';

          this.cd.detectChanges();
        }
      });
  }

  leaveClass(): void {
    if (
      !this.liveClassId ||
      this.leaving
    ) {
      return;
    }

    this.leaving = true;
    this.actionError = '';

    this.service
      .leave(this.liveClassId)
      .pipe(
        finalize(() => {
          this.leaving = false;
          this.cd.detectChanges();
        })
      )
      .subscribe({
        next: (response: any) => {
          this.liveClass = (
            response?.data ||
            response
          ) as LearnerLiveClass;

          this.joinResponse = null;
          this.cd.detectChanges();
        },
        error: (err: any) => {
          this.actionError =
            err?.error?.message ||
            err?.error?.error ||
            'Could not update attendance.';

          this.cd.detectChanges();
        }
      });
  }

  goBack(): void {
    this.router.navigate([
      '/learn/live-classes'
    ]);
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
        month: 'long',
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
    const remainder = minutes % 60;

    return remainder === 0
      ? `${hours} hr`
      : `${hours} hr ${remainder} min`;
  }
}