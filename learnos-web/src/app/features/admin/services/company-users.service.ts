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

export interface CompanyUser {
  id: string;
  userId: string;
  name: string;
  firstName?: string;
  lastName?: string;
  email: string;
  companyId: string | null;
  companyName: string | null;
  role: string;
  status: string;
}

export interface CompanyUserPayload {
  firstName: string;
  lastName: string;
  email: string;
  password: string;
  phone?: string;
  role: string;
  companyId?: string | null;
  companyRole?: string;
  status?: string;
}

@Injectable({
  providedIn: 'root'
})
export class CompanyUsersService {

  private readonly baseUrl =
    `${environment.apiUrl}/company-users`;

  constructor(
    private readonly http: HttpClient
  ) {}

  private headers(): HttpHeaders {
    const token =
      localStorage.getItem('accessToken')
      || '';

    return new HttpHeaders({
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json'
    });
  }

  getUsers(): Observable<CompanyUser[]> {
    return this.http.get<CompanyUser[]>(
      this.baseUrl,
      {
        headers: this.headers()
      }
    );
  }

  getUserById(
    id: string
  ): Observable<CompanyUser> {
    return this.http.get<CompanyUser>(
      `${this.baseUrl}/${id}`,
      {
        headers: this.headers()
      }
    );
  }

  createUser(
    payload: CompanyUserPayload
  ): Observable<CompanyUser> {
    return this.http.post<CompanyUser>(
      this.baseUrl,
      payload,
      {
        headers: this.headers()
      }
    );
  }

  updateUser(
    id: string,
    payload: CompanyUserPayload
  ): Observable<CompanyUser> {
    return this.http.put<CompanyUser>(
      `${this.baseUrl}/${id}`,
      payload,
      {
        headers: this.headers()
      }
    );
  }

  deleteUser(
    id: string
  ): Observable<void> {
    return this.http.delete<void>(
      `${this.baseUrl}/${id}`,
      {
        headers: this.headers()
      }
    );
  }
}