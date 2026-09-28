import {
  ChangeDetectorRef,
  Component,
  HostListener,
  OnDestroy,
  OnInit
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterModule } from '@angular/router';
import { DomSanitizer, SafeResourceUrl } from '@angular/platform-browser';
import { HttpClient } from '@angular/common/http';

import {
  CoursePaymentOrderResponse,
  CourseProgressResponse,
  CourseRatingResponse,
  LearnerPortalService,
  LessonProgressResponse
} from '../services/learner-portal.service';
import { LearnerQuizService } from '../services/learner-quiz.service';
import { resolveMediaUrl } from '../../../core/media-url.util';

declare global {
  interface Window {
    Razorpay: new (options: RazorpayCheckoutOptions) => RazorpayCheckout;
  }
}

interface RazorpayCheckoutResponse {
  razorpay_order_id: string;
  razorpay_payment_id: string;
  razorpay_signature: string;
}

interface RazorpayCheckoutOptions {
  key: string;
  amount: number;
  currency: string;
  name: string;
  description: string;
  order_id: string;
  handler: (response: RazorpayCheckoutResponse) => void;
  modal?: { ondismiss?: () => void };
  theme?: { color?: string };
}

interface RazorpayCheckout {
  open(): void;
  on(eventName: string, handler: (response: any) => void): void;
}

interface LessonItem {
  id: string;
  title: string;
  description: string | null;
  type: string;
  contentUrl: string | null;
  streamingUrl: string | null;
  textContent: string | null;
  isPreview: boolean;
  moduleId: string | null;
  durationSeconds: number | null;
  downloadable: boolean;
  completed: boolean;
  watchedSeconds: number;
  progressPercent: number;
}

interface ModuleItem {
  id: string;
  title: string;
  description: string | null;
  displayOrder: number;
  lessons: LessonItem[];
  expanded: boolean;
}

@Component({
  selector: 'app-learn-course-detail',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './course-detail.html',
  styleUrl: './course-detail.scss'
})
export class LearnCourseDetail implements OnInit, OnDestroy {
  courseId = '';
  course: any = null;
  modules: ModuleItem[] = [];
  enrolled = false;
  enrolling = false;
  paymentLoading = false;
  loading = true;
  errorMessage = '';
  paymentError = '';
  selectedLesson: LessonItem | null = null;
  quizzes: any[] = [];
  quizzesLoading = false;
  courseProgress: CourseProgressResponse | null = null;
  progressLoading = false;
  progressSaveInFlight = false;
  completionSaving = false;
  courseRating: CourseRatingResponse | null = null;
  ratingLoading = false;
  ratingSaving = false;
  downloadingLessonId = '';
  documentFullscreen = false;

  private activeMedia: HTMLMediaElement | null = null;
  private activeMediaLessonId = '';
  private lastSavedPositionSeconds = 0;
  private pendingProgressSave: { lessonId: string; watchedSeconds: number; completed: boolean } | null = null;
  private readonly progressSaveIntervalSeconds = 15;
  private readonly completionThresholdSeconds = 2;

  constructor(
    private route: ActivatedRoute,
    private service: LearnerPortalService,
    private quizService: LearnerQuizService,
    private sanitizer: DomSanitizer,
    private http: HttpClient,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    this.courseId = this.route.snapshot.paramMap.get('id') || '';
    this.load();
  }

  ngOnDestroy(): void {
    this.saveSelectedLessonProgress(true);
  }

  toggleDocumentFullscreen(element: HTMLElement): void {
    if (document.fullscreenElement) {
      document.exitFullscreen?.();
      return;
    }
    const request = element.requestFullscreen?.();
    request?.catch(() => undefined);
  }

  @HostListener('document:fullscreenchange')
  onFullscreenChange(): void {
    this.documentFullscreen = !!document.fullscreenElement;
    this.cdr.detectChanges();
  }

