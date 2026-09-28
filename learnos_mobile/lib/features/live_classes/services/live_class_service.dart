import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/live_class_model.dart';

class LiveClassService {
  final Dio _dio = ApiClient().dio;

  Future<List<LiveClassModel>> getUpcomingClasses() async {
    final response = await _dio.get(
      ApiConstants.upcomingLiveClasses,
    );

    final payload = response.data;
    final dynamic rawItems;

    if (payload is List) {
      rawItems = payload;
    } else if (payload is Map<String, dynamic>) {
      rawItems = payload['data'] ??
          payload['liveClasses'] ??
          payload['classes'] ??
          payload['items'] ??
          [];
    } else {
      rawItems = [];
    }

    if (rawItems is! List) {
      return [];
    }

    return rawItems
        .whereType<Map>()
        .map(
          (item) => LiveClassModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<String> joinClass(String classId) async {
    final response = await _dio.post(
      ApiConstants.joinLiveClass(classId),
    );

    final data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : <String, dynamic>{};

    final nestedData = data['data'] is Map<String, dynamic>
        ? data['data'] as Map<String, dynamic>
        : data;

    final meetingUrl = nestedData['meetingUrl'] ??
        nestedData['meetUrl'] ??
        nestedData['googleMeetUrl'] ??
        nestedData['joinUrl'] ??
        nestedData['url'];

    if (meetingUrl == null || meetingUrl.toString().trim().isEmpty) {
      throw Exception('The server did not return a meeting URL.');
    }

    return meetingUrl.toString().trim();
  }
}