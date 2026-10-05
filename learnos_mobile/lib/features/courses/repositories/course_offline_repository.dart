import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../models/course_model.dart';
import '../models/lesson_model.dart';
import '../models/module_model.dart';

class OfflineCourseResult {
  final List<CourseModel> courses;
  final bool fromCache;

  const OfflineCourseResult({
    required this.courses,
    required this.fromCache,
  });
}

class OfflineCourseContentResult {
  final List<ModuleModel> modules;
  final bool fromCache;

  const OfflineCourseContentResult({
    required this.modules,
    required this.fromCache,
  });
}

class OfflineLessonsResult {
  final List<LessonModel> lessons;
  final bool fromCache;

  const OfflineLessonsResult({
    required this.lessons,
    required this.fromCache,
  });
}

class CourseOfflineRepository {
  CourseOfflineRepository({
    AppDatabase? database,
  }) : _database = database ?? AppDatabase();

  final AppDatabase _database;

  Future<OfflineCourseResult> getMyCourses({
    required Future<List<CourseModel>> Function() remoteLoader,
  }) async {
    try {
      final remoteCourses = await remoteLoader();
      await cacheCourses(remoteCourses);

      return OfflineCourseResult(
        courses: remoteCourses,
        fromCache: false,
      );
    } on DioException {
      return OfflineCourseResult(
        courses: await getCachedCourses(),
        fromCache: true,
      );
    } catch (_) {
      return OfflineCourseResult(
        courses: await getCachedCourses(),
        fromCache: true,
      );
    }
  }

  Future<List<CourseModel>> getCachedCourses() async {
    final rows = await _database.getCachedCourses();
    return rows.map(_courseFromRow).toList();
  }

  Future<CourseModel?> getCachedCourseById(
    String courseId,
  ) async {
    final row = await _database.getCachedCourseById(courseId);

    if (row == null) {
      return null;
    }

    return _courseFromRow(row);
  }

  Future<void> cacheCourses(
    List<CourseModel> courses,
  ) async {
    final cachedAt = DateTime.now();

    for (final course in courses) {
      await _database.saveCourse(
        OfflineCoursesCompanion.insert(
          id: course.id,
          title: course.title,
          description: Value(course.description),
          shortDescription: Value(course.shortDescription),
          thumbnailUrl: Value(course.thumbnailUrl),
          categoryName: Value(course.categoryName),
          categoryId: Value(course.categoryId),
          instructorName: Value(course.instructorName),
          level: Value(course.level),
          status: Value(course.status),
          isPaid: Value(course.isPaid),
          price: Value(course.price),
          language: Value(course.language),
          durationMinutes: Value(course.durationMinutes),
          rating: Value(course.rating),
          ratingCount: Value(course.ratingCount),
          myRating: Value(course.myRating),
          enrolledCount: Value(course.enrolledCount),
          totalEnrollments: Value(course.totalEnrollments),
          totalLessons: Value(course.totalLessons),
          completionRate: Value(course.completionRate),
          tagsJson: Value(jsonEncode(course.tags)),
          learningOutcomesJson: Value(
            jsonEncode(course.learningOutcomes),
          ),
          featured: Value(course.featured),
          progressPercent: Value(
            (course.progress * 100).round().clamp(0, 100),
          ),
          cachedAt: cachedAt,
        ),
      );
    }
  }

  Future<void> cacheCourse(
    CourseModel course,
  ) {
    return cacheCourses([course]);
  }

  Future<void> cacheCourseContent({
    required String courseId,
    required List<ModuleModel> modules,
  }) async {
    final cachedAt = DateTime.now();

    for (final module in modules) {
      await _database.saveModule(
        OfflineModulesCompanion.insert(
          id: module.id,
          courseId: courseId,
          title: module.title,
          description: Value(module.description),
          displayOrder: Value(module.displayOrder),
          isPreview: Value(module.isPreview),
          cachedAt: cachedAt,
        ),
      );

      await cacheLessons(
        courseId: courseId,
        lessons: module.lessons,
        moduleTitles: {
          module.id: module.title,
        },
      );
    }
  }

  Future<void> cacheLessons({
    required String courseId,
    required List<LessonModel> lessons,
    Map<String, String>? moduleTitles,
  }) async {
    final cachedAt = DateTime.now();

    for (final lesson in lessons) {
      final existing = await _database.getCachedLessonById(lesson.id);

      final moduleTitle = lesson.moduleTitle ??
          (lesson.moduleId == null
              ? null
              : moduleTitles?[lesson.moduleId]);

      await _database.saveLesson(
        OfflineLessonsCompanion.insert(
          id: lesson.id,
          courseId: courseId,
          moduleId: Value(lesson.moduleId),
          moduleTitle: Value(moduleTitle),
          title: lesson.title,
          description: Value(lesson.description),
          type: Value(lesson.type),
          contentUrl: Value(lesson.contentUrl),
          streamingUrl: Value(lesson.streamingUrl),
          textContent: Value(lesson.textContent),
          durationMinutes: Value(lesson.durationMinutes),
          durationSeconds: Value(lesson.durationSeconds),
          displayOrder: Value(lesson.order),
          isPreview: Value(lesson.isPreview),
          isPublished: Value(lesson.isPublished),
          downloadable: Value(lesson.downloadable),
          completed: Value(lesson.isCompleted),
          watchedSeconds: Value(lesson.watchedSeconds),
          progressPercent: Value(lesson.progressPercent),
          localFilePath: Value(
            lesson.localFilePath ?? existing?.localFilePath,
          ),
          cachedAt: cachedAt,
        ),
      );
    }
  }