  get isPaid(): boolean { return !!this.course?.paid; }
  get coursePrice(): number | null { const price = Number(this.course?.price); return Number.isFinite(price) && price > 0 ? price : null; }
  get formattedPrice(): string { if (!this.isPaid) return 'Free'; if (this.coursePrice === null) return 'Price on request'; return `₹${this.coursePrice.toLocaleString('en-IN')}`; }
  get courseDescription(): string { return this.course?.description || this.course?.shortDescription || 'No course description has been added yet.'; }
  get learningOutcomes(): string[] { return Array.isArray(this.course?.learningOutcomes) ? this.course.learningOutcomes.filter((item: any) => !!String(item).trim()) : []; }
  get prerequisites(): string[] { return Array.isArray(this.course?.prerequisites) ? this.course.prerequisites.filter((item: any) => !!String(item).trim()) : []; }
  get totalLessons(): number { const count = this.modules.reduce((total, module) => total + module.lessons.length, 0); return count > 0 ? count : Number(this.course?.totalLessons ?? 0); }
  get completedLessons(): number { return this.courseProgress?.completedLessons ?? 0; }
  get courseProgressPercent(): number { return this.courseProgress?.progressPercent ?? 0; }
  get assessmentUnlocked(): boolean { return !!this.courseProgress?.assessmentUnlocked; }
  get hasResumeLesson(): boolean { return !!this.courseProgress?.resumeLessonId; }
  get averageRating(): number { return this.courseRating?.averageRating ?? Number(this.course?.averageRating ?? this.course?.rating ?? 0); }
  get ratingCount(): number { return this.courseRating?.ratingCount ?? Number(this.course?.ratingCount ?? 0); }
  get myRating(): number | null { return this.courseRating?.myRating ?? this.toNullableNumber(this.course?.myRating); }
  get ratingText(): string { return this.ratingCount === 0 ? 'No ratings yet' : `${this.ratingCount} ${this.ratingCount === 1 ? 'rating' : 'ratings'}`; }
  ratingStars(): number[] { return [1, 2, 3, 4, 5]; }
  isStarFilled(star: number): boolean { return star <= Math.round(this.averageRating); }

  lessonUrl(lesson: LessonItem): string | null { return resolveMediaUrl(lesson.streamingUrl || lesson.contentUrl); }
  documentUrl(lesson: LessonItem): string | null { return resolveMediaUrl(lesson.contentUrl || lesson.streamingUrl); }
  safeUrl(url: string | null): SafeResourceUrl { return this.sanitizer.bypassSecurityTrustResourceUrl(url || ''); }
  isDocumentLesson(lesson: LessonItem): boolean { return lesson.type === 'PDF' || lesson.type === 'SLIDES'; }
  isManualCompletionLesson(lesson: LessonItem): boolean { return ['PDF', 'SLIDES', 'TEXT'].includes(lesson.type); }

  downloadSelectedLesson(): void {
    const lesson = this.selectedLesson;
    if (!lesson || !lesson.downloadable || !this.enrolled || this.downloadingLessonId) return;

    this.downloadingLessonId = lesson.id;
    this.cdr.detectChanges();

    this.service.downloadLesson(lesson.id).subscribe({
      next: (blob: Blob) => {
        const url = window.URL.createObjectURL(blob);
        const anchor = document.createElement('a');
        anchor.href = url;
        anchor.download = this.downloadFileName(lesson);
        anchor.click();
        setTimeout(() => window.URL.revokeObjectURL(url), 1000);
        this.downloadingLessonId = '';
        this.cdr.detectChanges();
      },
      error: () => {
        this.downloadingLessonId = '';
        alert('Could not download this lesson. Please try again.');
        this.cdr.detectChanges();
      }
    });
  }

  private downloadFileName(lesson: LessonItem): string {
    const title = lesson.title.replace(/[^a-zA-Z0-9_-]+/g, '_') || 'lesson';
    const type = lesson.type.toUpperCase();
    const extension = type === 'PDF' || type === 'SLIDES' ? 'pdf' : type === 'AUDIO' ? 'mp3' : type === 'VIDEO' ? 'mp4' : 'bin';
    return `${title}.${extension}`;
  }

