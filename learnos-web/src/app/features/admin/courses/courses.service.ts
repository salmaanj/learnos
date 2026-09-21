import { Injectable } from '@angular/core';
import {
  HttpClient,
  HttpHeaders,
  HttpParams
} from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class CoursesService {
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

  getCourseById(id: string): Observable<any> {
    return this.http.get<any>(
      `${this.baseUrl}/courses/${id}`,
      {
        headers: this.headers()
      }
    );
  }

  updateCourse(
    id: string,
    payload: any
  ): Observable<any> {
    return this.http.put<any>(
      `${this.baseUrl}/courses/${id}`,
      payload,
      {
        headers: this.headers()
      }
    );
  }

  createCourse(payload: any): Observable<any> {
    return this.http.post<any>(
      `${this.baseUrl}/courses`,
      payload,
      {
        headers: this.headers()
      }
    );
  }

  getCategories(): Observable<any> {
    return this.http.get<any>(
      `${this.baseUrl}/categories`,
      {
        headers: this.headers()
      }
    );
  }

  getModules(courseId: string): Observable<any> {
    return this.http.get<any>(
      `${this.baseUrl}/courses/${courseId}/modules`,
      {
        headers: this.headers()
      }
    );
  }

  addModule(
    courseId: string,
    payload: any
  ): Observable<any> {
    return this.http.post<any>(
      `${this.baseUrl}/courses/${courseId}/modules`,
      payload,
      {
        headers: this.headers()
      }
    );
  }

  updateModule(
    courseId: string,
    moduleId: string,
    payload: any
  ): Observable<any> {
    return this.http.put<any>(
      `${this.baseUrl}/courses/${courseId}/modules/${moduleId}`,
      payload,
      {
        headers: this.headers()
      }
    );
  }

  deleteModule(
    courseId: string,
    moduleId: string
  ): Observable<any> {
    return this.http.delete<any>(
      `${this.baseUrl}/courses/${courseId}/modules/${moduleId}`,
      {
        headers: this.headers()
      }
    );
  }

  getLessonsByModule(
    courseId: string,
    moduleId: string
  ): Observable<any> {
    return this.http.get<any>(
      `${this.baseUrl}/lessons/module/${moduleId}`,
      {
        headers: this.headers()
      }
    );
  }

  getLessonsByCourse(
    courseId: string
  ): Observable<any> {
    return this.http.get<any>(
      `${this.baseUrl}/courses/${courseId}/lessons`,
      {
        headers: this.headers()
      }
    );
  }

  addLesson(
    courseId: string,
    moduleId: string,
    payload: any
  ): Observable<any> {
    return this.http.post<any>(
      `${this.baseUrl}/lessons/module/${moduleId}`,
      payload,
      {
        headers: this.headers()
      }
    );
  }

  updateLesson(
    courseId: string,
    moduleId: string,
    lessonId: string,
    payload: any
  ): Observable<any> {
    return this.http.put<any>(
      `${this.baseUrl}/lessons/${lessonId}`,
      payload,
      {
        headers: this.headers()
      }
    );
  }

  deleteLesson(
    courseId: string,
    moduleId: string,
    lessonId: string
  ): Observable<any> {
    return this.http.delete<any>(
      `${this.baseUrl}/lessons/${lessonId}`,
      {
        headers: this.headers()
      }
    );
  }

  uploadLessonContent(
    lessonId: string,
    file: File
  ): Observable<any> {
    const formData = new FormData();
    formData.append('file', file);

    return this.http.post<any>(
      `${this.baseUrl}/lessons/${lessonId}/upload`,
      formData,
      {
        headers: this.headers()
      }
    );
  }

  uploadThumbnail(
    courseId: string,
    file: File
  ): Observable<any> {
    const formData = new FormData();
    formData.append('file', file);

    return this.http.post<any>(
      `${this.baseUrl}/courses/${courseId}/thumbnail`,
      formData,
      {
        headers: this.headers()
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

  enrollLearnerInCourse(
    courseId: string,
    learnerId: string
  ): Observable<any> {
    return this.http.post<any>(
      `${this.baseUrl}/courses/${courseId}/enrollments`,
      {
        learnerId
      },
      {
        headers: this.headers()
      }
    );
  }

  removeLearnerFromCourse(
    courseId: string,
    learnerId: string
  ): Observable<any> {
    return this.http.delete<any>(
      `${this.baseUrl}/courses/${courseId}/enrollments/${learnerId}`,
      {
        headers: this.headers()
      }
    );
  }
}