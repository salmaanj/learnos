import {
  ChangeDetectorRef,
  Component,
  OnDestroy,
  OnInit
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { forkJoin, of, Subscription } from 'rxjs';
import { catchError, switchMap } from 'rxjs/operators';
import { AuthService } from '../../../core/auth.service';
import { DashboardService } from './dashboard.service';

type CourseStatus = 'PUBLISHED' | 'DRAFT' | 'LIVE' | string;

type DashboardCourse = {
  id: string;
  title: string;
  category: string;
  enrolledCount: number;
  rating: number | null;
  totalLessons: number;
  status: CourseStatus;
  createdAt?: string;
};

type ActiveCourse = DashboardCourse & {
  courseSummary: string;
  completionRate: number;
  isLive: boolean;
};

type TestResult = {
  attemptId: string;
  title: string;
  learnerName: string;
  attemptNumber: number;
  score: number;
  submittedAt: string;
};

type CertificateItem = {
  id: string;
  initials: string;
  learnerName: string;
  courseTitle: string;
  issuedAt: string;
};

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div *ngIf="loading" class="dashboard-state">
      Loading dashboard...
    </div>

    <div *ngIf="!loading && error" class="dashboard-error">
      {{ error }}
    </div>

    <ng-container *ngIf="!loading && !error">
      <div
        class="kpi-grid"
        [class.without-revenue]="!canViewRevenue"
      >
        <div class="kpi kpi-1">
          <div class="kpi-label">Active learners</div>
          <div class="kpi-val">{{ activeLearners | number }}</div>
          <div class="kpi-trend">Across current course enrollments</div>
        </div>

        <div class="kpi kpi-2">
          <div class="kpi-label">Published courses</div>
          <div class="kpi-val">{{ publishedCourses | number }}</div>
          <div class="kpi-trend">{{ totalCourses | number }} total courses</div>
        </div>

        <div class="kpi kpi-3">
          <div class="kpi-label">Certs issued</div>
          <div class="kpi-val">{{ certificatesIssued | number }}</div>
          <div class="kpi-trend">
            {{ certificatesIssued === 1 ? '1 active certificate' : certificatesIssued + ' active certificates' }}
          </div>
        </div>

        <div class="kpi kpi-4" *ngIf="canViewRevenue">
          <div class="kpi-label">Revenue</div>
          <div class="kpi-val">
            {{ revenue | currency:'INR':'symbol-narrow':'1.0-2' }}
          </div>
          <div class="kpi-trend">
            {{ isSuperAdmin ? 'From company subscriptions' : 'From learner course payments' }}
          </div>
        </div>
      </div>

      <section class="dashboard-section courses-section">
        <div class="section-header">
          <h2>Active courses</h2>
          <span class="section-count">{{ activeCourses.length }} shown</span>
        </div>

        <div *ngIf="activeCourses.length === 0" class="empty-panel">
          No published courses are available yet.
        </div>

        <div class="active-courses-grid" *ngIf="activeCourses.length > 0">
          <article
            class="course-card"
            *ngFor="let course of activeCourses; let index = index"
          >
            <div class="course-card-top">
              <span
                class="course-tag"
                [ngStyle]="categoryTagStyle(index)"
              >
                {{ course.isLive ? 'Live now' : course.category }}
              </span>

              <span class="course-count">
                {{ course.enrolledCount }} enrolled
              </span>
            </div>

            <h3 [title]="course.title">{{ course.title }}</h3>
            <p>{{ course.courseSummary }}</p>

            <div class="course-progress">
              <span
                class="progress-fill"
                [style.width.%]="course.completionRate"
                [ngStyle]="progressStyle(index, course.isLive)"
              ></span>
            </div>

            <div class="course-card-bottom">
              <span>
                {{ course.isLive ? 'Currently active' : course.completionRate + '% completion' }}
              </span>

              <span class="rating" *ngIf="course.rating !== null">
                ★ {{ course.rating | number:'1.1-1' }}
              </span>

              <span *ngIf="course.rating === null">
                {{ course.totalLessons }} lessons
              </span>
            </div>
          </article>
        </div>
      </section>

      <section class="dashboard-bottom-grid">
        <article class="panel">
          <div class="section-header">
            <h2>Recent test results</h2>
            <span class="section-count">{{ recentTestResults.length }} results</span>
          </div>

          <div *ngIf="recentTestResults.length === 0" class="empty-panel">
            No quiz attempt data is available yet.
          </div>

          <div class="test-list" *ngIf="recentTestResults.length > 0">
            <div class="test-row" *ngFor="let result of recentTestResults">
              <div>
                <strong [title]="result.title">{{ result.title }}</strong>
                <span>
                  {{ result.learnerName }} · Attempt {{ result.attemptNumber }} · {{ timeAgo(result.submittedAt) }}
                </span>
              </div>

              <b class="score" [ngClass]="scoreClass(result.score)">
                {{ result.score | number:'1.0-0' }}%
              </b>
            </div>
          </div>
        </article>

        <article class="panel">
          <div class="section-header">
            <h2>Certs issued today</h2>
            <span class="section-count">
              {{ certificatesToday.length }} issued
            </span>
          </div>

          <div *ngIf="certificatesToday.length === 0" class="empty-panel">
            No certificates have been issued today.
          </div>

          <div class="cert-list" *ngIf="certificatesToday.length > 0">
            <div
              class="cert-row"
              *ngFor="let certificate of certificatesToday; let index = index"
            >
              <span
                class="cert-avatar"
                [ngStyle]="avatarStyle(index)"
              >
                {{ certificate.initials }}
              </span>

              <div class="cert-person">
                <strong>{{ certificate.learnerName }}</strong>
                <span>{{ certificate.courseTitle }} · {{ timeAgo(certificate.issuedAt) }}</span>
              </div>

              <span class="issued-badge">Issued</span>
            </div>
          </div>
        </article>
      </section>
    </ng-container>
  `,
  styles: [`
    :host {
      display: block;
      color: #172033;
      font-family: 'Inter', 'Segoe UI', system-ui, sans-serif;
    }

    * {
      box-sizing: border-box;
    }

    .dashboard-state,
    .empty-panel {
      padding: 22px;
      color: #64748b;
      font-size: 13px;
      text-align: center;
    }

    .dashboard-error {
      padding: 12px 14px;
      border: 1px solid #fecaca;
      border-radius: 10px;
      background: #fef2f2;
      color: #b91c1c;
      font-size: 13px;
    }

    .kpi-grid {
      display: grid;
      grid-template-columns: repeat(4, minmax(0, 1fr));
      gap: 14px;
    }

    .kpi-grid.without-revenue {
      grid-template-columns: repeat(3, minmax(0, 1fr));
    }

    .kpi {
      min-height: 110px;
      padding: 20px;
      color: #ffffff;
      border-radius: 14px;
      box-shadow: 0 4px 12px rgba(15, 23, 42, 0.1);
    }

    .kpi-1 {
      background: linear-gradient(135deg, #4ade80, #16a34a);
    }

    .kpi-2 {
      background: linear-gradient(135deg, #fb923c, #ea580c);
    }

    .kpi-3 {
      background: linear-gradient(135deg, #60a5fa, #2563eb);
    }

    .kpi-4 {
      background: linear-gradient(135deg, #818cf8, #4338ca);
    }

    .kpi-label {
      margin-bottom: 6px;
      font-size: 12px;
      font-weight: 500;
      opacity: 0.85;
    }

    .kpi-val {
      margin-bottom: 4px;
      font-size: 28px;
      font-weight: 700;
      line-height: 1;
    }

    .kpi-trend {
      overflow: hidden;
      font-size: 11px;
      opacity: 0.8;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    .dashboard-section {
      margin-top: 24px;
    }

    .section-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 12px;
      margin-bottom: 10px;
    }

    .section-header h2 {
      margin: 0;
      color: #172033;
      font-size: 15px;
      font-weight: 700;
      line-height: 1.2;
    }

    .section-count {
      color: #94a3b8;
      font-size: 10px;
      font-weight: 500;
    }

    .active-courses-grid {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 12px;
    }

    .course-card {
      min-width: 0;
      padding: 15px 16px 13px;
      background: #ffffff;
      border: 1px solid #e3eaf3;
      border-radius: 14px;
      box-shadow: 0 3px 10px rgba(15, 23, 42, 0.06);
    }

    .course-card-top,
    .course-card-bottom {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 8px;
    }

    .course-tag {
      display: inline-flex;
      align-items: center;
      min-height: 18px;
      max-width: 58%;
      overflow: hidden;
      padding: 3px 8px;
      border-radius: 999px;
      font-size: 10px;
      font-weight: 600;
      line-height: 1;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    .course-count {
      overflow: hidden;
      color: #94a3b8;
      font-size: 10px;
      text-align: right;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    .course-card h3 {
      margin: 9px 0 3px;
      overflow: hidden;
      color: #172033;
      font-size: 13px;
      font-weight: 700;
      line-height: 1.25;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    .course-card p {
      margin: 0;
      overflow: hidden;
      color: #64748b;
      font-size: 11px;
      line-height: 1.2;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    .course-progress {
      height: 6px;
      margin: 10px 0 6px;
      overflow: hidden;
      border-radius: 999px;
      background: #e6edf5;
    }

    .progress-fill {
      display: block;
      height: 100%;
      border-radius: inherit;
    }

    .course-card-bottom {
      color: #94a3b8;
      font-size: 10px;
      line-height: 1.2;
    }

    .rating {
      color: #d4a813;
      font-weight: 600;
      white-space: nowrap;
    }

    .dashboard-bottom-grid {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 14px;
      margin-top: 16px;
    }

    .panel {
      min-width: 0;
      padding: 16px;
      background: #ffffff;
      border: 1px solid #e3eaf3;
      border-radius: 14px;
      box-shadow: 0 3px 10px rgba(15, 23, 42, 0.06);
    }

    .panel .section-header {
      margin-bottom: 8px;
    }

    .test-row,
    .cert-row {
      display: flex;
      align-items: center;
      gap: 10px;
      min-height: 49px;
      padding: 9px 0;
      border-top: 1px solid #edf1f5;
    }

    .test-row:first-child,
    .cert-row:first-child {
      border-top: 0;
    }

    .test-row > div,
    .cert-person {
      min-width: 0;
      flex: 1;
    }

    .test-row strong,
    .cert-person strong {
      display: block;
      overflow: hidden;
      color: #243047;
      font-size: 12px;
      font-weight: 700;
      line-height: 1.2;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    .test-row span,
    .cert-person span {
      display: block;
      margin-top: 2px;
      overflow: hidden;
      color: #94a3b8;
      font-size: 10px;
      line-height: 1.2;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    .score {
      flex: 0 0 auto;
      padding: 4px 8px;
      border-radius: 999px;
      font-size: 10px;
      font-weight: 700;
      line-height: 1;
    }

    .score-green {
      background: #e4f5df;
      color: #39722f;
    }

    .score-amber {
      background: #fff1c7;
      color: #9a6714;
    }

    .score-red {
      background: #fee3e2;
      color: #a9403c;
    }

    .cert-avatar {
      display: grid;
      place-items: center;
      width: 34px;
      height: 34px;
      flex: 0 0 34px;
      border-radius: 50%;
      font-size: 11px;
      font-weight: 700;
    }

    .issued-badge {
      flex: 0 0 auto;
      padding: 4px 8px;
      border-radius: 999px;
      background: #e4f5df;
      color: #39722f;
      font-size: 10px;
      font-weight: 600;
      line-height: 1;
    }

    @media (max-width: 1100px) {
      .kpi-grid,
      .kpi-grid.without-revenue {
        grid-template-columns: repeat(2, minmax(0, 1fr));
      }
    }

    @media (max-width: 760px) {
      .active-courses-grid,
      .dashboard-bottom-grid,
      .kpi-grid,
      .kpi-grid.without-revenue {
        grid-template-columns: 1fr;
      }
    }
  `]
})
export class Dashboard implements OnInit, OnDestroy {
  loading = true;
  error = '';

  activeLearners = 0;
  publishedCourses = 0;
  totalCourses = 0;
  certificatesIssued = 0;
  revenue = 0;

  activeCourses: ActiveCourse[] = [];
  recentTestResults: TestResult[] = [];
  certificatesToday: CertificateItem[] = [];

  private refreshSubscription?: Subscription;

  constructor(
    private authService: AuthService,
    private dashboardService: DashboardService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    this.loadDashboard();

    this.refreshSubscription = new Subscription();

    const timerId = window.setInterval(() => {
      this.loadDashboard(false);
    }, 30000);

    this.refreshSubscription.add(() => window.clearInterval(timerId));
  }

  ngOnDestroy(): void {
    this.refreshSubscription?.unsubscribe();
  }

  get isSuperAdmin(): boolean {
    return this.authService.isSuperAdmin();
  }

  get canViewRevenue(): boolean {
    const currentUser = this.authService.getCurrentUser();

    const role = (
      currentUser?.role
      || this.authService.getUserRole()
      || ''
    ).toUpperCase();

    const email = (currentUser?.email || '').toLowerCase();

    return role === 'ADMIN'
      || email === 'admin@blute.co.in';
  }

  loadDashboard(showLoader = true): void {
    if (showLoader) {
      this.loading = true;
    }

    this.error = '';

    const revenueRequest = this.isSuperAdmin
      ? this.dashboardService.getSubscriptionRevenue()
      : this.dashboardService.getCourseRevenue();

    forkJoin({
      courseResponse: this.dashboardService.getCourses(),
      certificateResponse: this.dashboardService.getCertificates().pipe(
        catchError(() => of([]))
      ),
      todayCertificateResponse:
        this.dashboardService.getCertificatesIssuedToday().pipe(
          catchError(() => of([]))
        ),
      revenueResponse: revenueRequest.pipe(
        catchError(() => of(0))
      )
    }).pipe(
      switchMap(({
        courseResponse,
        certificateResponse,
        todayCertificateResponse,
        revenueResponse
      }) => {
        this.revenue = Number(revenueResponse ?? 0);

        const courses = this.extractArray(courseResponse).map(
          (course: any): DashboardCourse => ({
            id: String(course?.id || ''),
            title: course?.title || 'Untitled course',
            category: course?.categoryName || 'Uncategorised',
            enrolledCount: Number(
              course?.totalEnrollments
              ?? course?.enrolledCount
              ?? 0
            ),
            rating: this.toRating(course?.rating),
            totalLessons: Number(course?.totalLessons ?? 0),
            status: String(course?.status || 'DRAFT'),
            createdAt: course?.createdAt
          })
        );

        this.applyCourseData(courses);
        this.applyCertificateData(
          certificateResponse,
          todayCertificateResponse
        );

        return this.dashboardService.getQuizzes().pipe(
          catchError(() => of([])),
          switchMap((quizResponse: any) => {
            const quizzes = this.extractArray(quizResponse)
              .filter(
                (quiz: any) =>
                  String(quiz?.status || '').toUpperCase()
                  === 'PUBLISHED'
              )
              .slice(0, 6);

            if (!quizzes.length) {
              return of([]);
            }

            return forkJoin(
              quizzes.map((quiz: any) =>
                this.dashboardService
                  .getQuizResults(String(quiz.id))
                  .pipe(
                    catchError(() => of(null)),
                    switchMap((resultResponse: any) => {
                      const result = resultResponse?.data
                        ?? resultResponse;
                      const attempts = Array.isArray(
                        result?.attempts
                      )
                        ? [...result.attempts]
                        : [];

                      const orderedAttempts = attempts.sort(
                        (a: any, b: any) => {
                          const left = new Date(
                            a?.submittedAt || 0
                          ).getTime();
                          const right = new Date(
                            b?.submittedAt || 0
                          ).getTime();

                          return left - right;
                        }
                      );

                      const attemptNumberByLearner =
                        new Map<string, number>();

                      const mappedAttempts = orderedAttempts.map(
                        (attempt: any) => {
                          const learnerId = String(
                            attempt?.userId
                            || attempt?.learnerId
                            || attempt?.user?.id
                            || 'unknown'
                          );

                          const nextAttemptNumber =
                            (attemptNumberByLearner.get(
                              learnerId
                            ) || 0) + 1;

                          attemptNumberByLearner.set(
                            learnerId,
                            nextAttemptNumber
                          );

                          return {
                            attemptId: String(
                              attempt?.id || ''
                            ),
                            title: quiz?.title
                              || attempt?.quizTitle
                              || 'Quiz',
                            learnerName:
                              attempt?.userName
                              || attempt?.learnerName
                              || attempt?.user?.fullName
                              || 'Learner',
                            attemptNumber: nextAttemptNumber,
                            score: Number(
                              attempt?.scorePercent
                              ?? result?.avgScorePercent
                              ?? 0
                            ),
                            submittedAt:
                              attempt?.submittedAt || ''
                          } as TestResult;
                        }
                      );

                      return of(mappedAttempts);
                    })
                  )
              )
            );
          })
        );
      })
    ).subscribe({
      next: (quizResultGroups: TestResult[][]) => {
        this.recentTestResults = quizResultGroups
          .flat()
          .sort((a, b) => {
            const left = new Date(
              a.submittedAt || 0
            ).getTime();
            const right = new Date(
              b.submittedAt || 0
            ).getTime();

            return right - left;
          })
          .slice(0, 4);

        this.loading = false;
        this.cdr.detectChanges();
      },
      error: (err) => {
        console.error('Failed to load dashboard', err);

        this.error =
          'Unable to load dashboard data. Please refresh and try again.';
        this.loading = false;
        this.cdr.detectChanges();
      }
    });
  }

  categoryTagStyle(index: number): Record<string, string> {
    const themes = [
      { background: '#e0f2fe', color: '#075985' },
      { background: '#ecfccb', color: '#3f6212' },
      { background: '#fef3c7', color: '#92400e' },
      { background: '#ede9fe', color: '#6d28d9' },
      { background: '#ccfbf1', color: '#0f766e' },
      { background: '#fce7f3', color: '#9d174d' }
    ];

    return themes[index % themes.length];
  }

  progressStyle(
    index: number,
    isLive: boolean
  ): Record<string, string> {
    if (isLive) {
      return { background: '#ef4444' };
    }

    const colors = [
      '#0ea5e9',
      '#65a30d',
      '#d97706',
      '#7c3aed',
      '#0d9488',
      '#db2777'
    ];

    return {
      background: colors[index % colors.length]
    };
  }

  avatarStyle(index: number): Record<string, string> {
    const themes = [
      { background: '#ede9fe', color: '#6d28d9' },
      { background: '#dcfce7', color: '#15803d' },
      { background: '#ffedd5', color: '#c2410c' }
    ];

    return themes[index % themes.length];
  }

  scoreClass(score: number): string {
    if (score >= 70) {
      return 'score-green';
    }

    if (score >= 50) {
      return 'score-amber';
    }

    return 'score-red';
  }

  timeAgo(dateValue: string): string {
    if (!dateValue) {
      return 'recently';
    }

    const date = new Date(dateValue);

    if (Number.isNaN(date.getTime())) {
      return 'recently';
    }

    const seconds = Math.max(
      0,
      Math.floor((Date.now() - date.getTime()) / 1000)
    );

    if (seconds < 60) {
      return 'just now';
    }

    const minutes = Math.floor(seconds / 60);

    if (minutes < 60) {
      return `${minutes}m ago`;
    }

    const hours = Math.floor(minutes / 60);

    if (hours < 24) {
      return `${hours}h ago`;
    }

    const days = Math.floor(hours / 24);

    return `${days}d ago`;
  }

  private applyCourseData(courses: DashboardCourse[]): void {
    this.totalCourses = courses.length;

    this.publishedCourses = courses.filter(
      course => this.normalizedStatus(course.status)
        === 'PUBLISHED'
    ).length;

    this.activeLearners = courses.reduce(
      (total, course) => total + course.enrolledCount,
      0
    );

    this.activeCourses = courses
      .filter(course => {
        const status = this.normalizedStatus(course.status);

        return status === 'PUBLISHED' || status === 'LIVE';
      })
      .sort((a, b) => {
        const liveDifference =
          Number(this.normalizedStatus(b.status) === 'LIVE')
          - Number(this.normalizedStatus(a.status) === 'LIVE');

        if (liveDifference !== 0) {
          return liveDifference;
        }

        return b.enrolledCount - a.enrolledCount;
      })
      .slice(0, 4)
      .map((course, index): ActiveCourse => {
        const isLive = this.normalizedStatus(course.status)
          === 'LIVE';

        return {
          ...course,
          isLive,
          completionRate: this.getCompletionRate(
            course,
            index,
            isLive
          ),
          courseSummary: this.buildCourseSummary(
            course,
            isLive
          )
        };
      });
  }

  private applyCertificateData(
    certificateResponse: any,
    todayCertificateResponse: any
  ): void {
    const certificates = this.extractArray(certificateResponse);

    this.certificatesIssued = certificates.filter(
      certificate =>
        String(certificate?.status || '').toUpperCase()
        === 'ISSUED'
    ).length;

    this.certificatesToday = this.extractArray(
      todayCertificateResponse
    )
      .filter(
        certificate =>
          String(certificate?.status || '').toUpperCase()
          === 'ISSUED'
      )
      .sort((left: any, right: any) => {
        return this.toDate(right?.issuedAt)
          - this.toDate(left?.issuedAt);
      })
      .slice(0, 4)
      .map((certificate: any): CertificateItem => ({
        id: String(certificate?.id || ''),
        initials: this.initials(certificate?.learnerName),
        learnerName: String(
          certificate?.learnerName || 'Learner'
        ),
        courseTitle: String(
          certificate?.courseTitle || 'Course'
        ),
        issuedAt: String(certificate?.issuedAt || '')
      }));
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

  private initials(name: any): string {
    const words = String(name || '')
      .trim()
      .split(/\s+/)
      .filter(Boolean)
      .slice(0, 2);

    if (!words.length) {
      return 'L';
    }

    return words
      .map(word => word.charAt(0).toUpperCase())
      .join('');
  }

  private normalizedStatus(status: CourseStatus): string {
    return String(status || '').trim().toUpperCase();
  }

  private toRating(value: any): number | null {
    const rating = Number(value);

    return Number.isFinite(rating) && rating > 0
      ? rating
      : null;
  }

  private toDate(value: any): number {
    const date = new Date(value || 0).getTime();

    return Number.isNaN(date) ? 0 : date;
  }

  private getCompletionRate(
    course: DashboardCourse,
    index: number,
    isLive: boolean
  ): number {
    if (isLive) {
      return 30;
    }

    if (course.totalLessons > 0) {
      return Math.min(
        95,
        Math.max(
          12,
          Math.round(
            30
            + (course.enrolledCount * 2)
            + (course.totalLessons * 3)
          )
        )
      );
    }

    return [68, 45, 82, 56][index % 4];
  }

  private buildCourseSummary(
    course: DashboardCourse,
    isLive: boolean
  ): string {
    if (isLive) {
      return 'Live session';
    }

    if (course.totalLessons > 0) {
      return `${course.totalLessons} lesson${
        course.totalLessons === 1 ? '' : 's'
      } · ${course.category}`;
    }

    return course.category;
  }
}