  lessonIcon(lesson: LessonItem): string {
    if (lesson.completed) return '✓';
    if (!this.isUnlocked(lesson)) return '🔒';
    switch (lesson.type) {
      case 'VIDEO': return '▶';
      case 'AUDIO': return '♫';
      case 'PDF': return 'PDF';
      case 'SLIDES': return '▣';
      case 'TEXT': return '≡';
      default: return '•';
    }
  }

  lessonStatusLabel(lesson: LessonItem): string {
    if (lesson.completed) return 'Completed';
    const progress = this.displayLessonProgress(lesson);
    if (progress > 0) return `${progress}%`;
    if (!this.isUnlocked(lesson)) return 'Locked';
    return lesson.type;
  }

  displayLessonProgress(lesson: LessonItem): number {
    if (lesson.completed || lesson.progressPercent >= 100) return 100;
    if (lesson.type !== 'VIDEO') return lesson.progressPercent || 0;
    const actualProgress = lesson.progressPercent || 0;
    if (actualProgress >= 75) return 75;
    if (actualProgress >= 50) return 50;
    if (actualProgress >= 25) return 25;
    return 0;
  }

  load(): void {
    this.loading = true;
    this.errorMessage = '';
    this.paymentError = '';
    this.service.getCourse(this.courseId).subscribe({
      next: (res: any) => {
        this.course = res?.data || res;
        this.loadCourseRating();
        this.checkEnrollmentAndLoadContent();
      },
      error: () => {
        this.errorMessage = 'Could not load this course.';
        this.loading = false;
        this.cdr.detectChanges();
      }
    });
  }

  private checkEnrollmentAndLoadContent(): void {
    this.service.getMyCourses().subscribe({
      next: (res: any) => {
        const myCourses = Array.isArray(res?.data) ? res.data : [];
        this.enrolled = myCourses.some((course: any) => String(course.id) === String(this.courseId));
        this.loadContent();
        if (this.enrolled) this.loadQuizzes();
      },
      error: () => { this.enrolled = false; this.loadContent(); }
    });
  }

  private loadCourseRating(): void {
    this.ratingLoading = true;
    this.service.getCourseRating(this.courseId).subscribe({
      next: (res: any) => {
        const rating = res?.data || res;
        this.courseRating = { courseId: String(rating?.courseId ?? this.courseId), averageRating: this.clampRating(Number(rating?.averageRating ?? 0)), ratingCount: Math.max(0, Number(rating?.ratingCount ?? 0)), myRating: this.toNullableNumber(rating?.myRating) };
        this.ratingLoading = false;
        this.cdr.detectChanges();
      },
      error: () => {
        this.courseRating = { courseId: this.courseId, averageRating: this.clampRating(Number(this.course?.averageRating ?? this.course?.rating ?? 0)), ratingCount: Math.max(0, Number(this.course?.ratingCount ?? 0)), myRating: this.toNullableNumber(this.course?.myRating) };
        this.ratingLoading = false;
        this.cdr.detectChanges();
      }
    });
  }

  submitRating(stars: number): void {
    if (!this.enrolled) { alert('Enroll in this course before rating it.'); return; }
    if (this.ratingSaving || stars < 1 || stars > 5) return;
    this.ratingSaving = true;
    this.cdr.detectChanges();
    this.service.saveCourseRating(this.courseId, stars).subscribe({
      next: (res: any) => {
        const rating = res?.data || res;
        this.courseRating = { courseId: String(rating?.courseId ?? this.courseId), averageRating: this.clampRating(Number(rating?.averageRating ?? 0)), ratingCount: Math.max(0, Number(rating?.ratingCount ?? 0)), myRating: this.toNullableNumber(rating?.myRating ?? stars) };
        this.ratingSaving = false;
        this.cdr.detectChanges();
      },
      error: (err: any) => { this.ratingSaving = false; alert(err?.error?.message || 'Could not save your rating. Please try again.'); this.cdr.detectChanges(); }
    });
  }

