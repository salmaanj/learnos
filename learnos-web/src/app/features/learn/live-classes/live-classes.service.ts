import { Injectable } from '@angular/core';
import {
  HttpClient,
  HttpHeaders
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

export type AttendanceStatus =
  | 'REGISTERED'
  | 'ATTENDED'
  | 'ABSENT'
  | 'CANCELLED';

export interface LearnerLiveClass {
  id: string;

  title: string;
  description: string | null;

  courseId: string | null;
  courseTitle: string | null;
  instructorName: string | null;

  startAt: string;
  endAt: string;
  timezone: string;

  provider: MeetingProvider;

  capacity: number | null;
  status: LiveClassStatus;

  thumbnailUrl: string | null;
  recordingUrl: string | null;

  eligible: boolean;
  joinAvailable: boolean;

  attendanceStatus: AttendanceStatus | null;
  joinAt: string | null;
  leaveAt: string | null;
  minutesAttended: number | null;
}

export interface LiveClassJoinResponse {
  liveClassId: string;
  title: string;
  provider: MeetingProvider;
  meetingUrl: string;
  meetingPassword: string | null;
  joinedAt: string;
}

@Injectable({
  providedIn: 'root'
})
export class LearnerLiveClassesService {
  private readonly baseUrl =
    'http://localhost:8080/api/v1/live-classes/learner';

  constructor(private http: HttpClient) {}

  private headers(): HttpHeaders {
    const token =
      localStorage.getItem('accessToken') || '';

    return new HttpHeaders({
      Authorization: `Bearer ${token}`
    });
  }

  getUpcoming(): Observable<any> {
    return this.http.get<any>(
      `${this.baseUrl}/upcoming`,
      {
        headers: this.headers()
      }
    );
  }

  getHistory(): Observable<any> {
    return this.http.get<any>(
      `${this.baseUrl}/history`,
      {
        headers: this.headers()
      }
    );
  }

  getDetails(id: string): Observable<any> {
    return this.http.get<any>(
      `${this.baseUrl}/${id}`,
      {
        headers: this.headers()
      }
    );
  }

  join(id: string): Observable<any> {
    return this.http.post<any>(
      `${this.baseUrl}/${id}/join`,
      {},
      {
        headers: this.headers()
      }
    );
  }

  leave(id: string): Observable<any> {
    return this.http.post<any>(
      `${this.baseUrl}/${id}/leave`,
      {},
      {
        headers: this.headers()
      }
    );
  }
}