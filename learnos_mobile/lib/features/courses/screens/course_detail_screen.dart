import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_loader.dart';
import '../../quizzes/models/quiz_model.dart';
import '../../quizzes/services/quiz_service.dart';
import '../models/course_model.dart';
import '../models/module_model.dart';
import '../providers/course_provider.dart';
import '../repositories/course_offline_repository.dart';
import '../services/course_service.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;
  final bool fromMyLearning;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
    this.fromMyLearning = false,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final _service = CourseService();
  final _offlineRepository = CourseOfflineRepository();
  final _quizService = QuizService();

  CourseModel? _course;
  CourseProgressModel? _courseProgress;

  bool _loading = true;
  bool _enrolling = false;
  bool _enrolled = false;
  bool _progressLoading = false;
  bool _showingOfflineCourse = false;

  String? _error;

  List<QuizModel> _quizzes = [];
  bool _quizzesLoading = false;

  List<ModuleModel> _modules = [];
  bool _contentLoading = true;

  int get _loadedLessonCount {
    return _modules.fold<int>(
      0,
      (total, module) => total + module.lessons.length,
    );
  }

  int get _progressPercent => _courseProgress?.progressPercent ?? 0;

  int get _completedLessons => _courseProgress?.completedLessons ?? 0;

  bool get _assessmentUnlocked =>
      _courseProgress?.assessmentUnlocked ?? false;

  bool get _contentCompleted =>
      _courseProgress?.contentCompleted ?? false;

  bool get _hasProgress => _progressPercent > 0;

  @override
  void initState() {
    super.initState();
    _loadCourse();
  }

  Future<void> _loadCourse() async {
    try {
      final course = await _service.getCourseById(widget.courseId);

      if (!mounted) return;

      setState(() {
        _course = course;
        _enrolled = widget.fromMyLearning;
        _showingOfflineCourse = false;
        _loading = false;
      });

      try {
        final myCourses = await _service.getMyCourses();

        if (!mounted) return;

        final enrolled = myCourses.any(
          (item) => item.id == widget.courseId,
        );

        setState(() {
          _enrolled = enrolled;
        });
      } catch (_) {
        if (!mounted) return;

        setState(() {
          _showingOfflineCourse = true;
          _enrolled = widget.fromMyLearning || _enrolled;
        });
      }

      if (_enrolled) {
        _loadProgress();
        _loadQuizzes();
      }

      _loadCourseContent();
    } catch (_) {
      await _loadCachedCourse();
    }
  }

  Future<void> _loadCachedCourse() async {
    final cachedCourse = await _offlineRepository.getCachedCourseById(
      widget.courseId,
    );

    if (!mounted) return;

    if (cachedCourse == null) {
      setState(() {
        _error = 'This course has not been cached on this device yet.';
        _loading = false;
      });
      return;
    }

    setState(() {
      _course = cachedCourse;
      _enrolled = true;
      _showingOfflineCourse = true;
      _loading = false;
    });

    _loadCourseContent();
  }

  Future<void> _refreshEnrollmentState() async {
    try {
      final myCourses = await _service.getMyCourses();
      final enrolled = myCourses.any(
        (item) => item.id == widget.courseId,
      );

      if (!mounted) return;

      setState(() {
        _enrolled = enrolled;
        _showingOfflineCourse = false;
      });

      if (enrolled) {
        await Future.wait([
          _loadProgress(),
          _loadQuizzes(),
          _loadCourseContent(),
        ]);
      }
    } catch (_) {
      if (!mounted) return;

      final cachedCourse = await _offlineRepository.getCachedCourseById(
        widget.courseId,
      );

      if (!mounted) return;

      if (cachedCourse != null) {
        setState(() {
          _course = cachedCourse;
          _enrolled = true;
          _showingOfflineCourse = true;
        });

        _loadCourseContent();
      }
    }
  }

  Future<void> _loadProgress() async {
    if (!_enrolled) return;

    setState(() {
      _progressLoading = true;
    });

    try {
      final progress = await _service.getCourseProgress(widget.courseId);

      if (!mounted) return;

      setState(() {
        _courseProgress = progress;
        _progressLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _progressLoading = false;
      });
    }
  }

  Future<void> _loadCourseContent() async {
    setState(() {
      _contentLoading = true;
    });

    try {
      final modules = await _service.getCourseContent(widget.courseId);

      if (!mounted) return;

      setState(() {
        _modules = modules;
        _contentLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _contentLoading = false;
      });
    }
  }

  Future<void> _loadQuizzes() async {
    setState(() {
      _quizzesLoading = true;
    });

    try {
      final quizzes = await _quizService.getQuizzesForCourse(
        widget.courseId,
      );

      if (!mounted) return;

      setState(() {
        _quizzes = quizzes;
        _quizzesLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _quizzesLoading = false;
      });
    }
  }

  Future<void> _enroll() async {
    setState(() {
      _enrolling = true;
    });

    try {
      await _service.enrollInCourse(widget.courseId);
      await context.read<CourseProvider>().loadMyCourses();
      await _refreshEnrollmentState();

      if (!mounted) return;

      setState(() {
        _enrolling = false;
        _enrolled = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully enrolled in ${_course?.title}!',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _enrolling = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openPayment() async {
    final completed = await context.push<bool>(
      '/course/${widget.courseId}/payment',
      extra: _course,
    );

    if (!mounted || completed != true) {
      return;
    }

    await _refreshEnrollmentState();
    await context.read<CourseProvider>().loadMyCourses();
  }

  Future<void> _openLearner({
    String? lessonId,
  }) async {
    final baseRoute = '/course/${widget.courseId}/learn'
        '?title=${Uri.encodeComponent(_course?.title ?? '')}';

    final route = lessonId == null || lessonId.isEmpty
        ? baseRoute
        : '$baseRoute&lessonId=${Uri.encodeComponent(lessonId)}';

    await context.push(route);

    if (!mounted) return;

    _loadProgress();
    _loadCourseContent();
  }

  void _openQuiz(QuizModel quiz) {
    if (!_assessmentUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Complete all lessons before starting this quiz.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    context.push('/quiz/${quiz.id}');
  }

  ({String text, Color color, VoidCallback? onPressed}) get _buttonConfig {
    if (!_enrolled) {
      if (_course!.isPaid) {
        return (
          text: 'Pay now to enroll — ${_course!.priceText}',
          color: AppColors.warning,
          onPressed: _enrolling ? null : _openPayment,
        );
      }

      return (
        text: 'Enroll Now — Free',
        color: AppColors.primary,
        onPressed: _enrolling ? null : _enroll,
      );
    }

    if (_progressLoading) {
      return (
        text: 'Loading progress…',
        color: AppColors.primary,
        onPressed: null,
      );
    }

    if (_contentCompleted || _progressPercent >= 100) {
      return (
        text: 'Course Completed ✓',
        color: AppColors.success,
        onPressed: () => _openLearner(),
      );
    }

    if (_hasProgress) {
      return (
        text: 'Continue Course →',
        color: AppColors.success,
        onPressed: () => _openLearner(),
      );
    }

    return (
      text: 'Start Learning →',
      color: AppColors.primary,
      onPressed: () => _openLearner(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: AppLoader(),
      );
    }

    if (_error != null || _course == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _error ?? 'Course not found',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final course = _course!;
    final button = _buttonConfig;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.bgGradient,
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: AppColors.background,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.background.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: AppColors.white,
                    size: 18,
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: course.thumbnailUrl != null
                    ? CachedNetworkImage(
                        imageUrl: course.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            _HeroPlaceholder(),
                      )
                    : _HeroPlaceholder(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_showingOfflineCourse) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.warning.withOpacity(0.45),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.cloud_off_rounded,
                              color: AppColors.warning,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'You are viewing cached course content offline.',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.warning,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    Row(
                      children: [
                        if (course.categoryName != null)
                          Flexible(
                            child: _Chip(
                              course.categoryName!,
                              AppColors.primary,
                            ),
                          ),
                        const SizedBox(width: 8),
                        _Chip(course.level, AppColors.warning),
                        const SizedBox(width: 8),
                        _Chip(
                          course.language ?? 'English',
                          AppColors.info,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      course.title,
                      style: AppTextStyles.h2,
                    ),
                    const SizedBox(height: 8),
                    if (course.shortDescription != null)
                      Text(
                        course.shortDescription!,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          _StatItem(
                            Icons.star_rounded,
                            course.rating.toStringAsFixed(1),
                            'Rating',
                            AppColors.warning,
                          ),
                          _Divider(),
                          _StatItem(
                            Icons.dashboard_rounded,
                            '${_modules.length}',
                            'Modules',
                            AppColors.primary,
                          ),
                          _Divider(),
                          _StatItem(
                            Icons.play_lesson_rounded,
                            _contentLoading
                                ? '${course.totalLessons}'
                                : '$_loadedLessonCount',
                            'Lessons',
                            AppColors.success,
                          ),
                          _Divider(),
                          _StatItem(
                            Icons.timer_rounded,
                            course.durationText,
                            'Duration',
                            AppColors.info,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_enrolled) ...[
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your Progress',
                            style: AppTextStyles.h4,
                          ),
                          Text(
                            _progressLoading
                                ? 'Loading…'
                                : '$_progressPercent% complete',
                            style: AppTextStyles.label.copyWith(
                              color: _contentCompleted
                                  ? AppColors.success
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: _progressPercent / 100,
                          minHeight: 8,
                          backgroundColor: AppColors.divider,
                          color: _contentCompleted
                              ? AppColors.success
                              : AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _progressLoading
                            ? 'Syncing your lesson progress…'
                            : '$_completedLessons of ${_loadedLessonCount > 0 ? _loadedLessonCount : course.totalLessons} lessons completed',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (_contentCompleted)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '✓ Course content completed. Quiz unlocked.',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                    if (_enrolled &&
                        (_quizzesLoading || _quizzes.isNotEmpty)) ...[
                      Text(
                        'Quizzes',
                        style: AppTextStyles.h4,
                      ),
                      const SizedBox(height: 12),
                      if (_quizzesLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      else
                        ..._quizzes.map(
                          (quiz) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _assessmentUnlocked
                                      ? Icons.quiz_rounded
                                      : Icons.lock_outline_rounded,
                                  color: _assessmentUnlocked
                                      ? AppColors.primary
                                      : AppColors.warning,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        quiz.title,
                                        style: AppTextStyles.bodyLarge,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${quiz.durationMinutes} min · ${quiz.totalQuestions} questions · Pass ${quiz.passPercent}%',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      if (!_assessmentUnlocked)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: Text(
                                            'Complete all lessons to unlock this quiz.',
                                            style: AppTextStyles.caption.copyWith(
                                              color: AppColors.warning,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _openQuiz(quiz),
                                  child: Text(
                                    _assessmentUnlocked
                                        ? 'Start'
                                        : 'Locked',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                    if (course.learningOutcomes.isNotEmpty) ...[
                      Text(
                        "What You'll Learn",
                        style: AppTextStyles.h4,
                      ),
                      const SizedBox(height: 12),
                      ...course.learningOutcomes.map(
                        (outcome) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  outcome,
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_contentLoading || _modules.isNotEmpty) ...[
                      Text(
                        'Course Content',
                        style: AppTextStyles.h4,
                      ),
                      const SizedBox(height: 12),
                      if (_contentLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      else
                        ..._modules.asMap().entries.map(
                          (entry) {
                            final moduleIndex = entry.key;
                            final module = entry.value;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  dividerColor: Colors.transparent,
                                ),
                                child: ExpansionTile(
                                  initiallyExpanded: moduleIndex == 0,
                                  title: Text(
                                    'Module ${moduleIndex + 1}: ${module.title}',
                                    style: AppTextStyles.bodyLarge,
                                  ),
                                  subtitle: Text(
                                    '${module.lessons.length} lesson${module.lessons.length == 1 ? '' : 's'}',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  children: module.lessons.map(
                                    (lesson) {
                                      final unlocked =
                                          _enrolled || lesson.isPreview;

                                      return ListTile(
                                        dense: true,
                                        onTap: () {
                                          if (unlocked) {
                                            _openLearner(
                                              lessonId: lesson.id,
                                            );
                                            return;
                                          }

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Enroll in this course to unlock this lesson.',
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        },
                                        leading: Icon(
                                          lesson.isCompleted
                                              ? Icons.check_circle_rounded
                                              : unlocked
                                                  ? Icons
                                                      .play_circle_outline_rounded
                                                  : Icons
                                                      .lock_outline_rounded,
                                          color: lesson.isCompleted
                                              ? AppColors.success
                                              : unlocked
                                                  ? AppColors.primary
                                                  : AppColors.textMuted,
                                          size: 20,
                                        ),
                                        title: Text(
                                          lesson.title,
                                          style: AppTextStyles.body,
                                        ),
                                        trailing:
                                            lesson.durationText.isNotEmpty
                                                ? Text(
                                                    lesson.durationText,
                                                    style: AppTextStyles.caption
                                                        .copyWith(
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  )
                                                : null,
                                      );
                                    },
                                  ).toList(),
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 16),
                    ],
                    if (course.tags.isNotEmpty) ...[
                      Text(
                        'Topics Covered',
                        style: AppTextStyles.h4,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: course.tags
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.divider,
                                  ),
                                ),
                                child: Text(
                                  tag,
                                  style: AppTextStyles.caption,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (course.description != null) ...[
                      Text(
                        'About This Course',
                        style: AppTextStyles.h4,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        course.description!,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.divider,
            ),
          ),
        ),
        child: Row(
          children: [
            if (!_enrolled) ...[
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price',
                    style: AppTextStyles.caption,
                  ),
                  Text(
                    course.priceText,
                    style: AppTextStyles.h3.copyWith(
                      color: course.isPaid
                          ? AppColors.warning
                          : AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
            ],
            Expanded(
              child: AppButton(
                text: button.text,
                isLoading: _enrolling || _progressLoading,
                onPressed: button.onPressed,
                color: button.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Icon(
          Icons.play_circle_rounded,
          color: AppColors.primary,
          size: 72,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip(
    this.label,
    this.color,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem(
    this.icon,
    this.value,
    this.label,
    this.color,
  );

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            value.isEmpty ? '—' : value,
            style: AppTextStyles.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: 1,
      color: AppColors.divider,
    );
  }
}