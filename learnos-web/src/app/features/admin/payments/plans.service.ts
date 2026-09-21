import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface Plan {
  id: string;
  code: string;
  name: string;
  price: number | null;
  currency: string;
  durationMonths: number | null;
  maxLearners: number | null;
  maxCourses: number | null;
  description?: string | null;
  active: boolean;
  displayOrder?: number | null;
  createdAt?: string;
}

export type PlanPayload = {
  code: string;
  name: string;
  price?: number | null;
  currency?: string;
  durationMonths?: number | null;
  maxLearners?: number | null;
  maxCourses?: number | null;
  description?: string | null;
  active?: boolean;
  displayOrder?: number | null;
};

@Injectable({
  providedIn: 'root'
})
export class PlansService {
  private readonly apiBaseUrl = 'http://localhost:8080/api/v1';
  private readonly baseUrl = `${this.apiBaseUrl}/plans`;

  constructor(private http: HttpClient) {}

  private jsonHeaders(): HttpHeaders {
    const token = localStorage.getItem('accessToken') || '';

    return new HttpHeaders({
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json'
    });
  }

  getPlans(): Observable<Plan[]> {
    return this.http.get<Plan[]>(this.baseUrl, {
      headers: this.jsonHeaders()
    });
  }

  getActivePlans(): Observable<Plan[]> {
    return this.http.get<Plan[]>(`${this.baseUrl}/active`, {
      headers: this.jsonHeaders()
    });
  }

  getPlanById(id: string): Observable<Plan> {
    return this.http.get<Plan>(`${this.baseUrl}/${id}`, {
      headers: this.jsonHeaders()
    });
  }

  createPlan(payload: PlanPayload): Observable<Plan> {
    return this.http.post<Plan>(this.baseUrl, payload, {
      headers: this.jsonHeaders()
    });
  }

  updatePlan(id: string, payload: PlanPayload): Observable<Plan> {
    return this.http.put<Plan>(`${this.baseUrl}/${id}`, payload, {
      headers: this.jsonHeaders()
    });
  }

  togglePlanStatus(id: string): Observable<Plan> {
    return this.http.patch<Plan>(
      `${this.baseUrl}/${id}/toggle-status`,
      {},
      { headers: this.jsonHeaders() }
    );
  }

  deletePlan(id: string): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}`, {
      headers: this.jsonHeaders()
    });
  }
}