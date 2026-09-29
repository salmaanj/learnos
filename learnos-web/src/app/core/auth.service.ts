import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, tap } from 'rxjs';
import { environment } from '../../environments/environment';

export interface LoginRequest {
  email: string;
  password: string;
}

export interface ForgotPasswordRequest {
  email: string;
}

export interface VerifyResetOtpRequest {
  email: string;
  otp: string;
}

export interface ResetPasswordRequest {
  email: string;
  otp: string;
  newPassword: string;
}

export interface AuthUser {
  id: string;
  email: string;
  firstName?: string;
  lastName?: string;
  fullName?: string;
  phone?: string | null;
  role?: string;
  permissions?: string[];
  profileImageUrl?: string | null;
  companyId?: string | null;
  companyName?: string | null;
  companyLogoUrl?: string | null;
  companyPrimaryColor?: string | null;
  companySecondaryColor?: string | null;
  companyAccentColor?: string | null;
}

export interface AuthData {
  accessToken: string;
  refreshToken: string;
  tokenType: string;
  expiresIn: number;
  user: AuthUser;
}

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private readonly baseUrl = environment.apiUrl;
  private readonly apiBaseUrl =
    'http://localhost:8080/api/v1';

  constructor(private http: HttpClient) {}

  login(payload: LoginRequest): Observable<AuthData> {
    return this.http
      .post<AuthData>(
        `${this.baseUrl}/auth/login`,
        payload
      )
      .pipe(
        tap(auth => {
          const user =
            auth.user || ({} as AuthUser);

          const userName =
            user.fullName
            || this.buildFullName(user);

          const role =
            this.normalizeRole(user.role);

          user.role = role;
          user.permissions = this.normalizePermissions(
            user.permissions
          );

          localStorage.setItem(
            'accessToken',
            auth.accessToken || ''
          );

          localStorage.setItem(
            'refreshToken',
            auth.refreshToken || ''
          );

          localStorage.setItem(
            'userEmail',
            user.email || ''
          );

          localStorage.setItem(
            'userName',
            userName
          );

          localStorage.setItem(
            'companyName',
            user.companyName || 'LearnOS'
          );

          localStorage.setItem(
            'companyInitials',
            this.getInitials(
              user.companyName || 'LearnOS'
            )
          );

          localStorage.setItem(
            'companyLogoUrl',
            this.resolveCompanyLogoUrl(
              user.companyLogoUrl
            )
          );

          localStorage.setItem(
            'userRole',
            role
          );

          localStorage.setItem(
            'currentUser',
            JSON.stringify(user)
          );

          localStorage.removeItem(
            'subscriptionStatus'
          );
        })
      );
  }

  forgotPassword(
    payload: ForgotPasswordRequest
  ): Observable<string> {
    return this.http.post(
      `${this.baseUrl}/auth/forgot-password`,
      payload,
      {
        responseType: 'text'
      }
    );
  }

  verifyResetOtp(
    payload: VerifyResetOtpRequest
  ): Observable<string> {
    return this.http.post(
      `${this.baseUrl}/auth/verify-reset-otp`,
      payload,
      {
        responseType: 'text'
      }
    );
  }

  resetPassword(
    payload: ResetPasswordRequest
  ): Observable<string> {
    return this.http.post(
      `${this.baseUrl}/auth/reset-password`,
      payload,
      {
        responseType: 'text'
      }
    );
  }

  logout(): void {
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
    localStorage.removeItem('userEmail');
    localStorage.removeItem('userName');
    localStorage.removeItem('companyName');
    localStorage.removeItem('companyInitials');
    localStorage.removeItem('companyLogoUrl');
    localStorage.removeItem('userRole');
    localStorage.removeItem('currentUser');
    localStorage.removeItem('subscriptionStatus');
  }

  getAccessToken(): string {
    return localStorage.getItem('accessToken') || '';
  }

  getCompanyName(): string {
    const currentUser =
      this.getCurrentUser();

    return currentUser?.companyName
      || localStorage.getItem('companyName')
      || 'LearnOS';
  }

  getCompanyLogoUrl(): string {
    const currentUser =
      this.getCurrentUser();

    return this.resolveCompanyLogoUrl(
      currentUser?.companyLogoUrl
      || localStorage.getItem('companyLogoUrl')
    );
  }

  getCompanyInitials(): string {
    return localStorage.getItem(
      'companyInitials'
    ) || 'LO';
  }

  getUserName(): string {
    const currentUser =
      this.getCurrentUser();

    return currentUser?.fullName
      || localStorage.getItem('userName')
      || '';
  }

  getUserRole(): string {
    return this.normalizeRole(
      this.getCurrentUser()?.role
      || localStorage.getItem('userRole')
      || ''
    );
  }

  getCurrentUser(): AuthUser | null {
    const raw =
      localStorage.getItem('currentUser');

    if (!raw) {
      return null;
    }

    try {
      const user =
        JSON.parse(raw) as AuthUser;

      return {
        ...user,
        role: this.normalizeRole(user.role),
        permissions: this.normalizePermissions(
          user.permissions
        )
      };
    } catch {
      return null;
    }
  }

  hasPermission(permission: string): boolean {
    const requestedPermission =
      permission.trim().toUpperCase();

    if (!requestedPermission) {
      return false;
    }

    return this.getCurrentUser()?.permissions
      ?.some(value =>
        value.trim().toUpperCase()
          === requestedPermission
      )
      ?? false;
  }

  isLoggedIn(): boolean {
    return !!this.getAccessToken();
  }

  isLearner(): boolean {
    return this.getUserRole() === 'LEARNER';
  }

  isCompanyAdmin(): boolean {
    return this.getUserRole() === 'ADMIN'
      && !this.isSuperAdmin();
  }

  isSuperAdmin(): boolean {
    const user =
      this.getCurrentUser();

    const email =
      String(user?.email || '')
        .trim()
        .toLowerCase();

    const fullName =
      String(user?.fullName || '')
        .trim()
        .toLowerCase();

    const role =
      this.getUserRole();

    return role === 'SUPERADMIN'
      || role === 'SUPERADMINISTRATOR'
      || role === 'SYSTEMADMIN'
      || role === 'ROOTADMIN'
      || email === 'admin@blute.co.in'
      || fullName === 'super admin';
  }

  isAdminOrTutor(): boolean {
    const role =
      this.getUserRole();

    return role === 'ADMIN'
      || role === 'TUTOR'
      || role === 'USER'
      || this.isSuperAdmin();
  }

  getSubscriptionStatus(): string {
    return String(
      localStorage.getItem(
        'subscriptionStatus'
      ) || ''
    )
      .trim()
      .toUpperCase();
  }

  setSubscriptionStatus(
    status: string | null | undefined
  ): void {
    const normalized =
      String(status || '')
        .trim()
        .toUpperCase();

    if (!normalized) {
      localStorage.removeItem(
        'subscriptionStatus'
      );

      return;
    }

    localStorage.setItem(
      'subscriptionStatus',
      normalized
    );
  }

  clearSubscriptionStatus(): void {
    localStorage.removeItem(
      'subscriptionStatus'
    );
  }

  isSubscriptionActive(): boolean {
    return this.isSuperAdmin()
      || this.getSubscriptionStatus()
        === 'ACTIVE';
  }

  homeRoute(): string {
    return this.isLearner()
      ? '/learn/courses'
      : '/admin/dashboard';
  }

  private normalizeRole(role: unknown): string {
    if (typeof role !== 'string') {
      return '';
    }

    return role
      .trim()
      .toUpperCase()
      .replace(/^ROLE_/, '')
      .replace(/[\s_-]/g, '');
  }

  private normalizePermissions(
    permissions: unknown
  ): string[] {
    if (!Array.isArray(permissions)) {
      return [];
    }

    return permissions
      .filter(
        (permission): permission is string =>
          typeof permission === 'string'
      )
      .map(permission =>
        permission.trim().toUpperCase()
      )
      .filter(Boolean);
  }

  private resolveCompanyLogoUrl(
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

    return `${this.apiBaseUrl}${logoUrl}`;
  }

  private buildFullName(
    user: AuthUser
  ): string {
    const first =
      user?.firstName?.trim() || '';

    const last =
      user?.lastName?.trim() || '';

    const full =
      `${first} ${last}`.trim();

    return full
      || user?.email
      || 'User';
  }

  private getInitials(
    name: string
  ): string {
    const trimmed =
      (name || '').trim();

    if (!trimmed) {
      return 'LO';
    }

    return trimmed
      .split(' ')
      .filter(Boolean)
      .slice(0, 2)
      .map(part =>
        part[0].toUpperCase()
      )
      .join('');
  }
}