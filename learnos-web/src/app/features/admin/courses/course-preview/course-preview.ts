import {
  ChangeDetectorRef,
  Component,
  OnInit
} from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  ActivatedRoute,
  Router,
  RouterModule
} from '@angular/router';
import {
  DomSanitizer,
  SafeResourceUrl
} from '@angular/platform-browser';
import { CoursesService } from '../courses.service';
import { resolveMediaUrl } from '../../../../core/media-url.util';

interface PreviewLesson {
  id: string;
  title: string;
  description: string | null;
  type: string;
  contentUrl: string | null;
  streamingUrl: string | null;
  textContent: string | null;
  isPublished: boolean;
  isPreview: boolean;
  moduleId: string;
  moduleTitle: string | null;
  order: number;
  durationSeconds: number | null;
}

interface PreviewModule {
  id: string;
  title: string;
  description: string | null;
  displayOrder: number;
  expanded: boolean;
  lessons: PreviewLesson[];
}

@Component({
  selector: 'app-course-preview',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './course-preview.html',
  styleUrl: './course-preview.scss'
})
export class CoursePreview implements OnInit {
  courseId = '';
  course: any = null;
  modules: PreviewModule[] = [];
  selectedLesson: PreviewLesson | null = null;

  loading = true;
  loadingContent = false;
  errorMessage = '';

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private coursesService: CoursesService,
    private sanitizer: DomSanitizer,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    this.courseId =
      this.route.snapshot.paramMap.get('id') || '';

    if (!this.courseId) {
      this.errorMessage = 'Course ID is missing.';
      this.loading = false;
      return;
    }

