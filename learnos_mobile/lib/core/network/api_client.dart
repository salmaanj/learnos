import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  late final Dio dio;

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        print('REQUEST: ${options.method} ${options.uri}');
        print('TOKEN: ${token != null ? "present" : "MISSING"}');
        return handler.next(options);
      },
      onError: (error, handler) async {
        print('API ERROR ${error.response?.statusCode}: ${error.response?.data}');
        if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
          try {
            final refreshToken = await SecureStorage.getRefreshToken();
            if (refreshToken != null) {
              final refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
              final response = await refreshDio.post(
                ApiConstants.refreshToken,
                data: {'refreshToken': refreshToken},
              );
              final newToken = response.data['data']['accessToken'];
              await SecureStorage.saveToken(newToken);
              error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final retryResponse = await dio.fetch(error.requestOptions);
              return handler.resolve(retryResponse);
            } else {
              await _forceLogout();
            }
          } catch (e) {
            print('TOKEN REFRESH FAILED: $e');
            await _forceLogout();
          }
        }
        return handler.next(error);
      },
    ));
  }

  Future<void> _forceLogout() async {
    await SecureStorage.clearAll();
    navigatorKey.currentContext?.let((ctx) {
      // ignore: use_build_context_synchronously
    });
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T) block) => block(this);
}