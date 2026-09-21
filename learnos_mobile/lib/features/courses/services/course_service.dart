import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/course_model.dart';
import '../models/lesson_model.dart';
import '../models/module_model.dart';

class LessonProgressModel {
  final String lessonId;
  final String moduleId;
  final String courseId;
  final bool completed;
  final int watchedSeconds;
  final int? durationSeconds;
  final int progressPercent;

  LessonProgressModel({
    required this.lessonId,
    required this.moduleId,
    required this.courseId,
    required this.completed,
    required this.watchedSeconds,
    this.durationSeconds,
    required this.progressPercent,
  });

  factory LessonProgressModel.fromJson(Map<String, dynamic> json) {
    return LessonProgressModel(
      lessonId: (json['lessonId'] ?? '').toString(),
      moduleId: (json['moduleId'] ?? '').toString(),
      courseId: (json['courseId'] ?? '').toString(),
      completed: _toBool(json['completed']),
      watchedSeconds: _toInt(json['watchedSeconds']),
      durationSeconds: json['durationSeconds'] == null
          ? null
          : _toInt(json['durationSeconds']),
      progressPercent: _toInt(json['progressPercent']),
    );
  }
}

class CourseProgressModel {
  final String courseId;
  final int totalLessons;
  final int completedLessons;
  final int progressPercent;
  final bool contentCompleted;
  final bool assessmentUnlocked;
  final String? resumeLessonId;
  final int resumePositionSeconds;
  final List<LessonProgressModel> lessons;

  CourseProgressModel({
    required this.courseId,
    required this.totalLessons,
    required this.completedLessons,
    required this.progressPercent,
    required this.contentCompleted,
    required this.assessmentUnlocked,
    this.resumeLessonId,
    required this.resumePositionSeconds,
    required this.lessons,
  });

  factory CourseProgressModel.fromJson(Map<String, dynamic> json) {
    final rawLessons = json['lessons'];

    return CourseProgressModel(
      courseId: (json['courseId'] ?? '').toString(),
      totalLessons: _toInt(json['totalLessons']),
      completedLessons: _toInt(json['completedLessons']),
      progressPercent: _toInt(json['progressPercent']),
      contentCompleted: _toBool(json['contentCompleted']),
      assessmentUnlocked: _toBool(json['assessmentUnlocked']),
      resumeLessonId: json['resumeLessonId']?.toString(),
      resumePositionSeconds: _toInt(json['resumePositionSeconds']),
      lessons: rawLessons is List
          ? rawLessons
          .whereType<Map>()
          .map(
            (item) => LessonProgressModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList()
          : [],
    );
  }
}

class CourseRatingModel {
  final String courseId;
  final double averageRating;
  final int ratingCount;
  final int? myRating;

  CourseRatingModel({
    required this.courseId,
    required this.averageRating,
    required this.ratingCount,
    this.myRating,
  });

  factory CourseRatingModel.fromJson(Map<String, dynamic> json) {
    final rawMyRating = json['myRating'];
    final parsedMyRating = rawMyRating == null ? null : _toInt(rawMyRating);

    return CourseRatingModel(
      courseId: (json['courseId'] ?? '').toString(),
      averageRating: _clampRating(_toDouble(json['averageRating'])),
      ratingCount: _toInt(json['ratingCount']),
      myRating: parsedMyRating != null &&
          parsedMyRating >= 1 &&
          parsedMyRating <= 5
          ? parsedMyRating
          : null,
    );
  }
}

class CoursePaymentOrderModel {
  final String paymentId;
  final String courseId;
  final String keyId;
  final String orderId;
  final int amountInPaise;
  final String currency;
  final String status;

  CoursePaymentOrderModel({
    required this.paymentId,
    required this.courseId,
    required this.keyId,
    required this.orderId,
    required this.amountInPaise,
    required this.currency,
    required this.status,
  });

