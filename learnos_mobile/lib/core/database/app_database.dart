import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class OfflineCourses extends Table {
  TextColumn get id => text()();

  TextColumn get title => text()();

  TextColumn get description => text().nullable()();

  TextColumn get shortDescription => text().nullable()();

  TextColumn get thumbnailUrl => text().nullable()();

  TextColumn get categoryName => text().nullable()();

  TextColumn get categoryId => text().nullable()();

  TextColumn get instructorName => text().nullable()();

  TextColumn get level => text().withDefault(
        const Constant('BEGINNER'),
      )();

  TextColumn get status => text().withDefault(
        const Constant('PUBLISHED'),
      )();

  BoolColumn get isPaid => boolean().withDefault(
        const Constant(false),
      )();

  RealColumn get price => real().nullable()();

  TextColumn get language => text().nullable()();

  IntColumn get durationMinutes => integer().nullable()();

  RealColumn get rating => real().withDefault(
        const Constant(0.0),
      )();

  IntColumn get ratingCount => integer().withDefault(
        const Constant(0),
      )();

  IntColumn get myRating => integer().nullable()();

  IntColumn get enrolledCount => integer().withDefault(
        const Constant(0),
      )();

  IntColumn get totalEnrollments => integer().withDefault(
        const Constant(0),
      )();

  IntColumn get totalLessons => integer().withDefault(
        const Constant(0),
      )();

  IntColumn get completionRate => integer().withDefault(
        const Constant(0),
      )();

  TextColumn get tagsJson => text().withDefault(
        const Constant('[]'),
      )();

  TextColumn get learningOutcomesJson => text().withDefault(
        const Constant('[]'),
      )();

  BoolColumn get featured => boolean().withDefault(
        const Constant(false),
      )();

  IntColumn get progressPercent => integer().withDefault(
        const Constant(0),
      )();

  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();

  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class OfflineModules extends Table {
  TextColumn get id => text()();

  TextColumn get courseId => text()();

  TextColumn get title => text()();

  TextColumn get description => text().nullable()();

  IntColumn get displayOrder => integer().withDefault(
        const Constant(0),
      )();

  BoolColumn get isPreview => boolean().withDefault(
        const Constant(false),
      )();

  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class OfflineLessons extends Table {
  TextColumn get id => text()();

  TextColumn get courseId => text()();

  TextColumn get moduleId => text().nullable()();

  TextColumn get moduleTitle => text().nullable()();

  TextColumn get title => text()();

  TextColumn get description => text().nullable()();

  TextColumn get type => text().withDefault(
        const Constant('VIDEO'),
      )();

  TextColumn get contentUrl => text().nullable()();

  TextColumn get streamingUrl => text().nullable()();

  TextColumn get textContent => text().nullable()();

  IntColumn get durationMinutes => integer().nullable()();

  IntColumn get durationSeconds => integer().nullable()();

  IntColumn get displayOrder => integer().withDefault(
        const Constant(0),
      )();

  BoolColumn get isPreview => boolean().withDefault(
        const Constant(false),
      )();

  BoolColumn get isPublished => boolean().withDefault(
        const Constant(false),
      )();

  BoolColumn get downloadable => boolean().withDefault(
        const Constant(false),
      )();

  BoolColumn get completed => boolean().withDefault(
        const Constant(false),
      )();

  IntColumn get watchedSeconds => integer().withDefault(
        const Constant(0),
      )();

  IntColumn get progressPercent => integer().withDefault(
        const Constant(0),
      )();

  TextColumn get localFilePath => text().nullable()();

  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();

  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    OfflineCourses,
    OfflineModules,
    OfflineLessons,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(
          driftDatabase(
            name: 'learnos_offline',
          ),
        );

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator migrator) async {
        await migrator.createAll();
      },
      onUpgrade: (
        Migrator migrator,
        int from,
        int to,
      ) async {
        if (from < 2) {
          await migrator.addColumn(
            offlineCourses,
            offlineCourses.shortDescription,
          );
          await migrator.addColumn(
            offlineCourses,
            offlineCourses.categoryName,
          );
          await migrator.addColumn(
            offlineCourses,
            offlineCourses.categoryId,
          );
          await migrator.addColumn(
            offlineCourses,
            offlineCourses.instructorName,
          );
          await migrator.addColumn(
            offlineCourses,
            offlineCourses.level,
          );
          await migrator.addColumn(
            offlineCourses,
            offlineCourses.status,
          );
          await migrator.addColumn(
            offlineCourses,
            offlineCourses.isPaid,
          );
          await migrator.addColumn(
            offlineCourses,
            offlineCourses.price,
          );
          await migrator.addColumn(
            offlineCourses,
            offlineCourses.language,
          );
          await migrator.addColumn(
            offlineCourses,
            offlineCourses.durationMinutes,
          );
          await migrator.addColumn(
            offlineCourses,
            offlineCourses.rating,
          );
          await migrator.addColumn(
            offlineCourses,
            offlineCourses.ratingCount,
          );
          await migrator.addColumn(
            offlineCourses,
            offlineCourses.myRating,
          );
          await migrator.addColumn(
            offlineCourses,
            offlineCourses.enrolledCount,
          );
          await migrator.addColumn(
            offlineCourses,
            offlineCourses.totalEnrollments,
          );
          await migrator.addColumn(
            offlineCourses,
            offlineCourses.totalLessons,
          );
          await migrator.addColumn(
            offlineCourses,
            offlineCourses.completionRate,
          );
          await migrator.addColumn(
            offlineCourses,
            offlineCourses.tagsJson,
          );
          await migrator.addColumn(
            offlineCourses,
            offlineCourses.learningOutcomesJson,
          );
          await migrator.addColumn(
            offlineCourses,
            offlineCourses.featured,
          );
        }

        if (from < 3) {
          await migrator.createTable(offlineModules);

          await migrator.addColumn(
            offlineLessons,
            offlineLessons.moduleTitle,
          );
          await migrator.addColumn(
            offlineLessons,
            offlineLessons.streamingUrl,
          );
          await migrator.addColumn(
            offlineLessons,
            offlineLessons.durationMinutes,
          );
          await migrator.addColumn(
            offlineLessons,
            offlineLessons.durationSeconds,
          );
          await migrator.addColumn(
            offlineLessons,
            offlineLessons.isPreview,
          );
          await migrator.addColumn(
            offlineLessons,
            offlineLessons.isPublished,
          );
        }
      },
    );
  }

  Future<List<OfflineCourse>> getCachedCourses() {
    return (
      select(offlineCourses)
        ..orderBy([
          (course) => OrderingTerm.desc(course.cachedAt),
        ])
    ).get();
  }

  Future<OfflineCourse?> getCachedCourseById(
    String courseId,
  ) {
    return (
      select(offlineCourses)
        ..where(
          (course) => course.id.equals(courseId),
        )
    ).getSingleOrNull();
  }

  Future<List<OfflineModule>> getCachedModules(
    String courseId,
  ) {
    return (
      select(offlineModules)
        ..where(
          (module) => module.courseId.equals(courseId),
        )
        ..orderBy([
          (module) => OrderingTerm.asc(module.displayOrder),
        ])
    ).get();
  }

  Future<List<OfflineLesson>> getCachedLessons(
    String courseId,
  ) {
    return (
      select(offlineLessons)
        ..where(
          (lesson) => lesson.courseId.equals(courseId),
        )
        ..orderBy([
          (lesson) => OrderingTerm.asc(lesson.displayOrder),
        ])
    ).get();
  }

  Future<OfflineLesson?> getCachedLessonById(
    String lessonId,
  ) {
    return (
      select(offlineLessons)
        ..where(
          (lesson) => lesson.id.equals(lessonId),
        )
    ).getSingleOrNull();
  }

  Future<void> saveCourse(
    OfflineCoursesCompanion course,
  ) {
    return into(offlineCourses).insertOnConflictUpdate(course);
  }

  Future<void> saveModule(
    OfflineModulesCompanion module,
  ) {
    return into(offlineModules).insertOnConflictUpdate(module);
  }

  Future<void> saveLesson(
    OfflineLessonsCompanion lesson,
  ) {
    return into(offlineLessons).insertOnConflictUpdate(lesson);
  }

  Future<void> updateLessonLocalFilePath({
    required String lessonId,
    required String? localFilePath,
  }) {
    return (
      update(offlineLessons)
        ..where(
          (lesson) => lesson.id.equals(lessonId),
        )
    ).write(
      OfflineLessonsCompanion(
        localFilePath: Value(localFilePath),
      ),
    );
  }

  Future<void> updateLessonProgress({
    required String lessonId,
    required bool completed,
    required int watchedSeconds,
    required int progressPercent,
    int? durationSeconds,
  }) {
    return (
      update(offlineLessons)
        ..where(
          (lesson) => lesson.id.equals(lessonId),
        )
    ).write(
      OfflineLessonsCompanion(
        completed: Value(completed),
        watchedSeconds: Value(watchedSeconds < 0 ? 0 : watchedSeconds),
        progressPercent: Value(progressPercent.clamp(0, 100)),
        durationSeconds: Value(durationSeconds),
      ),
    );
  }

  Future<void> closeDatabase() {
    return close();
  }
}