import { Injectable } from '@angular/core';
import {
  HttpClient,
  HttpHeaders
} from '@angular/common/http';
import { Observable } from 'rxjs';

export type PaymentMethod = 'CASH' | 'RAZORPAY';

export interface CompanySubscription {
  id: string | null;
  companyId: string;
  companyStatus: string | null;
  planId: string | null;
  planCode: string | null;
  planName: string | null;
  amount: number;
  currency: string;
  durationMonths: number | null;
  maxLearners: number | null;
  maxCourses: number | null;
  status: string;
  paymentMethod: PaymentMethod | null;
  startDate: string | null;
  expiryDate: string | null;
  razorpayOrderId: string | null;
}

export interface UpgradePlan {
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
}

export interface RazorpayOrderResponse {
  subscriptionId: string;
  companyId: string;
  planId: string;
  keyId: string;
  orderId: string;
  amount: number;
  currency: string;
  status: string;
}

export interface VerifyRazorpayPaymentRequest {
  razorpayOrderId: string;
  razorpayPaymentId: string;
  razorpaySignature: string;
}

@Injectable({
  providedIn: 'root'
})
export class SubscriptionService {
  private readonly apiBaseUrl =
    'http://localhost:8080/api/v1';

  private readonly baseUrl =
    `${this.apiBaseUrl}/company-subscriptions`;

  private readonly plansUrl =
    `${this.apiBaseUrl}/plans`;

  constructor(
    private readonly http: HttpClient
  ) {}

  private jsonHeaders(): HttpHeaders {
    const token =
      localStorage.getItem('accessToken') || '';

    return new HttpHeaders({
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json'
    });
  }

  getMySubscription(): Observable<CompanySubscription> {
    return this.http.get<CompanySubscription>(
      `${this.baseUrl}/my`,
      {
        headers: this.jsonHeaders()
      }
    );
  }

  getMyUpgradeOptions(): Observable<UpgradePlan[]> {
    return this.http.get<UpgradePlan[]>(
      `${this.baseUrl}/my/upgrade-options`,
      {
        headers: this.jsonHeaders()
      }
    );
  }

  getAllActivePlans(): Observable<UpgradePlan[]> {
    return this.http.get<UpgradePlan[]>(
      `${this.plansUrl}/active`,
      {
        headers: this.jsonHeaders()
      }
    );
  }

  createRazorpayOrder(
    companyId: string,
    planId: string
  ): Observable<RazorpayOrderResponse> {
    return this.http.post<RazorpayOrderResponse>(
      `${this.baseUrl}/payment-order`,
      {
        companyId,
        planId
      },
      {
        headers: this.jsonHeaders()
      }
    );
  }

  verifyRazorpayPayment(
    request: VerifyRazorpayPaymentRequest
  ): Observable<CompanySubscription> {
    return this.http.post<CompanySubscription>(
      `${this.baseUrl}/verify-payment`,
      request,
      {
        headers: this.jsonHeaders()
      }
    );
  }
}
