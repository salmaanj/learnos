import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HttpClient, HttpHeaders, HttpClientModule } from '@angular/common/http';
import { Router } from '@angular/router';

type SortColumn = 'name' | 'courses' | 'status' | 'updatedAt';
type SortDirection = 'asc' | 'desc';

@Component({
  selector: 'app-categories-list',
  standalone: true,
  imports: [CommonModule, HttpClientModule],
  templateUrl: './categories-list.component.html',
  styleUrl: './categories-list.component.scss'
})
export class CategoriesListComponent implements OnInit {
  categories: any[] = [];
  loading = false;
  error = '';

  searchTerm = '';
  sortColumn: SortColumn = 'name';
  sortDirection: SortDirection = 'asc';

  private readonly baseUrl = 'http://localhost:8080/api/v1';

  constructor(
    private http: HttpClient,
    private router: Router,
    private cd: ChangeDetectorRef
  ) {}

  get displayedCategories(): any[] {
    const term = this.searchTerm.trim().toLowerCase();

    const filtered = !term
      ? [...this.categories]
      : this.categories.filter(c =>
          [c.name, c.status]
            .filter(Boolean)
            .some(value =>
              String(value).toLowerCase().includes(term)
            )
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

  ngOnInit(): void {
    this.loadCategories();
  }

  private getHeaders(): HttpHeaders {
    const token = localStorage.getItem('accessToken') || '';
    return new HttpHeaders({
      Authorization: `Bearer ${token}`
    });
  }

  loadCategories(): void {
    this.loading = true;
    this.error = '';

    this.http.get<any>(`${this.baseUrl}/categories`, {
      headers: this.getHeaders()
    }).subscribe({
      next: (res) => {
        const data = res?.data || res || [];

        this.categories = Array.isArray(data)
          ? data.map((c: any) => ({
              id: c.id,
              name: c.name,
              courses: c.courseCount ?? c.courses ?? 0,
              status: c.active ? 'Active' : 'Inactive',
              updatedAt: c.updatedAt ? this.formatDate(c.updatedAt) : 'Today'
            }))
          : [];

        this.loading = false;
        this.cd.detectChanges();
      },
      error: (err) => {
        console.error('Failed to load categories', err);
        this.error = err?.error?.message || 'Failed to load categories.';
        this.categories = [];
        this.loading = false;
        this.cd.detectChanges();
      }
    });
  }

  onSearchChange(): void {
    this.cd.detectChanges();
  }

  sortBy(column: SortColumn): void {
    if (this.sortColumn === column) {
      this.sortDirection =
        this.sortDirection === 'asc' ? 'desc' : 'asc';
    } else {
      this.sortColumn = column;
      this.sortDirection = 'asc';
    }

    this.cd.detectChanges();
  }

  sortIndicator(column: SortColumn): string {
    if (this.sortColumn !== column) {
      return '↕';
    }

    return this.sortDirection === 'asc' ? '↑' : '↓';
  }

  editCategory(id: string): void {
    this.router.navigate(['/admin/courses/categories', id, 'edit']);
  }

  deleteCategory(id: string, name: string, event: Event): void {
    event.stopPropagation();

    if (!confirm(`Delete category "${name}"? This cannot be undone.`)) {
      return;
    }

    this.http.delete<any>(`${this.baseUrl}/categories/${id}`, {
      headers: this.getHeaders()
    }).subscribe({
      next: () => {
        this.loadCategories();
      },
      error: (err) => {
        alert(err?.error?.error || 'Could not delete this category.');
      }
    });
  }

  private formatDate(v: string): string {
    const d = new Date(v);
    if (isNaN(d.getTime())) {
      return v;
    }

    return d.toLocaleDateString('en-GB', {
      day: 'numeric',
      month: 'short',
      year: 'numeric'
    });
  }

  private getSortValue(c: any, column: SortColumn): string {
    switch (column) {
      case 'courses':
        return String(c.courses ?? 0).padStart(12, '0');

      case 'name':
      case 'status':
      case 'updatedAt':
        return String(c[column] ?? '');

      default:
        return '';
    }
  }
}