  factory CoursePaymentOrderModel.fromJson(Map<String, dynamic> json) {
    return CoursePaymentOrderModel(
      paymentId: (json['paymentId'] ?? '').toString(),
      courseId: (json['courseId'] ?? '').toString(),
      keyId: (json['keyId'] ?? '').toString(),
      orderId: (json['orderId'] ?? '').toString(),
      amountInPaise: _toInt(json['amountInPaise'] ?? json['amount']),
      currency: (json['currency'] ?? 'INR').toString(),
      status: (json['status'] ?? '').toString(),
    );
  }
}

class PaymentHistoryRecordModel {
  final String id;
  final String paymentType;
  final String? companyId;
  final String? companyName;
  final String? courseId;
  final String? courseName;
  final String? planId;
  final String? planCode;
  final String? planName;
  final double amount;
  final String currency;
  final String status;
  final String? paymentMethod;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final DateTime? paidAt;
  final DateTime? createdAt;

  PaymentHistoryRecordModel({
    required this.id,
    required this.paymentType,
    this.companyId,
    this.companyName,
    this.courseId,
    this.courseName,
    this.planId,
    this.planCode,
    this.planName,
    required this.amount,
    required this.currency,
    required this.status,
    this.paymentMethod,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.paidAt,
    this.createdAt,
  });

  factory PaymentHistoryRecordModel.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryRecordModel(
      id: (json['id'] ?? '').toString(),
      paymentType: (json['paymentType'] ?? '').toString(),
      companyId: json['companyId']?.toString(),
      companyName: json['companyName']?.toString(),
      courseId: json['courseId']?.toString(),
      courseName: json['courseName']?.toString(),
      planId: json['planId']?.toString(),
      planCode: json['planCode']?.toString(),
      planName: json['planName']?.toString(),
      amount: _toDouble(json['amount']),
      currency: (json['currency'] ?? 'INR').toString(),
      status: (json['status'] ?? '').toString(),
      paymentMethod: json['paymentMethod']?.toString(),
      razorpayOrderId: json['razorpayOrderId']?.toString(),
      razorpayPaymentId: json['razorpayPaymentId']?.toString(),
      paidAt: _parseDate(json['paidAt']),
      createdAt: _parseDate(json['createdAt']),
    );
  }
}

class CourseService {
  final _dio = ApiClient().dio;

  String get _apiBaseUrl => ApiConstants.baseUrl;

  Future<List<CategoryModel>> getCategories() async {
    final response = await _dio.get(ApiConstants.categories);
    final List data = response.data['data'];

    return data.map((item) => CategoryModel.fromJson(item)).toList();
  }

  Future<Map<String, dynamic>> getCourses({
    int page = 0,
    int size = 12,
  }) async {
    final response = await _dio.get(
      ApiConstants.courses,
      queryParameters: {'page': page, 'size': size},
    );

    final data = response.data['data'];
    final List content = data['content'];

    return {
      'courses': content.map((item) => CourseModel.fromJson(item)).toList(),
      'totalPages': data['totalPages'],
      'totalElements': data['totalElements'],
    };
  }

  Future<List<CourseModel>> searchCourses(String query) async {
    final response = await _dio.get(
      ApiConstants.searchCourses,
      queryParameters: {'q': query},
    );

    final List content = response.data['data']['content'];
    return content.map((item) => CourseModel.fromJson(item)).toList();
  }

  Future<List<CourseModel>> getMyCourses() async {
    final response = await _dio.get(ApiConstants.myCourses);
    final data = response.data['data'];

    if (data is Map && data['content'] != null) {
      final List content = data['content'];
      return content.map((item) => CourseModel.fromJson(item)).toList();
    }

    final List list = data is List ? data : [];
    return list.map((item) => CourseModel.fromJson(item)).toList();
  }

  Future<CourseModel> getCourseById(String id) async {
    final response = await _dio.get('${ApiConstants.courses}/$id');
    return CourseModel.fromJson(response.data['data']);
  }

