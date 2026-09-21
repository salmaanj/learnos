import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators
} from '@angular/forms';
import {
  Plan,
  PlanPayload,
  PlansService
} from './plans.service';

@Component({
  selector: 'app-plans',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule
  ],
  templateUrl: './plans.html',
  styleUrl: './plans.scss'
})
export class PlansComponent implements OnInit {
  plans: Plan[] = [];
  loading = false;
  errorMessage = '';

  searchTerm = '';

  showForm = false;
  isEditMode = false;
  editingPlanId: string | null = null;
  saving = false;

  planForm: FormGroup;

  constructor(
    private readonly plansService: PlansService,
    private readonly fb: FormBuilder,
    private readonly cd: ChangeDetectorRef
  ) {
    this.planForm = this.fb.group({
      code: [
        '',
        [
          Validators.required,
          Validators.maxLength(20)
        ]
      ],
      name: [
        '',
        [
          Validators.required,
          Validators.maxLength(80)
        ]
      ],
      price: [
        null,
        [Validators.min(0)]
      ],
      currency: [
        'INR',
        [
          Validators.required,
          Validators.maxLength(3)
        ]
      ],
      durationMonths: [
        12,
        [Validators.min(1)]
      ],
      maxLearners: [
        null,
        [Validators.min(0)]
      ],
      maxCourses: [
        null,
        [Validators.min(0)]
      ],
      description: [''],
      displayOrder: [
        0,
        [Validators.min(0)]
      ],
      active: [true]
    });
  }

  ngOnInit(): void {
    this.loadPlans();
  }

  get displayedPlans(): Plan[] {
    const term = this.searchTerm.trim().toLowerCase();

    if (!term) {
      return this.plans;
    }

    return this.plans.filter(plan =>
      [
        plan.code,
        plan.name,
        plan.currency,
        plan.active ? 'active' : 'inactive'
      ]
        .filter(Boolean)
        .some(value =>
          String(value).toLowerCase().includes(term)
        )
    );
  }

  loadPlans(): void {
    this.loading = true;
    this.errorMessage = '';
    this.cd.detectChanges();

    this.plansService.getPlans().subscribe({
      next: (plans) => {
        this.plans = plans;
        this.loading = false;
        this.cd.detectChanges();
      },
      error: (error) => {
        console.error('Could not load plans', error);
        this.errorMessage =
          'Could not load plans. Please try again.';
        this.loading = false;
        this.cd.detectChanges();
      }
    });
  }

  onSearchChange(): void {
    this.cd.detectChanges();
  }

  openCreateForm(): void {
    this.isEditMode = false;
    this.editingPlanId = null;
    this.errorMessage = '';

    this.planForm.reset({
      code: '',
      name: '',
      price: null,
      currency: 'INR',
      durationMonths: 12,
      maxLearners: null,
      maxCourses: null,
      description: '',
      displayOrder: 0,
      active: true
    });

    this.showForm = true;
    this.cd.detectChanges();
  }

  openEditForm(plan: Plan): void {
    this.isEditMode = true;
    this.editingPlanId = plan.id;
    this.errorMessage = '';

    this.planForm.reset({
      code: plan.code,
      name: plan.name,
      price: plan.price,
      currency: plan.currency || 'INR',
      durationMonths: plan.durationMonths,
      maxLearners: plan.maxLearners,
      maxCourses: plan.maxCourses,
      description: plan.description || '',
      displayOrder: plan.displayOrder ?? 0,
      active: plan.active
    });

    this.showForm = true;
    this.cd.detectChanges();
  }

  cancelForm(): void {
    if (this.saving) {
      return;
    }

    this.showForm = false;
    this.isEditMode = false;
    this.editingPlanId = null;
    this.cd.detectChanges();
  }

  submitForm(): void {
    if (this.saving) {
      return;
    }

    if (this.planForm.invalid) {
      this.planForm.markAllAsTouched();
      return;
    }

    this.saving = true;
    this.errorMessage = '';
    this.cd.detectChanges();

    const rawValue = this.planForm.getRawValue();

    const payload: PlanPayload = {
      code: String(rawValue.code ?? '').trim().toUpperCase(),
      name: String(rawValue.name ?? '').trim(),
      price: this.toNullableNumber(rawValue.price),
      currency: String(rawValue.currency ?? 'INR')
        .trim()
        .toUpperCase(),
      durationMonths: this.toNullableNumber(
        rawValue.durationMonths
      ),
      maxLearners: this.toNullableNumber(
        rawValue.maxLearners
      ),
      maxCourses: this.toNullableNumber(
        rawValue.maxCourses
      ),
      description: String(
        rawValue.description ?? ''
      ).trim(),
      displayOrder: this.toNullableNumber(
        rawValue.displayOrder
      ),
      active: rawValue.active === true
    };

    const request$ =
      this.isEditMode && this.editingPlanId
        ? this.plansService.updatePlan(
            this.editingPlanId,
            payload
          )
        : this.plansService.createPlan(payload);

    request$.subscribe({
      next: () => {
        this.saving = false;
        this.showForm = false;
        this.isEditMode = false;
        this.editingPlanId = null;
        this.cd.detectChanges();
        this.loadPlans();
      },
      error: (error) => {
        console.error('Could not save plan', error);
        this.saving = false;
        this.errorMessage = this.getErrorMessage(error);
        this.cd.detectChanges();
      }
    });
  }

  toggleStatus(plan: Plan): void {
    this.plansService.togglePlanStatus(plan.id).subscribe({
      next: (updated) => {
        const index = this.plans.findIndex(
          (item) => item.id === updated.id
        );

        if (index > -1) {
          this.plans[index] = updated;
        }

        this.cd.detectChanges();
      },
      error: (error) => {
        console.error('Could not update plan status', error);
        this.errorMessage =
          'Could not update the plan status.';
        this.cd.detectChanges();
      }
    });
  }

  deletePlan(plan: Plan): void {
    const confirmed = window.confirm(
      `Delete plan "${plan.name}"? This cannot be undone.`
    );

    if (!confirmed) {
      return;
    }

    this.plansService.deletePlan(plan.id).subscribe({
      next: () => {
        this.plans = this.plans.filter(
          (item) => item.id !== plan.id
        );
        this.cd.detectChanges();
      },
      error: (error) => {
        console.error('Could not delete plan', error);
        this.errorMessage =
          'Could not delete the plan. It may already be in use.';
        this.cd.detectChanges();
      }
    });
  }

  trackByPlanId(_: number, plan: Plan): string {
    return plan.id;
  }

  private toNullableNumber(value: unknown): number | null {
    if (value === null || value === undefined || value === '') {
      return null;
    }

    const numberValue = Number(value);

    return Number.isFinite(numberValue)
      ? numberValue
      : null;
  }

  private getErrorMessage(error: any): string {
    const backendMessage =
      error?.error?.message ||
      error?.error?.error ||
      error?.error;

    if (typeof backendMessage === 'string' &&
        backendMessage.trim()) {
      return backendMessage;
    }

    return 'Could not save the plan. Please check the details and try again.';
  }
}
