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
  });

  factory LiveClassModel.fromJson(Map<String, dynamic> json) {
    final course = json['course'];
    final tutor = json['tutor'];

    return LiveClassModel(
      id: '${json['id'] ?? json['_id'] ?? ''}',
      title: '${json['title'] ?? json['name'] ?? 'Live Class'}',
      description: json['description']?.toString(),
      courseTitle: json['courseTitle']?.toString() ??
          (course is Map ? course['title']?.toString() : null),
      tutorName: json['tutorName']?.toString() ??
          _readPersonName(tutor),
      scheduledAt: _parseDateTime(
        json['scheduledAt'] ??
            json['startAt'] ??
            json['startTime'] ??
            json['scheduledDate'] ??
            json['date'],
      ),
      durationMinutes: _parseInt(
        json['durationMinutes'] ??
            json['duration'] ??
            json['durationInMinutes'],
        fallback: 60,
      ),
      status: '${json['status'] ?? 'SCHEDULED'}',
      joined: json['joined'] == true || json['isJoined'] == true,
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

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) {
      return value.toLocal();
    }

    final text = value?.toString().trim() ?? '';
    final parsed = DateTime.tryParse(text);

    if (parsed != null) {
      return parsed.toLocal();
    }

    // The API must provide the scheduled date/time. This fallback only
    // prevents a malformed response from crashing the mobile screen.
    return DateTime.fromMillisecondsSinceEpoch(0).toLocal();
  }

  static int _parseInt(dynamic value, {required int fallback}) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}