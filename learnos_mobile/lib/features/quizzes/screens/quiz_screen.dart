import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../providers/quiz_provider.dart';

class QuizScreen extends StatefulWidget {
  final String quizId;

  const QuizScreen({
    super.key,
    required this.quizId,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().loadQuiz(widget.quizId);
    });
  }

  bool _isAssessmentLocked(String? error) {
    if (error == null || error.trim().isEmpty) {
      return false;
    }

    final normalized = error.toLowerCase();

    return normalized.contains('complete all course lessons') ||
        normalized.contains('complete all lessons') ||
        normalized.contains('assessment') &&
            normalized.contains('complete') ||
        normalized.contains('assessment is unavailable');
  }

  String _lockedMessage(String? error) {
    final normalized = (error ?? '').toLowerCase();

    if (normalized.contains('no published lessons')) {
      return 'This assessment is not available yet because the course has no published lessons.';
    }

    return 'Complete all course lessons before starting this quiz.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: Consumer<QuizProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (provider.error != null && provider.quiz == null) {
            if (_isAssessmentLocked(provider.error)) {
              return _AssessmentLockedView(
                message: _lockedMessage(provider.error),
                onBack: () => Navigator.of(context).pop(),
                onRetry: () => provider.loadQuiz(widget.quizId),
              );
            }

            return _QuizLoadErrorView(
              error: provider.error!,
              onBack: () => Navigator.of(context).pop(),
              onRetry: () => provider.loadQuiz(widget.quizId),
            );
          }

          if (provider.result != null) {
            return _ResultView(result: provider.result!);
          }

          if (provider.quiz == null || provider.quiz!.questions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'This quiz has no questions yet.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return _QuestionView(provider: provider);
        },
      ),
    );
  }
}

class _AssessmentLockedView extends StatelessWidget {
  final String message;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  const _AssessmentLockedView({
    required this.message,
    required this.onBack,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.warning,
                  size: 38,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Quiz Locked',
                style: AppTextStyles.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Return to the course, complete every lesson, then try again.',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'Back to Course',
                  onPressed: onBack,
                ),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Check again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizLoadErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  const _QuizLoadErrorView({
    required this.error,
    required this.onBack,
    required this.onRetry,
  });

  String get _displayError {
    final cleaned = error
        .replaceAll('Exception: ', '')
        .replaceAll('DioException [bad response]: ', '')
        .trim();

    if (cleaned.isEmpty) {
      return 'Could not load this quiz. Please try again.';
    }

    if (cleaned.contains('status code of 400')) {
      return 'Could not open this quiz. Please return to the course and try again.';
    }

    return cleaned;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
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
                'Could Not Load Quiz',
                style: AppTextStyles.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _displayError,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'Try Again',
                  onPressed: onRetry,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onBack,
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  final QuizProvider provider;

  const _QuestionView({
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final quiz = provider.quiz!;
    final question = provider.currentQuestion!;
    final selected = provider.answers[question.id];
    final progress = (provider.currentIndex + 1) / quiz.questions.length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.surfaceLight,
                valueColor: const AlwaysStoppedAnimation(
                  AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Question ${provider.currentIndex + 1} of ${quiz.questions.length}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              question.text,
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: question.options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final option = question.options[index];
                  final isSelected = selected == option.id;

                  return GestureDetector(
                    onTap: () {
                      provider.selectAnswer(
                        question.id,
                        option.id,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primarySurface.withOpacity(0.15)
                            : AppColors.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textMuted,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option.text,
                              style: AppTextStyles.body,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (provider.currentIndex > 0)
                  Expanded(
                    child: AppButton(
                      text: 'Back',
                      isOutlined: true,
                      onPressed: provider.previousQuestion,
                    ),
                  ),
                if (provider.currentIndex > 0) const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: provider.isLastQuestion ? 'Submit' : 'Next',
                    isLoading: provider.submitting,
                    onPressed: selected == null
                        ? null
                        : () {
                      if (provider.isLastQuestion) {
                        provider.submit();
                      } else {
                        provider.nextQuestion();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final dynamic result;

  const _ResultView({
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final passed = result.passed as bool;
    final color = passed ? AppColors.success : AppColors.error;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              passed
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              color: color,
              size: 72,
            ),
            const SizedBox(height: 16),
            Text(
              passed ? 'You passed!' : 'Not quite there',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 8),
            Text(
              '${result.scorePercent}% · '
                  '${result.correctCount}/${result.totalQuestions} correct',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Done',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}