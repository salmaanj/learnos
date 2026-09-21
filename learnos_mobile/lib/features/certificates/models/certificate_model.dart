class CertificateModel {
  final String id;
  final String certificateNumber;
  final String verificationCode;
  final String learnerName;
  final String courseId;
  final String courseTitle;
  final String? companyId;
  final String? companyName;
  final int? quizScorePercent;
  final String status;
  final DateTime? issuedAt;
  final DateTime? revokedAt;
  final String? revocationReason;

  CertificateModel({
    required this.id,
    required this.certificateNumber,
    required this.verificationCode,
    required this.learnerName,
    required this.courseId,
    required this.courseTitle,
    this.companyId,
    this.companyName,
    this.quizScorePercent,
    required this.status,
    this.issuedAt,
    this.revokedAt,
    this.revocationReason,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      id: (json['id'] ?? '').toString(),
      certificateNumber: (json['certificateNumber'] ?? '').toString(),
      verificationCode: (json['verificationCode'] ?? '').toString(),
      learnerName: (json['learnerName'] ?? '').toString(),
      courseId: (json['courseId'] ?? '').toString(),
      courseTitle: (json['courseTitle'] ?? '').toString(),
      companyId: json['companyId']?.toString(),
      companyName: json['companyName']?.toString(),
      quizScorePercent: _toNullableInt(json['quizScorePercent']),
      status: (json['status'] ?? 'ISSUED').toString().toUpperCase(),
      issuedAt: _toDate(json['issuedAt']),
      revokedAt: _toDate(json['revokedAt']),
      revocationReason: json['revocationReason']?.toString(),
    );
  }

  bool get isIssued => status == 'ISSUED';

  bool get isRevoked => status == 'REVOKED';

  String get scoreLabel {
    return quizScorePercent == null ? 'Passed' : '$quizScorePercent%';
  }

  String get issueDateLabel {
    if (issuedAt == null) {
      return '—';
    }

    final day = issuedAt!.day.toString().padLeft(2, '0');
    final month = issuedAt!.month.toString().padLeft(2, '0');
    final year = issuedAt!.year.toString();

    return '$day-$month-$year';
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
  }
}