import {
  ChangeDetectorRef,
  Component,
  OnDestroy,
  OnInit,
  inject
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { HttpClientModule } from '@angular/common/http';
import { Router, RouterModule } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { finalize, forkJoin } from 'rxjs';

import { CoursesService } from './courses.service';
import {
  Learner,
  LearnersService
} from '../services/learners.service';

type Lesson = {
  id: string;
  title: string;
  description?: string;
  type?: string;
  moduleId?: string;
  moduleTitle?: string;
  isPublished?: boolean;
  isPreview?: boolean;
  order?: number;
  streamingUrl?: string;
  videoUrl?: string;
};

type ModuleItem = {
  id: string;
  title: string;
  description?: string;
  displayOrder?: number;
  isPreview?: boolean;
  expanded?: boolean;
  lessons?: Lesson[];
};

type CourseApiItem = {
  id: string;
  title: string;
  categoryName?: string | null;
  category?: string | null;
  enrolledCount?: number | null;
  totalEnrollments?: number | null;
  completionRate?: number | null;
  averageRating?: number | null;
  rating?: number | null;
  ratingCount?: number | null;
  status?: string | null;
  companyId?: string | null;
  companyName?: string | null;
};

type Course = {
  id: string;
  title: string;
  category: string;
  enrolledCount: number;
  completionRate: number;
  rating: number;
  ratingCount: number;
  status: string;
  companyId?: string | null;
  companyName?: string | null;
  expanded?: boolean;
  modules?: ModuleItem[];
};

type SortColumn =
  | 'title'
  | 'category'
  | 'enrolledCount'
  | 'completionRate'
  | 'rating'
  | 'status';

type SortDirection = 'asc' | 'desc';

@Component({
  selector: 'app-courses',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    HttpClientModule,
    FormsModule
  ],
  templateUrl: './courses.html',
  styleUrl: './courses.scss'
})
export class Courses implements OnInit, OnDestroy {
  private coursesService = inject(CoursesService);
  private learnersService = inject(LearnersService);
  private router = inject(Router);
  private cd = inject(ChangeDetectorRef);

  private refreshTimer?: ReturnType<typeof setTimeout>;

  courses: Course[] = [];
  learners: Learner[] = [];

  loading = true;
  error = '';

  searchTerm = '';
  sortColumn: SortColumn = 'title';
  sortDirection: SortDirection = 'asc';

  ngOnInit(): void {
    this.loadInitialData();
  }

  ngOnDestroy(): void {
    if (this.refreshTimer) {
      clearTimeout(this.refreshTimer);
    }
  }

  get displayedCourses(): Course[] {
    const term = this.searchTerm.trim().toLowerCase();

    const filtered = !term
      ? [...this.courses]
      : this.courses.filter(course =>
          [
            course.title,
            course.category,
            course.status,
            course.rating.toFixed(1)
          ]
            .filter(Boolean)
            .some(value =>
              String(value).toLowerCase().includes(term)
            )
        );

    return filtered.sort((left, right) => {
      const leftValue = this.getSortValue(
        left,
        this.sortColumn
      );

      const rightValue = this.getSortValue(
        right,
        this.sortColumn
      );

      const result = leftValue.localeCompare(
        rightValue,
        undefined,
        {
          numeric: true,
          sensitivity: 'base'
        }
      );

      return this.sortDirection === 'asc'
        ? result
        : -result;
    });
  }

  loadInitialData(): void {
    this.loading = true;
    this.error = '';

    forkJoin({
      coursesResponse: this.coursesService.getCourses(),
      
    })
      .pipe(
        finalize(() => {
          this.loading = false;
          this.cd.detectChanges();
        })
      )
      .subscribe({
        next: ({ coursesResponse,  }) => {
          const items = this.extractArray(coursesResponse);

          this.courses = items.map(course =>
            this.mapCourse(course)
          );

         

          this.cd.detectChanges();
        },
        error: err => {
          console.error('Failed to load courses', err);

          this.courses = [];
          this.learners = [];

          this.error =
            err?.error?.message ||
            err?.error?.error ||
            'Failed to load courses.';

          this.cd.detectChanges();
        }
      });
  }

  loadCourses(): void {
    this.loadInitialData();
  }

  onSearchChange(): void {
    this.cd.detectChanges();
  }

  sortBy(column: SortColumn): void {
    if (this.sortColumn === column) {
      this.sortDirection =
        this.sortDirection === 'asc'
          ? 'desc'
          : 'asc';
    } else {
      this.sortColumn = column;
      this.sortDirection = 'asc';
    }

    this.cd.detectChanges();
  }

  sortIndicator(column: SortColumn): string {
    if (this.sortColumn !== column) {
      return '↕';
    }

    return this.sortDirection === 'asc'
      ? '↑'
      : '↓';
  }

  toggleCourse(course: Course): void {
    course.expanded = !course.expanded;

    if (
      course.expanded &&
      (!course.modules || course.modules.length === 0)
    ) {
      this.loadModules(course);
    }
  }

