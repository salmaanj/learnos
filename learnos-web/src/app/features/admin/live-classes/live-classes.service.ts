import { Injectable } from '@angular/core';
import {
  HttpClient,
  HttpHeaders,
  HttpParams
} from '@angular/common/http';
import { Observable } from 'rxjs';

export type LiveClassStatus =
  | 'DRAFT'
  | 'SCHEDULED'
  | 'LIVE'
  | 'COMPLETED'
  | 'CANCELLED';

export type MeetingProvider =
  | 'GOOGLE_MEET'
  | 'ZOOM'
  | 'MICROSOFT_TEAMS'
  | 'CUSTOM';

export interface LiveClass {
  id: string;

  companyId: string | null;
  companyName: string | null;

  courseId: string | null;
  courseTitle: string | null;

  instructorId: string | null;
  instructorName: string | null;

  title: string;
  description: string | null;

  startAt: string;
  endAt: string;
  timezone: string;

  provider: MeetingProvider;
  meetingUrl: string;

  capacity: number | null;
  status: LiveClassStatus;

  thumbnailUrl: string | null;
  recordingUrl: string | null;

  createdByUserId: string | null;
  createdByName: string | null;

  createdAt: string | null;
  updatedAt: string | null;
}

export interface LiveClassPage {
  content: LiveClass[];
  totalElements: number;
  totalPages: number;
  size: number;
  number: number;
}

export interface LiveClassPayload {
  companyId?: string | null;

  courseId: string | null;
  instructorId: string | null;

  title: string;
  description: string | null;

  startAt: string;
  endAt: string;
  timezone: string;

  provider: MeetingProvider;
  meetingUrl: string;
  meetingPassword: string | null;

  capacity: number | null;
  thumbnailUrl: string | null;
  recordingUrl: string | null;

  status: LiveClassStatus;
}

@Injectable({
  providedIn: 'root'
})
export class LiveClassesService {
  private readonly baseUrl =
    'http://localhost:8080/api/v1/live-classes';

  constructor(private http: HttpClient) {}

  private headers(): HttpHeaders {
    const token =
      localStorage.getItem('accessToken') || '';

    return new HttpHeaders({
      Authorization: `Bearer ${token}`
    });
  }

  getLiveClasses(options: {
    q?: string;
    status?: LiveClassStatus | '';
    page: number;
    size: number;
    sortBy?: string;
    direction?: 'ASC' | 'DESC';
  }): Observable<any> {
    let params = new HttpParams()
      .set('page', String(options.page))
      .set('size', String(options.size))
      .set('sortBy', options.sortBy || 'startAt')
      .set('direction', options.direction || 'ASC');

    if (options.q?.trim()) {
      params = params.set('q', options.q.trim());
    }

    if (options.status) {
      params = params.set('status', options.status);
    }

    return this.http.get<any>(
      this.baseUrl,
      {
        headers: this.headers(),
        params
      }
    );
  }

  getLiveClass(id: string): Observable<any> {
    return this.http.get<any>(
      `${this.baseUrl}/${id}`,
      {
        headers: this.headers()
      }
    );
  }

  createLiveClass(
    payload: LiveClassPayload
  ): Observable<any> {
    return this.http.post<any>(
      this.baseUrl,
      payload,
      {
        headers: this.headers()
      }
    );
  }

  updateLiveClass(
    id: string,
    payload: LiveClassPayload
  ): Observable<any> {
    return this.http.put<any>(
      `${this.baseUrl}/${id}`,
      payload,
      {
        headers: this.headers()
      }
    );
  }

  updateStatus(
    id: string,
    status: LiveClassStatus
  ): Observable<any> {
    return this.http.patch<any>(
      `${this.baseUrl}/${id}/status`,
      { status },
      {
        headers: this.headers()
      }
    );
  }
}