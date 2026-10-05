import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;

  Future<AuthResponse> login(
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
        options: Options(
          extra: {
            'skipAuthRefresh': true,
          },
        ),
      );

      final body = response.data;
      final data = body is Map && body['data'] != null
          ? body['data']
          : body;

      if (data is! Map) {
        throw Exception('The server returned an invalid sign-in response.');
      }

      final authResponse = AuthResponse.fromJson(
        Map<String, dynamic>.from(data),
      );

      if (authResponse.accessToken.trim().isEmpty) {
        throw Exception('The server did not return a valid access token.');
      }

      await SecureStorage.saveToken(authResponse.accessToken);
      await SecureStorage.saveRefreshToken(
        authResponse.refreshToken,
      );
      await SecureStorage.saveUserData(
        authResponse.user.toJsonString(),
      );

      return authResponse;
    } on DioException {
      rethrow;
    }
  }

  Future<String> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
    String? companyCode,
  }) async {
    try {
      final response = await _dio.post<String>(
        ApiConstants.register,
        data: {
          'firstName': firstName.trim(),
          'lastName': lastName.trim(),
          'email': email.trim().toLowerCase(),
          'password': password,
          'phone': phone?.trim(),
          if (companyCode != null &&
              companyCode.trim().isNotEmpty)
            'companyCode': companyCode.trim(),
        },
        options: Options(
          responseType: ResponseType.plain,
          headers: {
            'Accept': 'text/plain, application/json',
          },
          extra: {
            'skipAuthRefresh': true,
          },
        ),
      );

      final message = response.data?.trim() ?? '';

      if (message.isEmpty) {
        return 'Learner account created successfully.';
      }

      return message;
    } on DioException catch (error) {
      throw Exception(_extractError(error));
    }
  }

  Future<AuthResponse> verifyOtp(
    String email,
    String otp,
  ) async {
    final response = await _dio.post(
      ApiConstants.verifyOtp,
      data: {
        'email': email,
        'otp': otp,
      },
      options: Options(
        extra: {
          'skipAuthRefresh': true,
        },
      ),
    );

    final body = response.data;
    final data = body is Map && body['data'] != null
        ? body['data']
        : body;

    final authResponse = AuthResponse.fromJson(
      Map<String, dynamic>.from(data as Map),
    );

    await SecureStorage.saveToken(authResponse.accessToken);
    await SecureStorage.saveRefreshToken(
      authResponse.refreshToken,
    );
    await SecureStorage.saveUserData(
      authResponse.user.toJsonString(),
    );

    return authResponse;
  }

  Future<void> resendOtp(String email) async {
    await _dio.post(
      '${ApiConstants.resendOtp}?email=${Uri.encodeComponent(email)}',
      options: Options(
        extra: {
          'skipAuthRefresh': true,
        },
      ),
    );
  }

  Future<void> forgotPassword(String email) async {
    await _dio.post(
      ApiConstants.forgotPassword,
      data: {
        'email': email.trim().toLowerCase(),
      },
      options: Options(
        extra: {
          'skipAuthRefresh': true,
        },
      ),
    );
  }

  Future<void> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    await _dio.post(
      ApiConstants.resetPassword,
      data: {
        'email': email.trim().toLowerCase(),
        'otp': otp.trim(),
        'newPassword': newPassword,
      },
      options: Options(
        extra: {
          'skipAuthRefresh': true,
        },
      ),
    );
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } catch (_) {
      // Clear local session even if server logout is unavailable.
    }

    await SecureStorage.clearAll();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.post(
      ApiConstants.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  Future<UserModel> updateProfile({
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    final response = await _dio.put(
      ApiConstants.updateProfile,
      data: {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        if (phone != null && phone.trim().isNotEmpty)
          'phone': phone.trim(),
      },
    );

    final body = response.data;
    final data = body is Map && body['data'] != null
        ? body['data']
        : body;

    final updatedUser = UserModel.fromJson(
      Map<String, dynamic>.from(data as Map),
    );

    await SecureStorage.saveUserData(
      updatedUser.toJsonString(),
    );

    return updatedUser;
  }

  Future<UserModel?> getCachedUser() async {
    final json = await SecureStorage.getUserData();

    if (json == null) {
      return null;
    }

    return UserModel.fromJsonString(json);
  }

  Future<bool> isLoggedIn() async {
    final token = await SecureStorage.getToken();
    return token != null && token.trim().isNotEmpty;
  }

  String _extractError(DioException error) {
    final statusCode = error.response?.statusCode;
    final body = error.response?.data;

    if (body is Map) {
      final message = body['message'] ?? body['error'];

      if (message != null &&
          message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    if (body is String && body.trim().isNotEmpty) {
      return body.trim();
    }

    if (statusCode == 400) {
      return 'Please check the registration information and try again.';
    }

    if (statusCode == 409) {
      return 'An account with this email already exists. Please sign in instead.';
    }

    return error.message ?? 'Unable to create the learner account.';
  }
}