  Future<CourseRatingModel> getCourseRating(String courseId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.courses}/$courseId/rating',
      );

      final body = response.data;
      final data = body is Map && body['data'] != null ? body['data'] : body;

      return CourseRatingModel.fromJson(
        Map<String, dynamic>.from(data as Map),
      );
    } on DioException catch (e) {
      throw Exception(_extractDioError(e));
    }
  }

  Future<CourseRatingModel> saveCourseRating({
    required String courseId,
    required int stars,
  }) async {
    if (stars < 1 || stars > 5) {
      throw Exception('Rating must be between 1 and 5 stars.');
    }

    try {
      final response = await _dio.put(
        '${ApiConstants.courses}/$courseId/rating',
        data: {'stars': stars},
      );

      final body = response.data;
      final data = body is Map && body['data'] != null ? body['data'] : body;

      return CourseRatingModel.fromJson(
        Map<String, dynamic>.from(data as Map),
      );
    } on DioException catch (e) {
      throw Exception(_extractDioError(e));
    }
  }

  Future<List<CourseModel>> getFeaturedCourses() async {
    try {
      final response = await _dio.get('${ApiConstants.courses}/featured');
      final data = response.data['data'];
      final List list = data is List ? data : [];

      return list.map((item) => CourseModel.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<CoursePaymentOrderModel> createCoursePaymentOrder(
      String courseId,
      ) async {
    try {
      final response = await _dio.post(
        '$_apiBaseUrl/course-payments/payment-order',
        data: {'courseId': courseId},
      );

      final body = response.data;
      final data = body is Map && body['data'] != null ? body['data'] : body;

      if (data is! Map) {
        throw Exception('Invalid course payment order response.');
      }

      return CoursePaymentOrderModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    } on DioException catch (e) {
      throw Exception(_extractDioError(e));
    }
  }

  Future<String> verifyCoursePayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final response = await _dio.post(
        '$_apiBaseUrl/course-payments/verify-payment',
        data: {
          'razorpayOrderId': razorpayOrderId,
          'razorpayPaymentId': razorpayPaymentId,
          'razorpaySignature': razorpaySignature,
        },
      );

      final body = response.data;
      final data = body is Map && body['data'] != null ? body['data'] : body;

      return data?.toString() ?? 'Course payment verified.';
    } on DioException catch (e) {
      throw Exception(_extractDioError(e));
    }
  }

  Future<List<PaymentHistoryRecordModel>> getMyPaymentHistory() async {
    try {
      final response = await _dio.get('/payment-history/my');
      final body = response.data;

      dynamic data = body;
      if (body is Map && body['data'] != null) {
        data = body['data'];
      }

      if (data is! List) {
        return [];
      }

      return data
          .whereType<Map>()
          .map(
            (item) => PaymentHistoryRecordModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractDioError(e));
    }
  }

  Future<List<ModuleModel>> getCourseContent(String courseId) async {
    final modulesResponse = await _dio.get(
      '${ApiConstants.courses}/$courseId/modules',
    );
    final lessonsResponse = await _dio.get(
      '${ApiConstants.courses}/$courseId/lessons',
    );

    final modulesBody = modulesResponse.data;
    final lessonsBody = lessonsResponse.data;

    final modulesData = modulesBody is Map && modulesBody['data'] != null
        ? modulesBody['data']
        : modulesBody;
    final lessonsData = lessonsBody is Map && lessonsBody['data'] != null
        ? lessonsBody['data']
        : lessonsBody;

    final modules = modulesData is List
        ? modulesData
        .whereType<Map>()
        .map(
          (item) => ModuleModel.fromJson(Map<String, dynamic>.from(item)),
    )
        .toList()
        : <ModuleModel>[];

    final lessons = lessonsData is List
        ? lessonsData
        .whereType<Map>()
        .map(
          (item) => LessonModel.fromJson(Map<String, dynamic>.from(item)),
    )
        .where((lesson) => lesson.isPublished)
        .toList()
        : <LessonModel>[];

    modules.sort(
          (left, right) => left.displayOrder.compareTo(right.displayOrder),
    );

    return modules.map((module) {
      final moduleLessons = lessons
          .where((lesson) => lesson.moduleId == module.id)
          .toList()
        ..sort((left, right) => left.order.compareTo(right.order));

      return module.copyWith(lessons: moduleLessons);
    }).toList();
  }

  Future<void> enrollInCourse(String courseId) async {
    try {
      await _dio.post(
        '${ApiConstants.courses}/$courseId/enroll',
        data: {},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
    } on DioException catch (e) {
      throw Exception(_extractDioError(e));
    }
  }

  Future<List<LessonModel>> getLessons(String courseId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.courses}/$courseId/lessons',
      );

      final body = response.data;
      dynamic data = body;

      if (body is Map && body['data'] != null) data = body['data'];
      if (data is Map && data['content'] is List) data = data['content'];
      if (data is Map && data['lessons'] is List) data = data['lessons'];
      if (data is! List) return [];

      return data
          .whereType<Map>()
          .map(
            (item) => LessonModel.fromJson(Map<String, dynamic>.from(item)),
      )
          .where((lesson) => lesson.isPublished)
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractDioError(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<CourseProgressModel> getCourseProgress(String courseId) async {
    try {
      final response = await _dio.get(
        '$_apiBaseUrl/lessons/progress/course/$courseId',
      );

      final body = response.data;
      final data = body is Map && body['data'] != null ? body['data'] : body;

      if (data is! Map) {
        throw Exception('Invalid course progress response.');
      }

      return CourseProgressModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    } on DioException catch (e) {
      throw Exception(_extractDioError(e));
    }
  }

  Future<LessonProgressModel> saveLessonProgress({
    required String lessonId,
    required int watchedSeconds,
    bool completed = false,
  }) async {
    try {
      final response = await _dio.post(
        '$_apiBaseUrl/lessons/progress',
        data: {
          'lessonId': lessonId,
          'watchedSeconds': watchedSeconds < 0 ? 0 : watchedSeconds,
          'completed': completed,
        },
      );

      final body = response.data;
      final data = body is Map && body['data'] != null ? body['data'] : body;

      return LessonProgressModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    } on DioException catch (e) {
      throw Exception(_extractDioError(e));
    }
  }

  Future<LessonProgressModel> markLessonCompleted(String lessonId) async {
    try {
      final response = await _dio.post(
        '$_apiBaseUrl/lessons/$lessonId/complete',
        data: {},
      );

      final body = response.data;
      final data = body is Map && body['data'] != null ? body['data'] : body;

      return LessonProgressModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    } on DioException catch (e) {
      throw Exception(_extractDioError(e));
    }
  }

  Future<List<CourseModel>> getCoursesByCategory(String categoryId) async {
    final response = await _dio.get(
      '${ApiConstants.courses}/category/$categoryId',
    );

    final List content = response.data['data']['content'];
    return content.map((item) => CourseModel.fromJson(item)).toList();
  }

  String _extractDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final body = e.response?.data;

    if (body is Map) {
      final message = body['message'] ?? body['error'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    if (statusCode == 400) {
      return 'The server rejected this request. Please check the course and lesson data.';
    }
    if (statusCode == 401) {
      return 'Your session has expired. Please log in again.';
    }
    if (statusCode == 403) {
      return 'You do not have access to this course.';
    }
    if (statusCode == 404) {
      return 'The requested course content was not found.';
    }

    return e.message ?? 'Something went wrong.';
  }
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}

bool _toBool(dynamic value) {
  if (value is bool) return value;
  return value?.toString().toLowerCase() == 'true';
}

double _clampRating(double value) {
  return value.clamp(0.0, 5.0);
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
