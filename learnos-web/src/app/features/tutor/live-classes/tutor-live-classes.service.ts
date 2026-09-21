import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface TutorLiveClass {
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
  provider: string;
  meetingUrl: string;
  capacity: number | null;
  status: string;
  thumbnailUrl: string | null;
  recordingUrl: string | null;
  createdByUserId: string | null;
  createdByName: string | null;
  createdAt: string | null;
  updatedAt: string | null;
}

export interface TutorJoinResponse {
  liveClassId: string;
  title: string;
  provider: string;
  meetingUrl: string;
  meetingPassword: string | null;
  joinedAt: string;
}

@Injectable({
  providedIn: 'root'
})
export class TutorLiveClassesService {
  private readonly baseUrl =
    'http://localhost:8080/api/v1/live-classes/tutor';

  constructor(private http: HttpClient) {}

  private headers(): HttpHeaders {
    return new HttpHeaders({
      Authorization:
        `Bearer ${localStorage.getItem('accessToken') || ''}`
    });
  }

  getUpcoming(): Observable<any> {
    return this.http.get<any>(
      `${this.baseUrl}/upcoming`,
      { headers: this.headers() }
    );
  }

  joinClass(id: string): Observable<any> {
    return this.http.post<any>(
      `${this.baseUrl}/${id}/join`,
      {},
      { headers: this.headers() }
    );
  }
}
