import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../courses/models/course_model.dart';
import '../../courses/providers/course_provider.dart';
import '../../courses/services/course_service.dart';

class PaymentScreen extends StatefulWidget {
  final CourseModel course;

  const PaymentScreen({
    super.key,
    required this.course,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _courseService = CourseService();
  final _razorpay = Razorpay();

  bool _loading = true;
  bool _processing = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      _handlePaymentSuccess,
    );
    _razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      _handlePaymentError,
    );
    _razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      _handleExternalWallet,
    );

    _createOrder();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _createOrder() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _processing = true;
        _error = null;
      });
    }

    try {
      final order = await _courseService.createCoursePaymentOrder(
        widget.course.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
      });

      _razorpay.open({
        'key': order.keyId,
        'amount': order.amountInPaise,
        'currency': order.currency,
        'name': 'LearnOS',
        'description': '${widget.course.title} enrollment',
        'order_id': order.orderId,
        'timeout': 300,
        'theme': {
          'color': '#1E3A8A',
        },
      });
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _handlePaymentSuccess(
      PaymentSuccessResponse response,
      ) async {
    final orderId = response.orderId;
    final paymentId = response.paymentId;
    final signature = response.signature;

    if (
    orderId == null
        || orderId.isEmpty
        || paymentId == null
        || paymentId.isEmpty
        || signature == null
        || signature.isEmpty
    ) {
      _showError('Razorpay returned an incomplete payment response.');
      return;
    }

    if (mounted) {
      setState(() {
        _processing = true;
        _error = null;
      });
    }

    try {
      await _courseService.verifyCoursePayment(
        razorpayOrderId: orderId,
        razorpayPaymentId: paymentId,
        razorpaySignature: signature,
      );

      await context.read<CourseProvider>().loadMyCourses();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment successful. You are enrolled in ${widget.course.title}.',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      context.pop(true);
    } catch (e) {
      _showError(
          '${e.toString().replaceFirst('Exception: ', '')} '
              'Course access was not activated.'
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showError(
        response.message ?? 'Payment failed. Please try again.'
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showError(
        'External wallet selected: ${response.walletName ?? 'unknown wallet'}. '
            'Please complete the payment before returning.'
    );
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    setState(() {
      _loading = false;
      _processing = false;
      _error = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.course.title,
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 8),
            Text(
              'Pay securely to enroll in this course.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.course.priceText,
              style: AppTextStyles.h2.copyWith(
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _error!,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _processing ? null : _createOrder,
                child: Text(
                  _loading || _processing
                      ? 'Processing...'
                      : 'Try payment again',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You will be redirected to Razorpay Checkout to complete the payment.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
