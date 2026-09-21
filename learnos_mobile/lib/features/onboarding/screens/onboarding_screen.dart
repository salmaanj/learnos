import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final _pages = [
    _OnboardingData(
      icon: Icons.play_circle_filled_rounded,
      color: AppColors.primary,
      title: 'Learn At Your Own Pace',
      subtitle: 'Access hundreds of courses with video, audio, PDF and interactive content — anytime, anywhere.',
    ),
    _OnboardingData(
      icon: Icons.emoji_events_rounded,
      color: Color(0xFFDA7101),
      title: 'Earn Certificates',
      subtitle: 'Complete courses and assessments to earn verified certificates recognized by top companies.',
    ),
    _OnboardingData(
      icon: Icons.groups_rounded,
      color: Color(0xFF6B4DBA),
      title: 'Live & Interactive',
      subtitle: 'Join live classes, interact with instructors and collaborate with learners worldwide.',
    ),
  ];

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text('Skip', style: AppTextStyles.link),
                ),
              ),

              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 140, height: 140,
                            decoration: BoxDecoration(
                              color: page.color.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(page.icon, size: 72, color: page.color),
                          ),
                          const SizedBox(height: 48),
                          Text(page.title,
                              style: AppTextStyles.h2,
                              textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          Text(page.subtitle,
                              style: AppTextStyles.body.copyWith(
                                  color: AppColors.textSecondary, height: 1.6),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i ? AppColors.primary : AppColors.textMuted,
                    borderRadius: BorderRadius.circular(4),
                  ),
                )),
              ),
              const SizedBox(height: 40),

              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    AppButton(
                      text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                      onPressed: () {
                        if (_currentPage == _pages.length - 1) {
                          context.go('/login');
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    if (_currentPage == _pages.length - 1)
                      AppButton(
                        text: 'Sign In',
                        isOutlined: true,
                        onPressed: () => context.go('/login'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  const _OnboardingData({
    required this.icon, required this.color,
    required this.title, required this.subtitle,
  });
}
