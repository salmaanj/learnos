import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface QuizOption {
  id?: string;
  text: string;
  correct: boolean;
}

export interface QuizQuestion {
  id?: string;
  text: string;
  type: 'MCQ' | 'TRUE_FALSE';
  displayOrder?: number;
  options: QuizOption[];
}

export interface Quiz {
  id: string;
  title: string;
  courseId: string | null;
  courseName: string | null;
  durationMinutes: number;
  passPercent: number;
  status: 'DRAFT' | 'PUBLISHED';
  totalQuestions: number;
  questions: QuizQuestion[];
}

export interface QuizAttempt {
  id: string;
  quizId: string;
  quizTitle: string;
  userId: string;
  userName: string;
  totalQuestions: number;
  correctCount: number;
  scorePercent: number;
  passed: boolean;
  submittedAt: string;
}

export interface QuizResults {
  passedCount: number;
  failedCount: number;
  avgScorePercent: number;
  attempts: QuizAttempt[];
}

@Injectable({ providedIn: 'root' })
export class QuizService {
  private readonly baseUrl = 'http://localhost:8080/api/v1/quizzes';

  constructor(private http: HttpClient) {}

  private headers(): HttpHeaders {
    const token = localStorage.getItem('accessToken') || '';
    return new HttpHeaders({
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json'
    });
  }

  getAllQuizzes(): Observable<Quiz[]> {
    return this.http.get<Quiz[]>(this.baseUrl, { headers: this.headers() });
  }

  getQuiz(id: string): Observable<Quiz> {
    return this.http.get<Quiz>(`${this.baseUrl}/${id}`, { headers: this.headers() });
  }

  createQuiz(payload: { title: string; courseId: string | null; durationMinutes: number; passPercent: number }): Observable<Quiz> {
    return this.http.post<Quiz>(this.baseUrl, payload, { headers: this.headers() });
  }

  updateQuiz(id: string, payload: { title: string; courseId: string | null; durationMinutes: number; passPercent: number }): Observable<Quiz> {
    return this.http.put<Quiz>(`${this.baseUrl}/${id}`, payload, { headers: this.headers() });
  }

  deleteQuiz(id: string): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}`, { headers: this.headers() });
  }

  publishQuiz(id: string): Observable<Quiz> {
    return this.http.post<Quiz>(`${this.baseUrl}/${id}/publish`, {}, { headers: this.headers() });
  }

  addQuestion(quizId: string, payload: { text: string; type: string; options: QuizOption[] }): Observable<Quiz> {
    return this.http.post<Quiz>(`${this.baseUrl}/${quizId}/questions`, payload, { headers: this.headers() });
  }

  updateQuestion(quizId: string, questionId: string, payload: { text: string; type: string; options: QuizOption[] }): Observable<Quiz> {
    return this.http.put<Quiz>(`${this.baseUrl}/${quizId}/questions/${questionId}`, payload, { headers: this.headers() });
  }

  deleteQuestion(quizId: string, questionId: string): Observable<Quiz> {
    return this.http.delete<Quiz>(`${this.baseUrl}/${quizId}/questions/${questionId}`, { headers: this.headers() });
  }

  getResults(quizId: string): Observable<QuizResults> {
    return this.http.get<QuizResults>(`${this.baseUrl}/${quizId}/results`, { headers: this.headers() });
  }
}
