import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;
  final double height;
  final Color? color;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
    this.height = 54,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? AppColors.primary;
    final child = isLoading
        ? const SizedBox(
            width: 22, height: 22,
            child: CircularProgressIndicator(
              color: AppColors.white, strokeWidth: 2.5))
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: isOutlined ? bgColor : AppColors.white),
                const SizedBox(width: 8),
              ],
              Text(text,
                  style: AppTextStyles.button.copyWith(
                      color: isOutlined ? bgColor : AppColors.white)),
            ],
          );

    if (isOutlined) {
      return SizedBox(
        width: width ?? double.infinity, height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: bgColor, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity, height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: child,
      ),
    );
  }
}
