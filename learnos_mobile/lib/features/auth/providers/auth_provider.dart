import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _error;
  String? _pendingEmail;

  bool isForgotPasswordFlow = false;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  String? get pendingEmail => _pendingEmail;

  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> checkAuthStatus() async {
    final loggedIn = await _authService.isLoggedIn();

    if (loggedIn) {
      _user = await _authService.getCachedUser();
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<bool> login(
    String email,
    String password,
  ) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        email,
        password,
      );

      _user = response.user;
      _status = AuthStatus.authenticated;

      notifyListeners();

      return true;
    } catch (error) {
      _error = _parseLoginError(error);
      _status = AuthStatus.error;

      notifyListeners();

      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
    String? companyCode,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      await _authService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
        companyCode: companyCode,
      );

      _pendingEmail = email.trim().toLowerCase();
      isForgotPasswordFlow = false;

      _status = AuthStatus.unauthenticated;

      notifyListeners();

      return true;
    } catch (error) {
      _error = _parseRegistrationError(error);
      _status = AuthStatus.error;

      notifyListeners();

      return false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    if (_pendingEmail == null) {
      _error = 'No email address is available for OTP verification.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }

    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.verifyOtp(
        _pendingEmail!,
        otp,
      );

      _user = response.user;
      _status = AuthStatus.authenticated;

      notifyListeners();

      return true;
    } catch (error) {
      _error = _parseGenericError(error);
      _status = AuthStatus.error;

      notifyListeners();

      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      await _authService.forgotPassword(email);

      _pendingEmail = email.trim().toLowerCase();
      isForgotPasswordFlow = true;
      _status = AuthStatus.unauthenticated;

      notifyListeners();

      return true;
    } catch (error) {
      _error = _parseGenericError(error);
      _status = AuthStatus.error;

      notifyListeners();

      return false;
    }
  }

  Future<bool> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(
        email,
        otp,
        newPassword,
      );

      isForgotPasswordFlow = false;
      _pendingEmail = null;
      _status = AuthStatus.unauthenticated;

      notifyListeners();

      return true;
    } catch (error) {
      _error = _parseGenericError(error);
      _status = AuthStatus.error;

      notifyListeners();

      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _error = null;
    notifyListeners();

    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      return true;
    } catch (error) {
      _error = _parseGenericError(error);
      notifyListeners();

      return false;
    }
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    _error = null;
    notifyListeners();

    try {
      final updatedUser = await _authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );

      _user = updatedUser;
      notifyListeners();

      return true;
    } catch (error) {
      _error = _parseGenericError(error);
      notifyListeners();

      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();

    _user = null;
    _pendingEmail = null;
    _error = null;
    isForgotPasswordFlow = false;
    _status = AuthStatus.unauthenticated;

    notifyListeners();
  }

  Future<void> forceLogout() async {
    _user = null;
    _pendingEmail = null;
    _error = null;
    isForgotPasswordFlow = false;
    _status = AuthStatus.unauthenticated;

    notifyListeners();
  }

  void clearError() {
    _error = null;

    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  String _parseLoginError(Object error) {
    if (error is DioException) {
      final message = _messageFromDioError(error);

      if (message != null) {
        return _friendlyMessage(message);
      }

      final statusCode = error.response?.statusCode;

      if (statusCode == 400 || statusCode == 401) {
        return 'Incorrect email or password.';
      }

      if (statusCode == 403) {
        return 'Your account is not allowed to sign in. Please contact support.';
      }

      if (statusCode != null && statusCode >= 500) {
        return 'The server is unavailable right now. Please try again shortly.';
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        return 'Unable to reach the server. Check your connection and try again.';
      }

      return 'Unable to sign in. Please try again.';
    }

    return _friendlyMessage(
      error.toString().replaceFirst('Exception: ', ''),
    );
  }

  String _parseRegistrationError(Object error) {
    if (error is DioException) {
      final message = _messageFromDioError(error);

      if (message != null) {
        return _friendlyMessage(message);
      }

      final statusCode = error.response?.statusCode;

      if (statusCode == 409) {
        return 'An account with this email already exists. Please sign in instead.';
      }

      if (statusCode == 400) {
        return 'Please check the registration information and try again.';
      }

      if (statusCode != null && statusCode >= 500) {
        return 'The server is unavailable right now. Please try again shortly.';
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        return 'Unable to reach the server. Check your connection and try again.';
      }

      return 'Unable to create the learner account. Please try again.';
    }

    return _friendlyMessage(
      error.toString().replaceFirst('Exception: ', ''),
    );
  }

  String _parseGenericError(Object error) {
    if (error is DioException) {
      final message = _messageFromDioError(error);

      if (message != null) {
        return _friendlyMessage(message);
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        return 'Unable to reach the server. Check your connection and try again.';
      }

      if (error.response?.statusCode != null &&
          error.response!.statusCode! >= 500) {
        return 'The server is unavailable right now. Please try again shortly.';
      }

      return 'Something went wrong. Please try again.';
    }

    return _friendlyMessage(
      error.toString().replaceFirst('Exception: ', ''),
    );
  }

  String? _messageFromDioError(DioException error) {
    final body = error.response?.data;

    if (body is Map) {
      final message = body['message'] ?? body['error'];

      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    if (body is String && body.trim().isNotEmpty) {
      return body.trim();
    }

    return null;
  }

  String _friendlyMessage(String message) {
    final normalized = message.trim();
    final lowerCase = normalized.toLowerCase();

    if (lowerCase.contains('invalid credential') ||
        lowerCase.contains('bad credential') ||
        lowerCase.contains('invalid password') ||
        lowerCase.contains('incorrect password') ||
        lowerCase.contains('user not found')) {
      return 'Incorrect email or password.';
    }

    if (lowerCase.contains('email already exists') ||
        lowerCase.contains('email already exist') ||
        lowerCase.contains('duplicate') ||
        lowerCase.contains('unique constraint')) {
      return 'An account with this email already exists. Please sign in instead.';
    }

    if (normalized.isEmpty) {
      return 'Something went wrong. Please try again.';
    }

    return normalized;
  }
}