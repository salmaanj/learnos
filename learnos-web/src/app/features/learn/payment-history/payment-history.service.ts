import { Injectable } from '@angular/core';
import {
  HttpClient,
  HttpHeaders
} from '@angular/common/http';
import { Observable } from 'rxjs';
import { PaymentHistoryRecord }
  from './payment-history.model';

@Injectable({ providedIn: 'root' })
export class PaymentHistoryService {
  private readonly baseUrl =
    'http://localhost:8080/api/v1';

  constructor(private http: HttpClient) {}

  private headers(): HttpHeaders {
    const token =
      localStorage.getItem('accessToken') || '';

    return new HttpHeaders({
      Authorization: `Bearer ${token}`
    });
  }

  getMyHistory(): Observable<PaymentHistoryRecord[]> {
    return this.http.get<PaymentHistoryRecord[]>(
      `${this.baseUrl}/payment-history/my`,
      {
        headers: this.headers()
      }
    );
  }
}