  Future<OfflineCourseContentResult> getCachedCourseContent(
    String courseId,
  ) async {
    final moduleRows = await _database.getCachedModules(courseId);
    final lessonRows = await _database.getCachedLessons(courseId);

    if (moduleRows.isEmpty) {
      return const OfflineCourseContentResult(
        modules: [],
        fromCache: true,
      );
    }

    final lessonsByModuleId = <String, List<LessonModel>>{};

    for (final row in lessonRows) {
      final moduleId = row.moduleId;

      if (moduleId == null || moduleId.isEmpty) {
        continue;
      }

      lessonsByModuleId.putIfAbsent(moduleId, () => []).add(
            _lessonFromRow(row),
          );
    }

    final modules = moduleRows.map((row) {
      final lessons = List<LessonModel>.from(
        lessonsByModuleId[row.id] ?? const [],
      )..sort(
          (left, right) => left.order.compareTo(right.order),
        );

      return ModuleModel(
        id: row.id,
        title: row.title,
        description: row.description,
        displayOrder: row.displayOrder,
        isPreview: row.isPreview,
        lessons: lessons,
      );
    }).toList()
      ..sort(
        (left, right) => left.displayOrder.compareTo(right.displayOrder),
      );

    return OfflineCourseContentResult(
      modules: modules,
      fromCache: true,
    );
  }

  Future<OfflineLessonsResult> getCachedLessons(
    String courseId,
  ) async {
    final rows = await _database.getCachedLessons(courseId);

    final lessons = rows
        .map(_lessonFromRow)
        .where((lesson) => lesson.isPublished)
        .toList()
      ..sort(
        (left, right) => left.order.compareTo(right.order),
      );

    return OfflineLessonsResult(
      lessons: lessons,
      fromCache: true,
    );
  }

  Future<void> saveLocalLessonFile({
    required String lessonId,
    required String localFilePath,
  }) {
    return _database.updateLessonLocalFilePath(
      lessonId: lessonId,
      localFilePath: localFilePath,
    );
  }

  Future<void> saveLocalLessonProgress({
    required String lessonId,
    required bool completed,
    required int watchedSeconds,
    required int progressPercent,
    int? durationSeconds,
  }) {
    return _database.updateLessonProgress(
      lessonId: lessonId,
      completed: completed,
      watchedSeconds: watchedSeconds,
      progressPercent: progressPercent,
      durationSeconds: durationSeconds,
    );
  }

  CourseModel _courseFromRow(
    OfflineCourse row,
  ) {
    return CourseModel(
      id: row.id,
      title: row.title,
      description: row.description,
      shortDescription: row.shortDescription,
      thumbnailUrl: row.thumbnailUrl,
      categoryName: row.categoryName,
      categoryId: row.categoryId,
      instructorName: row.instructorName,
      level: row.level,
      status: row.status,
      isPaid: row.isPaid,
      price: row.price,
      language: row.language,
      durationMinutes: row.durationMinutes,
      rating: row.rating,
      ratingCount: row.ratingCount,
      myRating: row.myRating,
      enrolledCount: row.enrolledCount,
      totalEnrollments: row.totalEnrollments,
      totalLessons: row.totalLessons,
      completionRate: row.completionRate,
      tags: _stringListFromJson(row.tagsJson),
      learningOutcomes: _stringListFromJson(
        row.learningOutcomesJson,
      ),
      featured: row.featured,
      progress: row.progressPercent / 100,
    );
  }

  LessonModel _lessonFromRow(
    OfflineLesson row,
  ) {
    return LessonModel(
      id: row.id,
      title: row.title,
      description: row.description,
      contentUrl: row.contentUrl,
      streamingUrl: row.streamingUrl,
      localFilePath: row.localFilePath,
      textContent: row.textContent,
      type: row.type,
      durationMinutes: row.durationMinutes,
      durationSeconds: row.durationSeconds,
      order: row.displayOrder,
      isPreview: row.isPreview,
      isPublished: row.isPublished,
      downloadable: row.downloadable,
      isCompleted: row.completed,
      watchedSeconds: row.watchedSeconds,
      progressPercent: row.progressPercent,
      moduleId: row.moduleId,
      moduleTitle: row.moduleTitle,
    );
  }

  List<String> _stringListFromJson(
    String value,
  ) {
    try {
      final decoded = jsonDecode(value);

      if (decoded is! List) {
        return const [];
      }

      return decoded
          .map((item) => item.toString())
          .where(
            (item) => item.trim().isNotEmpty,
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }
}