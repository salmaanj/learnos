import '../../../core/constants/api_constants.dart';

class LessonModel {
  final String id;
  final String title;
  final String? description;
  final String? contentUrl;
  final String? streamingUrl;
  final String? localFilePath;
  final String? textContent;
  final String type;
  final int? durationMinutes;
  final int? durationSeconds;
  final int order;
  final bool isPreview;
  final bool isPublished;
  final bool downloadable;
  final bool isCompleted;
  final int watchedSeconds;
  final int progressPercent;
  final String? moduleId;
  final String? moduleTitle;

  LessonModel({
    required this.id,
    required this.title,
    this.description,
    this.contentUrl,
    this.streamingUrl,
    this.localFilePath,
    this.textContent,
    this.type = 'VIDEO',
    this.durationMinutes,
    this.durationSeconds,
    required this.order,
    this.isPreview = false,
    this.isPublished = false,
    this.downloadable = false,
    this.isCompleted = false,
    this.watchedSeconds = 0,
    this.progressPercent = 0,
    this.moduleId,
    this.moduleTitle,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    final seconds = _toInt(json['durationSeconds']);
    final durationValue = json['durationMinutes'] ?? json['duration'];
    final rawContent = _nonEmpty(
      json['contentUrl'] ?? json['content_url'] ?? json['url'],
    );
    final rawStreaming = _nonEmpty(
      json['streamingUrl'] ??
          json['streaming_url'] ??
          json['videoUrl'] ??
          json['video_url'],
    );

    return LessonModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      contentUrl: ApiConstants.resolveMediaUrl(rawContent),
      streamingUrl: ApiConstants.resolveMediaUrl(rawStreaming),
      localFilePath: _nonEmpty(
        json['localFilePath'] ?? json['local_file_path'],
      ),
      textContent: json['textContent']?.toString(),
      type: (json['type']?.toString() ?? 'VIDEO').toUpperCase(),
      durationMinutes: durationValue != null
          ? _toInt(durationValue)
          : _secondsToMinutes(seconds),
      durationSeconds: seconds,
      order: _toInt(
            json['displayOrder'] ??
                json['order'] ??
                json['sortOrder'],
          ) ??
          0,
      isPreview: _toBool(json['preview'] ?? json['isPreview']),
      isPublished: _toBool(json['published'] ?? json['isPublished']),
      downloadable: _toBool(
        json['downloadable'] ?? json['isDownloadable'],
      ),
      isCompleted: _toBool(json['completed'] ?? json['isCompleted']),
      watchedSeconds: _toInt(json['watchedSeconds']) ?? 0,
      progressPercent: _toInt(json['progressPercent']) ?? 0,
      moduleId: json['moduleId']?.toString(),
      moduleTitle: json['moduleTitle']?.toString(),
    );
  }

  String? get mediaUrl =>
      _hasValue(localFilePath)
          ? localFilePath
          : _hasValue(streamingUrl)
              ? streamingUrl
              : contentUrl;

  String? get documentUrl =>
      _hasValue(localFilePath) ? localFilePath : contentUrl;

  String? get videoUrl => mediaUrl;

  bool get hasLocalFile => _hasValue(localFilePath);

  LessonModel copyWith({
    String? contentUrl,
    String? streamingUrl,
    String? localFilePath,
    String? textContent,
    int? durationMinutes,
    bool? isCompleted,
    int? watchedSeconds,
    int? progressPercent,
    int? durationSeconds,
    bool? downloadable,
  }) {
    return LessonModel(
      id: id,
      title: title,
      description: description,
      contentUrl: contentUrl ?? this.contentUrl,
      streamingUrl: streamingUrl ?? this.streamingUrl,
      localFilePath: localFilePath ?? this.localFilePath,
      textContent: textContent ?? this.textContent,
      type: type,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      order: order,
      isPreview: isPreview,
      isPublished: isPublished,
      downloadable: downloadable ?? this.downloadable,
      isCompleted: isCompleted ?? this.isCompleted,
      watchedSeconds: watchedSeconds ?? this.watchedSeconds,
      progressPercent: progressPercent ?? this.progressPercent,
      moduleId: moduleId,
      moduleTitle: moduleTitle,
    );
  }

  static String? _nonEmpty(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  static int? _secondsToMinutes(int? seconds) {
    return seconds == null ? null : (seconds / 60).ceil();
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;

    final normalized = value?.toString().trim().toLowerCase();

    return normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes';
  }

  String get durationText {
    if (durationMinutes == null) return '';

    final hours = durationMinutes! ~/ 60;
    final minutes = durationMinutes! % 60;

    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }

  bool get isYoutube {
    final url = streamingUrl;

    return _hasValue(url) &&
        (url!.contains('youtube.com') || url.contains('youtu.be'));
  }

  String? get youtubeId {
    final url = streamingUrl;

    if (!isYoutube || url == null) return null;

    final uri = Uri.tryParse(url);

    if (uri == null) return null;

    if (uri.queryParameters.containsKey('v')) {
      return uri.queryParameters['v'];
    }

    return uri.pathSegments.isNotEmpty
        ? uri.pathSegments.last
        : null;
  }
}