import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../models/course_model.dart';
import '../models/lesson_model.dart';

class CourseOfflineRepository {
  CourseOfflineRepository({
    AppDatabase? database,
  }) : _database = database ?? AppDatabase();

  final AppDatabase _database;


  Future<List<CourseModel>> getMyCourses({
    required Future<List<CourseModel>> Function()
        remoteLoader,
  }) async {
    try {
      final remoteCourses =
          await remoteLoader();

      await cacheCourses(
        remoteCourses,
      );

      return remoteCourses;
    } on DioException {
      return getCachedCourses();
    } catch (_) {
      return getCachedCourses();
    }
  }

  Future<List<CourseModel>> getCachedCourses() async {
    final rows =
        await _database.getCachedCourses();

    return rows
        .map(
          _courseFromRow,
        )
        .toList();
  }

  Future<void> cacheCourses(
    List<CourseModel> courses,
  ) async {
    for (final course in courses) {
      await _database.saveCourse(
        OfflineCoursesCompanion.insert(
          id: course.id,
          title: course.title,
          description: Value(
            course.description,
          ),
          thumbnailUrl: Value(
            course.thumbnailUrl,
          ),
          progressPercent: Value(
            (course.progress * 100)
                .round(),
          ),
          cachedAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> cacheLessons({
    required String courseId,
    required List<LessonModel> lessons,
  }) async {
    for (final lesson in lessons) {
      await _database.saveLesson(
        OfflineLessonsCompanion.insert(
          id: lesson.id,
          courseId: courseId,
          moduleId: Value(
            lesson.moduleId,
          ),
          title: lesson.title,
          description: Value(
            lesson.description,
          ),
          type: Value(
            lesson.type,
          ),
          contentUrl: Value(
            lesson.contentUrl,
          ),
          textContent: Value(
            lesson.textContent,
          ),
          displayOrder: Value(
            lesson.order,
          ),
          downloadable: Value(
            lesson.downloadable,
          ),
          completed: Value(
            lesson.isCompleted,
          ),
          watchedSeconds: Value(
            lesson.watchedSeconds,
          ),
          progressPercent: Value(
            lesson.progressPercent,
          ),
          cachedAt: DateTime.now(),
        ),
      );
    }
  }

  Future<List<OfflineLesson>> getCachedLessons(
    String courseId,
  ) {
    return _database.getCachedLessons(
      courseId,
    );
  }

  CourseModel _courseFromRow(
    OfflineCourse row,
  ) {
    return CourseModel(
      id: row.id,
      title: row.title,
      description: row.description,
      thumbnailUrl: row.thumbnailUrl,
      level: 'BEGINNER',
      status: 'PUBLISHED',
      isPaid: false,
      rating: 0,
      ratingCount: 0,
      enrolledCount: 0,
      totalEnrollments: 0,
      totalLessons: 0,
      completionRate: row.progressPercent,
      tags: const [],
      learningOutcomes: const [],
      progress:
          row.progressPercent / 100,
    );
  }
}