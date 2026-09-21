import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { LearnerPortalService } from '../services/learner-portal.service';
import { resolveMediaUrl } from '../../../core/media-url.util';

interface MyCourseCard {
  id: string;
  title: string;
  shortDescription: string | null;
  progressPercent: number;
  totalLessons: number;
  thumbnailUrl: string | null;
}

@Component({
  selector: 'app-my-courses',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './my-courses.html',
  styleUrl: './my-courses.scss'
})
export class MyCourses implements OnInit {
  courses: MyCourseCard[] = [];
  loading = true;
  errorMessage = '';

  constructor(
    private service: LearnerPortalService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    this.load();
  }

  load(): void {
    this.loading = true;
    this.errorMessage = '';

    this.service.getMyCourses().subscribe({
      next: (res) => {
        const items = Array.isArray(res?.data) ? res.data : [];
        this.courses = items.map((c: any) => ({
          id: c.id,
          title: c.title,
          shortDescription: c.shortDescription,
          progressPercent: c.progressPercent ?? 0,
          totalLessons: c.totalLessons || 0,
          thumbnailUrl: resolveMediaUrl(c.thumbnailUrl)
        }));
        this.loading = false;
        this.cdr.detectChanges();
      },
      error: () => {
        this.errorMessage = 'Could not load your courses. Please try again.';
        this.loading = false;
        this.cdr.detectChanges();
      }
    });
  }
}
