import {
  ChangeDetectorRef,
  Component,
  OnInit,
  inject
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import {
  ActivatedRoute,
  Router,
  RouterModule
} from '@angular/router';
import { finalize, forkJoin } from 'rxjs';

import { CoursesService } from '../courses/courses.service';
import { AuthService } from '../../../core/auth.service';
import {
  CompanyUser,
  CompanyUsersService
} from '../company-users/company-users.service';
import {
  LiveClass,
  LiveClassesService,
  LiveClassPayload,
  LiveClassStatus,
  MeetingProvider
} from './live-classes.service';

type CourseOption = {
  id: string;
  title: string;
};

type ProviderOption = {
  value: MeetingProvider;
  label: string;
};

type StatusOption = {
  value: LiveClassStatus;
  label: string;
};

@Component({
  selector: 'app-live-class-form',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    RouterModule
  ],
  templateUrl: './live-class-form.html',
  styleUrl: './live-class-form.scss'
})
export class LiveClassForm implements OnInit {
  private route = inject(ActivatedRoute);
  private router = inject(Router);
  private liveClassesService = inject(LiveClassesService);
  private coursesService = inject(CoursesService);
  private companyUsersService = inject(CompanyUsersService);
  private authService = inject(AuthService);
  private cd = inject(ChangeDetectorRef);

  readonly providers: ProviderOption[] = [
    { value: 'GOOGLE_MEET', label: 'Google Meet' },
    { value: 'ZOOM', label: 'Zoom' },
    { value: 'MICROSOFT_TEAMS', label: 'Microsoft Teams' },
    { value: 'CUSTOM', label: 'Custom meeting link' }
  ];

  readonly statuses: StatusOption[] = [
    { value: 'DRAFT', label: 'Draft' },
    { value: 'SCHEDULED', label: 'Scheduled' },
    { value: 'LIVE', label: 'Live' },
    { value: 'COMPLETED', label: 'Completed' },
    { value: 'CANCELLED', label: 'Cancelled' }
  ];

  courses: CourseOption[] = [];
  instructors: CompanyUser[] = [];

  loading = true;
  loadingOptions = true;
  saving = false;
  error = '';
  formError = '';

  liveClassId = '';
  isEditMode = false;
  isTutor = false;

  form = this.emptyForm();

  ngOnInit(): void {
    this.liveClassId = this.route.snapshot.paramMap.get('id') || '';
    this.isEditMode = !!this.liveClassId;
    this.isTutor = this.authService.getUserRole() === 'TUTOR';
    this.loadInitialData();
  }

  loadInitialData(): void {
    this.loading = true;
    this.loadingOptions = true;
    this.error = '';

    const requests: any = {
      courses: this.coursesService.getCourses()
    };

    if (!this.isTutor) {
      requests.users = this.companyUsersService.getUsers();
    }

    if (this.isEditMode) {
      requests.liveClass = this.liveClassesService.getLiveClass(
        this.liveClassId
      );
    }

    forkJoin(requests)
      .pipe(
        finalize(() => {
          this.loading = false;
          this.loadingOptions = false;
          this.cd.detectChanges();
        })
      )
      .subscribe({
        next: (result: any) => {
          this.courses = this.extractCourses(result.courses);

          if (!this.isTutor) {
            this.instructors = this.extractInstructors(result.users);
          }

          if (this.isEditMode) {
            const liveClass = (
              result.liveClass?.data ||
              result.liveClass
            ) as LiveClass;

            this.populateForm(liveClass);
          } else if (this.isTutor) {
            this.form.instructorId = this.authService.getCurrentUser()?.id || '';
          }

          this.cd.detectChanges();
        },
        error: (err: any) => {
          this.error =
            err?.error?.message ||
            err?.error?.error ||
            'Could not load the live class form.';

          this.cd.detectChanges();
        }
      });
  }

  save(status?: LiveClassStatus): void {
    if (this.saving) {
      return;
    }

    this.formError = '';

    const validationError = this.validateForm();

    if (validationError) {
      this.formError = validationError;
      this.cd.detectChanges();
      return;
    }

    if (status) {
      this.form.status = status;
    }

    this.saving = true;
    this.cd.detectChanges();

    const payload = this.buildPayload();

    const request = this.isEditMode
      ? this.liveClassesService.updateLiveClass(
          this.liveClassId,
          payload
        )
      : this.liveClassesService.createLiveClass(payload);

    request
      .pipe(
        finalize(() => {
          this.saving = false;
          this.cd.detectChanges();
        })
      )
      .subscribe({
        next: () => {
          this.router.navigate(['/admin/live-classes']);
        },
        error: (err: any) => {
          this.formError =
            err?.error?.message ||
            err?.error?.error ||
            'Could not save the live class.';

          this.cd.detectChanges();
        }
      });
  }

  cancel(): void {
    if (!this.saving) {
      this.router.navigate(['/admin/live-classes']);
    }
  }

  instructorLabel(user: CompanyUser): string {
    const name =
      user.name ||
      `${user.firstName || ''} ${user.lastName || ''}`.trim();

    return user.email
      ? `${name || 'Unnamed user'} (${user.email})`
      : name || 'Unnamed user';
  }

