import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static Future<void> saveToken(String token) async =>
      await _storage.write(key: AppConstants.tokenKey, value: token);

  static Future<String?> getToken() async =>
      await _storage.read(key: AppConstants.tokenKey);

  static Future<void> saveRefreshToken(String token) async =>
      await _storage.write(key: AppConstants.refreshKey, value: token);

  static Future<String?> getRefreshToken() async =>
      await _storage.read(key: AppConstants.refreshKey);

  static Future<void> saveUserData(String json) async =>
      await _storage.write(key: AppConstants.userKey, value: json);

  static Future<String?> getUserData() async =>
      await _storage.read(key: AppConstants.userKey);

  static Future<void> clearAll() async => await _storage.deleteAll();
}
