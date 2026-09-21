import { Injectable } from '@angular/core';
import {
  HttpClient,
  HttpHeaders
} from '@angular/common/http';
import { Observable } from 'rxjs';

export type CompanyPlanCode =
  | 'BASIC'
  | 'PRO'
  | 'ENTERPRISE'
  | string;

export interface CompanyPayload {
  name: string;
  industry?: string;
  companyCode?: string;
  email?: string;
  phone?: string;
  contactPhone?: string;
  domain?: string;
  status?: string;
  address?: string;
  city?: string;
  state?: string;
  pinCode?: string;
  country?: string;
  gstNumber?: string;
  panNumber?: string;
  cinNumber?: string;
  logoUrl?: string | null;
  primaryColor?: string;
  secondaryColor?: string;
  accentColor?: string;
  planCode?: CompanyPlanCode;
  planStartDate?: string;
  planExpiryDate?: string;
  maxLearners?: number;
  maxCourses?: number;
  canCreateCourses?: boolean;
}

export interface Company extends CompanyPayload {
  id: string;
  status: string;
  learnerCount?: number;
  courseCount?: number;
  courseRevenue?: number;
  createdAt?: string;
  initials?: string;
  brandClass?: string;
  learners?: number;
  courses?: number;
  revenue?: string;
  joined?: string;
}

@Injectable({
  providedIn: 'root'
})
export class CompaniesService {
  private readonly baseUrl = 'http://localhost:8080/api/v1';

  constructor(private http: HttpClient) {}

  private headers(): HttpHeaders {
    const token = localStorage.getItem('accessToken') || '';

    return new HttpHeaders({
      Authorization: `Bearer ${token}`
    });
  }

  getCompanies(): Observable<Company[]> {
    return this.http.get<Company[]>(
      `${this.baseUrl}/companies`,
      { headers: this.headers() }
    );
  }

  getCompanyById(id: string): Observable<Company> {
    return this.http.get<Company>(
      `${this.baseUrl}/companies/${id}`,
      { headers: this.headers() }
    );
  }

  getCompany(id: string): Observable<Company> {
    return this.getCompanyById(id);
  }

  createCompany(payload: CompanyPayload): Observable<Company> {
    return this.http.post<Company>(
      `${this.baseUrl}/companies`,
      payload,
      { headers: this.headers() }
    );
  }

  updateCompany(
    id: string,
    payload: CompanyPayload
  ): Observable<Company> {
    return this.http.put<Company>(
      `${this.baseUrl}/companies/${id}`,
      payload,
      { headers: this.headers() }
    );
  }

  deleteCompany(id: string): Observable<void> {
    return this.http.delete<void>(
      `${this.baseUrl}/companies/${id}`,
      { headers: this.headers() }
    );
  }

  uploadCompanyLogo(
    id: string,
    file: File
  ): Observable<Company> {
    const formData = new FormData();
    formData.append('file', file);

    return this.http.post<Company>(
      `${this.baseUrl}/companies/${id}/logo`,
      formData,
      { headers: this.headers() }
    );
  }

  uploadLogo(
    id: string,
    file: File
  ): Observable<Company> {
    return this.uploadCompanyLogo(id, file);
  }

  getLogoUrl(logoUrl?: string | null): string {
    if (!logoUrl) {
      return '';
    }

    if (
      logoUrl.startsWith('http://')
      || logoUrl.startsWith('https://')
    ) {
      return logoUrl;
    }

    return `http://localhost:8080/api/v1${logoUrl}`;
  }
}
