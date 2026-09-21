import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppLoader extends StatelessWidget {
  final double size;
  const AppLoader({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) => Center(
        child: SizedBox(
          width: size, height: size,
          child: const CircularProgressIndicator(
            color: AppColors.primary, strokeWidth: 3),
        ),
      );
}

class AppShimmerBox extends StatelessWidget {
  final double width, height;
  final double radius;
  const AppShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: width, height: height,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}
