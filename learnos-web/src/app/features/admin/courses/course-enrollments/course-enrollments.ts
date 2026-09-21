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

import { CoursesService } from '../courses.service';
import {
  Learner,
  LearnersService
} from '../../services/learners.service';

type CourseEnrollment = {
  enrollmentId: string;
  learnerId: string;
  learnerName: string;
  learnerEmail: string;
  courseId: string;
  courseTitle: string;
  status: string;
  progressPercent: number;
  enrolledAt?: string | null;
  completedAt?: string | null;
};

type Course = {
  id: string;
  title: string;
  category: string;
  enrolledCount: number;
  completionRate: number;
  companyId?: string | null;
  companyName?: string | null;
};

@Component({
  selector: 'app-course-enrollments',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    RouterLink
  ],
  templateUrl: './course-enrollments.html',
  styleUrl: './course-enrollments.scss'
})
export class CourseEnrollments implements OnInit {
  private route = inject(ActivatedRoute);
  private coursesService = inject(CoursesService);
  private learnersService = inject(LearnersService);
  private cd = inject(ChangeDetectorRef);

  courseId = '';
  course: Course | null = null;

  learners: Learner[] = [];
  courseEnrollments: CourseEnrollment[] = [];

  newEnrollmentLearnerId = '';
  searchTerm = '';

  loading = true;
  loadingEnrollments = false;
  enrollingLearner = false;
  removingEnrollmentId = '';

  error = '';
  enrollmentError = '';

  ngOnInit(): void {
    this.courseId =
      this.route.snapshot.paramMap.get('id') || '';

    if (!this.courseId) {
      this.error = 'A course ID is required.';
      this.loading = false;
      return;
    }

    this.loadPage();
  }

  get filteredEnrollments(): CourseEnrollment[] {
    const term = this.searchTerm.trim().toLowerCase();

    if (!term) {
      return [...this.courseEnrollments];
    }

    return this.courseEnrollments.filter(enrollment =>
      [
        enrollment.learnerName,
        enrollment.learnerEmail,
        enrollment.status,
        String(enrollment.progressPercent)
      ]
        .filter(Boolean)
        .some(value =>
          String(value).toLowerCase().includes(term)
        )
    );
  }

  get availableLearnersForEnrollment(): Learner[] {
    if (!this.course) {
      return [];
    }

    const enrolledUserIds = new Set(
      this.courseEnrollments.map(
        enrollment => enrollment.learnerId
      )
    );

    return this.learners.filter(learner => {
      const learnerUserId = this.getLearnerUserId(learner);

      const sameCompany =
        !this.course?.companyId ||
        learner.companyId === this.course.companyId;

      return (
        Boolean(learnerUserId) &&
        sameCompany &&
        !enrolledUserIds.has(learnerUserId)
      );
    });
  }

  loadPage(): void {
    this.loading = true;
    this.error = '';
    this.enrollmentError = '';

    forkJoin({
      courseResponse: this.coursesService.getCourseById(
        this.courseId
      ),
      learnersResponse: this.learnersService.getLearners()
    })
      .pipe(
        finalize(() => {
          this.loading = false;
          this.cd.detectChanges();
        })
      )
      .subscribe({
        next: ({ courseResponse, learnersResponse }) => {
          this.course = this.mapCourse(
            courseResponse?.data ?? courseResponse
          );

          this.learners = Array.isArray(learnersResponse)
            ? learnersResponse
            : this.extractArray(learnersResponse);

          this.loadCourseEnrollments();
        },
        error: err => {
          console.error(
            'Failed to load course enrollment page',
            err
          );

          this.course = null;
          this.learners = [];
          this.error =
            err?.error?.message ||
            err?.error?.error ||
            'Could not load this course.';
        }
      });
  }

  loadCourseEnrollments(): void {
    if (!this.courseId) {
      return;
    }

    this.loadingEnrollments = true;
    this.enrollmentError = '';

    this.coursesService
      .getCourseEnrollments(this.courseId)
      .subscribe({
        next: response => {
          this.courseEnrollments = this.extractArray(response)
            .map(item => this.mapEnrollment(item))
            .sort((left, right) =>
              left.learnerName.localeCompare(
                right.learnerName
              )
            );

          this.loadingEnrollments = false;
          this.cd.detectChanges();
        },
        error: err => {
          console.error(
            'Failed to load course enrollments',
            err
          );

          this.courseEnrollments = [];
          this.enrollmentError =
            err?.error?.message ||
            err?.error?.error ||
            'Unable to load course enrollments.';

          this.loadingEnrollments = false;
          this.cd.detectChanges();
        }
      });
  }

