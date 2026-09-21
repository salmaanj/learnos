export type PaymentType =
  | 'COMPANY_SUBSCRIPTION'
  | 'COURSE_ENROLLMENT';

export interface PaymentHistoryRecord {
  id: string;
  paymentType: PaymentType;
  companyId: string | null;
  companyName: string | null;
  courseId: string | null;
  courseName: string | null;
  planId: string | null;
  planCode: string | null;
  planName: string | null;
  amount: number;
  currency: string;
  status: string;
  paymentMethod: string | null;
  razorpayOrderId: string | null;
  razorpayPaymentId: string | null;
  paidAt: string | null;
  createdAt: string | null;
}