  private loadContent(): void {
    this.service.getModules(this.courseId).subscribe({
      next: (modRes: any) => {
        const modulesRaw = Array.isArray(modRes?.data) ? modRes.data : Array.isArray(modRes) ? modRes : [];
        this.service.getLessons(this.courseId).subscribe({
          next: (lesRes: any) => {
            const lessonsRaw = Array.isArray(lesRes?.data) ? lesRes.data : Array.isArray(lesRes) ? lesRes : [];
            console.log('COURSE DETAIL LESSONS RESPONSE:', lesRes);
console.table(
  lessonsRaw.map((lesson: any) => ({
    title: lesson.title,
    id: lesson.id,
    downloadable: lesson.downloadable,
    isDownloadable: lesson.isDownloadable,
    moduleId: lesson.moduleId
  }))
);
            console.table(
              lessonsRaw.map((lesson: any) => ({
                title: lesson.title,
                downloadable: lesson.downloadable,
                isDownloadable: lesson.isDownloadable,
                moduleId: lesson.moduleId
              }))
            );
            this.modules = modulesRaw.sort((a: any, b: any) => (a.displayOrder ?? 0) - (b.displayOrder ?? 0)).map((module: any, moduleIndex: number): ModuleItem => ({
              id: String(module.id),
              title: module.title || 'Untitled module',
              description: module.description || null,
              displayOrder: module.displayOrder ?? 0,
              expanded: moduleIndex === 0,
              lessons: lessonsRaw.filter((lesson: any) => String(lesson.moduleId) === String(module.id)).sort((a: any, b: any) => (a.order ?? a.displayOrder ?? 0) - (b.order ?? b.displayOrder ?? 0)).map((lesson: any): LessonItem => ({
                id: String(lesson.id),
                title: lesson.title || 'Untitled lesson',
                description: lesson.description || null,
                type: String(lesson.type || 'CONTENT').toUpperCase(),
                contentUrl: lesson.contentUrl || null,
                streamingUrl: lesson.streamingUrl || null,
                textContent: String(lesson.textContent ?? ''),
                isPreview: !!(lesson.preview ?? lesson.isPreview),
                moduleId: lesson.moduleId || null,
                durationSeconds: lesson.durationSeconds ?? null,
                downloadable: lesson.downloadable === true ||
                lesson.isDownloadable === true ||
                lesson.downloadable === 'true' ||
                lesson.isDownloadable === 'true',
                completed: false,
                watchedSeconds: 0,
                progressPercent: 0
              }))
            }));
            this.loadProgressAfterContent();
            this.loading = false;
            this.cdr.detectChanges();
          },
          error: () => {
            this.modules = modulesRaw.map((module: any, moduleIndex: number): ModuleItem => ({ id: String(module.id), title: module.title || 'Untitled module', description: module.description || null, displayOrder: module.displayOrder ?? 0, expanded: moduleIndex === 0, lessons: [] }));
            this.loading = false;
            this.cdr.detectChanges();
          }
        });
      },
      error: () => { this.modules = []; this.loading = false; this.cdr.detectChanges(); }
    });
  }

  private loadProgressAfterContent(): void {
    if (!this.enrolled) return;
    this.progressLoading = true;
    this.service.getCourseProgress(this.courseId).subscribe({
      next: (res: any) => {
        const progress = (res?.data || res) as CourseProgressResponse;
        this.courseProgress = progress;
        this.applyProgressToLessons(progress.lessons || []);
        this.openResumeLesson(progress.resumeLessonId);
        this.progressLoading = false;
        this.cdr.detectChanges();
      },
      error: () => { this.progressLoading = false; this.cdr.detectChanges(); }
    });
  }

  private applyProgressToLessons(progressItems: LessonProgressResponse[]): void {
    const progressByLessonId = new Map(progressItems.map(item => [String(item.lessonId), item]));
    this.modules.forEach(module => module.lessons.forEach(lesson => {
      const progress = progressByLessonId.get(lesson.id);
      if (!progress) return;
      lesson.completed = !!progress.completed;
      lesson.watchedSeconds = progress.watchedSeconds || 0;
      lesson.progressPercent = progress.progressPercent || 0;
      if (progress.durationSeconds) lesson.durationSeconds = progress.durationSeconds;
    }));
  }

