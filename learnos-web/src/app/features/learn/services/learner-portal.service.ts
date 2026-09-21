import { Injectable } from '@angular/core';
import {
  HttpClient,
  HttpHeaders,
  HttpParams
} from '@angular/common/http';
import { Observable } from 'rxjs';

export interface LessonProgressResponse {
  lessonId: string;
  moduleId: string;
  courseId: string;
  completed: boolean;
  watchedSeconds: number;
  durationSeconds: number | null;
  progressPercent: number;
  completedAt: string | null;
  lastAccessedAt: string | null;
}

export interface CourseProgressResponse {
  courseId: string;
  totalLessons: number;
  completedLessons: number;
  progressPercent: number;
  contentCompleted: boolean;
  assessmentUnlocked: boolean;
  resumeLessonId: string | null;
  resumePositionSeconds: number;
  lessons: LessonProgressResponse[];
}

export interface CourseRatingResponse {
  courseId: string;
  averageRating: number;
  ratingCount: number;
  myRating: number | null;
}

export interface CoursePaymentOrderResponse {
  paymentId: string;
  courseId: string;
  keyId: string;
  orderId: string;
  amount: number;
  currency: string;
  status: string;
}

export interface VerifyCoursePaymentRequest {
  razorpayOrderId: string;
  razorpayPaymentId: string;
  razorpaySignature: string;
}

@Injectable({ providedIn: 'root' })
export class LearnerPortalService {
  private readonly baseUrl = 'http://localhost:8080/api/v1';

  constructor(private http: HttpClient) {}

  private headers(): HttpHeaders {
    const token = localStorage.getItem('accessToken') || '';

    return new HttpHeaders({
      Authorization: `Bearer ${token}`
    });
  }

  getAvailableCourses(): Observable<any> {
    const params = new HttpParams()
      .set('page', '0')
      .set('size', '50')
      .set('sortBy', 'createdAt');

    return this.http.get<any>(
      `${this.baseUrl}/courses`,
      {
        headers: this.headers(),
        params
      }
    );
  }

  getCategories(): Observable<any> {
    return this.http.get<any>(
      `${this.baseUrl}/categories`,
      { headers: this.headers() }
    );
  }

  getMyCourses(): Observable<any> {
    return this.http.get<any>(
      `${this.baseUrl}/courses/my-courses`,
      { headers: this.headers() }
    );
  }

  enroll(courseId: string): Observable<any> {
    return this.http.post<any>(
      `${this.baseUrl}/courses/${courseId}/enroll`,
      {},
      { headers: this.headers() }
    );
  }

  createCoursePaymentOrder(
    courseId: string
  ): Observable<CoursePaymentOrderResponse> {
    return this.http.post<CoursePaymentOrderResponse>(
      `${this.baseUrl}/course-payments/payment-order`,
      { courseId },
      { headers: this.headers() }
    );
  }

  verifyCoursePayment(
    request: VerifyCoursePaymentRequest
  ): Observable<any> {
    return this.http.post<any>(
      `${this.baseUrl}/course-payments/verify-payment`,
      request,
      { headers: this.headers() }
    );
  }

  getCourse(courseId: string): Observable<any> {
    return this.http.get<any>(
      `${this.baseUrl}/courses/${courseId}`,
      { headers: this.headers() }
    );
  }

  getCourseRating(courseId: string): Observable<any> {
    return this.http.get<any>(
      `${this.baseUrl}/courses/${courseId}/rating`,
      { headers: this.headers() }
    );
  }

  saveCourseRating(
    courseId: string,
    stars: number
  ): Observable<any> {
    return this.http.put<any>(
      `${this.baseUrl}/courses/${courseId}/rating`,
      { stars },
      { headers: this.headers() }
    );
  }

  getModules(courseId: string): Observable<any> {
    return this.http.get<any>(
      `${this.baseUrl}/courses/${courseId}/modules`,
      { headers: this.headers() }
    );
  }

  getLessons(courseId: string): Observable<any> {
    return this.http.get<any>(
      `${this.baseUrl}/courses/${courseId}/lessons`,
      { headers: this.headers() }
    );
  }

  getCourseProgress(courseId: string): Observable<any> {
    return this.http.get<any>(
      `${this.baseUrl}/lessons/progress/course/${courseId}`,
      { headers: this.headers() }
    );
  }

  getResumeProgress(courseId: string): Observable<any> {
    return this.http.get<any>(
      `${this.baseUrl}/lessons/progress/course/${courseId}/resume`,
      { headers: this.headers() }
    );
  }

  getAssessmentAccess(courseId: string): Observable<any> {
    return this.http.get<any>(
      `${this.baseUrl}/lessons/progress/course/${courseId}/assessment-access`,
      { headers: this.headers() }
    );
  }

  saveLessonProgress(
    lessonId: string,
    watchedSeconds: number,
    completed = false
  ): Observable<any> {
    return this.http.post<any>(
      `${this.baseUrl}/lessons/progress`,
      {
        lessonId,
        watchedSeconds: Math.max(
          0,
          Math.floor(watchedSeconds)
        ),
        completed
      },
      { headers: this.headers() }
    );
  }

  markLessonCompleted(lessonId: string): Observable<any> {
    return this.http.post<any>(
      `${this.baseUrl}/lessons/${lessonId}/complete`,
      {},
      { headers: this.headers() }
    );
  }
}
