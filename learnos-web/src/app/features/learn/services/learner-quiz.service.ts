import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class LearnerQuizService {
  private readonly baseUrl = 'http://localhost:8080/api/v1';

  constructor(private http: HttpClient) {}

  private headers(): HttpHeaders {
    const token = localStorage.getItem('accessToken') || '';
    return new HttpHeaders({ Authorization: `Bearer ${token}` });
  }

  /** Published quizzes available for a course (summary only - no questions). */
  getQuizzesForCourse(courseId: string): Observable<any> {
    return this.http.get<any>(
      `${this.baseUrl}/quiz-attempts/course/${courseId}`,
      { headers: this.headers() }
    );
  }

  /** Full quiz to render for taking - correct answers are never included. */
  getQuizToTake(quizId: string): Observable<any> {
    return this.http.get<any>(
      `${this.baseUrl}/quiz-attempts/quiz/${quizId}/take`,
      { headers: this.headers() }
    );
  }

  /** Submits answers (questionId -> selected optionId) and returns the graded result. */
  submitAttempt(quizId: string, answers: Record<string, string>): Observable<any> {
    return this.http.post<any>(
      `${this.baseUrl}/quiz-attempts`,
      { quizId, answers },
      { headers: this.headers() }
    );
  }

  /** The learner's own attempt history across all quizzes. */
  getMyAttempts(): Observable<any> {
    return this.http.get<any>(
      `${this.baseUrl}/quiz-attempts/my`,
      { headers: this.headers() }
    );
  }
}
