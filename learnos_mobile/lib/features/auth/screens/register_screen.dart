import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _firstCtrl = TextEditingController();
  final TextEditingController _lastCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();
  final TextEditingController _companyCodeCtrl = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _companyCodeCtrl.dispose();

    super.dispose();
  }

  Future<void> _register() async {
    if (_submitting || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _submitting = true;
    });

    final auth = context.read<AuthProvider>();

    final success = await auth.register(
      firstName: _firstCtrl.text.trim(),
      lastName: _lastCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      phone: _phoneCtrl.text.trim(),
      companyCode: _companyCodeCtrl.text.trim(),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _submitting = false;
    });

    if (success) {
      await _showRegistrationSuccessDialog();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          auth.error ?? 'Unable to create the learner account.',
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _showRegistrationSuccessDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 44,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Learner Account Created!',
                style: AppTextStyles.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Your journey begins now. Sign in with your email and password to start learning.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.go('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Go to Login'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = _submitting ||
        context.watch<AuthProvider>().status == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: loading ? null : () => context.pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.bgGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Join LearnOS',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Create your learner account and start learning today.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'First Name',
                          hint: 'John',
                          controller: _firstCtrl,
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }

                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppTextField(
                          label: 'Last Name',
                          hint: 'Doe',
                          controller: _lastCtrl,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }

                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: 'Email Address',
                    hint: 'you@example.com',
                    controller: _emailCtrl,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final email = value?.trim() ?? '';

                      if (email.isEmpty) {
                        return 'Email is required';
                      }

                      if (!email.contains('@')) {
                        return 'Enter a valid email';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: 'Phone Number',
                    hint: '+91 9999999999',
                    controller: _phoneCtrl,
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: 'Company Code (optional)',
                    hint: 'e.g. HDFC2024',
                    controller: _companyCodeCtrl,
                    prefixIcon: Icons.apartment_outlined,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ask your company admin for this code so your account '
                        'links to your organization. Leave it blank to sign up '
                        'as an independent learner.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: 'Password',
                    hint: 'Min. 8 characters',
                    controller: _passCtrl,
                    prefixIcon: Icons.lock_outline_rounded,
                    isPassword: true,
                    validator: (value) {
                      final password = value ?? '';

                      if (password.isEmpty) {
                        return 'Password is required';
                      }

                      if (password.length < 8) {
                        return 'Minimum 8 characters';
                      }

                      if (!password.contains(RegExp(r'[A-Z]'))) {
                        return 'Need an uppercase letter';
                      }

                      if (!password.contains(RegExp(r'[0-9]'))) {
                        return 'Need a number';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: 'Confirm Password',
                    hint: 'Re-enter password',
                    controller: _confirmCtrl,
                    prefixIcon: Icons.lock_outline_rounded,
                    isPassword: true,
                    validator: (value) {
                      if (value != _passCtrl.text) {
                        return 'Passwords do not match';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  AppButton(
                    text: 'Create Account',
                    isLoading: loading,
                    onPressed: loading ? null : _register,
                    icon: Icons.arrow_forward_rounded,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: loading ? null : () => context.pop(),
                        child: Text(
                          'Sign In',
                          style: AppTextStyles.link.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}