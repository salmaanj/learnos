import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_loader.dart';
import '../../certificates/screens/my_certificates_screen.dart';
import '../models/course_model.dart';
import '../providers/course_provider.dart';

class MyLearningScreen extends StatefulWidget {
  const MyLearningScreen({super.key});

  @override
  State<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends State<MyLearningScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().loadMyCourses();
    });
  }

  void _openCertificates() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MyCertificatesScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.bgGradient,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'My Learning',
                      style: AppTextStyles.h2,
                    ),
                  ),
                  IconButton(
                    tooltip: 'My Certificates',
                    onPressed: _openCertificates,
                    icon: const Icon(
                      Icons.workspace_premium_outlined,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<CourseProvider>(
                builder: (context, provider, _) {
                  if (provider.loadingMyCourses) {
                    return const Center(child: AppLoader());
                  }

                  if (provider.myCoursesError != null) {
                    return _ErrorState(
                      message: provider.myCoursesError!,
                      onRetry: () => provider.loadMyCourses(),
                    );
                  }

                  if (provider.myCourses.isEmpty) {
                    return const _EmptyState();
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => provider.loadMyCourses(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      itemCount: provider.myCourses.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final course = provider.myCourses[index];

                        return _CourseCard(
                          course: course,
                          onTap: () => context.push(
                            '/course/${course.id}?from=mylearning',
                          ),
                          onOpenCertificate: course.progress >= 1.0
                              ? _openCertificates
                              : null,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onTap;
  final VoidCallback? onOpenCertificate;

  const _CourseCard({
    required this.course,
    required this.onTap,
    this.onOpenCertificate,
  });

  @override
  Widget build(BuildContext context) {
    final completed = course.progress >= 1.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: completed
                        ? AppColors.success.withOpacity(0.12)
                        : AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      completed
                          ? Icons.check_circle_rounded
                          : Icons.play_circle_rounded,
                      color: completed
                          ? AppColors.success
                          : AppColors.primary,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: AppTextStyles.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _Tag(course.level, AppColors.warning),
                          const SizedBox(width: 6),
                          Flexible(
                            child: _Tag(
                              course.categoryName ?? 'Course',
                              AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            if (completed) ...[
              const SizedBox(height: 13),
              Container(
                width: double.infinity,
                height: 1,
                color: AppColors.divider,
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: onOpenCertificate,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.workspace_premium_rounded,
                        color: AppColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Certificate available',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.success,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.play_lesson_rounded,
            color: AppColors.primary,
            size: 72,
          ),
          const SizedBox(height: 16),
          Text(
            'No enrolled courses yet',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap Explore to browse and enroll in courses.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load courses',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}