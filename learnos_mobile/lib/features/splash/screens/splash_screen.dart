import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/auth/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnim  = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)));
    _scaleAnim = Tween<double>(begin: 0.7, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)));
    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    final isLoggedIn = await AuthService().isLoggedIn();
    if (!mounted) return;
    if (isLoggedIn) {
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo Container
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 30, spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.school_rounded,
                        color: AppColors.white, size: 52),
                  ),
                  const SizedBox(height: 24),
                  Text('LearnOS', style: AppTextStyles.h1.copyWith(
                      fontSize: 36, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Text('Learn. Grow. Achieve.',
                      style: AppTextStyles.bodySmall.copyWith(
                          letterSpacing: 2, color: AppColors.textMuted)),
                  const SizedBox(height: 60),
                  const SizedBox(
                    width: 28, height: 28,
                    child: CircularProgressIndicator(
                      color: AppColors.primary, strokeWidth: 2.5),
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
