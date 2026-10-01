import {
  Injectable
} from '@angular/core';

import {
  HttpClient,
  HttpHeaders
} from '@angular/common/http';

import {
  Observable
} from 'rxjs';

import {
  environment
} from '../../../../environments/environment';

export type CompanyPlanCode =
  | 'BASIC'
  | 'PRO'
  | 'ENTERPRISE'
  | string;

export type CompanyType =
  | 'BUSINESS'
  | 'UNIVERSITY_COLLEGE'
  | 'GOVERNMENT';

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
  companyType?: CompanyType;
  planCode?: CompanyPlanCode;
  planStartDate?: string | null;
  planExpiryDate?: string | null;
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

  private readonly baseUrl =
    environment.apiUrl;

  constructor(
    private readonly http: HttpClient
  ) {}

  private headers(
    includeContentType = false
  ): HttpHeaders {
    const token =
      localStorage.getItem('accessToken')
      || '';

    let headers = new HttpHeaders({
      Authorization: `Bearer ${token}`
    });

    if (includeContentType) {
      headers = headers.set(
        'Content-Type',
        'application/json'
      );
    }

    return headers;
  }

  getCompanies(): Observable<Company[]> {
    return this.http.get<Company[]>(
      `${this.baseUrl}/companies`,
      {
        headers: this.headers()
      }
    );
  }

  getCompanyById(
    id: string
  ): Observable<Company> {
    return this.http.get<Company>(
      `${this.baseUrl}/companies/${id}`,
      {
        headers: this.headers()
      }
    );
  }

  getCompany(
    id: string
  ): Observable<Company> {
    return this.getCompanyById(id);
  }

  createCompany(
    payload: CompanyPayload
  ): Observable<Company> {
    return this.http.post<Company>(
      `${this.baseUrl}/companies`,
      payload,
      {
        headers: this.headers(true)
      }
    );
  }

  updateCompany(
    id: string,
    payload: CompanyPayload
  ): Observable<Company> {
    return this.http.put<Company>(
      `${this.baseUrl}/companies/${id}`,
      payload,
      {
        headers: this.headers(true)
      }
    );
  }

  deleteCompany(
    id: string
  ): Observable<void> {
    return this.http.delete<void>(
      `${this.baseUrl}/companies/${id}`,
      {
        headers: this.headers()
      }
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
      {
        headers: this.headers()
      }
    );
  }

  uploadLogo(
    id: string,
    file: File
  ): Observable<Company> {
    return this.uploadCompanyLogo(
      id,
      file
    );
  }

  getLogoUrl(
    logoUrl?: string | null
  ): string {
    if (!logoUrl) {
      return '';
    }

    if (
      logoUrl.startsWith('http://')
      || logoUrl.startsWith('https://')
      || logoUrl.startsWith('blob:')
    ) {
      return logoUrl;
    }

    return `${this.baseUrl}${logoUrl}`;
  }
}