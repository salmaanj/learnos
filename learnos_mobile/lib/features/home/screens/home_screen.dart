import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/auth/models/user_model.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/certificates/screens/my_certificates_screen.dart';
import '../../../features/certificates/services/certificate_service.dart';
import '../../../features/courses/models/course_model.dart';
import '../../../features/courses/screens/course_list_screen.dart';
import '../../../features/courses/services/course_service.dart';
import '../../../features/profile/screens/change_password_screen.dart';
import '../../../features/profile/screens/edit_profile_screen.dart';
import '../../../features/profile/screens/help_support_screen.dart';
import '../../../features/profile/screens/notifications_screen.dart';
import '../../../features/profile/screens/payment_history_screen.dart';
import '../../courses/screens/my_learning_screen.dart';
import '../../live_classes/screens/learner_live_classes_screen.dart';

String _friendlyRole(String? rawRole) {
  switch ((rawRole ?? '').toUpperCase()) {
    case 'LEARNER':
      return 'Learner';
    case 'TUTOR':
      return 'Tutor';
    case 'ADMIN':
      return 'Admin';
    case 'USER':
      return 'Learner';
    default:
      return 'Learner';
  }
}

Color _levelColor(String? level) {
  switch ((level ?? '').toUpperCase()) {
    case 'BEGINNER':
      return const Color(0xFF65A30D);
    case 'INTERMEDIATE':
      return const Color(0xFFEA580C);
    case 'ADVANCED':
      return const Color(0xFF7C3AED);
    default:
      return AppColors.textSecondary;
  }
}

