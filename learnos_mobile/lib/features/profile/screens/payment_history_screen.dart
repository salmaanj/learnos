import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../courses/services/course_service.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final CourseService _courseService = CourseService();

  bool _loading = true;
  String? _error;
  List<PaymentHistoryRecordModel> _payments = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final payments = await _courseService.getMyPaymentHistory();

      if (!mounted) return;

      setState(() {
        _payments = payments;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment History')),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        color: AppColors.primary,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 52,
          ),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: AppTextStyles.body.copyWith(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadHistory,
            child: const Text('Try again'),
          ),
        ],
      );
    }

    if (_payments.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),
          const Icon(
            Icons.receipt_long_outlined,
            color: AppColors.textSecondary,
            size: 56,
          ),
          const SizedBox(height: 16),
          Text(
            'No payment history yet',
            style: AppTextStyles.h3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your payment records will appear here.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _payments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) => _PaymentCard(payment: _payments[index]),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final PaymentHistoryRecordModel payment;

  const _PaymentCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final title = payment.paymentType == 'COURSE_ENROLLMENT'
        ? payment.courseName ?? 'Course payment'
        : payment.planName ?? payment.planCode ?? 'Company subscription';

    final typeLabel = payment.paymentType == 'COURSE_ENROLLMENT'
        ? 'Course enrollment'
        : 'Company subscription';

    final statusColor = _statusColor(payment.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.h4,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              _StatusChip(
                label: _statusLabel(payment.status),
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            typeLabel,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Detail(
                  label: 'Amount',
                  value: _formatAmount(payment.amount, payment.currency),
                ),
              ),
              Expanded(
                child: _Detail(
                  label: 'Payment method',
                  value: _paymentMethod(payment.paymentMethod),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Detail(
                  label: 'Payment date',
                  value: _formatDate(payment.paidAt ?? payment.createdAt),
                ),
              ),
              Expanded(
                child: _Detail(
                  label: 'Reference',
                  value: _maskReference(
                    payment.razorpayPaymentId ?? payment.razorpayOrderId,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount, String currency) {
    final value = amount.toStringAsFixed(2);
    return currency.toUpperCase() == 'INR' ? '₹$value' : '$currency $value';
  }

  String _paymentMethod(String? method) {
    switch (method) {
      case 'CASH':
        return 'Cash / manual';
      case 'RAZORPAY':
        return 'Online payment';
      default:
        return method ?? '—';
    }
  }

  String _maskReference(String? value) {
    if (value == null || value.isEmpty) return '—';
    if (value.length <= 8) return value;
    return '${value.substring(0, 4)}…${value.substring(value.length - 4)}';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';

    final local = date.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return '${months[local.month - 1]} ${local.day}, ${local.year}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return AppColors.success;
      case 'PENDING_PAYMENT':
        return AppColors.warning;
      case 'PAYMENT_FAILED':
      case 'CANCELLED':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _statusLabel(String status) {
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
        return status.isEmpty ? 'Unknown' : status;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  final String label;
  final String value;

  const _Detail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
