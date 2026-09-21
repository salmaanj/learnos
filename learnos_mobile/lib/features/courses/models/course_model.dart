import '../../../core/constants/api_constants.dart';

class CourseModel {
  final String id;
  final String title;
  final String? description;
  final String? shortDescription;
  final String? thumbnailUrl;
  final String? categoryName;
  final String? categoryId;
  final String? instructorName;
  final String level;
  final String status;
  final bool isPaid;
  final double? price;
  final String? language;
  final int? durationMinutes;
  final double rating;
  final int ratingCount;
  final int? myRating;
  final int enrolledCount;
  final int totalEnrollments;
  final int totalLessons;
  final int completionRate;
  final List<String> tags;
  final List<String> learningOutcomes;
  final bool featured;
  final double progress;

  CourseModel({
    required this.id,
    required this.title,
    this.description,
    this.shortDescription,
    this.thumbnailUrl,
    this.categoryName,
    this.categoryId,
    this.instructorName,
    required this.level,
    required this.status,
    required this.isPaid,
    this.price,
    this.language,
    this.durationMinutes,
    required this.rating,
    required this.ratingCount,
    this.myRating,
    required this.enrolledCount,
    required this.totalEnrollments,
    required this.totalLessons,
    required this.completionRate,
    required this.tags,
    required this.learningOutcomes,
    this.featured = false,
    this.progress = 0.0,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    final rawRating = _toDouble(
      json['averageRating'] ?? json['rating'],
    );

    return CourseModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      shortDescription: json['shortDescription']?.toString(),
      thumbnailUrl: ApiConstants.resolveMediaUrl(
        json['thumbnailUrl']?.toString(),
      ),
      categoryName: json['categoryName']?.toString(),
      categoryId: json['categoryId']?.toString(),
      instructorName: json['instructorName']?.toString(),
      level: (json['level'] ?? 'BEGINNER').toString(),
      status: (json['status'] ?? 'DRAFT').toString(),
      isPaid: _toBool(json['paid'] ?? json['isPaid']),
      price: json['price'] == null
          ? null
          : _toDouble(json['price']),
      language: json['language']?.toString(),
      durationMinutes: json['durationMinutes'] == null
          ? null
          : _toInt(json['durationMinutes']),
      rating: _clampRating(rawRating),
      ratingCount: _toInt(json['ratingCount']),
      myRating: _toNullableRating(json['myRating']),
      enrolledCount: _toInt(
        json['enrolledCount'] ?? json['totalEnrollments'],
      ),
      totalEnrollments: _toInt(json['totalEnrollments']),
      totalLessons: _toInt(json['totalLessons']),
      completionRate: _toInt(json['completionRate']),
      tags: _toStringList(json['tags']),
      learningOutcomes: _toStringList(
        json['learningOutcomes'],
      ),
      featured: _toBool(json['featured']),
      progress: _progressFromJson(json),
    );
  }

  CourseModel copyWith({
    double? rating,
    int? ratingCount,
    int? myRating,
    bool clearMyRating = false,
    int? enrolledCount,
    int? completionRate,
    double? progress,
  }) {
    return CourseModel(
      id: id,
      title: title,
      description: description,
      shortDescription: shortDescription,
      thumbnailUrl: thumbnailUrl,
      categoryName: categoryName,
      categoryId: categoryId,
      instructorName: instructorName,
      level: level,
      status: status,
      isPaid: isPaid,
      price: price,
      language: language,
      durationMinutes: durationMinutes,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      myRating: clearMyRating
          ? null
          : (myRating ?? this.myRating),
      enrolledCount: enrolledCount ?? this.enrolledCount,
      totalEnrollments: totalEnrollments,
      totalLessons: totalLessons,
      completionRate: completionRate ?? this.completionRate,
      tags: tags,
      learningOutcomes: learningOutcomes,
      featured: featured,
      progress: progress ?? this.progress,
    );
  }

  String get durationText {
    if (durationMinutes == null) return '';

    final hours = durationMinutes! ~/ 60;
    final minutes = durationMinutes! % 60;

    return hours > 0
        ? '${hours}h ${minutes}m'
        : '${minutes}m';
  }

  String get priceText {
    return isPaid
        ? 'Rs. ${price?.toStringAsFixed(0) ?? '0'}'
        : 'Free';
  }

  String get progressText =>
      '${(progress * 100).toStringAsFixed(0)}% complete';

  String get ratingText {
    if (ratingCount <= 0) return 'No ratings yet';

    return '${rating.toStringAsFixed(1)} '
        '(${ratingCount == 1 ? '1 rating' : '$ratingCount ratings'})';
  }

  static double _progressFromJson(
      Map<String, dynamic> json,
      ) {
    final progressPercent = json['progressPercent'];

    if (progressPercent != null) {
      return _clampProgress(
        _toDouble(progressPercent) / 100,
      );
    }

    return _clampProgress(_toDouble(json['progress']));
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();

    return double.tryParse(value.toString()) ?? 0.0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;

    final normalized = value
        ?.toString()
        .trim()
        .toLowerCase();

    return normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes';
  }

  static int? _toNullableRating(dynamic value) {
    if (value == null) return null;

    final rating = _toInt(value);

    if (rating < 1 || rating > 5) return null;

    return rating;
  }

  static double _clampRating(double value) {
    return value.clamp(0.0, 5.0);
  }

  static double _clampProgress(double value) {
    return value.clamp(0.0, 1.0);
  }

  static List<String> _toStringList(dynamic value) {
    if (value is! List) return [];

    return value
        .map((item) => item.toString())
        .where((item) => item.trim().isNotEmpty)
        .toList();
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final String? color;
  final String? iconUrl;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.color,
    this.iconUrl,
  });

  factory CategoryModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return CategoryModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      color: json['color']?.toString(),
      iconUrl: json['iconUrl']?.toString(),
    );
  }
}