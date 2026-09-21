import 'dart:convert';

class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final String role;
  final String? profileImageUrl;
  final String? companyId;
  final String? companyName;
  final String? companyLogoUrl;
  final String? phone;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.role,
    this.profileImageUrl,
    this.companyId,
    this.companyName,
    this.companyLogoUrl,
    this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      role: (json['role'] ?? 'LEARNER').toString(),
      profileImageUrl: json['profileImageUrl']?.toString(),
      companyId: json['companyId']?.toString(),
      companyName: json['companyName']?.toString(),
      companyLogoUrl: json['companyLogoUrl']?.toString(),
      phone: json['phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'role': role,
      'profileImageUrl': profileImageUrl,
      'companyId': companyId,
      'companyName': companyName,
      'companyLogoUrl': companyLogoUrl,
      'phone': phone,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  static UserModel fromJsonString(String json) {
    return UserModel.fromJson(
      Map<String, dynamic>.from(jsonDecode(json) as Map),
    );
  }

  bool get isSuperAdmin => role == 'SUPER_ADMIN';

  bool get isCompanyAdmin => role == 'COMPANY_ADMIN';

  bool get isInstructor => role == 'INSTRUCTOR';

  bool get isLearner => role == 'LEARNER';
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: (json['accessToken'] ?? '').toString(),
      refreshToken: (json['refreshToken'] ?? '').toString(),
      user: UserModel.fromJson(
        Map<String, dynamic>.from(json['user'] as Map),
      ),
    );
  }
}