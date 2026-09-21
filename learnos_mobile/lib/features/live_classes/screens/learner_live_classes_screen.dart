import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/live_class_model.dart';
import '../services/live_class_service.dart';

class LearnerLiveClassesScreen extends StatefulWidget {
  const LearnerLiveClassesScreen({super.key});

  @override
  State<LearnerLiveClassesScreen> createState() =>
      _LearnerLiveClassesScreenState();
}

class _LearnerLiveClassesScreenState
    extends State<LearnerLiveClassesScreen> {
  final LiveClassService _service = LiveClassService();

  bool _loading = true;
  String? _error;
  List<LiveClassModel> _classes = [];

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final classes = await _service.getUpcomingClasses();

      if (!mounted) {
        return;
      }

      setState(() {
        _classes = classes;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _error = 'Unable to load upcoming live classes.';
      });
    }
  }

  Future<void> _joinClass(LiveClassModel liveClass) async {
    try {
      final meetingUrl = await _service.joinClass(liveClass.id);
      final uri = Uri.tryParse(meetingUrl);

      if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) {
        throw Exception('Invalid meeting URL.');
      }

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('Could not open meeting URL.');
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.bgGradient,
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadClasses,
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
                  child: Text(
                    'Live Classes',
                    style: AppTextStyles.h1,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: Text(
                    'Join your upcoming instructor-led sessions.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              if (_loading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                )
              else if (_error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _MessageState(
                    icon: Icons.cloud_off_rounded,
                    message: _error!,
                    actionLabel: 'Try Again',
                    onAction: _loadClasses,
                  ),
                )
              else if (_classes.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _MessageState(
                      icon: Icons.video_camera_front_outlined,
                      message: 'No upcoming live classes.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    sliver: SliverList.separated(
                      itemCount: _classes.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        return _LiveClassCard(
                          liveClass: _classes[index],
                          onJoin: () => _joinClass(_classes[index]),
                        );
                      },
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveClassCard extends StatelessWidget {
  final LiveClassModel liveClass;
  final VoidCallback onJoin;

  const _LiveClassCard({
    required this.liveClass,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final start = liveClass.scheduledAt;
    final date = _formatDate(start);
    final time = _formatTime(start);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.video_camera_front_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      liveClass.title,
                      style: AppTextStyles.h4,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if ((liveClass.courseTitle ?? '').isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        liveClass.courseTitle!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if ((liveClass.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              liveClass.description!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.calendar_today_outlined,
                label: date,
              ),
              _InfoChip(
                icon: Icons.schedule_rounded,
                label: time,
              ),
              _InfoChip(
                icon: Icons.timer_outlined,
                label: '${liveClass.durationMinutes} min',
              ),
            ],
          ),
          if ((liveClass.tutorName ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Tutor: ${liveClass.tutorName}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onJoin,
              icon: const Icon(Icons.login_rounded),
              label: const Text('Join Class'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime dateTime) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour == 0
        ? 12
        : dateTime.hour > 12
        ? dateTime.hour - 12
        : dateTime.hour;

    final minute = dateTime.minute.toString().padLeft(2, '0');
    final suffix = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $suffix';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 54,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}