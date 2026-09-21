import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface Learner {
  id: string;
  userId: string;
  name: string;
  email: string;
  phone: string | null;
  companyId: string | null;
  companyName: string | null;
  coursesEnrolled: number;
  avgProgressPercent: number;
  lastActive: string | null;
  status:
    | 'Active'
    | 'Completed'
    | 'Certified'
    | 'At risk'
    | 'Inactive';
}

export interface LearnerEnrollment {
  enrollmentId: string;
  learnerId: string;
  courseId: string;
  courseTitle: string;
  courseCategory: string | null;
  status: string;
  progressPercent: number;
  enrolledAt: string | null;
  completedAt: string | null;
}

@Injectable({
  providedIn: 'root'
})
export class LearnersService {
  private readonly baseUrl =
    'http://localhost:8080/api/v1/learners';

  constructor(private http: HttpClient) {}

  private headers(): HttpHeaders {
    const token = localStorage.getItem('accessToken') || '';

    return new HttpHeaders({
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json'
    });
  }

  getLearners(): Observable<Learner[]> {
    return this.http.get<Learner[]>(
      this.baseUrl,
      {
        headers: this.headers()
      }
    );
  }

  getLearnerEnrollments(
    learnerId: string
  ): Observable<LearnerEnrollment[]> {
    return this.http.get<LearnerEnrollment[]>(
      `${this.baseUrl}/${learnerId}/enrollments`,
      {
        headers: this.headers()
      }
    );
  }
}