class LiveClassModel {
  final String id;
  final String title;
  final String? description;
  final String? courseTitle;
  final String? tutorName;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String status;
  final bool joined;
  final bool eligible;
  final bool joinAvailable;
  final String? timezone;

  const LiveClassModel({
    required this.id,
    required this.title,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.status,
    this.description,
    this.courseTitle,
    this.tutorName,
    this.joined = false,
    this.eligible = false,
    this.joinAvailable = false,
    this.timezone,
  });

  bool get canJoin {
    final normalizedStatus = status.trim().toUpperCase();

    return eligible &&
        joinAvailable &&
        normalizedStatus != 'DRAFT' &&
        normalizedStatus != 'CANCELLED' &&
        normalizedStatus != 'COMPLETED';
  }

  String get joinButtonLabel {
    final normalizedStatus = status.trim().toUpperCase();

    if (normalizedStatus == 'CANCELLED') {
      return 'Class Cancelled';
    }

    if (normalizedStatus == 'COMPLETED') {
      return 'Class Completed';
    }

    if (!eligible) {
      return 'Not Available';
    }

    return canJoin ? 'Join Class' : 'Joining Not Open';
  }

  String get availabilityMessage {
    final normalizedStatus = status.trim().toUpperCase();

    if (normalizedStatus == 'CANCELLED') {
      return 'This class has been cancelled.';
    }

    if (normalizedStatus == 'COMPLETED') {
      return 'This class has been completed.';
    }

    if (!eligible) {
      return 'You are not eligible to join this class.';
    }

    return 'Joining is available from 15 minutes before the class '
        'until 30 minutes after it ends.';
  }

  factory LiveClassModel.fromJson(Map<String, dynamic> json) {
    final course = json['course'];
    final tutor = json['tutor'];

    final startValue = json['scheduledAt'] ??
        json['startAt'] ??
        json['startTime'] ??
        json['scheduledDate'] ??
        json['date'];

    final endValue = json['endAt'] ?? json['endTime'];

    final start = _tryParseDateTime(startValue);
    final end = _tryParseDateTime(endValue);

    final explicitDuration = json['durationMinutes'] ??
        json['duration'] ??
        json['durationInMinutes'];

    final calculatedDuration = start != null && end != null
        ? end.difference(start).inMinutes
        : null;

    return LiveClassModel(
      id: '${json['id'] ?? json['_id'] ?? ''}',
      title: '${json['title'] ?? json['name'] ?? 'Live Class'}',
      description: json['description']?.toString(),
      courseTitle: json['courseTitle']?.toString() ??
          (course is Map ? course['title']?.toString() : null),
      tutorName: json['instructorName']?.toString() ??
          json['tutorName']?.toString() ??
          _readPersonName(tutor),
      scheduledAt: start ?? DateTime.fromMillisecondsSinceEpoch(0),
      durationMinutes: _parseInt(
        explicitDuration,
        fallback: calculatedDuration != null && calculatedDuration > 0
            ? calculatedDuration
            : 60,
      ),
      status: '${json['status'] ?? 'SCHEDULED'}',
      joined: _parseBool(json['joined']) ||
          _parseBool(json['isJoined']) ||
          json['joinAt'] != null,
      eligible: _parseBool(json['eligible']),
      joinAvailable: _parseBool(json['joinAvailable']),
      timezone: json['timezone']?.toString(),
    );
  }

  static String? _readPersonName(dynamic person) {
    if (person is! Map) {
      return null;
    }

    final firstName = person['firstName']?.toString().trim() ?? '';
    final lastName = person['lastName']?.toString().trim() ?? '';
    final fullName = person['fullName']?.toString().trim() ?? '';
    final name = '$firstName $lastName'.trim();

    if (name.isNotEmpty) {
      return name;
    }

    return fullName.isEmpty ? null : fullName;
  }

  static DateTime? _tryParseDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    final text = value?.toString().trim() ?? '';

    if (text.isEmpty) {
      return null;
    }

    // Backend startAt/endAt are class-local wall-clock values.
    // Keep those components for display and show the timezone separately.
    // Join permission always comes from the backend.
    return DateTime.tryParse(text);
  }

  static int _parseInt(dynamic value, {required int fallback}) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    final text = value?.toString().trim().toLowerCase();

    return text == 'true' || text == '1';
  }
}
