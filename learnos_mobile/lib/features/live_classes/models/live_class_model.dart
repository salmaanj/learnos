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
      id: '${json['id'] ?? json['_id']}',
      title: '${json['title'] ?? json['name'] ?? 'Live Class'}',
      description: json['description']?.toString(),
      courseTitle: json['courseTitle']?.toString() ??
          (course is Map ? course['title']?.toString() : null),
      tutorName: json['tutorName']?.toString() ??
          (tutor is Map
              ? '${tutor['firstName'] ?? ''} ${tutor['lastName'] ?? ''}'
              .trim()
              : null),
      scheduledAt: _parseDateTime(
        json['scheduledAt'] ??
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

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) {
      return value.toLocal();
    }

    final parsed = DateTime.tryParse(value?.toString() ?? '');

    return (parsed ?? DateTime.now()).toLocal();
  }

  static int _parseInt(dynamic value, {required int fallback}) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}