  private openResumeLesson(resumeLessonId: string | null): void {
    if (!resumeLessonId || this.selectedLesson) return;
    const found = this.findLesson(resumeLessonId);
    if (!found || !this.isUnlocked(found.lesson)) return;
    found.module.expanded = true;
    this.selectedLesson = found.lesson;
    this.lastSavedPositionSeconds = found.lesson.watchedSeconds || 0;
  }

  private findLesson(lessonId: string): { lesson: LessonItem; module: ModuleItem } | null {
    for (const module of this.modules) {
      const lesson = module.lessons.find(item => item.id === lessonId);
      if (lesson) return { lesson, module };
    }
    return null;
  }

  loadQuizzes(): void {
    this.quizzesLoading = true;
    this.quizService.getQuizzesForCourse(this.courseId).subscribe({
      next: (res: any) => { this.quizzes = Array.isArray(res?.data) ? res.data : Array.isArray(res) ? res : []; this.quizzesLoading = false; this.cdr.detectChanges(); },
      error: () => { this.quizzesLoading = false; this.cdr.detectChanges(); }
    });
  }

  toggleModule(module: ModuleItem): void { module.expanded = !module.expanded; }
  isUnlocked(lesson: LessonItem): boolean { return this.enrolled || lesson.isPreview; }
  isLockedLesson(lesson: LessonItem): boolean { return !this.enrolled && !lesson.isPreview; }

  openLesson(lesson: LessonItem): void {
    if (this.isLockedLesson(lesson)) {
      this.selectedLesson = null;
      this.cdr.detectChanges();
      setTimeout(() => document.getElementById('course-access-message')?.scrollIntoView({ behavior: 'smooth', block: 'center' }));
      return;
    }
    this.saveSelectedLessonProgress(true);
    this.selectedLesson = lesson;
    this.activeMedia = null;
    this.activeMediaLessonId = '';
    this.pendingProgressSave = null;
    this.lastSavedPositionSeconds = lesson.watchedSeconds || 0;
    this.cdr.detectChanges();
  }

  continueLearning(): void {
    if (!this.enrolled) return;
    const resumeLessonId = this.courseProgress?.resumeLessonId;
    if (resumeLessonId) {
      const found = this.findLesson(resumeLessonId);
      if (found) { found.module.expanded = true; this.openLesson(found.lesson); this.scrollToCourseContent(); return; }
    }
    const firstLesson = this.modules.flatMap(module => module.lessons).find(lesson => this.isUnlocked(lesson));
    if (firstLesson) { this.openLesson(firstLesson); this.scrollToCourseContent(); }
  }

  onMediaLoaded(media: HTMLMediaElement): void {
    if (!this.selectedLesson) return;
    this.activeMedia = media;
    this.activeMediaLessonId = this.selectedLesson.id;
    const resumeAt = this.selectedLesson.watchedSeconds || 0;
    if (resumeAt > 0 && Number.isFinite(media.duration) && resumeAt < media.duration - this.completionThresholdSeconds) media.currentTime = resumeAt;
  }

  onMediaTimeUpdate(media: HTMLMediaElement): void {
    if (!this.selectedLesson || !this.enrolled || this.selectedLesson.completed) return;
    this.activeMedia = media;
    this.activeMediaLessonId = this.selectedLesson.id;
    const currentPosition = this.mediaPosition(media);
    if (currentPosition - this.lastSavedPositionSeconds >= this.progressSaveIntervalSeconds) this.queueLessonProgressSave(this.selectedLesson.id, currentPosition, false);
  }

  onMediaPause(media: HTMLMediaElement): void {
    if (!this.selectedLesson || !this.enrolled || this.selectedLesson.completed) return;
    this.activeMedia = media;
    this.activeMediaLessonId = this.selectedLesson.id;
    const completed = this.hasReachedMediaEnd(media);
    this.queueLessonProgressSave(this.selectedLesson.id, completed ? this.mediaDurationOrPosition(media) : this.mediaPosition(media), completed);
  }

