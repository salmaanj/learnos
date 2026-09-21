import { CommonModule } from '@angular/common';
import { ChangeDetectorRef, Component, OnInit, inject } from '@angular/core';
import { PaymentHistoryService } from './payment-history.service';
import { PaymentHistoryRecord } from './payment-history.model';

@Component({
  selector: 'app-payment-history',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './payment-history.html',
  styleUrl: './payment-history.scss'
})
export class PaymentHistory implements OnInit {
  private readonly paymentHistoryService =
    inject(PaymentHistoryService);

  private readonly cd = inject(ChangeDetectorRef);

  payments: PaymentHistoryRecord[] = [];
  loading = true;
  error = '';

  ngOnInit(): void {
    this.loadHistory();
  }

  loadHistory(): void {
    this.loading = true;
    this.error = '';
    this.cd.detectChanges();

    this.paymentHistoryService.getMyHistory().subscribe({
      next: payments => {
        this.payments = payments;
        this.loading = false;
        this.cd.detectChanges();
      },
      error: () => {
        this.error = 'Unable to load payment history.';
        this.loading = false;
        this.cd.detectChanges();
      }
    });
  }

  getTitle(payment: PaymentHistoryRecord): string {
    return payment.paymentType === 'COURSE_ENROLLMENT'
      ? payment.courseName || 'Course payment'
      : payment.planName
        || payment.planCode
        || 'Company subscription';
  }

  getTypeLabel(payment: PaymentHistoryRecord): string {
    return payment.paymentType === 'COURSE_ENROLLMENT'
      ? 'Course enrollment'
      : 'Company subscription';
  }

  getStatusLabel(status: string | null): string {
    switch (status) {
      case 'ACTIVE':
        return 'Paid';
      case 'PENDING_PAYMENT':
        return 'Payment pending';
      case 'PAYMENT_FAILED':
        return 'Payment failed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status || 'Unknown';
    }
  }
   getPaymentMethodLabel(
      payment: PaymentHistoryRecord
    ): string {
      if (payment.paymentMethod === 'CASH') {
        return 'Cash / manual';
      }

      if (payment.paymentMethod === 'RAZORPAY') {
        return 'Online payment';
      }

      return payment.paymentMethod || '—';
   }
  getStatusClass(status: string | null): string {
    switch (status) {
      case 'ACTIVE':
        return 'status-paid';
      case 'PENDING_PAYMENT':
        return 'status-pending';
      case 'PAYMENT_FAILED':
      case 'CANCELLED':
        return 'status-failed';
      default:
        return 'status-unknown';
    }
  }

  mask(value: string | null): string {
    if (!value) {
      return '—';
    }

    if (value.length <= 8) {
      return value;
    }

    return `${value.slice(0, 4)}…${value.slice(-4)}`;
  }
}