class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8080/api/v1';

  static const String fileBaseUrl =
      'http://10.0.2.2:8080/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String refreshToken = '/auth/refresh-token';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Courses
  static const String courses = '/courses';
  static const String categories = '/categories';
  static const String myCourses = '/courses/my-courses';
  static const String searchCourses = '/courses/search';

  // Lessons
  static const String lessons = '/lessons';
  static const String progress = '/lessons/progress';
  static const String myProgress = '/lessons/progress/my';

  // Certificates
  static const String certificates = '/certificates';
  static const String myCertificates = '/certificates/my';
  
  // Live Classes
  static const String upcomingLiveClasses =
      '/live-classes/learner/upcoming';

  static String joinLiveClass(String id) {
    return '/live-classes/learner/$id/join';
  }
  // Profile
  static const String changePassword = '/auth/change-password';
  static const String updateProfile = '/auth/update-profile';

  // Quizzes
  static const String quizAttempts = '/quiz-attempts';
  static const String myQuizAttempts = '/quiz-attempts/my';

  static String certificateDownload(String certificateId) {
    return '$certificates/$certificateId/download';
  }

  static String? resolveMediaUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) {
      return null;
    }

    final value = rawUrl.trim();
    final filePathIndex = value.indexOf('/files/');

    if (filePathIndex == -1) {
      return value;
    }

    final relativeFilePath = value.substring(filePathIndex);

    return '$fileBaseUrl$relativeFilePath';
  }
}