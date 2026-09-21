import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _courseUpdates    = true;
  bool _newCourses       = true;
  bool _reminders        = false;
  bool _promotions       = false;
  bool _achievements     = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // ── App Bar ───────────────────────────────────────
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
                      child: Text('Notifications', style: AppTextStyles.h3),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // ── Banner ────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.notifications_active_rounded,
                                color: AppColors.primary, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Manage what notifications you receive from the app.',
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Learning ──────────────────────────────
                      Text('Learning',
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.textMuted)),
                      const SizedBox(height: 12),
                      _NotifTile(
                        icon: Icons.update_rounded,
                        title: 'Course Updates',
                        subtitle: 'When a course you enrolled in is updated',
                        value: _courseUpdates,
                        onChanged: (v) =>
                            setState(() => _courseUpdates = v),
                      ),
                      _NotifTile(
                        icon: Icons.auto_stories_rounded,
                        title: 'New Courses',
                        subtitle: 'When new courses are added',
                        value: _newCourses,
                        onChanged: (v) =>
                            setState(() => _newCourses = v),
                      ),
                      _NotifTile(
                        icon: Icons.alarm_rounded,
                        title: 'Study Reminders',
                        subtitle: 'Daily reminders to continue learning',
                        value: _reminders,
                        onChanged: (v) =>
                            setState(() => _reminders = v),
                      ),

                      const SizedBox(height: 28),

                      // ── General ───────────────────────────────
                      Text('General',
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.textMuted)),
                      const SizedBox(height: 12),
                      _NotifTile(
                        icon: Icons.emoji_events_rounded,
                        title: 'Achievements',
                        subtitle: 'Certificates and completion badges',
                        value: _achievements,
                        onChanged: (v) =>
                            setState(() => _achievements = v),
                      ),
                      _NotifTile(
                        icon: Icons.local_offer_rounded,
                        title: 'Promotions',
                        subtitle: 'Offers, discounts and announcements',
                        value: _promotions,
                        onChanged: (v) =>
                            setState(() => _promotions = v),
                      ),

                      const SizedBox(height: 36),

                      // ── Save Button ───────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: persist preferences to API / local storage
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    'Notification preferences saved!'),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding:
                            const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Text('Save Preferences',
                              style: AppTextStyles.button),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title, style: AppTextStyles.body),
        subtitle: Text(subtitle,
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textMuted)),
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}