import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../providers/auth_provider.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpCtrl = TextEditingController();
  int _resendSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          _canResend = true;
        }
      });
      return _resendSeconds > 0;
    });
  }

  Future<void> _verify() async {
    if (_otpCtrl.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter 6-digit OTP')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();

    // ← Forgot password flow: go to reset password screen
    if (auth.isForgotPasswordFlow) {
      context.go('/reset-password', extra: {
        'email': auth.pendingEmail ?? '',
        'otp': _otpCtrl.text,
      });
      return;
    }

    // Normal registration flow
    final success = await auth.verifyOtp(_otpCtrl.text);
    if (!mounted) return;
    if (success) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Invalid OTP'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  void dispose() { _otpCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final defaultTheme = PinTheme(
      width: 56, height: 60,
      textStyle: AppTextStyles.h3.copyWith(fontSize: 22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.mark_email_read_rounded,
                      color: AppColors.primary, size: 42),
                ),
                const SizedBox(height: 24),
                Text('Verify Your Email', style: AppTextStyles.h2),
                const SizedBox(height: 12),
                Text(
                  'We sent a 6-digit OTP to\n${auth.pendingEmail ?? 'your email'}',
                  style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary, height: 1.6),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Pinput(
                  controller: _otpCtrl,
                  length: 6,
                  defaultPinTheme: defaultTheme,
                  focusedPinTheme: defaultTheme.copyWith(
                    decoration: defaultTheme.decoration!.copyWith(
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                  ),
                  submittedPinTheme: defaultTheme.copyWith(
                    decoration: defaultTheme.decoration!.copyWith(
                      color: AppColors.primarySurface,
                      border: Border.all(color: AppColors.primary),
                    ),
                  ),
                  onCompleted: (_) => _verify(),
                ),
                const SizedBox(height: 40),
                AppButton(
                  text: 'Verify Email',
                  isLoading: auth.status == AuthStatus.loading,
                  onPressed: _verify,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Didn't receive the OTP? ",
                        style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary)),
                    _canResend
                        ? GestureDetector(
                      onTap: () async {
                        // ← Fixed: use existing provider, not a new instance
                        final auth = context.read<AuthProvider>();
                        await auth.forgotPassword(auth.pendingEmail ?? '');
                        setState(() {
                          _resendSeconds = 60;
                          _canResend = false;
                        });
                        _startTimer();
                      },
                      child: Text('Resend', style: AppTextStyles.link),
                    )
                        : Text('Resend in ${_resendSeconds}s',
                        style: AppTextStyles.body.copyWith(
                            color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}