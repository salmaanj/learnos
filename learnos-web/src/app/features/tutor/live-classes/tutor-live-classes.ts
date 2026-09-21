import {
  ChangeDetectorRef,
  Component,
  OnInit,
  inject
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { finalize } from 'rxjs';
import {
  TutorLiveClass,
  TutorLiveClassesService,
  TutorJoinResponse
} from './tutor-live-classes.service';

@Component({
  selector: 'app-tutor-live-classes',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './tutor-live-classes.html',
  styleUrl: './tutor-live-classes.scss'
})
export class TutorLiveClasses implements OnInit {
  private readonly service = inject(TutorLiveClassesService);
  private readonly cd = inject(ChangeDetectorRef);
  private readonly router = inject(Router);

  classes: TutorLiveClass[] = [];
  todayClasses: TutorLiveClass[] = [];
  loading = true;
  error = '';
  actionError = '';
  joiningId = '';

  ngOnInit(): void {
    this.loadClasses();
  }

  loadClasses(): void {
    this.loading = true;
    this.error = '';
    this.actionError = '';

    this.service.getUpcoming()
      .pipe(finalize(() => {
        this.loading = false;
        this.cd.detectChanges();
      }))
      .subscribe({
        next: (response: any) => {
          const data = response?.data || response || [];
          this.classes = Array.isArray(data) ? data : [];
          this.todayClasses = this.classes.filter(item =>
            this.dateKey(item.startAt) === this.dateKey(new Date())
          );
          this.cd.detectChanges();
        },
        error: (err: any) => {
          this.classes = [];
          this.todayClasses = [];
          this.error = err?.error?.message || err?.error?.error ||
            'Could not load your assigned live classes.';
          this.cd.detectChanges();
        }
      });
  }

  joinClass(item: TutorLiveClass): void {
    if (!item.id || this.joiningId) return;

    this.joiningId = item.id;
    this.actionError = '';

    this.service.joinClass(item.id)
      .pipe(finalize(() => {
        this.joiningId = '';
        this.cd.detectChanges();
      }))
      .subscribe({
        next: (response: any) => {
          const data = (response?.data || response) as TutorJoinResponse;
          if (data?.meetingUrl) {
            window.open(data.meetingUrl, '_blank', 'noopener,noreferrer');
          } else {
            this.actionError = 'The meeting URL was not returned.';
          }
        },
        error: (err: any) => {
          this.actionError = err?.error?.message || err?.error?.error ||
            'Could not join this live class.';
        }
      });
  }

  goToDashboard(): void {
    this.router.navigate(['/admin/dashboard']);
  }

  goToLiveClasses(): void {
    this.router.navigate(['/admin/live-classes']);
  }

  formatDate(value: string): string {
    const date = new Date(value);
    return Number.isNaN(date.getTime()) ? 'Date unavailable' :
      new Intl.DateTimeFormat('en-IN', {
        day: '2-digit', month: 'short', year: 'numeric'
      }).format(date);
  }

  formatTime(value: string): string {
    const date = new Date(value);
    return Number.isNaN(date.getTime()) ? 'Time unavailable' :
      new Intl.DateTimeFormat('en-IN', {
        hour: 'numeric', minute: '2-digit', hour12: true
      }).format(date);
  }

  formatProvider(value: string): string {
    switch (value) {
      case 'GOOGLE_MEET': return 'Google Meet';
      case 'MICROSOFT_TEAMS': return 'Microsoft Teams';
      case 'ZOOM': return 'Zoom';
      default: return 'Online meeting';
    }
  }

  trackById(_: number, item: TutorLiveClass): string {
    return item.id;
  }

  private dateKey(value: string | Date): string {
    const date = new Date(value);
    if (Number.isNaN(date.getTime())) return '';
    return [
      date.getFullYear(),
      String(date.getMonth() + 1).padStart(2, '0'),
      String(date.getDate()).padStart(2, '0')
    ].join('-');
  }
}