  enrollSelectedLearner(): void {
  if (
    !this.course ||
    !this.newEnrollmentLearnerId ||
    this.enrollingLearner
  ) {
    return;
  }

  const learner = this.learners.find(
    item =>
      this.getLearnerUserId(item) ===
      this.newEnrollmentLearnerId
  );

  const learnerId = learner
    ? this.getLearnerUserId(learner)
    : '';

  if (!learnerId) {
    this.enrollmentError =
      'The selected learner does not have a valid user ID. Refresh and try again.';
    return;
  }

  this.enrollingLearner = true;
  this.enrollmentError = '';

  this.coursesService
    .enrollLearnerInCourse(
      this.course.id,
      learnerId
    )
    .subscribe({
      next: () => {
        this.newEnrollmentLearnerId = '';
        this.enrollingLearner = false;

        this.loadCourseEnrollments();
        this.refreshCourse();

        this.cd.detectChanges();
      },
      error: err => {
        console.error(
          'Failed to enroll learner',
          err
        );

        this.enrollmentError =
          err?.error?.message ||
          err?.error?.error ||
          'Unable to enroll learner in this course.';

        this.enrollingLearner = false;
        this.cd.detectChanges();
      }
    });
}

  removeCourseEnrollment(
  enrollment: CourseEnrollment
): void {
  if (!this.course || this.removingEnrollmentId) {
    return;
  }

  const confirmed = confirm(
    `Remove "${enrollment.learnerName}" from "${this.course.title}"?`
  );

  if (!confirmed) {
    return;
  }

  this.removingEnrollmentId =
    enrollment.enrollmentId;

  this.enrollmentError = '';

  this.coursesService
    .removeLearnerFromCourse(
      this.course.id,
      enrollment.learnerId
    )
    .subscribe({
      next: () => {
        this.removingEnrollmentId = '';

        this.loadCourseEnrollments();
        this.refreshCourse();

        this.cd.detectChanges();
      },
      error: err => {
        console.error(
          'Failed to remove course enrollment',
          err
        );

        this.enrollmentError =
          err?.error?.message ||
          err?.error?.error ||
          'Unable to remove this learner from the course.';

        this.removingEnrollmentId = '';
        this.cd.detectChanges();
      }
    });
}

  trackByEnrollmentId(
    _: number,
    enrollment: CourseEnrollment
  ): string {
    return enrollment.enrollmentId;
  }

  formatEnrollmentDate(
    value?: string | null
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

  displayEnrollmentStatus(
    status: string
  ): string {
    const normalized = String(status || '')
      .trim()
      .toUpperCase();

    if (normalized === 'COMPLETED') {
      return 'Completed';
    }

    if (normalized === 'CANCELLED') {
      return 'Cancelled';
    }

    if (normalized === 'CERTIFIED') {
      return 'Certified';
    }

    return 'In progress';
  }

  enrollmentStatusClass(
    status: string
  ): string {
    const normalized = String(status || '')
      .trim()
      .toUpperCase();

    if (normalized === 'CERTIFIED') {
      return 'status-certified';
    }

    if (normalized === 'COMPLETED') {
      return 'status-completed';
    }

    if (normalized === 'CANCELLED') {
      return 'status-cancelled';
    }

    return 'status-active';
  }

  private refreshCourse(): void {
    this.coursesService
      .getCourseById(this.courseId)
      .subscribe({
        next: response => {
          this.course = this.mapCourse(
            response?.data ?? response
          );

          this.cd.detectChanges();
        },
        error: err => {
          console.error(
            'Failed to refresh course details',
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
      id: String(course?.id ?? this.courseId),
      title: String(
        course?.title ?? 'Untitled course'
      ),
      category: String(
        course?.categoryName ??
        course?.category ??
        'Uncategorized'
      ),
      enrolledCount: this.toNumber(
        course?.enrolledCount ??
        course?.totalEnrollments ??
        0
      ),
      completionRate: this.clampPercent(
        this.toNumber(
          course?.completionRate ?? 0
        )
      ),
      companyId: course?.companyId ?? null,
      companyName: course?.companyName ?? null
    };
  }

  private mapEnrollment(
    enrollment: any
  ): CourseEnrollment {
    return {
      enrollmentId: String(
        enrollment?.enrollmentId || ''
      ),
      learnerId: String(
        enrollment?.learnerId || ''
      ),
      learnerName: String(
        enrollment?.learnerName || 'Learner'
      ),
      learnerEmail: String(
        enrollment?.learnerEmail || ''
      ),
      courseId: String(
        enrollment?.courseId || this.courseId
      ),
      courseTitle: String(
        enrollment?.courseTitle ||
        this.course?.title ||
        ''
      ),
      status: String(
        enrollment?.status || 'ACTIVE'
      ),
      progressPercent: this.clampPercent(
        this.toNumber(
          enrollment?.progressPercent ?? 0
        )
      ),
      enrolledAt:
        enrollment?.enrolledAt ?? null,
      completedAt:
        enrollment?.completedAt ?? null
    };
  }

  private getLearnerUserId(
    learner: Learner
  ): string {
    return String(
      learner.userId || learner.id || ''
    ).trim();
  }

  private toNumber(value: unknown): number {
    const parsed = Number(value);

    return Number.isFinite(parsed)
      ? parsed
      : 0;
  }

  private clampPercent(value: number): number {
    return Math.max(
      0,
      Math.min(100, Math.round(value))
    );
  }
}