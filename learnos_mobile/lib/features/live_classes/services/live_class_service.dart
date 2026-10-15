import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/live_class_model.dart';

class LiveClassException implements Exception {
  final String message;

  const LiveClassException(this.message);

  @override
  String toString() => message;
}

class LiveClassService {
  final Dio _dio = ApiClient().dio;

  Future<List<LiveClassModel>> getUpcomingClasses() async {
    try {
      final response = await _dio.get(
        ApiConstants.upcomingLiveClasses,
      );

      dynamic rawItems = response.data;

      if (rawItems is Map) {
        rawItems = rawItems['data'] ??
            rawItems['liveClasses'] ??
            rawItems['classes'] ??
            rawItems['items'] ??
            rawItems['content'];
      }

      if (rawItems is Map) {
        rawItems = rawItems['liveClasses'] ??
            rawItems['classes'] ??
            rawItems['items'] ??
            rawItems['content'];
      }

      if (rawItems is! List) {
        throw const LiveClassException(
          'The server returned an unexpected live classes response.',
        );
      }

      return rawItems
          .whereType<Map>()
          .map(
            (item) => LiveClassModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw LiveClassException(
        _errorMessage(
          error,
          fallback: 'Unable to load upcoming live classes. Please try again.',
        ),
      );
    }
  }

  Future<String> joinClass(String classId) async {
    try {
      final response = await _dio.post(
        ApiConstants.joinLiveClass(classId),
      );

      final payload = response.data;

      if (payload is! Map) {
        throw const LiveClassException(
          'The server did not return a meeting URL.',
        );
      }

      final nested = payload['data'];
      final Map data = nested is Map ? nested : payload;

      final meetingUrl = data['meetingUrl'] ??
          data['meetUrl'] ??
          data['googleMeetUrl'] ??
          data['joinUrl'] ??
          data['url'];

      if (meetingUrl == null || meetingUrl.toString().trim().isEmpty) {
        throw const LiveClassException(
          'The meeting link is not available. Please contact your instructor.',
        );
      }

      return meetingUrl.toString().trim();
    } on DioException catch (error) {
      throw LiveClassException(
        _errorMessage(
          error,
          fallback: error.response?.statusCode == 400
              ? 'Unable to join this class. Joining is available from '
                  '15 minutes before the class until 30 minutes after it ends.'
              : 'Unable to join this class. Please try again.',
        ),
      );
    }
  }

  static String _errorMessage(
    DioException error, {
    required String fallback,
  }) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'The request timed out. Please try again.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Unable to connect to the server. Check your connection '
          'and try again.';
    }

    final statusCode = error.response?.statusCode;

    if (statusCode == 401) {
      return 'Your session has expired. Please sign in again.';
    }

    if (statusCode == 403) {
      return 'You do not have permission to access this class.';
    }

    if (statusCode == 404) {
      return 'This live class could not be found.';
    }

    if (statusCode != null && statusCode >= 500) {
      return 'The server could not complete the request. Please try again later.';
    }

    final payload = error.response?.data;

    if (payload is Map) {
      final nestedError = payload['error'];
      final nestedData = payload['data'];

      final candidates = <dynamic>[
        payload['message'],
        nestedError is Map ? nestedError['message'] : null,
        nestedData is Map ? nestedData['message'] : null,
        payload['detail'],
      ];

      for (final candidate in candidates) {
        if (candidate is! String) {
          continue;
        }

        final message = candidate.trim();

        if (message.isNotEmpty &&
            message.length <= 300 &&
            !message.contains('DioException') &&
            !message.contains('<html')) {
          return message;
        }
      }
    }

    return fallback;
  }
}
