import { Injectable } from '@angular/core';
import {
  HttpClient,
  HttpHeaders,
  HttpParams
} from '@angular/common/http';
import { Observable } from 'rxjs';

export type BatchStatus =
  | 'DRAFT'
  | 'SCHEDULED'
  | 'ACTIVE'
  | 'COMPLETED'
  | 'ARCHIVED';

export type BatchDeliveryMode =
  | 'SELF_PACED'
  | 'LIVE_ONLINE'
  | 'BLENDED';

export type BatchMemberStatus =
  | 'INVITED'
  | 'ACTIVE'
  | 'COMPLETED'
  | 'REMOVED';

export interface Batch {
  id: string;
  name: string;
  code: string;
  description?: string | null;
  courseId: string;
  courseTitle: string;
  companyId?: string | null;
  companyName?: string | null;
  instructorId?: string | null;
  instructorName?: string | null;
  deliveryMode: BatchDeliveryMode;
  status: BatchStatus;
  startDate?: string | null;
  endDate?: string | null;
  maxLearners: number;
  learnerCount: number;
  averageProgressPercent: number;
  completedLearnerCount: number;
  createdAt?: string | null;
  updatedAt?: string | null;
}

export interface BatchMember {
  membershipId: string;
  learnerId: string;
  learnerName: string;
  learnerEmail: string;
  companyName?: string | null;
  status: BatchMemberStatus;
  courseProgressPercent: number;
  joinedAt?: string | null;
  completedAt?: string | null;
}

export interface CourseEnrollment {
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
}

export interface BatchRequest {
  name: string;
  code: string;
  description?: string | null;
  courseId: string;
  companyId?: string | null;
  instructorId?: string | null;
  deliveryMode: BatchDeliveryMode;
  status: BatchStatus;
  startDate?: string | null;
  endDate?: string | null;
  maxLearners: number;
}

@Injectable({
  providedIn: 'root'
})
export class BatchesService {
  private readonly baseUrl = 'http://localhost:8080/api/v1';

  constructor(private http: HttpClient) {}

  private headers(): HttpHeaders {
    const token = localStorage.getItem('accessToken') || '';

    return new HttpHeaders({
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json'
    });
  }

  getBatches(): Observable<any> {
    return this.http.get<any>(
      `${this.baseUrl}/batches`,
      {
        headers: this.headers()
      }
    );
  }

  getBatch(batchId: string): Observable<any> {
    return this.http.get<any>(
      `${this.baseUrl}/batches/${batchId}`,
      {
        headers: this.headers()
      }
    );
  }

  createBatch(request: BatchRequest): Observable<any> {
    return this.http.post<any>(
      `${this.baseUrl}/batches`,
      request,
      {
        headers: this.headers()
      }
    );
  }

  updateBatch(
    batchId: string,
    request: BatchRequest
  ): Observable<any> {
    return this.http.put<any>(
      `${this.baseUrl}/batches/${batchId}`,
      request,
      {
        headers: this.headers()
      }
    );
  }

  archiveBatch(batchId: string): Observable<any> {
    return this.http.delete<any>(
      `${this.baseUrl}/batches/${batchId}`,
      {
        headers: this.headers()
      }
    );
  }

  getBatchMembers(batchId: string): Observable<any> {
    return this.http.get<any>(
      `${this.baseUrl}/batches/${batchId}/members`,
      {
        headers: this.headers()
      }
    );
  }

  addMember(
    batchId: string,
    learnerId: string
  ): Observable<any> {
    return this.http.post<any>(
      `${this.baseUrl}/batches/${batchId}/members/${learnerId}`,
      {},
      {
        headers: this.headers()
      }
    );
  }

  removeMember(
    batchId: string,
    learnerId: string
  ): Observable<any> {
    return this.http.delete<any>(
      `${this.baseUrl}/batches/${batchId}/members/${learnerId}`,
      {
        headers: this.headers()
      }
    );
  }

  getCourses(): Observable<any> {
    const params = new HttpParams()
      .set('page', '0')
      .set('size', '100')
      .set('sortBy', 'createdAt');

    return this.http.get<any>(
      `${this.baseUrl}/courses`,
      {
        headers: this.headers(),
        params
      }
    );
  }

  getCourseEnrollments(
    courseId: string
  ): Observable<any> {
    return this.http.get<any>(
      `${this.baseUrl}/courses/${courseId}/enrollments`,
      {
        headers: this.headers()
      }
    );
  }
}