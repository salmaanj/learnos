import {
  ChangeDetectorRef,
  Component,
  OnInit,
  inject
} from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  ActivatedRoute,
  RouterLink
} from '@angular/router';
import { FormsModule } from '@angular/forms';
import { forkJoin } from 'rxjs';
import { finalize } from 'rxjs/operators';

import {
  Learner,
  LearnerEnrollment,
  LearnersService
} from '../../services/learners.service';
import { CoursesService } from '../../courses/courses.service';

type Course = {
  id: string;
  title: string;
  category: string;
  companyId: string | null;
  companyName: string | null;
  status: string;
};

@Component({
  selector: 'app-learner-enrollments',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    RouterLink
  ],
  templateUrl: './learner-enrollments.html',
  styleUrl: './learner-enrollments.scss'
})
export class LearnerEnrollments implements OnInit {
  private route = inject(ActivatedRoute);
  private learnersService = inject(LearnersService);
  private coursesService = inject(CoursesService);
  private cdr = inject(ChangeDetectorRef);

  learnerUserId = '';
  learner: Learner | null = null;

  learnerEnrollments: LearnerEnrollment[] = [];
  courses: Course[] = [];

  courseSearchTerm = '';
  selectedCourseId = '';

  loading = true;
  loadingEnrollments = false;
  enrolling = false;
  removingEnrollmentId = '';

  errorMessage = '';
  enrollmentError = '';

  ngOnInit(): void {
    this.learnerUserId =
      this.route.snapshot.paramMap.get('userId') || '';

    if (!this.learnerUserId) {
      this.loading = false;
      this.errorMessage = 'A learner ID is required.';
      return;
    }

    this.loadPage();
  }

  get filteredAvailableCourses(): Course[] {
    if (!this.learner) {
      return [];
    }

    const enrolledCourseIds = new Set(
      this.learnerEnrollments.map(
        enrollment => enrollment.courseId
      )
    );

    const rawTerm = this.courseSearchTerm
      .trim()
      .toLowerCase();

    return this.courses
      .filter(course => {
        const sameCompany =
          !course.companyId ||
          course.companyId === this.learner?.companyId;

        return (
          sameCompany &&
          !enrolledCourseIds.has(course.id)
        );
      })
      .filter(course => {
        if (!rawTerm) {
          return true;
        }

        return [
          course.title,
          course.category,
          course.status
        ]
          .filter(Boolean)
          .some(value =>
            String(value)
              .toLowerCase()
              .includes(rawTerm)
          );
      })
      .sort((left, right) =>
        left.title.localeCompare(right.title)
      );
  }

  get filteredEnrollments(): LearnerEnrollment[] {
    return [...this.learnerEnrollments].sort(
      (left, right) =>
        left.courseTitle.localeCompare(right.courseTitle)
    );
  }

  loadPage(): void {
    this.loading = true;
    this.errorMessage = '';
    this.enrollmentError = '';

    forkJoin({
      learnersResponse: this.learnersService.getLearners(),
      coursesResponse: this.coursesService.getCourses()
    })
      .pipe(
        finalize(() => {
          this.loading = false;
          this.cdr.detectChanges();
        })
      )
      .subscribe({
        next: ({ learnersResponse, coursesResponse }) => {
          const learners = Array.isArray(learnersResponse)
            ? learnersResponse
            : this.extractArray(learnersResponse);

          this.learner = learners.find(
            item =>
              String(item.userId) ===
              String(this.learnerUserId)
          ) || null;

          if (!this.learner) {
            this.errorMessage = 'Learner not found.';
            return;
          }

          this.courses = this.extractArray(coursesResponse)
            .map(item => this.mapCourse(item))
            .filter(course => Boolean(course.id));

          this.loadLearnerEnrollments();
        },
        error: err => {
          console.error(
            'Failed to load learner enrollments page',
            err
          );

          this.errorMessage =
            err?.error?.message ||
            err?.error?.error ||
            'Could not load learner enrollment details.';
        }
      });
  }

  loadLearnerEnrollments(): void {
    if (!this.learnerUserId) {
      return;
    }

    this.loadingEnrollments = true;
    this.enrollmentError = '';

    this.learnersService
      .getLearnerEnrollments(this.learnerUserId)
      .subscribe({
        next: response => {
          this.learnerEnrollments = this.extractArray(response)
            .map(item => this.mapEnrollment(item))
            .sort((left, right) =>
              left.courseTitle.localeCompare(right.courseTitle)
            );

          this.loadingEnrollments = false;
          this.cdr.detectChanges();
        },
        error: err => {
          console.error(
            'Failed to load learner course enrollments',
            err
          );

          this.learnerEnrollments = [];
          this.enrollmentError =
            err?.error?.message ||
            err?.error?.error ||
            'Could not load the learner’s course enrollments.';

          this.loadingEnrollments = false;
          this.cdr.detectChanges();
        }
      });
  }

