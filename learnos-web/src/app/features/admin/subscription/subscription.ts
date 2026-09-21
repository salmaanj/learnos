import {
  ChangeDetectorRef,
  Component,
  OnInit
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { finalize } from 'rxjs';

import {
  AuthService
} from '../../../core/auth.service';

import {
  CompanySubscription,
  RazorpayOrderResponse,
  SubscriptionService,
  UpgradePlan
} from './subscription.service';

declare global {
  interface Window {
    Razorpay: new (options: RazorpayCheckoutOptions) => RazorpayCheckout;
  }
}

interface RazorpayCheckoutResponse {
  razorpay_order_id: string;
  razorpay_payment_id: string;
  razorpay_signature: string;
}

interface RazorpayCheckoutOptions {
  key: string;
  amount: number;
  currency: string;
  name: string;
  description: string;
  order_id: string;
  handler: (response: RazorpayCheckoutResponse) => void;
  modal?: {
    ondismiss?: () => void;
  };
  theme?: {
    color?: string;
  };
}

interface RazorpayCheckout {
  open(): void;
  on(
    eventName: string,
    handler: (response: any) => void
  ): void;
}

@Component({
  selector: 'app-subscription',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './subscription.html',
  styleUrl: './subscription.scss'
})
export class SubscriptionComponent implements OnInit {
  subscription: CompanySubscription | null = null;
  upgradePlans: UpgradePlan[] = [];

  loading = true;
  plansLoading = false;
  paymentLoading = false;
  paymentPlanId: string | null = null;
  errorMessage = '';
  plansError = '';
  paymentError = '';

  constructor(
    private readonly subscriptionService: SubscriptionService,
    private readonly authService: AuthService,
    private readonly cd: ChangeDetectorRef
  ) {}

  get isSuperAdmin(): boolean {
    return this.authService.isSuperAdmin();
  }

  get isPendingPayment(): boolean {
    return this.subscription?.status === 'PENDING_PAYMENT';
  }

  get isActive(): boolean {
    return this.subscription?.status === 'ACTIVE';
  }

  get hasSelectedPlan(): boolean {
    return !!(
      this.subscription?.planId
      || this.subscription?.planCode
    );
  }

  get hasUpgradeOptions(): boolean {
    return this.upgradePlans.length > 0;
  }

  ngOnInit(): void {
    this.loadSubscription();
  }

  loadSubscription(): void {
    this.loading = true;
    this.errorMessage = '';
    this.plansError = '';
    this.upgradePlans = [];
    this.cd.detectChanges();

    this.subscriptionService
      .getMySubscription()
      .pipe(
        finalize(() => {
          this.loading = false;
          this.cd.detectChanges();
        })
      )
      .subscribe({
        next: subscription => {
          this.subscription = this.normalizeSubscription(
            subscription
          );

          this.authService.setSubscriptionStatus(
            this.subscription.status
          );

          this.cd.detectChanges();
          this.loadPlanOptions();
        },
        error: err => {
          this.subscription = null;
          this.errorMessage =
            err?.error?.message
            || err?.error?.error
            || 'Could not load subscription details.';

          this.authService.setSubscriptionStatus(
            'PENDING_PAYMENT'
          );

          console.error(
            'Failed to load subscription',
            err
          );

          this.cd.detectChanges();
          this.loadAllPlansForNewCompany();
        }
      });
  }

  private normalizeSubscription(
    value: CompanySubscription
  ): CompanySubscription {
    const planId = value?.planId ?? null;
    const planCode = this.cleanNullableString(
      value?.planCode
    );
    const planName = this.cleanNullableString(
      value?.planName
    );

    const hasPlan = !!(planId || planCode);
    const status = this.normalizeStatus(
      value?.status,
      hasPlan
    );

    return {
      ...value,
      planId,
      planCode,
      planName: hasPlan ? planName : null,
      status
    };
  }

  private normalizeStatus(
    value: unknown,
    hasPlan: boolean
  ): string {
    const status = String(value ?? '')
      .trim()
      .toUpperCase()
      .replace(/[\s-]+/g, '_');

    if (status === 'ACTIVE') {
      return 'ACTIVE';
    }

    if (status === 'INACTIVE') {
      return 'INACTIVE';
    }

    if (status === 'SUSPENDED') {
      return 'SUSPENDED';
    }

    if (
      status === 'PENDING'
      || status === 'PENDING_PAYMENT'
      || !hasPlan
    ) {
      return 'PENDING_PAYMENT';
    }

    return 'PENDING_PAYMENT';
  }

  private cleanNullableString(
    value: unknown
  ): string | null {
    const text = String(value ?? '').trim();
    return text ? text : null;
  }

  private loadPlanOptions(): void {
    if (!this.subscription || !this.hasSelectedPlan) {
      this.loadAllPlansForNewCompany();
      return;
    }

    if (this.subscription.status === 'ACTIVE') {
      this.loadUpgradeOptions();
      return;
    }

    this.loadAllPlansForNewCompany();
  }

  private loadAllPlansForNewCompany(): void {
    this.plansLoading = true;
    this.plansError = '';
    this.cd.detectChanges();

    this.subscriptionService
      .getAllActivePlans()
      .pipe(
        finalize(() => {
          this.plansLoading = false;
          this.cd.detectChanges();
        })
      )
      .subscribe({
        next: plans => {
          this.upgradePlans = Array.isArray(plans)
            ? plans
            : [];

          if (this.upgradePlans.length === 0) {
            this.plansError =
              'No active plans are currently available.';
          }

          this.cd.detectChanges();
        },
        error: err => {
          this.upgradePlans = [];
          this.plansError =
            err?.error?.message
            || err?.error?.error
            || 'Could not load active plans.';
          console.error(
            'Failed to load active plans',
            err
          );
          this.cd.detectChanges();
        }
      });
  }

  private loadUpgradeOptions(): void {
    this.plansLoading = true;
    this.plansError = '';
    this.cd.detectChanges();

    this.subscriptionService
      .getMyUpgradeOptions()
      .pipe(
        finalize(() => {
          this.plansLoading = false;
          this.cd.detectChanges();
        })
      )
      .subscribe({
        next: plans => {
          this.upgradePlans = Array.isArray(plans)
            ? plans
            : [];
          this.cd.detectChanges();
        },
        error: err => {
          this.upgradePlans = [];
          this.plansError =
            err?.error?.message
            || err?.error?.error
            || 'Could not load upgrade plans.';
          console.error(
            'Failed to load upgrade plans',
            err
          );
          this.cd.detectChanges();
        }
      });
  }

  payForPlan(plan: UpgradePlan): void {
    if (this.paymentLoading) {
      return;
    }

    if (!plan.id) {
      this.paymentError = 'This plan has no valid plan ID.';
      return;
    }

    if (!this.subscription?.companyId) {
      this.paymentError =
        'Company details are unavailable. Please reload the page.';
      return;
    }

    if (!window.Razorpay) {
      this.paymentError =
        'Razorpay Checkout is not loaded. Please reload the page.';
      return;
    }

    this.paymentLoading = true;
    this.paymentPlanId = plan.id;
    this.paymentError = '';
    this.cd.detectChanges();

    this.subscriptionService
      .createRazorpayOrder(
        this.subscription.companyId,
        plan.id
      )
      .pipe(
        finalize(() => {
          this.paymentLoading = false;
          this.paymentPlanId = null;
          this.cd.detectChanges();
        })
      )
      .subscribe({
        next: order => {
          this.openRazorpayCheckout(order, plan);
        },
        error: err => {
          this.paymentError =
            err?.error?.message
            || err?.error?.error
            || 'Could not create the payment order.';
          console.error(
            'Failed to create Razorpay order',
            err
          );
          this.cd.detectChanges();
        }
      });
  }

  isPlanPaymentLoading(plan: UpgradePlan): boolean {
    return this.paymentPlanId === plan.id;
  }

  private openRazorpayCheckout(
    order: RazorpayOrderResponse,
    plan: UpgradePlan
  ): void {
    const checkout = new window.Razorpay({
      key: order.keyId,
      amount: order.amount,
      currency: order.currency || plan.currency || 'INR',
      name: 'LearnOS',
      description: `${plan.name} subscription`,
      order_id: order.orderId,
      handler: response => {
        this.verifyPayment(response);
      },
      modal: {
        ondismiss: () => {
          this.paymentError =
            'Payment window was closed. No payment was completed.';
          this.cd.detectChanges();
        }
      },
      theme: {
        color: '#1E3A8A'
      }
    });

    checkout.on('payment.failed', response => {
      this.paymentError =
        response?.error?.description
        || 'Razorpay payment failed.';
      this.cd.detectChanges();
    });

    checkout.open();
  }

  private verifyPayment(
    response: RazorpayCheckoutResponse
  ): void {
    this.paymentLoading = true;
    this.paymentError = '';
    this.cd.detectChanges();

    this.subscriptionService
      .verifyRazorpayPayment({
        razorpayOrderId: response.razorpay_order_id,
        razorpayPaymentId: response.razorpay_payment_id,
        razorpaySignature: response.razorpay_signature
      })
      .pipe(
        finalize(() => {
          this.paymentLoading = false;
          this.paymentPlanId = null;
          this.cd.detectChanges();
        })
      )
      .subscribe({
        next: subscription => {
          this.subscription = this.normalizeSubscription(
            subscription
          );
          this.authService.setSubscriptionStatus(
            this.subscription.status
          );
          this.paymentError = '';
          this.loadPlanOptions();
          this.cd.detectChanges();
        },
        error: err => {
          this.paymentError =
            err?.error?.message
            || err?.error?.error
            || 'Payment verification failed.';
          console.error(
            'Failed to verify Razorpay payment',
            err
          );
          this.cd.detectChanges();
        }
      });
  }

  get pageHeading(): string {
    if (!this.hasSelectedPlan) {
      return 'Choose a subscription plan';
    }

    return this.isPendingPayment
      ? 'Complete your subscription'
      : 'Subscription active';
  }

  get pageDescription(): string {
    if (!this.hasSelectedPlan) {
      return 'Select one of the available plans to continue with payment.';
    }

    return this.isPendingPayment
      ? 'Choose a plan and complete the payment to unlock the Admin features.'
      : 'You can upgrade to a higher-priced plan at any time.';
  }

  formatAmount(
    amount: number | null | undefined,
    currency = 'INR'
  ): string {
    if (amount == null) {
      return 'Price unavailable';
    }

    return new Intl.NumberFormat(
      'en-IN',
      {
        style: 'currency',
        currency
      }
    ).format(amount);
  }

  calculateUpgradeAmount(plan: UpgradePlan): number {
    if (!this.hasSelectedPlan) {
      return Number(plan.price || 0);
    }

    return Math.max(
      0,
      Number(plan.price || 0)
      - Number(this.subscription?.amount || 0)
    );
  }

  formatPayableAmount(plan: UpgradePlan): string {
    return this.formatAmount(
      this.calculateUpgradeAmount(plan),
      plan.currency || 'INR'
    );
  }

  get planActionLabel(): string {
    return this.hasSelectedPlan
      ? 'Pay upgrade difference'
      : 'Pay and activate plan';
  }

  trackPlan(_index: number, plan: UpgradePlan): string {
    return plan.id;
  }
}
