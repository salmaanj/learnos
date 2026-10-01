import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class OfflineCourses extends Table {
  TextColumn get id => text()();

  TextColumn get title => text()();

  TextColumn get description =>
      text().nullable()();

  TextColumn get thumbnailUrl =>
      text().nullable()();

  IntColumn get progressPercent =>
      integer().withDefault(
        const Constant(0),
      )();

  DateTimeColumn get serverUpdatedAt =>
      dateTime().nullable()();

  DateTimeColumn get cachedAt =>
      dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class OfflineLessons extends Table {
  TextColumn get id => text()();

  TextColumn get courseId => text()();

  TextColumn get moduleId =>
      text().nullable()();

  TextColumn get title => text()();

  TextColumn get description =>
      text().nullable()();

  TextColumn get type =>
      text().withDefault(
        const Constant('VIDEO'),
      )();

  TextColumn get contentUrl =>
      text().nullable()();

  TextColumn get textContent =>
      text().nullable()();

  IntColumn get displayOrder =>
      integer().withDefault(
        const Constant(0),
      )();

  BoolColumn get downloadable =>
      boolean().withDefault(
        const Constant(false),
      )();

  BoolColumn get completed =>
      boolean().withDefault(
        const Constant(false),
      )();

  IntColumn get watchedSeconds =>
      integer().withDefault(
        const Constant(0),
      )();

  IntColumn get progressPercent =>
      integer().withDefault(
        const Constant(0),
      )();

  TextColumn get localFilePath =>
      text().nullable()();

  DateTimeColumn get serverUpdatedAt =>
      dateTime().nullable()();

  DateTimeColumn get cachedAt =>
      dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    OfflineCourses,
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
  int get schemaVersion => 1;

  Future<List<OfflineCourse>> getCachedCourses() {
    return select(offlineCourses).get();
  }

  Future<List<OfflineLesson>> getCachedLessons(
    String courseId,
  ) {
    return (
      select(offlineLessons)
        ..where(
          (lesson) =>
              lesson.courseId.equals(courseId),
        )
        ..orderBy([
          (lesson) => OrderingTerm.asc(
                lesson.displayOrder,
              ),
        ])
    ).get();
  }

  Future<void> saveCourse(
    OfflineCoursesCompanion course,
  ) {
    return into(offlineCourses).insertOnConflictUpdate(
      course,
    );
  }

  Future<void> saveLesson(
    OfflineLessonsCompanion lesson,
  ) {
    return into(offlineLessons).insertOnConflictUpdate(
      lesson,
    );
  }

  Future<void> closeDatabase() {
    return close();
  }
}