  enrollSelectedCourse(): void {
    if (
      !this.learner ||
      !this.selectedCourseId ||
      this.enrolling
    ) {
      return;
    }

    const course = this.courses.find(
      item => item.id === this.selectedCourseId
    );

    if (!course) {
      this.enrollmentError =
        'Select a valid course before enrolling the learner.';
      return;
    }

    this.enrolling = true;
    this.enrollmentError = '';

    this.coursesService
      .enrollLearnerInCourse(
        course.id,
        this.learner.userId
      )
      .subscribe({
        next: () => {
          this.selectedCourseId = '';
          this.enrolling = false;

          this.loadLearnerEnrollments();
          this.refreshLearner();

          this.cdr.detectChanges();
        },
        error: err => {
          console.error(
            'Failed to enroll learner in course',
            err
          );

          this.enrollmentError =
            err?.error?.message ||
            err?.error?.error ||
            'Could not enroll this learner in the selected course.';

          this.enrolling = false;
          this.cdr.detectChanges();
        }
      });
  }

  removeEnrollment(
    enrollment: LearnerEnrollment
  ): void {
    if (!this.learner || this.removingEnrollmentId) {
      return;
    }

    const confirmed = confirm(
      `Remove "${this.learner.name}" from "${enrollment.courseTitle}"?`
    );

    if (!confirmed) {
      return;
    }

    this.removingEnrollmentId = enrollment.enrollmentId;
    this.enrollmentError = '';

    this.coursesService
      .removeLearnerFromCourse(
        enrollment.courseId,
        this.learner.userId
      )
      .subscribe({
        next: () => {
          this.removingEnrollmentId = '';

          this.loadLearnerEnrollments();
          this.refreshLearner();

          this.cdr.detectChanges();
        },
        error: err => {
          console.error(
            'Failed to remove learner enrollment',
            err
          );

          this.enrollmentError =
            err?.error?.message ||
            err?.error?.error ||
            'Could not remove this course enrollment.';

          this.removingEnrollmentId = '';
          this.cdr.detectChanges();
        }
      });
  }

  trackByEnrollmentId(
    _: number,
    enrollment: LearnerEnrollment
  ): string {
    return enrollment.enrollmentId;
  }

  formatEnrollmentDate(
    value: string | null | undefined
  ): string {
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

  enrollmentStatusLabel(status: string): string {
    const normalized = String(status || '')
      .trim()
      .toUpperCase();

    if (normalized === 'CERTIFIED') {
      return 'Certified';
    }

    if (normalized === 'COMPLETED') {
      return 'Completed';
    }

    if (
      normalized === 'IN PROGRESS' ||
      normalized === 'ACTIVE'
    ) {
      return 'In progress';
    }

    if (normalized === 'CANCELLED') {
      return 'Cancelled';
    }

    return status || 'Unknown';
  }

  enrollmentStatusClass(status: string): string {
    const normalized = String(status || '')
      .trim()
      .toUpperCase();

    if (normalized === 'CERTIFIED') {
      return 'enrollment-certified';
    }

    if (normalized === 'COMPLETED') {
      return 'enrollment-completed';
    }

    if (
      normalized === 'IN PROGRESS' ||
      normalized === 'ACTIVE'
    ) {
      return 'enrollment-active';
    }

    return 'enrollment-other';
  }

  private refreshLearner(): void {
    this.learnersService.getLearners().subscribe({
      next: response => {
        const learners = Array.isArray(response)
          ? response
          : this.extractArray(response);

        this.learner = learners.find(
          item =>
            String(item.userId) ===
            String(this.learnerUserId)
        ) || this.learner;

        this.cdr.detectChanges();
      },
      error: err => {
        console.error(
          'Failed to refresh learner details',
          err
        );
      }
    });
  }

  private extractArray(response: any): any[] {
    if (Array.isArray(response?.data?.content)) {
      return response.data.content;
    }

    if (Array.isArray(response?.content)) {
      return response.content;
    }

    if (Array.isArray(response?.data)) {
      return response.data;
    }

    if (Array.isArray(response)) {
      return response;
    }

    return [];
  }

  private mapCourse(course: any): Course {
    return {
      id: String(course?.id ?? ''),
      title: String(
        course?.title ?? 'Untitled course'
      ),
      category: String(
        course?.categoryName ??
        course?.category ??
        'Uncategorized'
      ),
      companyId: course?.companyId ?? null,
      companyName: course?.companyName ?? null,
      status: String(course?.status ?? 'DRAFT')
    };
  }

  private mapEnrollment(
    enrollment: any
  ): LearnerEnrollment {
    return {
      enrollmentId: String(
        enrollment?.enrollmentId || ''
      ),
      learnerId: String(
        enrollment?.learnerId ||
        this.learnerUserId
      ),
      courseId: String(enrollment?.courseId || ''),
      courseTitle: String(
        enrollment?.courseTitle || 'Course'
      ),
      courseCategory:
        enrollment?.courseCategory ?? null,
      status: String(
        enrollment?.status || 'In progress'
      ),
      progressPercent: this.clampPercent(
        Number(enrollment?.progressPercent ?? 0)
      ),
      enrolledAt:
        enrollment?.enrolledAt ?? null,
      completedAt:
        enrollment?.completedAt ?? null
    };
  }

  private clampPercent(value: number): number {
    if (!Number.isFinite(value)) {
      return 0;
    }

    return Math.max(
      0,
      Math.min(100, Math.round(value))
    );
  }
}