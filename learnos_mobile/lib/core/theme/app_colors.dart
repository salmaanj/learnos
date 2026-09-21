import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand
  static const Color primary        = Color(0xFF01696F);
  static const Color primaryLight   = Color(0xFF01868D);
  static const Color primaryDark    = Color(0xFF014D52);
  static const Color primarySurface = Color(0xFFE0F0F1);

  // Background (dark theme from approved screens)
  static const Color background     = Color(0xFF1A202C);
  static const Color surface        = Color(0xFF2D3748);
  static const Color surfaceLight   = Color(0xFF3A4A5C);
  static const Color cardBg         = Color(0xFF243040);

  // Text
  static const Color textPrimary    = Color(0xFFFFFFFF);
  static const Color textSecondary  = Color(0xFFB0BEC5);
  static const Color textMuted      = Color(0xFF718096);
  static const Color textDark       = Color(0xFF1A202C);

  // Status
  static const Color success        = Color(0xFF437A22);
  static const Color successLight   = Color(0xFFEAF4E2);
  static const Color warning        = Color(0xFFDA7101);
  static const Color warningLight   = Color(0xFFFFF8E6);
  static const Color error          = Color(0xFFC53030);
  static const Color errorLight     = Color(0xFFFFF0F0);
  static const Color info           = Color(0xFF006494);
  static const Color infoLight      = Color(0xFFE6F2F8);

  // Category Colors
  static const Color catIT          = Color(0xFF006494);
  static const Color catFinance     = Color(0xFF437A22);
  static const Color catSoftSkills  = Color(0xFFDA7101);
  static const Color catHealthcare  = Color(0xFFC53030);
  static const Color catSales       = Color(0xFF6B4DBA);
  static const Color catCompliance  = Color(0xFF01696F);

  // Misc
  static const Color divider        = Color(0xFF2D3748);
  static const Color shimmerBase    = Color(0xFF2D3748);
  static const Color shimmerHighlight = Color(0xFF3A4A5C);
  static const Color white          = Color(0xFFFFFFFF);
  static const Color black          = Color(0xFF000000);
  static const Color transparent    = Colors.transparent;

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF01696F), Color(0xFF014D52)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF1A202C), Color(0xFF243040)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
