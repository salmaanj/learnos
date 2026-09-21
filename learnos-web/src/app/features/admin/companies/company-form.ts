import {
  Component,
  OnDestroy,
  OnInit
} from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators
} from '@angular/forms';
import {
  ActivatedRoute,
  Router,
  RouterModule
} from '@angular/router';
import {
  finalize,
  forkJoin,
  of,
  switchMap
} from 'rxjs';
import {
  CompaniesService,
  CompanyPayload,
  CompanyPlanCode
} from '../services/companies.service';
import {
  Plan,
  PlansService
} from '../payments/plans.service';
import {
  AuthService
} from '../../../core/auth.service';

@Component({
  selector: 'app-company-form',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    RouterModule
  ],
  templateUrl: './company-form.html',
  styleUrls: ['./company-form.scss']
})
export class CompanyForm
  implements OnInit, OnDestroy {
  companyForm!: FormGroup;

  isEdit = false;
  companyId = '';
  isSaving = false;
  saveError = '';

  plans: Plan[] = [];
  plansLoading = true;
  plansError = '';

  logoPreview = '';
  selectedLogoFile: File | null = null;

  private objectUrl = '';

  constructor(
    private readonly fb: FormBuilder,
    private readonly route: ActivatedRoute,
    private readonly router: Router,
    private readonly service: CompaniesService,
    private readonly plansService: PlansService,
    private readonly authService: AuthService
  ) {}

  get isSuperAdmin(): boolean {
    return this.authService.isSuperAdmin();
  }

  get isCompanyAdminEdit(): boolean {
    return this.isEdit && !this.isSuperAdmin;
  }

  ngOnInit(): void {
    this.companyForm = this.fb.group({
      name: ['', Validators.required],
      industry: ['', Validators.required],
      companyCode: ['', Validators.required],
      email: [
        '',
        [Validators.required, Validators.email]
      ],
      phone: [''],
      domain: [''],
      address: [''],
      city: [''],
      state: [''],
      pinCode: [''],
      country: ['India'],
      gstNumber: [
        '',
        [
          Validators.pattern(
            /^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$/
          )
        ]
      ],
      panNumber: [
        '',
        [Validators.pattern(/^[A-Z]{5}[0-9]{4}[A-Z]$/)]
      ],
      planCode: [''],
      planStartDate: [''],
      planExpiryDate: [''],
      primaryColor: ['#1E3A8A'],
      secondaryColor: ['#F97316'],
      accentColor: ['#2563EB'],
      status: ['PENDING_PAYMENT', Validators.required]
    });

    const id = this.route.snapshot.paramMap.get('id');

    this.isEdit = !!id;
    this.companyId = id ?? '';

    if (id) {
      this.loadCompanyAndPlans(id);
    } else {
      this.loadActivePlans();
    }
  }

  ngOnDestroy(): void {
    this.revokeObjectUrl();
  }

  private loadCompanyAndPlans(id: string): void {
    this.plansLoading = true;
    this.plansError = '';
    this.saveError = '';

    forkJoin({
      company: this.service.getCompanyById(id),
      plans: this.plansService.getActivePlans()
    }).subscribe({
      next: ({ company, plans }) => {
        this.plans = Array.isArray(plans) ? plans : [];
        this.plansLoading = false;

        this.logoPreview = this.resolveLogoUrl(company.logoUrl);

        const savedPlanCode = String(company.planCode ?? '')
          .trim()
          .toUpperCase();

        this.patchCompanyForm(company, savedPlanCode);

        if (this.isCompanyAdminEdit) {
          this.disableCompanyAdminFields();
        }

        const savedPlanIsActive =
          !savedPlanCode
          || this.plans.some(
            plan => String(plan.code)
              .trim()
              .toUpperCase() === savedPlanCode
          );

        if (savedPlanCode && !savedPlanIsActive) {
          this.plansError =
            'The company has a plan that is no longer active. Please select a new active plan before saving.';
        }
      },
      error: err => {
        this.plansLoading = false;
        this.plans = [];
        this.saveError =
          err?.error?.message
          || err?.error?.error
          || 'Could not load company and plan details.';
        console.error(
          'Failed to load company and plans',
          err
        );
      }
    });
  }

  private loadActivePlans(): void {
    this.plansLoading = true;
    this.plansError = '';

    this.plansService.getActivePlans().subscribe({
      next: plans => {
        this.plans = Array.isArray(plans) ? plans : [];
        this.plansLoading = false;

        if (this.plans.length === 0) {
          this.plansError =
            'No active plans are available. Companies can still be created as Pending Payment.';
        }
      },
      error: err => {
        this.plansLoading = false;
        this.plans = [];
        this.plansError =
          err?.error?.message
          || err?.error?.error
          || 'Could not load active plans.';
        console.error('Failed to load active plans', err);
      }
    });
  }

  private patchCompanyForm(
    company: any,
    savedPlanCode: string
  ): void {
    this.companyForm.patchValue({
      name: company.name ?? '',
      industry: company.industry ?? '',
      companyCode: company.companyCode ?? '',
      email: company.email ?? '',
      phone: company.phone ?? '',
      domain: company.domain ?? '',
      address: company.address ?? '',
      city: company.city ?? '',
      state: company.state ?? '',
      pinCode: company.pinCode ?? '',
      country: company.country ?? 'India',
      gstNumber: company.gstNumber ?? '',
      panNumber: company.panNumber ?? '',
      planCode: savedPlanCode,
      planStartDate: this.toDateInputValue(
        company.planStartDate
      ),
      planExpiryDate: this.toDateInputValue(
        company.planExpiryDate
      ),
      primaryColor: company.primaryColor ?? '#1E3A8A',
      secondaryColor: company.secondaryColor ?? '#F97316',
      accentColor: company.accentColor ?? '#2563EB',
      status: this.normalizeStatus(company.status)
    });
  }

  private disableCompanyAdminFields(): void {
    this.companyForm.get('companyCode')
      ?.disable({ emitEvent: false });
    this.companyForm.get('planCode')
      ?.disable({ emitEvent: false });
    this.companyForm.get('planStartDate')
      ?.disable({ emitEvent: false });
    this.companyForm.get('planExpiryDate')
      ?.disable({ emitEvent: false });
    this.companyForm.get('status')
      ?.disable({ emitEvent: false });
  }

  onLogoSelected(event: Event): void {
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0];

    if (!file) {
      return;
    }

    const allowedTypes = [
      'image/png',
      'image/jpeg',
      'image/webp',
      'image/svg+xml'
    ];

    if (!allowedTypes.includes(file.type)) {
      this.saveError =
        'Please choose a PNG, JPG, WebP, or SVG logo.';
      input.value = '';
      return;
    }

    if (file.size > 5 * 1024 * 1024) {
      this.saveError =
        'Logo file size must be 5 MB or less.';
      input.value = '';
      return;
    }

    this.saveError = '';
    this.selectedLogoFile = file;
    this.revokeObjectUrl();
    this.objectUrl = URL.createObjectURL(file);
    this.logoPreview = this.objectUrl;
  }

  onTaxInput(
    controlName: 'gstNumber' | 'panNumber'
  ): void {
    const value = String(
      this.companyForm.get(controlName)?.value ?? ''
    ).toUpperCase();

    this.companyForm.get(controlName)?.setValue(
      value,
      { emitEvent: false }
    );
  }

  save(): void {
    this.saveError = '';

    if (this.companyForm.invalid) {
      this.companyForm.markAllAsTouched();
      return;
    }

    if (this.plansLoading) {
      this.saveError =
        'Please wait while plan details are loading.';
      return;
    }

    const formValue = this.companyForm.getRawValue();
    const status = this.normalizeStatus(formValue.status);
    const selectedPlanCode = this.toCompanyPlanCode(
      formValue.planCode
    );

    const isNewPendingCompany =
      !this.isEdit && status === 'PENDING_PAYMENT';

    if (!selectedPlanCode && !isNewPendingCompany) {
      this.saveError =
        'Please select a plan unless the new company is Pending Payment.';
      this.companyForm.get('planCode')?.markAsTouched();
      return;
    }

    if (status === 'ACTIVE' && !selectedPlanCode) {
      this.saveError =
        'An Active company must have a plan selected.';
      this.companyForm.get('planCode')?.markAsTouched();
      return;
    }

    this.isSaving = true;

    const payload = this.getPayload(
      selectedPlanCode,
      status
    );

    const saveRequest = this.isEdit
      ? this.service.updateCompany(this.companyId, payload)
      : this.service.createCompany(payload);

    saveRequest.pipe(
      switchMap(company => {
        this.companyId = company.id;

        return this.selectedLogoFile
          ? this.service.uploadCompanyLogo(
              company.id,
              this.selectedLogoFile
            )
          : of(company);
      }),
      finalize(() => {
        this.isSaving = false;
      })
    ).subscribe({
      next: company => {
        if (company.logoUrl) {
          this.logoPreview = this.resolveLogoUrl(
            company.logoUrl
          );
        }

        this.selectedLogoFile = null;
        this.router.navigate(['/admin/companies']);
      },
      error: err => {
        this.saveError =
          err?.error?.message
          || err?.error?.error
          || 'Company save or logo upload failed.';
        console.error(
          'Company save or logo upload failed',
          err
        );
      }
    });
  }

  cancel(): void {
    this.router.navigate(['/admin/companies']);
  }

  formatPlanLabel(plan: Plan): string {
    const price = plan.price == null
      ? ''
      : ` — ${plan.currency || 'INR'} ${plan.price}`;

    const duration = plan.durationMonths
      ? ` / ${plan.durationMonths} month${
          plan.durationMonths === 1 ? '' : 's'
        }`
      : '';

    return `${plan.name}${price}${duration}`;
  }

  private getPayload(
    planCode: CompanyPlanCode,
    status: string
  ): CompanyPayload {
    const formValue = this.companyForm.getRawValue();

    return {
      name: formValue.name,
      industry: formValue.industry,
      companyCode: formValue.companyCode,
      email: formValue.email,
      phone: formValue.phone,
      domain: formValue.domain,
      address: formValue.address,
      city: formValue.city,
      state: formValue.state,
      pinCode: formValue.pinCode,
      country: formValue.country,
      gstNumber: formValue.gstNumber,
      panNumber: formValue.panNumber,
      planCode: planCode || '',
      planStartDate: formValue.planStartDate || null,
      planExpiryDate: formValue.planExpiryDate || null,
      primaryColor: formValue.primaryColor,
      secondaryColor: formValue.secondaryColor,
      accentColor: formValue.accentColor,
      status
    };
  }

  private toCompanyPlanCode(
    value: unknown
  ): CompanyPlanCode {
    const code = String(value ?? '')
      .trim()
      .toUpperCase();

    if (
      code === 'BASIC'
      || code === 'PRO'
      || code === 'ENTERPRISE'
    ) {
      return code;
    }

    return '';
  }

  private normalizeStatus(value: unknown): string {
    const status = String(value ?? '')
      .trim()
      .toUpperCase()
      .replace(/[\s-]+/g, '_');

    if (
      status === 'PENDING'
      || status === 'PENDING_PAYMENT'
    ) {
      return 'PENDING_PAYMENT';
    }

    if (status === 'ACTIVE') {
      return 'ACTIVE';
    }

    if (status === 'SUSPENDED') {
      return 'SUSPENDED';
    }

    if (status === 'INACTIVE') {
      return 'INACTIVE';
    }

    return 'PENDING_PAYMENT';
  }

  private toDateInputValue(value: unknown): string {
    if (!value) {
      return '';
    }

    const text = String(value);
    return text.length >= 10
      ? text.substring(0, 10)
      : text;
  }

  private resolveLogoUrl(
    logoUrl: string | null | undefined
  ): string {
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

  private revokeObjectUrl(): void {
    if (this.objectUrl) {
      URL.revokeObjectURL(this.objectUrl);
      this.objectUrl = '';
    }
  }
}
