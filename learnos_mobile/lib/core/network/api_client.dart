import 'package:dio/dio.dart';
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

          return handler.next(options);
        },
        onError: (error, handler) async {
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