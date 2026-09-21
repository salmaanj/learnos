import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _faqs = const [
    {
      'question': 'How do I enroll in a course?',
      'answer':
      'Go to the Explore tab, find a course you like and tap "Enroll". Free courses are instantly accessible.',
    },
    {
      'question': 'Can I download courses for offline use?',
      'answer':
      'Offline downloads are coming soon. Currently all content requires an internet connection.',
    },
    {
      'question': 'How do I get my certificate?',
      'answer':
      'Complete all lessons and pass the final assessment. Your certificate will appear in your Profile under Certificates.',
    },
    {
      'question': 'How do I reset my password?',
      'answer':
      'Go to Profile → Change Password, or use the "Forgot Password" option on the login screen.',
    },
    {
      'question': 'Who do I contact for billing issues?',
      'answer':
      'Email us at billing@yourlms.com and our team will respond within 24 hours.',
    },
  ];

  int? _expandedIndex;

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
                      child:
                      Text('Help & Support', style: AppTextStyles.h3),
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

                      // ── Contact Cards ─────────────────────────
                      Row(
                        children: [
                          _ContactCard(
                            icon: Icons.email_outlined,
                            label: 'Email Us',
                            value: 'support@yourlms.com',
                            color: AppColors.primary,
                            onTap: () {
                              // TODO: launch_url mailto
                            },
                          ),
                          const SizedBox(width: 12),
                          _ContactCard(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: 'Live Chat',
                            value: 'Mon–Fri, 9am–6pm',
                            color: AppColors.success,
                            onTap: () {
                              // TODO: open chat
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // ── FAQ ───────────────────────────────────
                      Text('Frequently Asked Questions',
                          style: AppTextStyles.h3),
                      const SizedBox(height: 16),

                      ...List.generate(_faqs.length, (index) {
                        final faq = _faqs[index];
                        final isExpanded = _expandedIndex == index;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isExpanded
                                  ? AppColors.primary.withOpacity(0.4)
                                  : AppColors.divider,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: ExpansionTile(
                              onExpansionChanged: (expanded) => setState(
                                      () => _expandedIndex =
                                  expanded ? index : null),
                              initiallyExpanded: isExpanded,
                              tilePadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              childrenPadding: const EdgeInsets.fromLTRB(
                                  16, 0, 16, 16),
                              iconColor: AppColors.primary,
                              collapsedIconColor: AppColors.textSecondary,
                              title: Text(
                                faq['question']!,
                                style: AppTextStyles.body,
                              ),
                              children: [
                                Text(
                                  faq['answer']!,
                                  style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                      height: 1.6),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 32),

                      // ── Still need help ───────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.support_agent_rounded,
                                color: AppColors.primary, size: 36),
                            const SizedBox(height: 10),
                            Text('Still need help?',
                                style: AppTextStyles.h4),
                            const SizedBox(height: 6),
                            Text(
                              'Our support team is happy to assist you with any issue.',
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.5),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // TODO: launch_url mailto
                                },
                                icon: const Icon(Icons.send_rounded,
                                    size: 18),
                                label: const Text('Contact Support'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
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

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 10),
              Text(label,
                  style: AppTextStyles.label.copyWith(color: color)),
              const SizedBox(height: 2),
              Text(value,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}