    this.loadPreview();
  }

  get isDraft(): boolean {
    return String(this.course?.status || '')
      .toUpperCase() === 'DRAFT';
  }

  get courseStatusLabel(): string {
    const status = String(this.course?.status || 'DRAFT')
      .toUpperCase();

    if (status === 'PUBLISHED') {
      return 'Published';
    }

    if (status === 'LIVE') {
      return 'Live';
    }

    return 'Draft';
  }

  get courseDescription(): string {
    return (
      this.course?.description ||
      this.course?.shortDescription ||
      'No course description has been added yet.'
    );
  }

  get totalVisibleLessons(): number {
    return this.modules.reduce(
      (total, module) => total + module.lessons.length,
      0
    );
  }

  get totalModules(): number {
    return this.modules.length;
  }

  get learningOutcomes(): string[] {
    return Array.isArray(this.course?.learningOutcomes)
      ? this.course.learningOutcomes.filter(
          (item: unknown) => !!String(item).trim()
        )
      : [];
  }

  get prerequisites(): string[] {
    return Array.isArray(this.course?.prerequisites)
      ? this.course.prerequisites.filter(
          (item: unknown) => !!String(item).trim()
        )
      : [];
  }

  loadPreview(): void {
    this.loading = true;
    this.loadingContent = true;
    this.errorMessage = '';

    this.coursesService
      .getCourseById(this.courseId)
      .subscribe({
        next: (courseResponse) => {
          this.course =
            courseResponse?.data ||
            courseResponse;

          this.loadModulesAndLessons();
        },
        error: (error) => {
          console.error('Failed to load preview course', error);
          this.errorMessage =
            error?.error?.message ||
            'Could not load this course preview.';
          this.loading = false;
          this.loadingContent = false;
          this.cdr.detectChanges();
        }
      });
  }

  private loadModulesAndLessons(): void {
    this.coursesService
      .getModules(this.courseId)
      .subscribe({
        next: (moduleResponse) => {
          const rawModules = Array.isArray(moduleResponse?.data)
            ? moduleResponse.data
            : Array.isArray(moduleResponse)
              ? moduleResponse
              : [];

          this.coursesService
            .getLessonsByCourse(this.courseId)
            .subscribe({
              next: (lessonResponse) => {
                const rawLessons = Array.isArray(lessonResponse?.data)
                  ? lessonResponse.data
                  : Array.isArray(lessonResponse)
                    ? lessonResponse
                    : [];

                this.modules = rawModules
                  .sort(
                    (left: any, right: any) =>
                      this.toNumber(left?.displayOrder) -
                      this.toNumber(right?.displayOrder)
                  )
                  .map(
                    (
                      module: any,
                      moduleIndex: number
                    ): PreviewModule => {
                      const moduleId = String(module?.id || '');

                      const lessons = rawLessons
                        .filter(
                          (lesson: any) =>
                            String(lesson?.moduleId || '') ===
                            moduleId
                        )
                        .map(
                          (lesson: any): PreviewLesson => ({
                            id: String(lesson?.id || ''),
                            title:
                              lesson?.title ||
                              'Untitled lesson',
                            description:
                              lesson?.description || null,
                            type: String(
                              lesson?.type || 'CONTENT'
                            ).toUpperCase(),
                            contentUrl:
                              lesson?.contentUrl || null,
                            streamingUrl:
                              lesson?.streamingUrl || null,
                            textContent:
                              lesson?.textContent || null,
                            isPublished: !!(
                              lesson?.isPublished ??
                              lesson?.published
                            ),
                            isPreview: !!(
                              lesson?.isPreview ??
                              lesson?.preview
                            ),
                            moduleId,
                            moduleTitle:
                              lesson?.moduleTitle ||
                              module?.title ||
                              null,
                            order: this.toNumber(
                              lesson?.order ??
                              lesson?.displayOrder
                            ),
                            durationSeconds:
                              lesson?.durationSeconds ?? null
                          })
                        )
                        .filter((lesson: PreviewLesson) =>
                          this.shouldShowLesson(lesson)
                        )
                        .sort(
                          (
                            left: PreviewLesson,
                            right: PreviewLesson
                          ) => left.order - right.order
                        );

                      return {
                        id: moduleId,
                        title:
                          module?.title ||
                          'Untitled module',
                        description:
                          module?.description || null,
                        displayOrder: this.toNumber(
                          module?.displayOrder
                        ),
                        expanded: moduleIndex === 0,
                        lessons
                      };
                    }
                  )
                  .filter(
                    (module: PreviewModule) =>
                      module.lessons.length > 0
                  );

                this.selectFirstLesson();

                this.loading = false;
                this.loadingContent = false;
                this.cdr.detectChanges();
              },
              error: (error) => {
                console.error(
                  'Failed to load preview lessons',
                  error
                );

                this.modules = [];
                this.loading = false;
                this.loadingContent = false;
                this.errorMessage =
                  error?.error?.message ||
                  'Could not load course lessons.';
                this.cdr.detectChanges();
              }
            });
        },
        error: (error) => {
          console.error(
            'Failed to load preview modules',
            error
          );

          this.modules = [];
          this.loading = false;
          this.loadingContent = false;
          this.errorMessage =
            error?.error?.message ||
            'Could not load course modules.';
          this.cdr.detectChanges();
        }
      });
  }

  private shouldShowLesson(
    lesson: PreviewLesson
  ): boolean {
    if (this.isDraft) {
      return true;
    }

    return lesson.isPublished;
  }

  private selectFirstLesson(): void {
    const firstLesson = this.modules
      .flatMap((module) => module.lessons)
      .find(Boolean);

    if (firstLesson) {
      this.selectedLesson = firstLesson;
    }
  }

  toggleModule(module: PreviewModule): void {
    module.expanded = !module.expanded;
  }

  openLesson(lesson: PreviewLesson): void {
    this.selectedLesson = lesson;
    this.cdr.detectChanges();
  }

  previousLesson(): void {
    const lessons = this.getAllLessons();
    const currentIndex = lessons.findIndex(
      (lesson) =>
        lesson.id === this.selectedLesson?.id
    );

    if (currentIndex <= 0) {
      return;
    }

    this.selectedLesson = lessons[currentIndex - 1];
    this.expandModuleForLesson(this.selectedLesson);
    this.cdr.detectChanges();
  }

  nextLesson(): void {
    const lessons = this.getAllLessons();
    const currentIndex = lessons.findIndex(
      (lesson) =>
        lesson.id === this.selectedLesson?.id
    );

    if (
      currentIndex < 0 ||
      currentIndex >= lessons.length - 1
    ) {
      return;
    }

    this.selectedLesson = lessons[currentIndex + 1];
    this.expandModuleForLesson(this.selectedLesson);
    this.cdr.detectChanges();
  }

  get canGoPrevious(): boolean {
    const lessons = this.getAllLessons();

    return lessons.findIndex(
      (lesson) =>
        lesson.id === this.selectedLesson?.id
    ) > 0;
  }

  get canGoNext(): boolean {
    const lessons = this.getAllLessons();
    const currentIndex = lessons.findIndex(
      (lesson) =>
        lesson.id === this.selectedLesson?.id
    );

    return (
      currentIndex >= 0 &&
      currentIndex < lessons.length - 1
    );
  }

  get currentLessonNumber(): number {
    const lessons = this.getAllLessons();
    const index = lessons.findIndex(
      (lesson) =>
        lesson.id === this.selectedLesson?.id
    );

    return index >= 0 ? index + 1 : 0;
  }

  get allLessonCount(): number {
    return this.getAllLessons().length;
  }

  lessonUrl(lesson: PreviewLesson): string | null {
    return resolveMediaUrl(
      lesson.streamingUrl || lesson.contentUrl
    );
  }

  documentUrl(lesson: PreviewLesson): string | null {
    return resolveMediaUrl(
      lesson.contentUrl || lesson.streamingUrl
    );
  }

  safeUrl(url: string | null): SafeResourceUrl {
    return this.sanitizer.bypassSecurityTrustResourceUrl(
      url || ''
    );
  }

  isDocumentLesson(lesson: PreviewLesson): boolean {
    return lesson.type === 'PDF' ||
      lesson.type === 'SLIDES';
  }

  lessonIcon(lesson: PreviewLesson): string {
    switch (lesson.type) {
      case 'VIDEO':
        return '▶';
      case 'AUDIO':
        return '♫';
      case 'PDF':
        return 'PDF';
      case 'SLIDES':
        return '▣';
      case 'TEXT':
        return '≡';
      default:
        return '•';
    }
  }

  lessonStatus(lesson: PreviewLesson): string {
    if (this.isDraft && !lesson.isPublished) {
      return 'Draft';
    }

    return 'Available';
  }

  backToCourses(): void {
    this.router.navigate(['/admin/courses']);
  }

  trackByModuleId(
    _: number,
    module: PreviewModule
  ): string {
    return module.id;
  }

  trackByLessonId(
    _: number,
    lesson: PreviewLesson
  ): string {
    return lesson.id;
  }

  private getAllLessons(): PreviewLesson[] {
    return this.modules.flatMap(
      (module) => module.lessons
    );
  }

  private expandModuleForLesson(
    lesson: PreviewLesson | null
  ): void {
    if (!lesson) {
      return;
    }

    const module = this.modules.find(
      (item) => item.id === lesson.moduleId
    );

    if (module) {
      module.expanded = true;
    }
  }

  private toNumber(value: unknown): number {
    const parsed = Number(value);

    return Number.isFinite(parsed)
      ? parsed
      : 0;
  }
}