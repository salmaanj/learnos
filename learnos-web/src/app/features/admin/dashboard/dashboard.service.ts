import { Injectable } from '@angular/core';
import {
  HttpClient,
  HttpHeaders,
  HttpParams
} from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class DashboardService {
  private readonly baseUrl = 'http://localhost:8080/api/v1';

  constructor(private http: HttpClient) {}

  private headers(): HttpHeaders {
    const token = localStorage.getItem('accessToken') || '';

    return new HttpHeaders({
      Authorization: `Bearer ${token}`
    });
  }

  getCourses(): Observable<any> {
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

  getQuizzes(): Observable<any> {
    return this.http.get<any>(
      `${this.baseUrl}/quizzes`,
      { headers: this.headers() }
    );
  }

  getQuizResults(quizId: string): Observable<any> {
    return this.http.get<any>(
      `${this.baseUrl}/quizzes/${quizId}/results`,
      { headers: this.headers() }
    );
  }

  getCertificates(): Observable<any> {
    return this.http.get<any>(
      `${this.baseUrl}/certificates`,
      { headers: this.headers() }
    );
  }

  getCertificatesIssuedToday(): Observable<any> {
    return this.http.get<any>(
      `${this.baseUrl}/certificates/today`,
      { headers: this.headers() }
    );
  }

  getCourseRevenue(): Observable<number> {
    return this.http.get<number>(
      `${this.baseUrl}/dashboard/course-revenue`,
      { headers: this.headers() }
    );
  }

  getSubscriptionRevenue(): Observable<number> {
    return this.http.get<number>(
      `${this.baseUrl}/dashboard/subscription-revenue`,
      { headers: this.headers() }
    );
  }
}
