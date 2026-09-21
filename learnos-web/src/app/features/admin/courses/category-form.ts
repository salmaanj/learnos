import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators
} from '@angular/forms';
import {
  HttpClient,
  HttpHeaders,
  HttpClientModule
} from '@angular/common/http';
import {
  ActivatedRoute,
  Router,
  RouterLink
} from '@angular/router';
import { AuthService } from '../../../core/auth.service';

@Component({
  selector: 'app-category-form',
  standalone: true,
  imports: [
    CommonModule,
    HttpClientModule,
    ReactiveFormsModule,
    RouterLink
  ],
  templateUrl: './category-form.html',
  styleUrls: ['./category-form.scss']
})
export class CategoryForm implements OnInit {
  form!: FormGroup;

  loading = false;
  submitting = false;
  error = '';

  isEdit = false;
  categoryId = '';

  isSuperAdmin = false;
  companies: any[] = [];

  private readonly baseUrl = 'http://localhost:8080/api/v1';

  constructor(
    private fb: FormBuilder,
    private http: HttpClient,
    private router: Router,
    private route: ActivatedRoute,
    private authService: AuthService
  ) {}

  ngOnInit(): void {
    this.isSuperAdmin = this.authService.isSuperAdmin();

    this.form = this.fb.group({
      companyId: [''],
      name: ['', [Validators.required]],
      description: ['']
    });

    const id = this.route.snapshot.paramMap.get('id');

    if (id) {
      this.isEdit = true;
      this.categoryId = id;

      if (this.isSuperAdmin) {
        this.loadCompanies();
      }

      this.loadCategory(id);
      return;
    }

    if (this.isSuperAdmin) {
      this.loadCompanies();
    }
  }

  private getHeaders(): HttpHeaders {
    const token = this.authService.getAccessToken();

    return new HttpHeaders({
      Authorization: `Bearer ${token}`
    });
  }

  private loadCompanies(): void {
    this.http.get<any>(`${this.baseUrl}/companies`, {
      headers: this.getHeaders()
    }).subscribe({
      next: (res) => {
        const data = res?.data ?? res ?? [];
        this.companies = Array.isArray(data) ? data : [];
      },
      error: (err) => {
        console.error('Failed to load companies', err);
        this.companies = [];
      }
    });
  }

  private loadCategory(id: string): void {
    this.loading = true;
    this.error = '';

    this.http.get<any>(`${this.baseUrl}/categories/${id}`, {
      headers: this.getHeaders()
    }).subscribe({
      next: (res) => {
        const data = res?.data ?? res ?? {};

        this.form.patchValue({
          companyId: data.companyId ?? data.company?.id ?? '',
          name: data.name ?? '',
          description: data.description ?? ''
        });

        this.loading = false;
      },
      error: (err) => {
        console.error('Failed to load category', err);

        this.error =
          err?.error?.message ||
          err?.error?.error ||
          'Failed to load category.';

        this.loading = false;
      }
    });
  }

  submit(): void {
    if (this.form.invalid || this.submitting) {
      this.form.markAllAsTouched();
      return;
    }

    this.submitting = true;
    this.error = '';

    const payload: any = {
      name: String(this.form.value.name || '').trim(),
      description: String(this.form.value.description || '').trim()
    };

    if (this.isSuperAdmin) {
      payload.companyId = this.form.value.companyId || null;
    }

    const request = this.isEdit
      ? this.http.put<any>(
          `${this.baseUrl}/categories/${this.categoryId}`,
          payload,
          { headers: this.getHeaders() }
        )
      : this.http.post<any>(
          `${this.baseUrl}/categories`,
          payload,
          { headers: this.getHeaders() }
        );

    request.subscribe({
      next: () => {
        this.submitting = false;
        this.router.navigate(['/admin/courses/categories']);
      },
      error: (err) => {
        console.error('Failed to save category', err);

        this.error =
          err?.error?.message ||
          err?.error?.error ||
          'Could not save category.';

        this.submitting = false;
      }
    });
  }
}