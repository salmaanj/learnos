import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_loader.dart';
import '../providers/course_provider.dart';
import '../widgets/course_card.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});
  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().loadInitial();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CourseProvider>(
      builder: (context, provider, _) {
        return Container(
          decoration: const BoxDecoration(gradient: AppColors.bgGradient),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Text('Explore Courses', style: AppTextStyles.h2),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    controller: _searchCtrl,
                    style: AppTextStyles.body,
                    onSubmitted: (v) => context.read<CourseProvider>().search(v),
                    decoration: InputDecoration(
                      hintText: 'Search courses...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted),
                        onPressed: () {
                          _searchCtrl.clear();
                          context.read<CourseProvider>().refresh();
                          setState(() {});
                        },
                      )
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(height: 16),
                if (provider.categories.isNotEmpty)
                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: provider.categories.length + 1,
                      itemBuilder: (context, index) {
                        final isAll = index == 0;
                        final cat = isAll ? null : provider.categories[index - 1];
                        final selected = isAll
                            ? provider.selectedCategoryId == null
                            : provider.selectedCategoryId == cat?.id;
                        return GestureDetector(
                          onTap: () => context.read<CourseProvider>().filterByCategory(isAll ? null : cat!.id),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.primary : AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: selected ? AppColors.primary : AppColors.divider),
                            ),
                            child: Text(isAll ? 'All' : cat!.name,
                              style: AppTextStyles.label.copyWith(
                                color: selected ? AppColors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                Expanded(
                  child: provider.loading
                      ? const AppLoader()
                      : provider.error != null
                      ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
                        const SizedBox(height: 12),
                        Text('Failed to load courses', style: AppTextStyles.body),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => context.read<CourseProvider>().loadInitial(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                      : provider.courses.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off_rounded, color: AppColors.textMuted, size: 56),
                        const SizedBox(height: 12),
                        Text('No courses found', style: AppTextStyles.h4),
                        const SizedBox(height: 6),
                        Text('Try a different search or category', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  )
                      : RefreshIndicator(
                    onRefresh: () => context.read<CourseProvider>().refresh(),
                    color: AppColors.primary,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 300) {
                          context.read<CourseProvider>().loadMore();
                        }
                        return false;
                      },
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          mainAxisExtent: 300,
                        ),
                        itemCount: provider.courses.length,
                        itemBuilder: (context, i) => CourseCard(
                          course: provider.courses[i],
                          onTap: () => context.push('/course/${provider.courses[i].id}'),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