  private extractCourses(response: any): CourseOption[] {
    const data = response?.data || response || {};
    const rawCourses = Array.isArray(data.content)
      ? data.content
      : Array.isArray(data)
        ? data
        : [];

    return rawCourses
      .filter((course: any) => course?.id)
      .map((course: any) => ({
        id: String(course.id),
        title: String(course.title || 'Untitled course')
      }));
  }

  private extractInstructors(response: any): CompanyUser[] {
    const data = response?.data || response || {};
    const users = Array.isArray(data)
      ? data
      : Array.isArray(data.content)
        ? data.content
        : [];

    return users.filter((user: CompanyUser) => {
      const role = String(user.role || '').toUpperCase();
      const status = String(user.status || '').toUpperCase();

      return !!user.userId
        && status !== 'INACTIVE'
        && (
          role === 'ADMIN' ||
          role === 'TUTOR' ||
          role === 'INSTRUCTOR' ||
          role === 'USER'
        );
    });
  }

  private populateForm(item: LiveClass): void {
    if (!item) {
      this.error = 'The requested live class could not be found.';
      return;
    }

    this.form = {
      courseId: item.courseId || '',
      instructorId: this.isTutor
        ? this.authService.getCurrentUser()?.id || item.instructorId || ''
        : item.instructorId || '',
      title: item.title || '',
      description: item.description || '',
      startAt: this.toDateTimeLocal(item.startAt),
      endAt: this.toDateTimeLocal(item.endAt),
      timezone: item.timezone || 'Asia/Kolkata',
      provider: item.provider || 'GOOGLE_MEET',
      meetingUrl: item.meetingUrl || '',
      meetingPassword: '',
      capacity: item.capacity !== null && item.capacity !== undefined
        ? String(item.capacity)
        : '',
      thumbnailUrl: item.thumbnailUrl || '',
      recordingUrl: item.recordingUrl || '',
      status: item.status || 'DRAFT'
    };
  }

  private buildPayload(): LiveClassPayload {
    return {
      courseId: this.form.courseId || null,
      instructorId: this.isTutor
        ? this.authService.getCurrentUser()?.id || this.form.instructorId || null
        : this.form.instructorId || null,
      title: this.form.title.trim(),
      description: this.form.description.trim() || null,
      startAt: this.toLocalDateTime(this.form.startAt),
      endAt: this.toLocalDateTime(this.form.endAt),
      timezone: this.form.timezone.trim() || 'Asia/Kolkata',
      provider: this.form.provider,
      meetingUrl: this.form.meetingUrl.trim(),
      meetingPassword: this.form.meetingPassword.trim() || null,
      capacity: this.toNullablePositiveNumber(this.form.capacity),
      thumbnailUrl: this.form.thumbnailUrl.trim() || null,
      recordingUrl: this.form.recordingUrl.trim() || null,
      status: this.form.status
    };
  }

  private validateForm(): string {
    if (!this.form.title.trim()) {
      return 'Please enter a live class title.';
    }

    if (!this.form.startAt || !this.form.endAt) {
      return 'Please select both start and end date and time.';
    }

    const start = new Date(this.form.startAt).getTime();
    const end = new Date(this.form.endAt).getTime();

    if (Number.isNaN(start) || Number.isNaN(end) || end <= start) {
      return 'The end date and time must be after the start date and time.';
    }

    if (!this.form.meetingUrl.trim()) {
      return 'Please enter the meeting URL.';
    }

    if (!/^https?:\/\/.+/i.test(this.form.meetingUrl.trim())) {
      return 'Meeting URL must start with http:// or https://.';
    }

    const capacity = this.toNullablePositiveNumber(this.form.capacity);

    if (this.form.capacity.trim() && capacity === null) {
      return 'Capacity must be a whole number of at least 1.';
    }

    if (this.isTutor && !this.authService.getCurrentUser()?.id) {
      return 'Tutor identity could not be determined. Please log in again.';
    }

    return '';
  }

  private toNullablePositiveNumber(value: string): number | null {
    if (!value.trim()) {
      return null;
    }

    const parsed = Number(value);

    if (!Number.isFinite(parsed) || parsed < 1) {
      return null;
    }

    return Math.floor(parsed);
  }

  private toLocalDateTime(value: string): string {
    return value ? `${value}:00` : '';
  }

  private toDateTimeLocal(value: string): string {
    if (!value) {
      return '';
    }

    const date = new Date(value);

    if (Number.isNaN(date.getTime())) {
      return '';
    }

    const offset = date.getTimezoneOffset() * 60000;

    return new Date(date.getTime() - offset)
      .toISOString()
      .slice(0, 16);
  }

  private emptyForm() {
    return {
      courseId: '',
      instructorId: '',
      title: '',
      description: '',
      startAt: '',
      endAt: '',
      timezone: 'Asia/Kolkata',
      provider: 'GOOGLE_MEET' as MeetingProvider,
      meetingUrl: '',
      meetingPassword: '',
      capacity: '',
      thumbnailUrl: '',
      recordingUrl: '',
      status: 'DRAFT' as LiveClassStatus
    };
  }
}