  onMediaEnded(media: HTMLMediaElement): void {
    if (!this.selectedLesson || !this.enrolled) return;
    this.activeMedia = media;
    this.activeMediaLessonId = this.selectedLesson.id;
    this.queueLessonProgressSave(this.selectedLesson.id, this.mediaDurationOrPosition(media), true);
  }

  markSelectedLessonCompleted(): void {
    if (!this.selectedLesson || !this.enrolled || this.selectedLesson.completed || this.completionSaving) return;
    this.completionSaving = true;
    this.service.markLessonCompleted(this.selectedLesson.id).subscribe({
      next: (res: any) => {
        const response = (res?.data || res) as LessonProgressResponse;
        this.applyProgressResponse(this.selectedLesson!, response);
        this.completionSaving = false;
        this.refreshCourseProgress();
        this.cdr.detectChanges();
      },
      error: () => { this.completionSaving = false; alert('Could not mark this lesson as completed. Please try again.'); this.cdr.detectChanges(); }
    });
  }

  private saveSelectedLessonProgress(allowCompletion = false): void {
    if (!this.selectedLesson || !this.enrolled || !['VIDEO', 'AUDIO'].includes(this.selectedLesson.type)) return;
    const lesson = this.selectedLesson;
    if (this.activeMedia && this.activeMediaLessonId === lesson.id) {
      const completed = allowCompletion && this.hasReachedMediaEnd(this.activeMedia);
      this.queueLessonProgressSave(lesson.id, completed ? this.mediaDurationOrPosition(this.activeMedia) : this.mediaPosition(this.activeMedia), completed);
      return;
    }
    this.queueLessonProgressSave(lesson.id, lesson.watchedSeconds || 0, false);
  }

  private queueLessonProgressSave(lessonId: string, watchedSeconds: number, completed: boolean): void {
    if (!this.enrolled) return;
    const safePosition = Math.max(0, Math.floor(watchedSeconds || 0));
    const existing = this.pendingProgressSave;
    if (existing && existing.lessonId === lessonId) { existing.watchedSeconds = Math.max(existing.watchedSeconds, safePosition); existing.completed = existing.completed || completed; }
    else this.pendingProgressSave = { lessonId, watchedSeconds: safePosition, completed };
    this.flushQueuedProgressSave();
  }

  private flushQueuedProgressSave(): void {
    if (this.progressSaveInFlight || !this.pendingProgressSave) return;
    const pending = this.pendingProgressSave;
    this.pendingProgressSave = null;
    const lesson = this.findLesson(pending.lessonId)?.lesson;
    if (!lesson || lesson.completed) { this.flushQueuedProgressSave(); return; }
    this.progressSaveInFlight = true;
    this.service.saveLessonProgress(pending.lessonId, pending.watchedSeconds, pending.completed).subscribe({
      next: (res: any) => {
        const response = (res?.data || res) as LessonProgressResponse;
        this.applyProgressResponse(lesson, response);
        this.lastSavedPositionSeconds = Math.max(this.lastSavedPositionSeconds, response.watchedSeconds || pending.watchedSeconds);
        this.progressSaveInFlight = false;
        if (response.completed || pending.completed) this.refreshCourseProgress();
        this.cdr.detectChanges();
        this.flushQueuedProgressSave();
      },
      error: () => { this.progressSaveInFlight = false; this.cdr.detectChanges(); this.flushQueuedProgressSave(); }
    });
  }

  private applyProgressResponse(lesson: LessonItem, response: LessonProgressResponse): void {
    lesson.completed = !!response.completed;
    lesson.watchedSeconds = response.watchedSeconds || 0;
    lesson.progressPercent = response.progressPercent || 0;
    if (response.durationSeconds) lesson.durationSeconds = response.durationSeconds;
  }

  private mediaPosition(media: HTMLMediaElement): number { const position = Number(media.currentTime); return Number.isFinite(position) ? Math.max(0, Math.floor(position)) : 0; }
  private mediaDurationOrPosition(media: HTMLMediaElement): number { const duration = Number(media.duration); return Number.isFinite(duration) && duration > 0 ? Math.ceil(duration) : this.mediaPosition(media); }
  private hasReachedMediaEnd(media: HTMLMediaElement): boolean { const duration = Number(media.duration); const currentTime = Number(media.currentTime); return Number.isFinite(duration) && duration > 0 && Number.isFinite(currentTime) && currentTime >= duration - this.completionThresholdSeconds; }

