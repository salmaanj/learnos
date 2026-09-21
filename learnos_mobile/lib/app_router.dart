import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/otp_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/reset_password_screen.dart';
import 'features/courses/models/course_model.dart';
import 'features/courses/screens/course_detail_screen.dart';
import 'features/courses/screens/course_learn_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/payments/screens/payment_screen.dart';
import 'features/quizzes/screens/quiz_screen.dart';
import 'features/splash/screens/splash_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final authStatus = context.read<AuthProvider>().status;

    final isAuthRoute = state.matchedLocation == '/' ||
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation == '/onboarding' ||
        state.matchedLocation == '/verify-otp' ||
        state.matchedLocation == '/forgot-password' ||
        state.matchedLocation == '/reset-password';

    if (authStatus == AuthStatus.unauthenticated && !isAuthRoute) {
      return '/login';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (_, __) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (_, __) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/verify-otp',
      builder: (_, __) => const OtpScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (_, __) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (_, state) {
        final extra = state.extra as Map<String, String>;

        return ResetPasswordScreen(
          email: extra['email']!,
          otp: extra['otp']!,
        );
      },
    ),
    GoRoute(
      path: '/home',
      builder: (_, __) => const HomeScreen(),
    ),
    GoRoute(
      path: '/course/:id',
      builder: (_, state) {
        return CourseDetailScreen(
          courseId: state.pathParameters['id']!,
          fromMyLearning:
          state.uri.queryParameters['from'] == 'mylearning',
        );
      },
    ),
    GoRoute(
      path: '/course/:id/learn',
      builder: (_, state) {
        return CourseLearnScreen(
          courseId: state.pathParameters['id']!,
          courseTitle: state.uri.queryParameters['title'] ?? 'Course',
          selectedLessonId: state.uri.queryParameters['lessonId'],
        );
      },
    ),
    GoRoute(
      path: '/quiz/:id',
      builder: (_, state) {
        return QuizScreen(
          quizId: state.pathParameters['id']!,
        );
      },
    ),
    GoRoute(
      path: '/course/:id/payment',
      builder: (_, state) {
        return PaymentScreen(
          course: state.extra as CourseModel,
        );
      },
    ),
  ],
);