import {
  Component,
  OnInit,
  inject,
  ChangeDetectorRef
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, ActivatedRoute } from '@angular/router';
import { CompanyUsersService, CompanyUser } from './company-users.service';

type SortColumn =
  | 'name'
  | 'email'
  | 'companyName'
  | 'role'
  | 'status';

type SortDirection = 'asc' | 'desc';

@Component({
  selector: 'app-company-users-list',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './company-users-list.html',
  styleUrl: './company-users-list.scss'
})
export class CompanyUsersList implements OnInit {
  private companyUsersService = inject(CompanyUsersService);
  private route = inject(ActivatedRoute);
  private cdr = inject(ChangeDetectorRef);

  users: CompanyUser[] = [];
  private allUsers: CompanyUser[] = [];

  filteredCompanyId: string | null = null;
  filteredCompanyName: string | null = null;

  loading = false;
  error = '';

  searchTerm = '';
  sortColumn: SortColumn = 'name';
  sortDirection: SortDirection = 'asc';

  ngOnInit(): void {
    this.filteredCompanyId =
      this.route.snapshot.queryParamMap.get('companyId');

    this.loadUsers();
  }

  get displayedUsers(): CompanyUser[] {
    const query = this.searchTerm.trim().toLowerCase();

    const filtered = !query
      ? [...this.users]
      : this.users.filter(user =>
          [
            user.name,
            user.email,
            (user as any).companyName,
            user.role,
            user.status
          ]
            .filter(Boolean)
            .some(value => String(value).toLowerCase().includes(query))
        );

    return filtered.sort((left, right) => {
      const leftValue = this.getSortValue(left, this.sortColumn);
      const rightValue = this.getSortValue(right, this.sortColumn);

      const result = leftValue.localeCompare(rightValue, undefined, {
        numeric: true,
        sensitivity: 'base'
      });

      return this.sortDirection === 'asc' ? result : -result;
    });
  }

  loadUsers(): void {
    this.loading = true;
    this.error = '';

    this.companyUsersService.getUsers().subscribe({
      next: (users) => {
        this.allUsers = (Array.isArray(users) ? users : [])
          .filter(user => (user.role || '').toUpperCase() !== 'LEARNER');

        if (this.filteredCompanyId) {
          this.users = this.allUsers.filter(
            user => (user as any).companyId === this.filteredCompanyId
          );

          this.filteredCompanyName = this.users[0]
            ? (this.users[0] as any).companyName
            : null;
        } else {
          this.users = [...this.allUsers];
        }

        this.loading = false;
        this.cdr.detectChanges();
      },
      error: (err) => {
        console.error(err);

        this.users = [];
        this.error = this.getErrorMessage(
          err,
          'Failed to load company users'
        );

        this.loading = false;
        this.cdr.detectChanges();
      }
    });
  }

  refresh(): void {
    this.loadUsers();
  }

  onSearch(value: string): void {
    this.searchTerm = value;
  }

  sortBy(column: SortColumn): void {
    if (this.sortColumn === column) {
      this.sortDirection =
        this.sortDirection === 'asc' ? 'desc' : 'asc';
    } else {
      this.sortColumn = column;
      this.sortDirection = 'asc';
    }
  }

  sortIndicator(column: SortColumn): string {
    if (this.sortColumn !== column) {
      return '↕';
    }

    return this.sortDirection === 'asc' ? '↑' : '↓';
  }

  trackById(_: number, user: CompanyUser): string {
    return user.id;
  }

  getStatusClass(status: string | null | undefined): string {
    const value = (status || '').toLowerCase();

    if (value === 'active') {
      return 'pill success';
    }

    if (value === 'inactive') {
      return 'pill muted';
    }

    if (value === 'pending') {
      return 'pill warning';
    }

    return 'pill';
  }

  getRoleClass(role: string | null | undefined): string {
    const value = (role || '').toLowerCase();

    if (value.includes('admin')) {
      return 'pill success';
    }

    return 'pill category';
  }

  private getSortValue(
    user: CompanyUser,
    column: SortColumn
  ): string {
    switch (column) {
      case 'companyName':
        return String((user as any).companyName || '');

      case 'name':
      case 'email':
      case 'role':
      case 'status':
        return String(user[column] || '');

      default:
        return '';
    }
  }

  private getErrorMessage(err: any, fallback: string): string {
    const backendMessage = String(
      err?.error?.error ||
      err?.error?.message ||
      err?.message ||
      ''
    ).toLowerCase();

    if (
      err?.status === 401 ||
      err?.status === 403 ||
      backendMessage.includes('permission') ||
      backendMessage.includes('forbidden') ||
      backendMessage.includes('access denied')
    ) {
      return "You don't have permission to view this page.";
    }

    return fallback;
  }
}