  loadModules(course: Course): void {
    this.coursesService.getModules(course.id).subscribe({
      next: res => {
        const rawModules = this.extractArray(res);

        course.modules = rawModules
          .sort(
            (left: any, right: any) =>
              (left.displayOrder ?? 0) -
              (right.displayOrder ?? 0)
          )
          .map(
            (module: any): ModuleItem => ({
              id: String(module.id ?? ''),
              title: module.title || 'Untitled module',
              description: module.description,
              displayOrder: module.displayOrder ?? 0,
              isPreview: !!(
                module.isPreview ??
                module.preview
              ),
              expanded: false,
              lessons: []
            })
          );

        this.cd.detectChanges();
      },
      error: err => {
        console.error('Failed to load modules', err);
        course.modules = [];
        this.cd.detectChanges();
      }
    });
  }

  toggleModule(
    course: Course,
    module: ModuleItem
  ): void {
    module.expanded = !module.expanded;

    if (
      module.expanded &&
      (!module.lessons || module.lessons.length === 0)
    ) {
      this.loadLessons(course, module);
    }
  }

  loadLessons(
    course: Course,
    module: ModuleItem
  ): void {
    this.coursesService
      .getLessonsByModule(course.id, module.id)
      .subscribe({
        next: res => {
          const rawLessons = this.extractArray(res);

          module.lessons = rawLessons
            .sort(
              (left: any, right: any) =>
                (left.order ?? left.displayOrder ?? 0) -
                (right.order ?? right.displayOrder ?? 0)
            )
            .map(
              (lesson: any): Lesson => ({
                id: String(lesson.id ?? ''),
                title: lesson.title || 'Untitled lesson',
                description: lesson.description,
                type: lesson.type,
                moduleId: lesson.moduleId,
                moduleTitle: lesson.moduleTitle,
                isPublished: !!(
                  lesson.isPublished ??
                  lesson.published
                ),
                isPreview: !!(
                  lesson.isPreview ??
                  lesson.preview
                ),
                order:
                  lesson.order ??
                  lesson.displayOrder ??
                  0,
                streamingUrl: lesson.streamingUrl,
                videoUrl: lesson.videoUrl
              })
            );

          this.cd.detectChanges();
        },
        error: err => {
          console.error('Failed to load lessons', err);
          module.lessons = [];
          this.cd.detectChanges();
        }
      });
  }

  refreshCourses(): void {
    this.loadInitialData();
  }

  editCourse(course: Course): void {
    this.router.navigate([
      '/admin/courses',
      course.id,
      'edit'
    ]);
  }

  previewCourse(course: Course): void {
    this.router.navigate([
      '/admin/courses',
      course.id,
      'preview'
    ]);
  }

  trackByCourseId(
    _: number,
    course: Course
  ): string {
    return course.id;
  }

  trackByModuleId(
    _: number,
    module: ModuleItem
  ): string {
    return module.id;
  }

  trackByLessonId(
    _: number,
    lesson: Lesson
  ): string {
    return lesson.id;
  }

  ratingStars(rating: number): string[] {
    const fullStars = Math.floor(rating);
    const hasHalfStar = rating - fullStars >= 0.5;

    return Array.from({ length: 5 }, (_, index) => {
      const starNumber = index + 1;

      if (starNumber <= fullStars) {
        return '★';
      }

      if (
        starNumber === fullStars + 1 &&
        hasHalfStar
      ) {
        return '◐';
      }

      return '☆';
    });
  }

  ratingLabel(course: Course): string {
    if (course.ratingCount === 0) {
      return 'No ratings yet';
    }

    const word =
      course.ratingCount === 1
        ? 'rating'
        : 'ratings';

    return `${course.ratingCount} ${word}`;
  }

  private formatStatus(
    status?: string | null
  ): string {
    if (!status) {
      return 'Draft';
    }

    const value = status.trim().toUpperCase();

    if (value === 'PUBLISHED') {
      return 'Published';
    }

    if (value === 'DRAFT') {
      return 'Draft';
    }

    if (value === 'LIVE') {
      return 'Live';
    }

    return (
      status.charAt(0).toUpperCase() +
      status.slice(1).toLowerCase()
    );
  }

  private getSortValue(
    course: Course,
    column: SortColumn
  ): string {
    switch (column) {
      case 'enrolledCount':
        return String(course.enrolledCount).padStart(
          12,
          '0'
        );

      case 'completionRate':
        return String(course.completionRate).padStart(
          12,
          '0'
        );

      case 'rating':
        return String(
          Math.round(course.rating * 10)
        ).padStart(12, '0');

      case 'title':
      case 'category':
      case 'status':
        return String(course[column] ?? '');

      default:
        return '';
    }
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

  private clampRating(value: number): number {
    return Math.max(
      0,
      Math.min(5, Math.round(value * 10) / 10)
    );
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

  private mapCourse(
    course: CourseApiItem | any
  ): Course {
    return {
      id: String(course?.id ?? ''),
      title: course?.title || 'Untitled course',
      category:
        course?.categoryName ||
        course?.category ||
        'Uncategorized',
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
      rating: this.clampRating(
        this.toNumber(
          course?.averageRating ??
          course?.rating ??
          0
        )
      ),
      ratingCount: Math.max(
        0,
        this.toNumber(course?.ratingCount ?? 0)
      ),
      status: this.formatStatus(course?.status),
      companyId: course?.companyId ?? null,
      companyName: course?.companyName ?? null,
      expanded: false,
      modules: []
    };
  }
}