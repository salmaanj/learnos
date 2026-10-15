import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage.dart';

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  late final Dio dio;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: AppConstants.connectTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: AppConstants.receiveTimeout,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final skipAuthRefresh =
              options.extra['skipAuthRefresh'] == true;

          if (!skipAuthRefresh) {
            final token = await SecureStorage.getToken();

            if (token != null && token.trim().isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          debugPrint(
            'API REQUEST: ${options.method} ${options.uri}',
          );

          if (options.data is Map) {
            final safeData =
                Map<String, dynamic>.from(options.data as Map);

            safeData.remove('password');
            safeData.remove('newPassword');
            safeData.remove('currentPassword');

            debugPrint('API REQUEST DATA: $safeData');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            'API RESPONSE: ${response.statusCode} '
            '${response.requestOptions.uri}',
          );

          if (response.data is Map) {
            debugPrint(
              'API RESPONSE KEYS: '
              '${(response.data as Map).keys.toList()}',
            );
          }

          return handler.next(response);
        },
        onError: (error, handler) async {
          debugPrint(
            'API ERROR: ${error.type} '
            '${error.response?.statusCode} '
            '${error.requestOptions.uri}',
          );
          debugPrint(
            'API ERROR RESPONSE: ${error.response?.data}',
          );

          final requestOptions = error.requestOptions;
          final skipAuthRefresh =
              requestOptions.extra['skipAuthRefresh'] == true;
          final alreadyRetried =
              requestOptions.extra['authRetried'] == true;

          final statusCode = error.response?.statusCode;
          final shouldTryRefresh = !skipAuthRefresh &&
              !alreadyRetried &&
              (statusCode == 401 || statusCode == 403);

          if (!shouldTryRefresh) {
            return handler.next(error);
          }

          try {
            final refreshToken =
                await SecureStorage.getRefreshToken();

            if (refreshToken == null ||
                refreshToken.trim().isEmpty) {
              await _forceLogout();
              return handler.next(error);
            }

            final refreshDio = Dio(
              BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            );

            final response = await refreshDio.post(
              ApiConstants.refreshToken,
              data: {
                'refreshToken': refreshToken,
              },
            );

            final body = response.data;
            final data = body is Map && body['data'] != null
                ? body['data']
                : body;

            if (data is! Map ||
                data['accessToken'] == null ||
                data['accessToken'].toString().trim().isEmpty) {
              await _forceLogout();
              return handler.next(error);
            }

            final newToken = data['accessToken'].toString();

            await SecureStorage.saveToken(newToken);

            requestOptions.headers['Authorization'] =
                'Bearer $newToken';
            requestOptions.extra['authRetried'] = true;

            final retryResponse = await dio.fetch(requestOptions);

            return handler.resolve(retryResponse);
          } catch (_) {
            await _forceLogout();
            return handler.next(error);
          }
        },
      ),
    );
  }

  Future<void> _forceLogout() async {
    await SecureStorage.clearAll();

    final navigator = navigatorKey.currentState;

    if (navigator != null && navigator.mounted) {
      navigator.pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }
}