  private refreshCourseProgress(): void {
    if (!this.enrolled) return;
    this.service.getCourseProgress(this.courseId).subscribe({
      next: (res: any) => { const progress = (res?.data || res) as CourseProgressResponse; this.courseProgress = progress; this.applyProgressToLessons(progress.lessons || []); this.cdr.detectChanges(); }
    });
  }

  private scrollToCourseContent(): void { setTimeout(() => document.getElementById('course-content')?.scrollIntoView({ behavior: 'smooth', block: 'start' })); }

  enroll(): void {
    if (this.isPaid) { this.startPaidCoursePayment(); return; }
    this.enrolling = true;
    this.paymentError = '';
    this.cdr.detectChanges();
    this.service.enroll(this.courseId).subscribe({
      next: () => { this.enrolled = true; this.enrolling = false; this.loadQuizzes(); this.loadProgressAfterContent(); this.cdr.detectChanges(); },
      error: (err: any) => { this.enrolling = false; alert(err?.error?.error || err?.error?.message || 'Could not enroll in this course.'); this.cdr.detectChanges(); }
    });
  }

  private startPaidCoursePayment(): void {
    if (this.paymentLoading || !this.courseId) return;
    if (!window.Razorpay) { this.paymentError = 'Razorpay Checkout is not loaded. Please reload the page.'; this.cdr.detectChanges(); return; }
    this.paymentLoading = true;
    this.paymentError = '';
    this.cdr.detectChanges();
    this.service.createCoursePaymentOrder(this.courseId).subscribe({
      next: (res: CoursePaymentOrderResponse | any) => this.openCourseCheckout(res?.data || res),
      error: (err: any) => { this.paymentLoading = false; this.paymentError = err?.error?.message || err?.error?.error || 'Could not create the course payment order.'; this.cdr.detectChanges(); }
    });
  }

  private openCourseCheckout(order: CoursePaymentOrderResponse): void {
    const checkout = new window.Razorpay({ key: order.keyId, amount: order.amount, currency: order.currency || 'INR', name: 'LearnOS', description: `${this.course?.title || 'Course'} enrollment`, order_id: order.orderId, handler: response => this.verifyCoursePayment(response), modal: { ondismiss: () => { this.paymentLoading = false; this.paymentError = 'Payment window was closed. No enrollment was completed.'; this.cdr.detectChanges(); } }, theme: { color: '#1E3A8A' } });
    checkout.on('payment.failed', response => { this.paymentLoading = false; this.paymentError = response?.error?.description || 'Course payment failed.'; this.cdr.detectChanges(); });
    checkout.open();
  }

  private verifyCoursePayment(response: RazorpayCheckoutResponse): void {
    this.paymentError = '';
    this.cdr.detectChanges();
    this.service.verifyCoursePayment({ razorpayOrderId: response.razorpay_order_id, razorpayPaymentId: response.razorpay_payment_id, razorpaySignature: response.razorpay_signature }).subscribe({
      next: () => { this.paymentLoading = false; this.enrolled = true; this.loadQuizzes(); this.loadProgressAfterContent(); this.loadContent(); this.cdr.detectChanges(); },
      error: (err: any) => { this.paymentLoading = false; this.paymentError = err?.error?.message || err?.error?.error || 'Payment verification failed. Course access was not activated.'; this.cdr.detectChanges(); }
    });
  }

  isPaymentLoading(): boolean { return this.paymentLoading; }
  private clampRating(value: number): number { return Number.isFinite(value) ? Math.max(0, Math.min(5, Math.round(value * 10) / 10)) : 0; }
  private toNullableNumber(value: unknown): number | null { if (value === null || value === undefined) return null; const parsed = Number(value); return !Number.isFinite(parsed) || parsed < 1 || parsed > 5 ? null : Math.round(parsed); }
}
