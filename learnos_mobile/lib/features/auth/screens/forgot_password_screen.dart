import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.forgotPassword(_emailCtrl.text.trim());
    if (!mounted) return;
    if (success) context.push('/verify-otp');
  }

  @override
  Widget build(BuildContext context) {
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.lock_reset_rounded,
                        color: AppColors.primary, size: 40),
                  ),
                  const SizedBox(height: 24),
                  Text('Forgot Password?', style: AppTextStyles.h2),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your registered email and we will send you an OTP to reset your password.',
                    style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary, height: 1.6),
                  ),
                  const SizedBox(height: 40),
                  AppTextField(
                    label: 'Email Address',
                    hint: 'you@example.com',
                    controller: _emailCtrl,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Email is required';
                      if (!v.contains('@')) return 'Enter valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  Consumer<AuthProvider>(
                    builder: (ctx, auth, _) => AppButton(
                      text: 'Send OTP',
                      isLoading: auth.status == AuthStatus.loading,
                      onPressed: _submit,
                      icon: Icons.send_rounded,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () => context.pop(),
                      child: Text('Back to Login', style: AppTextStyles.link),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
