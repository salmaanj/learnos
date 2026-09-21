import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const String _font = 'Poppins';

  static const TextStyle h1 = TextStyle(
    fontFamily: _font, fontSize: 32,
    fontWeight: FontWeight.w700, color: AppColors.textPrimary,
  );
  static const TextStyle h2 = TextStyle(
    fontFamily: _font, fontSize: 24,
    fontWeight: FontWeight.w700, color: AppColors.textPrimary,
  );
  static const TextStyle h3 = TextStyle(
    fontFamily: _font, fontSize: 20,
    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static const TextStyle h4 = TextStyle(
    fontFamily: _font, fontSize: 18,
    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _font, fontSize: 17,
    fontWeight: FontWeight.w400, color: AppColors.textPrimary,
  );
  static const TextStyle body = TextStyle(
    fontFamily: _font, fontSize: 16,
    fontWeight: FontWeight.w400, color: AppColors.textPrimary,
  );
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _font, fontSize: 14,
    fontWeight: FontWeight.w400, color: AppColors.textSecondary,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: _font, fontSize: 15,
    fontWeight: FontWeight.w400, color: AppColors.textMuted,
  );
  static const TextStyle button = TextStyle(
    fontFamily: _font, fontSize: 17,
    fontWeight: FontWeight.w600, color: AppColors.white,
    letterSpacing: 0.5,
  );
  static const TextStyle label = TextStyle(
    fontFamily: _font, fontSize: 15,
    fontWeight: FontWeight.w500, color: AppColors.textSecondary,
  );
  static const TextStyle link = TextStyle(
    fontFamily: _font, fontSize: 16,
    fontWeight: FontWeight.w500, color: AppColors.primary,
  );
}
