import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { LearnerPortalService } from '../services/learner-portal.service';
import { resolveMediaUrl } from '../../../core/media-url.util';

interface CourseCard {
  id: string;
  title: string;
  shortDescription: string | null;
  categoryId: string | null;
  categoryName: string | null;
  paid: boolean;
  price: number | null;
  totalLessons: number;
  durationMinutes: number | null;
  enrolled: boolean;
  enrolling: boolean;
  thumbnailUrl: string | null;
}

interface CategoryOption {
  id: string;
  name: string;
}

@Component({
  selector: 'app-browse-courses',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './browse-courses.html',
  styleUrl: './browse-courses.scss'
})
export class BrowseCourses implements OnInit {
  courses: CourseCard[] = [];
  filteredCourses: CourseCard[] = [];
  categories: CategoryOption[] = [];
  selectedCategoryId: string | null = null;
  loading = true;
  errorMessage = '';
  private myCourseIds = new Set<string>();

  constructor(
    private service: LearnerPortalService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    this.load();
    this.loadCategories();
  }

  loadCategories(): void {
    this.service.getCategories().subscribe({
      next: (res) => {
        const items = Array.isArray(res?.data) ? res.data : (Array.isArray(res) ? res : []);
        this.categories = items.map((c: any) => ({ id: c.id, name: c.name }));
        this.cdr.detectChanges();
      },
      error: () => { /* category filter is a bonus - fail quietly */ }
    });
  }

  selectCategory(categoryId: string | null): void {
    this.selectedCategoryId = categoryId;
    this.filteredCourses = categoryId
      ? this.courses.filter(c => c.categoryId === categoryId)
      : this.courses;
  }

  load(): void {
    this.loading = true;
    this.errorMessage = '';

    this.service.getMyCourses().subscribe({
      next: (myRes) => {
        const myCourses = Array.isArray(myRes?.data) ? myRes.data : [];
        this.myCourseIds = new Set(myCourses.map((c: any) => c.id));
        this.loadAvailable();
      },
      error: () => this.loadAvailable() // "my courses" failing shouldn't block browsing
    });
  }

  private loadAvailable(): void {
    this.service.getAvailableCourses().subscribe({
      next: (res) => {
        const items = Array.isArray(res?.data?.content) ? res.data.content : [];
        this.courses = items.map((c: any) => ({
          id: c.id,
          title: c.title,
          shortDescription: c.shortDescription,
          categoryId: c.categoryId,
          categoryName: c.categoryName,
          paid: !!c.paid,
          price: c.price,
          totalLessons: c.totalLessons || 0,
          durationMinutes: c.durationMinutes,
          enrolled: this.myCourseIds.has(c.id),
          thumbnailUrl: resolveMediaUrl(c.thumbnailUrl),
          enrolling: false
        }));
        this.filteredCourses = this.selectedCategoryId
          ? this.courses.filter(c => c.categoryId === this.selectedCategoryId)
          : this.courses;
        this.loading = false;
        this.cdr.detectChanges();
      },
      error: () => {
        this.errorMessage = 'Could not load courses. Please try again.';
        this.loading = false;
        this.cdr.detectChanges();
      }
    });
  }

  enroll(course: CourseCard): void {
    if (course.paid) {
      // No payment gateway wired up yet - be upfront rather than faking it.
      alert(
        `"${course.title}" is a paid course (₹${course.price ?? '—'}). ` +
        `Online payment isn't connected yet - please contact your company admin to get access.`
      );
      return;
    }

    course.enrolling = true;
    this.service.enroll(course.id).subscribe({
      next: () => {
        course.enrolled = true;
        course.enrolling = false;
        this.cdr.detectChanges();
      },
      error: (err) => {
        course.enrolling = false;
        alert(err?.error?.error || 'Could not enroll in this course.');
        this.cdr.detectChanges();
      }
    });
  }
}