String _shortLevel(String? level) {
  switch ((level ?? '').toUpperCase()) {
    case 'BEGINNER':
      return 'BEG';
    case 'INTERMEDIATE':
      return 'INT';
    case 'ADVANCED':
      return 'ADV';
    default:
      return (level ?? '').toUpperCase();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  void _goToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  void initState() {
    super.initState();
    _screens = [
      _DashboardTab(onNavigateToTab: _goToTab),
      const CourseListScreen(),
      const MyLearningScreen(),
      const LearnerLiveClassesScreen(),
      const _ProfileTab(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _goToTab,
            backgroundColor: AppColors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard_rounded), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore_rounded), label: 'Explore'),
              BottomNavigationBarItem(icon: Icon(Icons.play_circle_outline_rounded), activeIcon: Icon(Icons.play_circle_rounded), label: 'My Learning'),
              BottomNavigationBarItem(icon: Icon(Icons.video_camera_front_outlined), activeIcon: Icon(Icons.video_camera_front_rounded), label: 'Live Classes'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardTab extends StatefulWidget {
  final void Function(int) onNavigateToTab;
  const _DashboardTab({required this.onNavigateToTab});

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  final CourseService _courseService = CourseService();
  final CertificateService _certificateService = CertificateService();
  bool _loading = true;
  int _enrolledCount = 0;
  int _completedCount = 0;
  int _certificateCount = 0;
  List<CourseModel> _featuredCourses = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    List<CourseModel> myCourses = [];
    List<CourseModel> featured = [];
    int certificateCount = 0;

    try {
      myCourses = await _courseService.getMyCourses();
    } catch (_) {}
    try {
      featured = await _courseService.getFeaturedCourses();
    } catch (_) {}
    try {
      final certificates = await _certificateService.getMyCertificates();
      certificateCount = certificates.where((certificate) => certificate.isIssued).length;
    } catch (_) {
      certificateCount = 0;
    }

    if (!mounted) return;

    setState(() {
      _enrolledCount = myCourses.length;
      _completedCount = myCourses.where((course) => course.progress >= 1.0).length;
      _certificateCount = certificateCount;
      _featuredCourses = featured;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(24, 16, 24, 0), child: _MobileBrandRow(user: user))),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hi', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
                          const SizedBox(height: 4),
                          Text(user?.firstName ?? 'Learner', style: AppTextStyles.h2),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary, size: 22),
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary,
                      child: Text(_firstLetter(user?.firstName, 'L'), style: AppTextStyles.h4.copyWith(color: AppColors.white)),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  children: [
                    _StatCard(icon: Icons.play_lesson_rounded, label: 'Enrolled', value: _loading ? '—' : '$_enrolledCount', color: AppColors.primary),
                    const SizedBox(width: 12),
                    _StatCard(icon: Icons.check_circle_rounded, label: 'Completed', value: _loading ? '—' : '$_completedCount', color: AppColors.success),
                    const SizedBox(width: 12),
                    _StatCard(icon: Icons.emoji_events_rounded, label: 'Certificates', value: _loading ? '—' : '$_certificateCount', color: AppColors.warning),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Start Learning Today!', style: AppTextStyles.h4),
                            const SizedBox(height: 6),
                            Text('Explore courses across\nmultiple categories', style: AppTextStyles.bodySmall.copyWith(color: AppColors.white.withOpacity(0.85), height: 1.5)),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () => widget.onNavigateToTab(1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(color: AppColors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                                child: Text('Browse Courses →', style: AppTextStyles.label.copyWith(color: AppColors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.rocket_launch_rounded, color: AppColors.white, size: 64),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Featured Courses', style: AppTextStyles.h3),
                    GestureDetector(onTap: () => widget.onNavigateToTab(1), child: Text('See All', style: AppTextStyles.link)),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: _loading
                    ? const Center(child: Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: CircularProgressIndicator(color: AppColors.primary)))
                    : _featuredCourses.isEmpty
                    ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text('No featured courses yet. Check Explore to see everything available.', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                )
                    : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _featuredCourses.length,
                  itemBuilder: (context, index) {
                    final course = _featuredCourses[index];
                    final levelColor = _levelColor(course.level);

                    return GestureDetector(
                      onTap: () => context.push('/course/${course.id}'),
                      child: Container(
                        width: 220,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 110,
                              clipBehavior: Clip.antiAlias,
                              decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                              child: course.thumbnailUrl != null
                                  ? CachedNetworkImage(
                                imageUrl: course.thumbnailUrl!,
                                height: 110,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => _FeaturedThumbFallback(title: course.title),
                                errorWidget: (_, __, ___) => _FeaturedThumbFallback(title: course.title),
                              )
                                  : _FeaturedThumbFallback(title: course.title),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(course.title, style: AppTextStyles.h4.copyWith(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 7),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          course.priceText,
                                          style: AppTextStyles.caption.copyWith(
                                            color: course.priceText.toLowerCase() == 'free' ? const Color(0xFF65A30D) : const Color(0xFFEA580C),
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(color: levelColor.withOpacity(0.14), borderRadius: BorderRadius.circular(5)),
                                        child: Text(_shortLevel(course.level), style: AppTextStyles.caption.copyWith(color: levelColor, fontSize: 10, fontWeight: FontWeight.w800)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _MobileBrandRow extends StatelessWidget {
  final UserModel? user;
  const _MobileBrandRow({required this.user});

  @override
  Widget build(BuildContext context) {
    final companyName = user?.companyName?.trim() ?? '';

    return Row(
      children: [
        Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.divider)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/learnos-logo.png', height: 22, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.school_rounded, color: AppColors.primary, size: 20)),
              const SizedBox(width: 7),
              Text('LearnOS', style: AppTextStyles.label.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        const Spacer(),
        if (companyName.isNotEmpty) _CompanyLogoBadge(logoUrl: user?.companyLogoUrl, companyName: companyName),
      ],
    );
  }
}

class _CompanyLogoBadge extends StatelessWidget {
  final String? logoUrl;
  final String companyName;
  const _CompanyLogoBadge({required this.logoUrl, required this.companyName});

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolveCompanyLogoUrl(logoUrl);

    return Container(
      height: 34,
      constraints: const BoxConstraints(maxWidth: 145),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.divider)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CompanyLogoImage(imageUrl: imageUrl, companyName: companyName, size: 24),
          const SizedBox(width: 7),
          Flexible(child: Text(companyName, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _CompanyLogoImage extends StatelessWidget {
  final String? imageUrl;
  final String companyName;
  final double size;
  const _CompanyLogoImage({required this.imageUrl, required this.companyName, required this.size});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _CompanyInitialsAvatar(companyName: companyName, size: size);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.25),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.contain,
        placeholder: (_, __) => _CompanyInitialsAvatar(companyName: companyName, size: size),
        errorWidget: (_, __, ___) => _CompanyInitialsAvatar(companyName: companyName, size: size),
      ),
    );
  }
}

class _CompanyInitialsAvatar extends StatelessWidget {
  final String companyName;
  final double size;
  const _CompanyInitialsAvatar({required this.companyName, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(size * 0.25)),
      child: Text(_companyInitials(companyName), style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: size < 30 ? 8 : 11)),
    );
  }
}

class _FeaturedThumbFallback extends StatelessWidget {
  final String title;
  const _FeaturedThumbFallback({required this.title});

  Color _colorFor(String text) {
    const palette = [Color(0xFF2563EB), Color(0xFF16A34A), Color(0xFFEA580C), Color(0xFFDB2777), Color(0xFF7C3AED), Color(0xFF0EA5E9), Color(0xFFDC2626), Color(0xFF65A30D)];
    final hash = text.isEmpty ? 0 : text.codeUnitAt(0) + text.length;
    return palette[hash % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(title);
    final trimmed = title.trim();
    final initial = trimmed.isNotEmpty ? trimmed[0].toUpperCase() : 'C';

    return Container(
      height: 110,
      width: double.infinity,
      color: color.withOpacity(0.15),
      child: Center(child: Text(initial, style: TextStyle(color: color, fontSize: 36, fontWeight: FontWeight.w700))),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.2))),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(value, style: AppTextStyles.h3.copyWith(color: color)),
            Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center, maxLines: 1, softWrap: false, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Logout', style: AppTextStyles.h3),
          content: Text('Are you sure you want to logout?', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final auth = context.read<AuthProvider>();
                await auth.logout();
                if (context.mounted) context.go('/login');
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: AppColors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final companyName = user?.companyName?.trim() ?? '';

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              CircleAvatar(radius: 44, backgroundColor: AppColors.primary, child: Text(_firstLetter(user?.firstName, 'L'), style: AppTextStyles.h1.copyWith(color: AppColors.white))),
              const SizedBox(height: 16),
              Text(user?.fullName ?? '', style: AppTextStyles.h3),
              const SizedBox(height: 4),
              Text(user?.email ?? '', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(20)),
                child: Text(_friendlyRole(user?.role), style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
              ),
              if (companyName.isNotEmpty) ...[
                const SizedBox(height: 18),
                _ProfileCompanyBrand(logoUrl: user?.companyLogoUrl, companyName: companyName),
              ],
              const SizedBox(height: 36),
              _ProfileMenuItem(
                icon: Icons.person_outline_rounded,
                label: 'Edit Profile',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
              ),
              _ProfileMenuItem(
                icon: Icons.workspace_premium_outlined,
                label: 'My Certificates',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyCertificatesScreen())),
              ),
              _ProfileMenuItem(
                icon: Icons.receipt_long_outlined,
                label: 'Payment History',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentHistoryScreen())),
              ),
              _ProfileMenuItem(
                icon: Icons.lock_outline_rounded,
                label: 'Change Password',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
              ),
              _ProfileMenuItem(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
              ),
              _ProfileMenuItem(
                icon: Icons.help_outline_rounded,
                label: 'Help & Support',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error.withOpacity(0.12), foregroundColor: AppColors.error, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: AppColors.error.withOpacity(0.3), width: 1))),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCompanyBrand extends StatelessWidget {
  final String? logoUrl;
  final String companyName;
  const _ProfileCompanyBrand({required this.logoUrl, required this.companyName});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CompanyLogoImage(imageUrl: _resolveCompanyLogoUrl(logoUrl), companyName: companyName, size: 32),
          const SizedBox(width: 10),
          Flexible(child: Text(companyName, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ProfileMenuItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.textSecondary, size: 22),
        title: Text(label, style: AppTextStyles.body),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

String? _resolveCompanyLogoUrl(String? rawUrl) {
  if (rawUrl == null || rawUrl.trim().isEmpty) return null;
  final value = rawUrl.trim();
  if (value.startsWith('http://') || value.startsWith('https://')) return value;
  return ApiConstants.resolveMediaUrl(value);
}

String _companyInitials(String companyName) {
  final words = companyName.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).take(2).toList();
  if (words.isEmpty) return 'CO';
  return words.map((word) => word[0].toUpperCase()).join();
}

String _firstLetter(String? value, String fallback) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return fallback;
  return text[0].toUpperCase();
}
