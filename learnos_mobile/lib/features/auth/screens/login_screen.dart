import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (success) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Login failed'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Logo + Title
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.school_rounded,
                              color: AppColors.white, size: 40),
                        ),
                        const SizedBox(height: 16),
                        Text('Welcome Back!', style: AppTextStyles.h2),
                        const SizedBox(height: 8),
                        Text('Sign in to continue learning',
                            style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Email
                  AppTextField(
                    label: 'Email Address',
                    hint: 'you@example.com',
                    controller: _emailCtrl,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Email is required';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password
                  AppTextField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _passCtrl,
                    prefixIcon: Icons.lock_outline_rounded,
                    isPassword: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 6) return 'Minimum 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      child: Text('Forgot Password?', style: AppTextStyles.link),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login Button
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) => AppButton(
                      text: 'Sign In',
                      isLoading: auth.status == AuthStatus.loading,
                      onPressed: _login,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Row(children: [
                    const Expanded(child: Divider(color: AppColors.divider)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR', style: AppTextStyles.caption),
                    ),
                    const Expanded(child: Divider(color: AppColors.divider)),
                  ]),
                  const SizedBox(height: 24),

                  // Register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ",
                          style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary)),
                      GestureDetector(
                        onTap: () => context.push('/register'),
                        child: Text('Sign Up', style: AppTextStyles.link.copyWith(
                            fontWeight: FontWeight.w700)),
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
