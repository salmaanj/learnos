import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/auth/providers/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController     = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showCurrent = false;
  bool _showNew     = false;
  bool _showConfirm = false;
  bool _isLoading   = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await context.read<AuthProvider>().changePassword(
        currentPassword: _currentPasswordController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password changed successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      } else {
        final error = context.read<AuthProvider>().error ??
            'Failed to change password';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      debugPrint('changePassword error: $e'); // ← check terminal
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'), // ← raw error for debugging
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // ── App Bar ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 24, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20),
                      color: AppColors.textPrimary,
                    ),
                    Expanded(
                      child: Text('Change Password',
                          style: AppTextStyles.h3),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),

                        // ── Lock icon banner ───────────────────
                        Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock_reset_rounded,
                              color: AppColors.primary,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            'Set a new password',
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // ── Current Password ───────────────────
                        Text('Current Password',
                            style: AppTextStyles.label
                                .copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        _buildPasswordField(
                          controller: _currentPasswordController,
                          hint: 'Enter current password',
                          show: _showCurrent,
                          onToggle: () =>
                              setState(() => _showCurrent = !_showCurrent),
                          validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                        ),

                        const SizedBox(height: 20),

                        // ── New Password ───────────────────────
                        Text('New Password',
                            style: AppTextStyles.label
                                .copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        _buildPasswordField(
                          controller: _newPasswordController,
                          hint: 'Enter new password',
                          show: _showNew,
                          onToggle: () =>
                              setState(() => _showNew = !_showNew),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (v.length < 8) return 'Minimum 8 characters';
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // ── Confirm Password ───────────────────
                        Text('Confirm New Password',
                            style: AppTextStyles.label
                                .copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          hint: 'Re-enter new password',
                          show: _showConfirm,
                          onToggle: () =>
                              setState(() => _showConfirm = !_showConfirm),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (v != _newPasswordController.text)
                              return 'Passwords do not match';
                            return null;
                          },
                        ),

                        const SizedBox(height: 36),

                        // ── Submit Button ──────────────────────
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                                : Text('Update Password',
                                style: AppTextStyles.button),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool show,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !show,
      validator: validator,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
        AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
        prefixIcon: const Icon(Icons.lock_outline_rounded,
            color: AppColors.textSecondary, size: 20),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            show
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}