import 'lesson_model.dart';

class ModuleModel {
  final String id;
  final String title;
  final String? description;
  final int displayOrder;
  final bool isPreview;
  final List<LessonModel> lessons;

  ModuleModel({
    required this.id,
    required this.title,
    this.description,
    required this.displayOrder,
    this.isPreview = false,
    this.lessons = const [],
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      isPreview: json['isPreview'] == true || json['preview'] == true,
      lessons: const [],
    );
  }

  ModuleModel copyWith({List<LessonModel>? lessons}) {
    return ModuleModel(
      id: id,
      title: title,
      description: description,
      displayOrder: displayOrder,
      isPreview: isPreview,
      lessons: lessons ?? this.lessons,
    );
  }
}
