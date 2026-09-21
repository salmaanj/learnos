import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/course_model.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback? onTap;

  const CourseCard({super.key, required this.course, this.onTap});

  Color _levelColor() {
    switch (course.level) {
      case 'BEGINNER':     return AppColors.success;
      case 'INTERMEDIATE': return AppColors.warning;
      case 'ADVANCED':     return AppColors.error;
      default:             return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: course.thumbnailUrl != null
                  ? CachedNetworkImage(
                imageUrl: course.thumbnailUrl!,
                height: 110, width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => _ThumbnailPlaceholder(title: course.title),
                errorWidget: (_, __, ___) => _ThumbnailPlaceholder(title: course.title),
              )
                  : _ThumbnailPlaceholder(title: course.title),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip
                  if (course.categoryName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(course.categoryName!,
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  const SizedBox(height: 6),

                  // Title
                  Text(course.title,
                      style: AppTextStyles.label.copyWith(
                          color: AppColors.textPrimary, height: 1.3),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),

                  // Rating row
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFFFB800), size: 14),
                      const SizedBox(width: 3),
                      Text(course.rating.toStringAsFixed(1),
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _levelColor().withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          course.level.substring(0, 3),
                          style: AppTextStyles.caption.copyWith(
                              color: _levelColor()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Price
                  Text(course.priceText,
                      style: AppTextStyles.label.copyWith(
                          color: course.isPaid
                              ? AppColors.warning
                              : AppColors.success,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  final String title;
  const _ThumbnailPlaceholder({required this.title});

  // Deterministic color per course, so the same course always gets the
  // same "default image" color instead of it changing on every rebuild.
  Color _colorFor(String text) {
    const palette = [
      Color(0xFF2563EB), Color(0xFF16A34A), Color(0xFFEA580C),
      Color(0xFFDB2777), Color(0xFF7C3AED), Color(0xFF0EA5E9),
      Color(0xFFDC2626), Color(0xFF65A30D),
    ];
    final hash = text.isEmpty ? 0 : text.codeUnitAt(0) + text.length;
    return palette[hash % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(title);
    final initial = title.trim().isNotEmpty ? title.trim()[0].toUpperCase() : 'C';
    return Container(
      height: 110,
      width: double.infinity,
      color: color.withOpacity(0.15),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: color,
            fontSize: 40,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
