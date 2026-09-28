import {
  Injectable,
  inject
} from '@angular/core';
import {
  HttpClient
} from '@angular/common/http';
import {
  Observable
} from 'rxjs';

export interface Role {
  id: string;
  name: string;
  description: string | null;
  systemRole: boolean;
  permissions: string[];
}

export interface Permission {
  id: string;
  code: string;
  description: string | null;
}

export interface RoleRequest {
  name: string;
  description: string;
  permissionIds: string[];
}

@Injectable({
  providedIn: 'root'
})
export class RoleService {
  private readonly http = inject(HttpClient);
  private readonly baseUrl =
    'http://localhost:8080/api/v1/roles';

  getRoles(): Observable<Role[]> {
    return this.http.get<Role[]>(
      this.baseUrl
    );
  }

  getPermissions(): Observable<Permission[]> {
    return this.http.get<Permission[]>(
      `${this.baseUrl}/permissions`
    );
  }

  createRole(
    request: RoleRequest
  ): Observable<Role> {
    return this.http.post<Role>(
      this.baseUrl,
      request
    );
  }

  updateRole(
    id: string,
    request: RoleRequest
  ): Observable<Role> {
    return this.http.put<Role>(
      `${this.baseUrl}/${id}`,
      request
    );
  }

  deleteRole(id: string): Observable<void> {
    return this.http.delete<void>(
      `${this.baseUrl}/${id}`
    );
  }
}
