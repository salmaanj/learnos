// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $OfflineCoursesTable extends OfflineCourses
    with TableInfo<$OfflineCoursesTable, OfflineCourse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineCoursesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _shortDescriptionMeta =
      const VerificationMeta('shortDescription');
  @override
  late final GeneratedColumn<String> shortDescription = GeneratedColumn<String>(
      'short_description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _thumbnailUrlMeta =
      const VerificationMeta('thumbnailUrl');
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
      'thumbnail_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryNameMeta =
      const VerificationMeta('categoryName');
  @override
  late final GeneratedColumn<String> categoryName = GeneratedColumn<String>(
      'category_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _instructorNameMeta =
      const VerificationMeta('instructorName');
  @override
  late final GeneratedColumn<String> instructorName = GeneratedColumn<String>(
      'instructor_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
      'level', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('BEGINNER'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('PUBLISHED'));
  static const VerificationMeta _isPaidMeta = const VerificationMeta('isPaid');
  @override
  late final GeneratedColumn<bool> isPaid = GeneratedColumn<bool>(
      'is_paid', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_paid" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
      'price', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _languageMeta =
      const VerificationMeta('language');
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
      'language', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _durationMinutesMeta =
      const VerificationMeta('durationMinutes');
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
      'duration_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
      'rating', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _ratingCountMeta =
      const VerificationMeta('ratingCount');
  @override
  late final GeneratedColumn<int> ratingCount = GeneratedColumn<int>(
      'rating_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _myRatingMeta =
      const VerificationMeta('myRating');
  @override
  late final GeneratedColumn<int> myRating = GeneratedColumn<int>(
      'my_rating', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _enrolledCountMeta =
      const VerificationMeta('enrolledCount');
  @override
  late final GeneratedColumn<int> enrolledCount = GeneratedColumn<int>(
      'enrolled_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalEnrollmentsMeta =
      const VerificationMeta('totalEnrollments');
  @override
  late final GeneratedColumn<int> totalEnrollments = GeneratedColumn<int>(
      'total_enrollments', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalLessonsMeta =
      const VerificationMeta('totalLessons');
  @override
  late final GeneratedColumn<int> totalLessons = GeneratedColumn<int>(
      'total_lessons', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _completionRateMeta =
      const VerificationMeta('completionRate');
  @override
  late final GeneratedColumn<int> completionRate = GeneratedColumn<int>(
      'completion_rate', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _tagsJsonMeta =
      const VerificationMeta('tagsJson');
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
      'tags_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _learningOutcomesJsonMeta =
      const VerificationMeta('learningOutcomesJson');
  @override
  late final GeneratedColumn<String> learningOutcomesJson =
      GeneratedColumn<String>('learning_outcomes_json', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _featuredMeta =
      const VerificationMeta('featured');
  @override
  late final GeneratedColumn<bool> featured = GeneratedColumn<bool>(
      'featured', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("featured" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _progressPercentMeta =
      const VerificationMeta('progressPercent');
  @override
  late final GeneratedColumn<int> progressPercent = GeneratedColumn<int>(
      'progress_percent', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _serverUpdatedAtMeta =
      const VerificationMeta('serverUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> serverUpdatedAt =
      GeneratedColumn<DateTime>('server_updated_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        description,
        shortDescription,
        thumbnailUrl,
        categoryName,
        categoryId,
        instructorName,
        level,
        status,
        isPaid,
        price,
        language,
        durationMinutes,
        rating,
        ratingCount,
        myRating,
        enrolledCount,
        totalEnrollments,
        totalLessons,
        completionRate,
        tagsJson,
        learningOutcomesJson,
        featured,
        progressPercent,
        serverUpdatedAt,
        cachedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_courses';
  @override
  VerificationContext validateIntegrity(Insertable<OfflineCourse> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('short_description')) {
      context.handle(
          _shortDescriptionMeta,
          shortDescription.isAcceptableOrUnknown(
              data['short_description']!, _shortDescriptionMeta));
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
          _thumbnailUrlMeta,
          thumbnailUrl.isAcceptableOrUnknown(
              data['thumbnail_url']!, _thumbnailUrlMeta));
    }
    if (data.containsKey('category_name')) {
      context.handle(
          _categoryNameMeta,
          categoryName.isAcceptableOrUnknown(
              data['category_name']!, _categoryNameMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('instructor_name')) {
      context.handle(
          _instructorNameMeta,
          instructorName.isAcceptableOrUnknown(
              data['instructor_name']!, _instructorNameMeta));
    }
    if (data.containsKey('level')) {
      context.handle(
          _levelMeta, level.isAcceptableOrUnknown(data['level']!, _levelMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('is_paid')) {
      context.handle(_isPaidMeta,
          isPaid.isAcceptableOrUnknown(data['is_paid']!, _isPaidMeta));
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    }
    if (data.containsKey('language')) {
      context.handle(_languageMeta,
          language.isAcceptableOrUnknown(data['language']!, _languageMeta));
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
          _durationMinutesMeta,
          durationMinutes.isAcceptableOrUnknown(
              data['duration_minutes']!, _durationMinutesMeta));
    }
    if (data.containsKey('rating')) {
      context.handle(_ratingMeta,
          rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));
    }
    if (data.containsKey('rating_count')) {
      context.handle(
          _ratingCountMeta,
          ratingCount.isAcceptableOrUnknown(
              data['rating_count']!, _ratingCountMeta));
    }
    if (data.containsKey('my_rating')) {
      context.handle(_myRatingMeta,
          myRating.isAcceptableOrUnknown(data['my_rating']!, _myRatingMeta));
    }
    if (data.containsKey('enrolled_count')) {
      context.handle(
          _enrolledCountMeta,
          enrolledCount.isAcceptableOrUnknown(
              data['enrolled_count']!, _enrolledCountMeta));
    }
    if (data.containsKey('total_enrollments')) {
      context.handle(
          _totalEnrollmentsMeta,
          totalEnrollments.isAcceptableOrUnknown(
              data['total_enrollments']!, _totalEnrollmentsMeta));
    }
    if (data.containsKey('total_lessons')) {
      context.handle(
          _totalLessonsMeta,
          totalLessons.isAcceptableOrUnknown(
              data['total_lessons']!, _totalLessonsMeta));
    }
    if (data.containsKey('completion_rate')) {
      context.handle(
          _completionRateMeta,
          completionRate.isAcceptableOrUnknown(
              data['completion_rate']!, _completionRateMeta));
    }
    if (data.containsKey('tags_json')) {
      context.handle(_tagsJsonMeta,
          tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta));
    }
    if (data.containsKey('learning_outcomes_json')) {
      context.handle(
          _learningOutcomesJsonMeta,
          learningOutcomesJson.isAcceptableOrUnknown(
              data['learning_outcomes_json']!, _learningOutcomesJsonMeta));
    }
    if (data.containsKey('featured')) {
      context.handle(_featuredMeta,
          featured.isAcceptableOrUnknown(data['featured']!, _featuredMeta));
    }
    if (data.containsKey('progress_percent')) {
      context.handle(
          _progressPercentMeta,
          progressPercent.isAcceptableOrUnknown(
              data['progress_percent']!, _progressPercentMeta));
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
          _serverUpdatedAtMeta,
          serverUpdatedAt.isAcceptableOrUnknown(
              data['server_updated_at']!, _serverUpdatedAtMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfflineCourse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineCourse(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      shortDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}short_description']),
      thumbnailUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thumbnail_url']),
      categoryName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_name']),
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      instructorName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}instructor_name']),
      level: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}level'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      isPaid: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_paid'])!,
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price']),
      language: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language']),
      durationMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_minutes']),
      rating: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rating'])!,
      ratingCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rating_count'])!,
      myRating: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}my_rating']),
      enrolledCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}enrolled_count'])!,
      totalEnrollments: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_enrollments'])!,
      totalLessons: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_lessons'])!,
      completionRate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}completion_rate'])!,
      tagsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags_json'])!,
      learningOutcomesJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}learning_outcomes_json'])!,
      featured: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}featured'])!,
      progressPercent: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}progress_percent'])!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}server_updated_at']),
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $OfflineCoursesTable createAlias(String alias) {
    return $OfflineCoursesTable(attachedDatabase, alias);
  }
}

class OfflineCourse extends DataClass implements Insertable<OfflineCourse> {
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
  final String tagsJson;
  final String learningOutcomesJson;
  final bool featured;
  final int progressPercent;
  final DateTime? serverUpdatedAt;
  final DateTime cachedAt;
  const OfflineCourse(
      {required this.id,
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
      required this.tagsJson,
      required this.learningOutcomesJson,
      required this.featured,
      required this.progressPercent,
      this.serverUpdatedAt,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || shortDescription != null) {
      map['short_description'] = Variable<String>(shortDescription);
    }
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    if (!nullToAbsent || categoryName != null) {
      map['category_name'] = Variable<String>(categoryName);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || instructorName != null) {
      map['instructor_name'] = Variable<String>(instructorName);
    }
    map['level'] = Variable<String>(level);
    map['status'] = Variable<String>(status);
    map['is_paid'] = Variable<bool>(isPaid);
    if (!nullToAbsent || price != null) {
      map['price'] = Variable<double>(price);
    }
    if (!nullToAbsent || language != null) {
      map['language'] = Variable<String>(language);
    }
    if (!nullToAbsent || durationMinutes != null) {
      map['duration_minutes'] = Variable<int>(durationMinutes);
    }
    map['rating'] = Variable<double>(rating);
    map['rating_count'] = Variable<int>(ratingCount);
    if (!nullToAbsent || myRating != null) {
      map['my_rating'] = Variable<int>(myRating);
    }
    map['enrolled_count'] = Variable<int>(enrolledCount);
    map['total_enrollments'] = Variable<int>(totalEnrollments);
    map['total_lessons'] = Variable<int>(totalLessons);
    map['completion_rate'] = Variable<int>(completionRate);
    map['tags_json'] = Variable<String>(tagsJson);
    map['learning_outcomes_json'] = Variable<String>(learningOutcomesJson);
    map['featured'] = Variable<bool>(featured);
    map['progress_percent'] = Variable<int>(progressPercent);
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  OfflineCoursesCompanion toCompanion(bool nullToAbsent) {
    return OfflineCoursesCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      shortDescription: shortDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(shortDescription),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      categoryName: categoryName == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryName),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      instructorName: instructorName == null && nullToAbsent
          ? const Value.absent()
          : Value(instructorName),
      level: Value(level),
      status: Value(status),
      isPaid: Value(isPaid),
      price:
          price == null && nullToAbsent ? const Value.absent() : Value(price),
      language: language == null && nullToAbsent
          ? const Value.absent()
          : Value(language),
      durationMinutes: durationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMinutes),
      rating: Value(rating),
      ratingCount: Value(ratingCount),
      myRating: myRating == null && nullToAbsent
          ? const Value.absent()
          : Value(myRating),
      enrolledCount: Value(enrolledCount),
      totalEnrollments: Value(totalEnrollments),
      totalLessons: Value(totalLessons),
      completionRate: Value(completionRate),
      tagsJson: Value(tagsJson),
      learningOutcomesJson: Value(learningOutcomesJson),
      featured: Value(featured),
      progressPercent: Value(progressPercent),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      cachedAt: Value(cachedAt),
    );
  }

  factory OfflineCourse.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineCourse(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      shortDescription: serializer.fromJson<String?>(json['shortDescription']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      categoryName: serializer.fromJson<String?>(json['categoryName']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      instructorName: serializer.fromJson<String?>(json['instructorName']),
      level: serializer.fromJson<String>(json['level']),
      status: serializer.fromJson<String>(json['status']),
      isPaid: serializer.fromJson<bool>(json['isPaid']),
      price: serializer.fromJson<double?>(json['price']),
      language: serializer.fromJson<String?>(json['language']),
      durationMinutes: serializer.fromJson<int?>(json['durationMinutes']),
      rating: serializer.fromJson<double>(json['rating']),
      ratingCount: serializer.fromJson<int>(json['ratingCount']),
      myRating: serializer.fromJson<int?>(json['myRating']),
      enrolledCount: serializer.fromJson<int>(json['enrolledCount']),
      totalEnrollments: serializer.fromJson<int>(json['totalEnrollments']),
      totalLessons: serializer.fromJson<int>(json['totalLessons']),
      completionRate: serializer.fromJson<int>(json['completionRate']),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      learningOutcomesJson:
          serializer.fromJson<String>(json['learningOutcomesJson']),
      featured: serializer.fromJson<bool>(json['featured']),
      progressPercent: serializer.fromJson<int>(json['progressPercent']),
      serverUpdatedAt: serializer.fromJson<DateTime?>(json['serverUpdatedAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'shortDescription': serializer.toJson<String?>(shortDescription),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'categoryName': serializer.toJson<String?>(categoryName),
      'categoryId': serializer.toJson<String?>(categoryId),
      'instructorName': serializer.toJson<String?>(instructorName),
      'level': serializer.toJson<String>(level),
      'status': serializer.toJson<String>(status),
      'isPaid': serializer.toJson<bool>(isPaid),
      'price': serializer.toJson<double?>(price),
      'language': serializer.toJson<String?>(language),
      'durationMinutes': serializer.toJson<int?>(durationMinutes),
      'rating': serializer.toJson<double>(rating),
      'ratingCount': serializer.toJson<int>(ratingCount),
      'myRating': serializer.toJson<int?>(myRating),
      'enrolledCount': serializer.toJson<int>(enrolledCount),
      'totalEnrollments': serializer.toJson<int>(totalEnrollments),
      'totalLessons': serializer.toJson<int>(totalLessons),
      'completionRate': serializer.toJson<int>(completionRate),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'learningOutcomesJson': serializer.toJson<String>(learningOutcomesJson),
      'featured': serializer.toJson<bool>(featured),
      'progressPercent': serializer.toJson<int>(progressPercent),
      'serverUpdatedAt': serializer.toJson<DateTime?>(serverUpdatedAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  OfflineCourse copyWith(
          {String? id,
          String? title,
          Value<String?> description = const Value.absent(),
          Value<String?> shortDescription = const Value.absent(),
          Value<String?> thumbnailUrl = const Value.absent(),
          Value<String?> categoryName = const Value.absent(),
          Value<String?> categoryId = const Value.absent(),
          Value<String?> instructorName = const Value.absent(),
          String? level,
          String? status,
          bool? isPaid,
          Value<double?> price = const Value.absent(),
          Value<String?> language = const Value.absent(),
          Value<int?> durationMinutes = const Value.absent(),
          double? rating,
          int? ratingCount,
          Value<int?> myRating = const Value.absent(),
          int? enrolledCount,
          int? totalEnrollments,
          int? totalLessons,
          int? completionRate,
          String? tagsJson,
          String? learningOutcomesJson,
          bool? featured,
          int? progressPercent,
          Value<DateTime?> serverUpdatedAt = const Value.absent(),
          DateTime? cachedAt}) =>
      OfflineCourse(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        shortDescription: shortDescription.present
            ? shortDescription.value
            : this.shortDescription,
        thumbnailUrl:
            thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
        categoryName:
            categoryName.present ? categoryName.value : this.categoryName,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        instructorName:
            instructorName.present ? instructorName.value : this.instructorName,
        level: level ?? this.level,
        status: status ?? this.status,
        isPaid: isPaid ?? this.isPaid,
        price: price.present ? price.value : this.price,
        language: language.present ? language.value : this.language,
        durationMinutes: durationMinutes.present
            ? durationMinutes.value
            : this.durationMinutes,
        rating: rating ?? this.rating,
        ratingCount: ratingCount ?? this.ratingCount,
        myRating: myRating.present ? myRating.value : this.myRating,
        enrolledCount: enrolledCount ?? this.enrolledCount,
        totalEnrollments: totalEnrollments ?? this.totalEnrollments,
        totalLessons: totalLessons ?? this.totalLessons,
        completionRate: completionRate ?? this.completionRate,
        tagsJson: tagsJson ?? this.tagsJson,
        learningOutcomesJson: learningOutcomesJson ?? this.learningOutcomesJson,
        featured: featured ?? this.featured,
        progressPercent: progressPercent ?? this.progressPercent,
        serverUpdatedAt: serverUpdatedAt.present
            ? serverUpdatedAt.value
            : this.serverUpdatedAt,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  OfflineCourse copyWithCompanion(OfflineCoursesCompanion data) {
    return OfflineCourse(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      shortDescription: data.shortDescription.present
          ? data.shortDescription.value
          : this.shortDescription,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      categoryName: data.categoryName.present
          ? data.categoryName.value
          : this.categoryName,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      instructorName: data.instructorName.present
          ? data.instructorName.value
          : this.instructorName,
      level: data.level.present ? data.level.value : this.level,
      status: data.status.present ? data.status.value : this.status,
      isPaid: data.isPaid.present ? data.isPaid.value : this.isPaid,
      price: data.price.present ? data.price.value : this.price,
      language: data.language.present ? data.language.value : this.language,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      rating: data.rating.present ? data.rating.value : this.rating,
      ratingCount:
          data.ratingCount.present ? data.ratingCount.value : this.ratingCount,
      myRating: data.myRating.present ? data.myRating.value : this.myRating,
      enrolledCount: data.enrolledCount.present
          ? data.enrolledCount.value
          : this.enrolledCount,
      totalEnrollments: data.totalEnrollments.present
          ? data.totalEnrollments.value
          : this.totalEnrollments,
      totalLessons: data.totalLessons.present
          ? data.totalLessons.value
          : this.totalLessons,
      completionRate: data.completionRate.present
          ? data.completionRate.value
          : this.completionRate,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      learningOutcomesJson: data.learningOutcomesJson.present
          ? data.learningOutcomesJson.value
          : this.learningOutcomesJson,
      featured: data.featured.present ? data.featured.value : this.featured,
      progressPercent: data.progressPercent.present
          ? data.progressPercent.value
          : this.progressPercent,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineCourse(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('shortDescription: $shortDescription, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('categoryName: $categoryName, ')
          ..write('categoryId: $categoryId, ')
          ..write('instructorName: $instructorName, ')
          ..write('level: $level, ')
          ..write('status: $status, ')
          ..write('isPaid: $isPaid, ')
          ..write('price: $price, ')
          ..write('language: $language, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('rating: $rating, ')
          ..write('ratingCount: $ratingCount, ')
          ..write('myRating: $myRating, ')
          ..write('enrolledCount: $enrolledCount, ')
          ..write('totalEnrollments: $totalEnrollments, ')
          ..write('totalLessons: $totalLessons, ')
          ..write('completionRate: $completionRate, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('learningOutcomesJson: $learningOutcomesJson, ')
          ..write('featured: $featured, ')
          ..write('progressPercent: $progressPercent, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        title,
        description,
        shortDescription,
        thumbnailUrl,
        categoryName,
        categoryId,
        instructorName,
        level,
        status,
        isPaid,
        price,
        language,
        durationMinutes,
        rating,
        ratingCount,
        myRating,
        enrolledCount,
        totalEnrollments,
        totalLessons,
        completionRate,
        tagsJson,
        learningOutcomesJson,
        featured,
        progressPercent,
        serverUpdatedAt,
        cachedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineCourse &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.shortDescription == this.shortDescription &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.categoryName == this.categoryName &&
          other.categoryId == this.categoryId &&
          other.instructorName == this.instructorName &&
          other.level == this.level &&
          other.status == this.status &&
          other.isPaid == this.isPaid &&
          other.price == this.price &&
          other.language == this.language &&
          other.durationMinutes == this.durationMinutes &&
          other.rating == this.rating &&
          other.ratingCount == this.ratingCount &&
          other.myRating == this.myRating &&
          other.enrolledCount == this.enrolledCount &&
          other.totalEnrollments == this.totalEnrollments &&
          other.totalLessons == this.totalLessons &&
          other.completionRate == this.completionRate &&
          other.tagsJson == this.tagsJson &&
          other.learningOutcomesJson == this.learningOutcomesJson &&
          other.featured == this.featured &&
          other.progressPercent == this.progressPercent &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.cachedAt == this.cachedAt);
}

class OfflineCoursesCompanion extends UpdateCompanion<OfflineCourse> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> shortDescription;
  final Value<String?> thumbnailUrl;
  final Value<String?> categoryName;
  final Value<String?> categoryId;
  final Value<String?> instructorName;
  final Value<String> level;
  final Value<String> status;
  final Value<bool> isPaid;
  final Value<double?> price;
  final Value<String?> language;
  final Value<int?> durationMinutes;
  final Value<double> rating;
  final Value<int> ratingCount;
  final Value<int?> myRating;
  final Value<int> enrolledCount;
  final Value<int> totalEnrollments;
  final Value<int> totalLessons;
  final Value<int> completionRate;
  final Value<String> tagsJson;
  final Value<String> learningOutcomesJson;
  final Value<bool> featured;
  final Value<int> progressPercent;
  final Value<DateTime?> serverUpdatedAt;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const OfflineCoursesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.shortDescription = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.instructorName = const Value.absent(),
    this.level = const Value.absent(),
    this.status = const Value.absent(),
    this.isPaid = const Value.absent(),
    this.price = const Value.absent(),
    this.language = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.rating = const Value.absent(),
    this.ratingCount = const Value.absent(),
    this.myRating = const Value.absent(),
    this.enrolledCount = const Value.absent(),
    this.totalEnrollments = const Value.absent(),
    this.totalLessons = const Value.absent(),
    this.completionRate = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.learningOutcomesJson = const Value.absent(),
    this.featured = const Value.absent(),
    this.progressPercent = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OfflineCoursesCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    this.shortDescription = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.instructorName = const Value.absent(),
    this.level = const Value.absent(),
    this.status = const Value.absent(),
    this.isPaid = const Value.absent(),
    this.price = const Value.absent(),
    this.language = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.rating = const Value.absent(),
    this.ratingCount = const Value.absent(),
    this.myRating = const Value.absent(),
    this.enrolledCount = const Value.absent(),
    this.totalEnrollments = const Value.absent(),
    this.totalLessons = const Value.absent(),
    this.completionRate = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.learningOutcomesJson = const Value.absent(),
    this.featured = const Value.absent(),
    this.progressPercent = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        cachedAt = Value(cachedAt);
  static Insertable<OfflineCourse> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? shortDescription,
    Expression<String>? thumbnailUrl,
    Expression<String>? categoryName,
    Expression<String>? categoryId,
    Expression<String>? instructorName,
    Expression<String>? level,
    Expression<String>? status,
    Expression<bool>? isPaid,
    Expression<double>? price,
    Expression<String>? language,
    Expression<int>? durationMinutes,
    Expression<double>? rating,
    Expression<int>? ratingCount,
    Expression<int>? myRating,
    Expression<int>? enrolledCount,
    Expression<int>? totalEnrollments,
    Expression<int>? totalLessons,
    Expression<int>? completionRate,
    Expression<String>? tagsJson,
    Expression<String>? learningOutcomesJson,
    Expression<bool>? featured,
    Expression<int>? progressPercent,
    Expression<DateTime>? serverUpdatedAt,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (shortDescription != null) 'short_description': shortDescription,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (categoryName != null) 'category_name': categoryName,
      if (categoryId != null) 'category_id': categoryId,
      if (instructorName != null) 'instructor_name': instructorName,
      if (level != null) 'level': level,
      if (status != null) 'status': status,
      if (isPaid != null) 'is_paid': isPaid,
      if (price != null) 'price': price,
      if (language != null) 'language': language,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (rating != null) 'rating': rating,
      if (ratingCount != null) 'rating_count': ratingCount,
      if (myRating != null) 'my_rating': myRating,
      if (enrolledCount != null) 'enrolled_count': enrolledCount,
      if (totalEnrollments != null) 'total_enrollments': totalEnrollments,
      if (totalLessons != null) 'total_lessons': totalLessons,
      if (completionRate != null) 'completion_rate': completionRate,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (learningOutcomesJson != null)
        'learning_outcomes_json': learningOutcomesJson,
      if (featured != null) 'featured': featured,
      if (progressPercent != null) 'progress_percent': progressPercent,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OfflineCoursesCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String?>? description,
      Value<String?>? shortDescription,
      Value<String?>? thumbnailUrl,
      Value<String?>? categoryName,
      Value<String?>? categoryId,
      Value<String?>? instructorName,
      Value<String>? level,
      Value<String>? status,
      Value<bool>? isPaid,
      Value<double?>? price,
      Value<String?>? language,
      Value<int?>? durationMinutes,
      Value<double>? rating,
      Value<int>? ratingCount,
      Value<int?>? myRating,
      Value<int>? enrolledCount,
      Value<int>? totalEnrollments,
      Value<int>? totalLessons,
      Value<int>? completionRate,
      Value<String>? tagsJson,
      Value<String>? learningOutcomesJson,
      Value<bool>? featured,
      Value<int>? progressPercent,
      Value<DateTime?>? serverUpdatedAt,
      Value<DateTime>? cachedAt,
      Value<int>? rowid}) {
    return OfflineCoursesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      categoryName: categoryName ?? this.categoryName,
      categoryId: categoryId ?? this.categoryId,
      instructorName: instructorName ?? this.instructorName,
      level: level ?? this.level,
      status: status ?? this.status,
      isPaid: isPaid ?? this.isPaid,
      price: price ?? this.price,
      language: language ?? this.language,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      myRating: myRating ?? this.myRating,
      enrolledCount: enrolledCount ?? this.enrolledCount,
      totalEnrollments: totalEnrollments ?? this.totalEnrollments,
      totalLessons: totalLessons ?? this.totalLessons,
      completionRate: completionRate ?? this.completionRate,
      tagsJson: tagsJson ?? this.tagsJson,
      learningOutcomesJson: learningOutcomesJson ?? this.learningOutcomesJson,
      featured: featured ?? this.featured,
      progressPercent: progressPercent ?? this.progressPercent,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (shortDescription.present) {
      map['short_description'] = Variable<String>(shortDescription.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (categoryName.present) {
      map['category_name'] = Variable<String>(categoryName.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (instructorName.present) {
      map['instructor_name'] = Variable<String>(instructorName.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isPaid.present) {
      map['is_paid'] = Variable<bool>(isPaid.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (ratingCount.present) {
      map['rating_count'] = Variable<int>(ratingCount.value);
    }
    if (myRating.present) {
      map['my_rating'] = Variable<int>(myRating.value);
    }
    if (enrolledCount.present) {
      map['enrolled_count'] = Variable<int>(enrolledCount.value);
    }
    if (totalEnrollments.present) {
      map['total_enrollments'] = Variable<int>(totalEnrollments.value);
    }
    if (totalLessons.present) {
      map['total_lessons'] = Variable<int>(totalLessons.value);
    }
    if (completionRate.present) {
      map['completion_rate'] = Variable<int>(completionRate.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (learningOutcomesJson.present) {
      map['learning_outcomes_json'] =
          Variable<String>(learningOutcomesJson.value);
    }
    if (featured.present) {
      map['featured'] = Variable<bool>(featured.value);
    }
    if (progressPercent.present) {
      map['progress_percent'] = Variable<int>(progressPercent.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineCoursesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('shortDescription: $shortDescription, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('categoryName: $categoryName, ')
          ..write('categoryId: $categoryId, ')
          ..write('instructorName: $instructorName, ')
          ..write('level: $level, ')
          ..write('status: $status, ')
          ..write('isPaid: $isPaid, ')
          ..write('price: $price, ')
          ..write('language: $language, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('rating: $rating, ')
          ..write('ratingCount: $ratingCount, ')
          ..write('myRating: $myRating, ')
          ..write('enrolledCount: $enrolledCount, ')
          ..write('totalEnrollments: $totalEnrollments, ')
          ..write('totalLessons: $totalLessons, ')
          ..write('completionRate: $completionRate, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('learningOutcomesJson: $learningOutcomesJson, ')
          ..write('featured: $featured, ')
          ..write('progressPercent: $progressPercent, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OfflineModulesTable extends OfflineModules
    with TableInfo<$OfflineModulesTable, OfflineModule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineModulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _courseIdMeta =
      const VerificationMeta('courseId');
  @override
  late final GeneratedColumn<String> courseId = GeneratedColumn<String>(
      'course_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _displayOrderMeta =
      const VerificationMeta('displayOrder');
  @override
  late final GeneratedColumn<int> displayOrder = GeneratedColumn<int>(
      'display_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isPreviewMeta =
      const VerificationMeta('isPreview');
  @override
  late final GeneratedColumn<bool> isPreview = GeneratedColumn<bool>(
      'is_preview', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_preview" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, courseId, title, description, displayOrder, isPreview, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_modules';
  @override
  VerificationContext validateIntegrity(Insertable<OfflineModule> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('course_id')) {
      context.handle(_courseIdMeta,
          courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta));
    } else if (isInserting) {
      context.missing(_courseIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('display_order')) {
      context.handle(
          _displayOrderMeta,
          displayOrder.isAcceptableOrUnknown(
              data['display_order']!, _displayOrderMeta));
    }
    if (data.containsKey('is_preview')) {
      context.handle(_isPreviewMeta,
          isPreview.isAcceptableOrUnknown(data['is_preview']!, _isPreviewMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfflineModule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineModule(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      courseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}course_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      displayOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}display_order'])!,
      isPreview: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_preview'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $OfflineModulesTable createAlias(String alias) {
    return $OfflineModulesTable(attachedDatabase, alias);
  }
}

class OfflineModule extends DataClass implements Insertable<OfflineModule> {
  final String id;
  final String courseId;
  final String title;
  final String? description;
  final int displayOrder;
  final bool isPreview;
  final DateTime cachedAt;
  const OfflineModule(
      {required this.id,
      required this.courseId,
      required this.title,
      this.description,
      required this.displayOrder,
      required this.isPreview,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['course_id'] = Variable<String>(courseId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['display_order'] = Variable<int>(displayOrder);
    map['is_preview'] = Variable<bool>(isPreview);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  OfflineModulesCompanion toCompanion(bool nullToAbsent) {
    return OfflineModulesCompanion(
      id: Value(id),
      courseId: Value(courseId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      displayOrder: Value(displayOrder),
      isPreview: Value(isPreview),
      cachedAt: Value(cachedAt),
    );
  }

  factory OfflineModule.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineModule(
      id: serializer.fromJson<String>(json['id']),
      courseId: serializer.fromJson<String>(json['courseId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      displayOrder: serializer.fromJson<int>(json['displayOrder']),
      isPreview: serializer.fromJson<bool>(json['isPreview']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'courseId': serializer.toJson<String>(courseId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'displayOrder': serializer.toJson<int>(displayOrder),
      'isPreview': serializer.toJson<bool>(isPreview),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  OfflineModule copyWith(
          {String? id,
          String? courseId,
          String? title,
          Value<String?> description = const Value.absent(),
          int? displayOrder,
          bool? isPreview,
          DateTime? cachedAt}) =>
      OfflineModule(
        id: id ?? this.id,
        courseId: courseId ?? this.courseId,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        displayOrder: displayOrder ?? this.displayOrder,
        isPreview: isPreview ?? this.isPreview,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  OfflineModule copyWithCompanion(OfflineModulesCompanion data) {
    return OfflineModule(
      id: data.id.present ? data.id.value : this.id,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      displayOrder: data.displayOrder.present
          ? data.displayOrder.value
          : this.displayOrder,
      isPreview: data.isPreview.present ? data.isPreview.value : this.isPreview,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineModule(')
          ..write('id: $id, ')
          ..write('courseId: $courseId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('isPreview: $isPreview, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, courseId, title, description, displayOrder, isPreview, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineModule &&
          other.id == this.id &&
          other.courseId == this.courseId &&
          other.title == this.title &&
          other.description == this.description &&
          other.displayOrder == this.displayOrder &&
          other.isPreview == this.isPreview &&
          other.cachedAt == this.cachedAt);
}

class OfflineModulesCompanion extends UpdateCompanion<OfflineModule> {
  final Value<String> id;
  final Value<String> courseId;
  final Value<String> title;
  final Value<String?> description;
  final Value<int> displayOrder;
  final Value<bool> isPreview;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const OfflineModulesCompanion({
    this.id = const Value.absent(),
    this.courseId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.isPreview = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OfflineModulesCompanion.insert({
    required String id,
    required String courseId,
    required String title,
    this.description = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.isPreview = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        courseId = Value(courseId),
        title = Value(title),
        cachedAt = Value(cachedAt);
  static Insertable<OfflineModule> custom({
    Expression<String>? id,
    Expression<String>? courseId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? displayOrder,
    Expression<bool>? isPreview,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (courseId != null) 'course_id': courseId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (displayOrder != null) 'display_order': displayOrder,
      if (isPreview != null) 'is_preview': isPreview,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OfflineModulesCompanion copyWith(
      {Value<String>? id,
      Value<String>? courseId,
      Value<String>? title,
      Value<String?>? description,
      Value<int>? displayOrder,
      Value<bool>? isPreview,
      Value<DateTime>? cachedAt,
      Value<int>? rowid}) {
    return OfflineModulesCompanion(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      displayOrder: displayOrder ?? this.displayOrder,
      isPreview: isPreview ?? this.isPreview,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<String>(courseId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (displayOrder.present) {
      map['display_order'] = Variable<int>(displayOrder.value);
    }
    if (isPreview.present) {
      map['is_preview'] = Variable<bool>(isPreview.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineModulesCompanion(')
          ..write('id: $id, ')
          ..write('courseId: $courseId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('isPreview: $isPreview, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OfflineLessonsTable extends OfflineLessons
    with TableInfo<$OfflineLessonsTable, OfflineLesson> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineLessonsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _courseIdMeta =
      const VerificationMeta('courseId');
  @override
  late final GeneratedColumn<String> courseId = GeneratedColumn<String>(
      'course_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _moduleIdMeta =
      const VerificationMeta('moduleId');
  @override
  late final GeneratedColumn<String> moduleId = GeneratedColumn<String>(
      'module_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _moduleTitleMeta =
      const VerificationMeta('moduleTitle');
  @override
  late final GeneratedColumn<String> moduleTitle = GeneratedColumn<String>(
      'module_title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('VIDEO'));
  static const VerificationMeta _contentUrlMeta =
      const VerificationMeta('contentUrl');
  @override
  late final GeneratedColumn<String> contentUrl = GeneratedColumn<String>(
      'content_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _streamingUrlMeta =
      const VerificationMeta('streamingUrl');
  @override
  late final GeneratedColumn<String> streamingUrl = GeneratedColumn<String>(
      'streaming_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _textContentMeta =
      const VerificationMeta('textContent');
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
      'text_content', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _durationMinutesMeta =
      const VerificationMeta('durationMinutes');
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
      'duration_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
      'duration_seconds', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _displayOrderMeta =
      const VerificationMeta('displayOrder');
  @override
  late final GeneratedColumn<int> displayOrder = GeneratedColumn<int>(
      'display_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isPreviewMeta =
      const VerificationMeta('isPreview');
  @override
  late final GeneratedColumn<bool> isPreview = GeneratedColumn<bool>(
      'is_preview', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_preview" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isPublishedMeta =
      const VerificationMeta('isPublished');
  @override
  late final GeneratedColumn<bool> isPublished = GeneratedColumn<bool>(
      'is_published', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_published" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _downloadableMeta =
      const VerificationMeta('downloadable');
  @override
  late final GeneratedColumn<bool> downloadable = GeneratedColumn<bool>(
      'downloadable', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("downloadable" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _completedMeta =
      const VerificationMeta('completed');
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
      'completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _watchedSecondsMeta =
      const VerificationMeta('watchedSeconds');
  @override
  late final GeneratedColumn<int> watchedSeconds = GeneratedColumn<int>(
      'watched_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _progressPercentMeta =
      const VerificationMeta('progressPercent');
  @override
  late final GeneratedColumn<int> progressPercent = GeneratedColumn<int>(
      'progress_percent', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _localFilePathMeta =
      const VerificationMeta('localFilePath');
  @override
  late final GeneratedColumn<String> localFilePath = GeneratedColumn<String>(
      'local_file_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _serverUpdatedAtMeta =
      const VerificationMeta('serverUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> serverUpdatedAt =
      GeneratedColumn<DateTime>('server_updated_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        courseId,
        moduleId,
        moduleTitle,
        title,
        description,
        type,
        contentUrl,
        streamingUrl,
        textContent,
        durationMinutes,
        durationSeconds,
        displayOrder,
        isPreview,
        isPublished,
        downloadable,
        completed,
        watchedSeconds,
        progressPercent,
        localFilePath,
        serverUpdatedAt,
        cachedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_lessons';
  @override
  VerificationContext validateIntegrity(Insertable<OfflineLesson> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('course_id')) {
      context.handle(_courseIdMeta,
          courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta));
    } else if (isInserting) {
      context.missing(_courseIdMeta);
    }
    if (data.containsKey('module_id')) {
      context.handle(_moduleIdMeta,
          moduleId.isAcceptableOrUnknown(data['module_id']!, _moduleIdMeta));
    }
    if (data.containsKey('module_title')) {
      context.handle(
          _moduleTitleMeta,
          moduleTitle.isAcceptableOrUnknown(
              data['module_title']!, _moduleTitleMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('content_url')) {
      context.handle(
          _contentUrlMeta,
          contentUrl.isAcceptableOrUnknown(
              data['content_url']!, _contentUrlMeta));
    }
    if (data.containsKey('streaming_url')) {
      context.handle(
          _streamingUrlMeta,
          streamingUrl.isAcceptableOrUnknown(
              data['streaming_url']!, _streamingUrlMeta));
    }
    if (data.containsKey('text_content')) {
      context.handle(
          _textContentMeta,
          textContent.isAcceptableOrUnknown(
              data['text_content']!, _textContentMeta));
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
          _durationMinutesMeta,
          durationMinutes.isAcceptableOrUnknown(
              data['duration_minutes']!, _durationMinutesMeta));
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    }
    if (data.containsKey('display_order')) {
      context.handle(
          _displayOrderMeta,
          displayOrder.isAcceptableOrUnknown(
              data['display_order']!, _displayOrderMeta));
    }
    if (data.containsKey('is_preview')) {
      context.handle(_isPreviewMeta,
          isPreview.isAcceptableOrUnknown(data['is_preview']!, _isPreviewMeta));
    }
    if (data.containsKey('is_published')) {
      context.handle(
          _isPublishedMeta,
          isPublished.isAcceptableOrUnknown(
              data['is_published']!, _isPublishedMeta));
    }
    if (data.containsKey('downloadable')) {
      context.handle(
          _downloadableMeta,
          downloadable.isAcceptableOrUnknown(
              data['downloadable']!, _downloadableMeta));
    }
    if (data.containsKey('completed')) {
      context.handle(_completedMeta,
          completed.isAcceptableOrUnknown(data['completed']!, _completedMeta));
    }
    if (data.containsKey('watched_seconds')) {
      context.handle(
          _watchedSecondsMeta,
          watchedSeconds.isAcceptableOrUnknown(
              data['watched_seconds']!, _watchedSecondsMeta));
    }
    if (data.containsKey('progress_percent')) {
      context.handle(
          _progressPercentMeta,
          progressPercent.isAcceptableOrUnknown(
              data['progress_percent']!, _progressPercentMeta));
    }
    if (data.containsKey('local_file_path')) {
      context.handle(
          _localFilePathMeta,
          localFilePath.isAcceptableOrUnknown(
              data['local_file_path']!, _localFilePathMeta));
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
          _serverUpdatedAtMeta,
          serverUpdatedAt.isAcceptableOrUnknown(
              data['server_updated_at']!, _serverUpdatedAtMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfflineLesson map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineLesson(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      courseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}course_id'])!,
      moduleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}module_id']),
      moduleTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}module_title']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      contentUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content_url']),
      streamingUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}streaming_url']),
      textContent: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}text_content']),
      durationMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_minutes']),
      durationSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_seconds']),
      displayOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}display_order'])!,
      isPreview: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_preview'])!,
      isPublished: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_published'])!,
      downloadable: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}downloadable'])!,
      completed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}completed'])!,
      watchedSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}watched_seconds'])!,
      progressPercent: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}progress_percent'])!,
      localFilePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_file_path']),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}server_updated_at']),
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $OfflineLessonsTable createAlias(String alias) {
    return $OfflineLessonsTable(attachedDatabase, alias);
  }
}

class OfflineLesson extends DataClass implements Insertable<OfflineLesson> {
  final String id;
  final String courseId;
  final String? moduleId;
  final String? moduleTitle;
  final String title;
  final String? description;
  final String type;
  final String? contentUrl;
  final String? streamingUrl;
  final String? textContent;
  final int? durationMinutes;
  final int? durationSeconds;
  final int displayOrder;
  final bool isPreview;
  final bool isPublished;
  final bool downloadable;
  final bool completed;
  final int watchedSeconds;
  final int progressPercent;
  final String? localFilePath;
  final DateTime? serverUpdatedAt;
  final DateTime cachedAt;
  const OfflineLesson(
      {required this.id,
      required this.courseId,
      this.moduleId,
      this.moduleTitle,
      required this.title,
      this.description,
      required this.type,
      this.contentUrl,
      this.streamingUrl,
      this.textContent,
      this.durationMinutes,
      this.durationSeconds,
      required this.displayOrder,
      required this.isPreview,
      required this.isPublished,
      required this.downloadable,
      required this.completed,
      required this.watchedSeconds,
      required this.progressPercent,
      this.localFilePath,
      this.serverUpdatedAt,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['course_id'] = Variable<String>(courseId);
    if (!nullToAbsent || moduleId != null) {
      map['module_id'] = Variable<String>(moduleId);
    }
    if (!nullToAbsent || moduleTitle != null) {
      map['module_title'] = Variable<String>(moduleTitle);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || contentUrl != null) {
      map['content_url'] = Variable<String>(contentUrl);
    }
    if (!nullToAbsent || streamingUrl != null) {
      map['streaming_url'] = Variable<String>(streamingUrl);
    }
    if (!nullToAbsent || textContent != null) {
      map['text_content'] = Variable<String>(textContent);
    }
    if (!nullToAbsent || durationMinutes != null) {
      map['duration_minutes'] = Variable<int>(durationMinutes);
    }
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    map['display_order'] = Variable<int>(displayOrder);
    map['is_preview'] = Variable<bool>(isPreview);
    map['is_published'] = Variable<bool>(isPublished);
    map['downloadable'] = Variable<bool>(downloadable);
    map['completed'] = Variable<bool>(completed);
    map['watched_seconds'] = Variable<int>(watchedSeconds);
    map['progress_percent'] = Variable<int>(progressPercent);
    if (!nullToAbsent || localFilePath != null) {
      map['local_file_path'] = Variable<String>(localFilePath);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  OfflineLessonsCompanion toCompanion(bool nullToAbsent) {
    return OfflineLessonsCompanion(
      id: Value(id),
      courseId: Value(courseId),
      moduleId: moduleId == null && nullToAbsent
          ? const Value.absent()
          : Value(moduleId),
      moduleTitle: moduleTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(moduleTitle),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      type: Value(type),
      contentUrl: contentUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(contentUrl),
      streamingUrl: streamingUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(streamingUrl),
      textContent: textContent == null && nullToAbsent
          ? const Value.absent()
          : Value(textContent),
      durationMinutes: durationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMinutes),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      displayOrder: Value(displayOrder),
      isPreview: Value(isPreview),
      isPublished: Value(isPublished),
      downloadable: Value(downloadable),
      completed: Value(completed),
      watchedSeconds: Value(watchedSeconds),
      progressPercent: Value(progressPercent),
      localFilePath: localFilePath == null && nullToAbsent
          ? const Value.absent()
          : Value(localFilePath),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      cachedAt: Value(cachedAt),
    );
  }

  factory OfflineLesson.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineLesson(
      id: serializer.fromJson<String>(json['id']),
      courseId: serializer.fromJson<String>(json['courseId']),
      moduleId: serializer.fromJson<String?>(json['moduleId']),
      moduleTitle: serializer.fromJson<String?>(json['moduleTitle']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      type: serializer.fromJson<String>(json['type']),
      contentUrl: serializer.fromJson<String?>(json['contentUrl']),
      streamingUrl: serializer.fromJson<String?>(json['streamingUrl']),
      textContent: serializer.fromJson<String?>(json['textContent']),
      durationMinutes: serializer.fromJson<int?>(json['durationMinutes']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      displayOrder: serializer.fromJson<int>(json['displayOrder']),
      isPreview: serializer.fromJson<bool>(json['isPreview']),
      isPublished: serializer.fromJson<bool>(json['isPublished']),
      downloadable: serializer.fromJson<bool>(json['downloadable']),
      completed: serializer.fromJson<bool>(json['completed']),
      watchedSeconds: serializer.fromJson<int>(json['watchedSeconds']),
      progressPercent: serializer.fromJson<int>(json['progressPercent']),
      localFilePath: serializer.fromJson<String?>(json['localFilePath']),
      serverUpdatedAt: serializer.fromJson<DateTime?>(json['serverUpdatedAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'courseId': serializer.toJson<String>(courseId),
      'moduleId': serializer.toJson<String?>(moduleId),
      'moduleTitle': serializer.toJson<String?>(moduleTitle),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'type': serializer.toJson<String>(type),
      'contentUrl': serializer.toJson<String?>(contentUrl),
      'streamingUrl': serializer.toJson<String?>(streamingUrl),
      'textContent': serializer.toJson<String?>(textContent),
      'durationMinutes': serializer.toJson<int?>(durationMinutes),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'displayOrder': serializer.toJson<int>(displayOrder),
      'isPreview': serializer.toJson<bool>(isPreview),
      'isPublished': serializer.toJson<bool>(isPublished),
      'downloadable': serializer.toJson<bool>(downloadable),
      'completed': serializer.toJson<bool>(completed),
      'watchedSeconds': serializer.toJson<int>(watchedSeconds),
      'progressPercent': serializer.toJson<int>(progressPercent),
      'localFilePath': serializer.toJson<String?>(localFilePath),
      'serverUpdatedAt': serializer.toJson<DateTime?>(serverUpdatedAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  OfflineLesson copyWith(
          {String? id,
          String? courseId,
          Value<String?> moduleId = const Value.absent(),
          Value<String?> moduleTitle = const Value.absent(),
          String? title,
          Value<String?> description = const Value.absent(),
          String? type,
          Value<String?> contentUrl = const Value.absent(),
          Value<String?> streamingUrl = const Value.absent(),
          Value<String?> textContent = const Value.absent(),
          Value<int?> durationMinutes = const Value.absent(),
          Value<int?> durationSeconds = const Value.absent(),
          int? displayOrder,
          bool? isPreview,
          bool? isPublished,
          bool? downloadable,
          bool? completed,
          int? watchedSeconds,
          int? progressPercent,
          Value<String?> localFilePath = const Value.absent(),
          Value<DateTime?> serverUpdatedAt = const Value.absent(),
          DateTime? cachedAt}) =>
      OfflineLesson(
        id: id ?? this.id,
        courseId: courseId ?? this.courseId,
        moduleId: moduleId.present ? moduleId.value : this.moduleId,
        moduleTitle: moduleTitle.present ? moduleTitle.value : this.moduleTitle,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        type: type ?? this.type,
        contentUrl: contentUrl.present ? contentUrl.value : this.contentUrl,
        streamingUrl:
            streamingUrl.present ? streamingUrl.value : this.streamingUrl,
        textContent: textContent.present ? textContent.value : this.textContent,
        durationMinutes: durationMinutes.present
            ? durationMinutes.value
            : this.durationMinutes,
        durationSeconds: durationSeconds.present
            ? durationSeconds.value
            : this.durationSeconds,
        displayOrder: displayOrder ?? this.displayOrder,
        isPreview: isPreview ?? this.isPreview,
        isPublished: isPublished ?? this.isPublished,
        downloadable: downloadable ?? this.downloadable,
        completed: completed ?? this.completed,
        watchedSeconds: watchedSeconds ?? this.watchedSeconds,
        progressPercent: progressPercent ?? this.progressPercent,
        localFilePath:
            localFilePath.present ? localFilePath.value : this.localFilePath,
        serverUpdatedAt: serverUpdatedAt.present
            ? serverUpdatedAt.value
            : this.serverUpdatedAt,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  OfflineLesson copyWithCompanion(OfflineLessonsCompanion data) {
    return OfflineLesson(
      id: data.id.present ? data.id.value : this.id,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      moduleId: data.moduleId.present ? data.moduleId.value : this.moduleId,
      moduleTitle:
          data.moduleTitle.present ? data.moduleTitle.value : this.moduleTitle,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      type: data.type.present ? data.type.value : this.type,
      contentUrl:
          data.contentUrl.present ? data.contentUrl.value : this.contentUrl,
      streamingUrl: data.streamingUrl.present
          ? data.streamingUrl.value
          : this.streamingUrl,
      textContent:
          data.textContent.present ? data.textContent.value : this.textContent,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      displayOrder: data.displayOrder.present
          ? data.displayOrder.value
          : this.displayOrder,
      isPreview: data.isPreview.present ? data.isPreview.value : this.isPreview,
      isPublished:
          data.isPublished.present ? data.isPublished.value : this.isPublished,
      downloadable: data.downloadable.present
          ? data.downloadable.value
          : this.downloadable,
      completed: data.completed.present ? data.completed.value : this.completed,
      watchedSeconds: data.watchedSeconds.present
          ? data.watchedSeconds.value
          : this.watchedSeconds,
      progressPercent: data.progressPercent.present
          ? data.progressPercent.value
          : this.progressPercent,
      localFilePath: data.localFilePath.present
          ? data.localFilePath.value
          : this.localFilePath,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineLesson(')
          ..write('id: $id, ')
          ..write('courseId: $courseId, ')
          ..write('moduleId: $moduleId, ')
          ..write('moduleTitle: $moduleTitle, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('contentUrl: $contentUrl, ')
          ..write('streamingUrl: $streamingUrl, ')
          ..write('textContent: $textContent, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('isPreview: $isPreview, ')
          ..write('isPublished: $isPublished, ')
          ..write('downloadable: $downloadable, ')
          ..write('completed: $completed, ')
          ..write('watchedSeconds: $watchedSeconds, ')
          ..write('progressPercent: $progressPercent, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        courseId,
        moduleId,
        moduleTitle,
        title,
        description,
        type,
        contentUrl,
        streamingUrl,
        textContent,
        durationMinutes,
        durationSeconds,
        displayOrder,
        isPreview,
        isPublished,
        downloadable,
        completed,
        watchedSeconds,
        progressPercent,
        localFilePath,
        serverUpdatedAt,
        cachedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineLesson &&
          other.id == this.id &&
          other.courseId == this.courseId &&
          other.moduleId == this.moduleId &&
          other.moduleTitle == this.moduleTitle &&
          other.title == this.title &&
          other.description == this.description &&
          other.type == this.type &&
          other.contentUrl == this.contentUrl &&
          other.streamingUrl == this.streamingUrl &&
          other.textContent == this.textContent &&
          other.durationMinutes == this.durationMinutes &&
          other.durationSeconds == this.durationSeconds &&
          other.displayOrder == this.displayOrder &&
          other.isPreview == this.isPreview &&
          other.isPublished == this.isPublished &&
          other.downloadable == this.downloadable &&
          other.completed == this.completed &&
          other.watchedSeconds == this.watchedSeconds &&
          other.progressPercent == this.progressPercent &&
          other.localFilePath == this.localFilePath &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.cachedAt == this.cachedAt);
}

class OfflineLessonsCompanion extends UpdateCompanion<OfflineLesson> {
  final Value<String> id;
  final Value<String> courseId;
  final Value<String?> moduleId;
  final Value<String?> moduleTitle;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> type;
  final Value<String?> contentUrl;
  final Value<String?> streamingUrl;
  final Value<String?> textContent;
  final Value<int?> durationMinutes;
  final Value<int?> durationSeconds;
  final Value<int> displayOrder;
  final Value<bool> isPreview;
  final Value<bool> isPublished;
  final Value<bool> downloadable;
  final Value<bool> completed;
  final Value<int> watchedSeconds;
  final Value<int> progressPercent;
  final Value<String?> localFilePath;
  final Value<DateTime?> serverUpdatedAt;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const OfflineLessonsCompanion({
    this.id = const Value.absent(),
    this.courseId = const Value.absent(),
    this.moduleId = const Value.absent(),
    this.moduleTitle = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.type = const Value.absent(),
    this.contentUrl = const Value.absent(),
    this.streamingUrl = const Value.absent(),
    this.textContent = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.isPreview = const Value.absent(),
    this.isPublished = const Value.absent(),
    this.downloadable = const Value.absent(),
    this.completed = const Value.absent(),
    this.watchedSeconds = const Value.absent(),
    this.progressPercent = const Value.absent(),
    this.localFilePath = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OfflineLessonsCompanion.insert({
    required String id,
    required String courseId,
    this.moduleId = const Value.absent(),
    this.moduleTitle = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.type = const Value.absent(),
    this.contentUrl = const Value.absent(),
    this.streamingUrl = const Value.absent(),
    this.textContent = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.isPreview = const Value.absent(),
    this.isPublished = const Value.absent(),
    this.downloadable = const Value.absent(),
    this.completed = const Value.absent(),
    this.watchedSeconds = const Value.absent(),
    this.progressPercent = const Value.absent(),
    this.localFilePath = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        courseId = Value(courseId),
        title = Value(title),
        cachedAt = Value(cachedAt);
  static Insertable<OfflineLesson> custom({
    Expression<String>? id,
    Expression<String>? courseId,
    Expression<String>? moduleId,
    Expression<String>? moduleTitle,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? type,
    Expression<String>? contentUrl,
    Expression<String>? streamingUrl,
    Expression<String>? textContent,
    Expression<int>? durationMinutes,
    Expression<int>? durationSeconds,
    Expression<int>? displayOrder,
    Expression<bool>? isPreview,
    Expression<bool>? isPublished,
    Expression<bool>? downloadable,
    Expression<bool>? completed,
    Expression<int>? watchedSeconds,
    Expression<int>? progressPercent,
    Expression<String>? localFilePath,
    Expression<DateTime>? serverUpdatedAt,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (courseId != null) 'course_id': courseId,
      if (moduleId != null) 'module_id': moduleId,
      if (moduleTitle != null) 'module_title': moduleTitle,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
      if (contentUrl != null) 'content_url': contentUrl,
      if (streamingUrl != null) 'streaming_url': streamingUrl,
      if (textContent != null) 'text_content': textContent,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (displayOrder != null) 'display_order': displayOrder,
      if (isPreview != null) 'is_preview': isPreview,
      if (isPublished != null) 'is_published': isPublished,
      if (downloadable != null) 'downloadable': downloadable,
      if (completed != null) 'completed': completed,
      if (watchedSeconds != null) 'watched_seconds': watchedSeconds,
      if (progressPercent != null) 'progress_percent': progressPercent,
      if (localFilePath != null) 'local_file_path': localFilePath,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OfflineLessonsCompanion copyWith(
      {Value<String>? id,
      Value<String>? courseId,
      Value<String?>? moduleId,
      Value<String?>? moduleTitle,
      Value<String>? title,
      Value<String?>? description,
      Value<String>? type,
      Value<String?>? contentUrl,
      Value<String?>? streamingUrl,
      Value<String?>? textContent,
      Value<int?>? durationMinutes,
      Value<int?>? durationSeconds,
      Value<int>? displayOrder,
      Value<bool>? isPreview,
      Value<bool>? isPublished,
      Value<bool>? downloadable,
      Value<bool>? completed,
      Value<int>? watchedSeconds,
      Value<int>? progressPercent,
      Value<String?>? localFilePath,
      Value<DateTime?>? serverUpdatedAt,
      Value<DateTime>? cachedAt,
      Value<int>? rowid}) {
    return OfflineLessonsCompanion(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      moduleId: moduleId ?? this.moduleId,
      moduleTitle: moduleTitle ?? this.moduleTitle,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      contentUrl: contentUrl ?? this.contentUrl,
      streamingUrl: streamingUrl ?? this.streamingUrl,
      textContent: textContent ?? this.textContent,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      displayOrder: displayOrder ?? this.displayOrder,
      isPreview: isPreview ?? this.isPreview,
      isPublished: isPublished ?? this.isPublished,
      downloadable: downloadable ?? this.downloadable,
      completed: completed ?? this.completed,
      watchedSeconds: watchedSeconds ?? this.watchedSeconds,
      progressPercent: progressPercent ?? this.progressPercent,
      localFilePath: localFilePath ?? this.localFilePath,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<String>(courseId.value);
    }
    if (moduleId.present) {
      map['module_id'] = Variable<String>(moduleId.value);
    }
    if (moduleTitle.present) {
      map['module_title'] = Variable<String>(moduleTitle.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (contentUrl.present) {
      map['content_url'] = Variable<String>(contentUrl.value);
    }
    if (streamingUrl.present) {
      map['streaming_url'] = Variable<String>(streamingUrl.value);
    }
    if (textContent.present) {
      map['text_content'] = Variable<String>(textContent.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (displayOrder.present) {
      map['display_order'] = Variable<int>(displayOrder.value);
    }
    if (isPreview.present) {
      map['is_preview'] = Variable<bool>(isPreview.value);
    }
    if (isPublished.present) {
      map['is_published'] = Variable<bool>(isPublished.value);
    }
    if (downloadable.present) {
      map['downloadable'] = Variable<bool>(downloadable.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (watchedSeconds.present) {
      map['watched_seconds'] = Variable<int>(watchedSeconds.value);
    }
    if (progressPercent.present) {
      map['progress_percent'] = Variable<int>(progressPercent.value);
    }
    if (localFilePath.present) {
      map['local_file_path'] = Variable<String>(localFilePath.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<DateTime>(serverUpdatedAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineLessonsCompanion(')
          ..write('id: $id, ')
          ..write('courseId: $courseId, ')
          ..write('moduleId: $moduleId, ')
          ..write('moduleTitle: $moduleTitle, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('contentUrl: $contentUrl, ')
          ..write('streamingUrl: $streamingUrl, ')
          ..write('textContent: $textContent, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('isPreview: $isPreview, ')
          ..write('isPublished: $isPublished, ')
          ..write('downloadable: $downloadable, ')
          ..write('completed: $completed, ')
          ..write('watchedSeconds: $watchedSeconds, ')
          ..write('progressPercent: $progressPercent, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $OfflineCoursesTable offlineCourses = $OfflineCoursesTable(this);
  late final $OfflineModulesTable offlineModules = $OfflineModulesTable(this);
  late final $OfflineLessonsTable offlineLessons = $OfflineLessonsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [offlineCourses, offlineModules, offlineLessons];
}

typedef $$OfflineCoursesTableCreateCompanionBuilder = OfflineCoursesCompanion
    Function({
  required String id,
  required String title,
  Value<String?> description,
  Value<String?> shortDescription,
  Value<String?> thumbnailUrl,
  Value<String?> categoryName,
  Value<String?> categoryId,
  Value<String?> instructorName,
  Value<String> level,
  Value<String> status,
  Value<bool> isPaid,
  Value<double?> price,
  Value<String?> language,
  Value<int?> durationMinutes,
  Value<double> rating,
  Value<int> ratingCount,
  Value<int?> myRating,
  Value<int> enrolledCount,
  Value<int> totalEnrollments,
  Value<int> totalLessons,
  Value<int> completionRate,
  Value<String> tagsJson,
  Value<String> learningOutcomesJson,
  Value<bool> featured,
  Value<int> progressPercent,
  Value<DateTime?> serverUpdatedAt,
  required DateTime cachedAt,
  Value<int> rowid,
});
typedef $$OfflineCoursesTableUpdateCompanionBuilder = OfflineCoursesCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<String?> description,
  Value<String?> shortDescription,
  Value<String?> thumbnailUrl,
  Value<String?> categoryName,
  Value<String?> categoryId,
  Value<String?> instructorName,
  Value<String> level,
  Value<String> status,
  Value<bool> isPaid,
  Value<double?> price,
  Value<String?> language,
  Value<int?> durationMinutes,
  Value<double> rating,
  Value<int> ratingCount,
  Value<int?> myRating,
  Value<int> enrolledCount,
  Value<int> totalEnrollments,
  Value<int> totalLessons,
  Value<int> completionRate,
  Value<String> tagsJson,
  Value<String> learningOutcomesJson,
  Value<bool> featured,
  Value<int> progressPercent,
  Value<DateTime?> serverUpdatedAt,
  Value<DateTime> cachedAt,
  Value<int> rowid,
});

class $$OfflineCoursesTableFilterComposer
    extends Composer<_$AppDatabase, $OfflineCoursesTable> {
  $$OfflineCoursesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shortDescription => $composableBuilder(
      column: $table.shortDescription,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
      column: $table.thumbnailUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryName => $composableBuilder(
      column: $table.categoryName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get instructorName => $composableBuilder(
      column: $table.instructorName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPaid => $composableBuilder(
      column: $table.isPaid, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ratingCount => $composableBuilder(
      column: $table.ratingCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get myRating => $composableBuilder(
      column: $table.myRating, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get enrolledCount => $composableBuilder(
      column: $table.enrolledCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalEnrollments => $composableBuilder(
      column: $table.totalEnrollments,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalLessons => $composableBuilder(
      column: $table.totalLessons, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get completionRate => $composableBuilder(
      column: $table.completionRate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagsJson => $composableBuilder(
      column: $table.tagsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get learningOutcomesJson => $composableBuilder(
      column: $table.learningOutcomesJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get featured => $composableBuilder(
      column: $table.featured, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get progressPercent => $composableBuilder(
      column: $table.progressPercent,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$OfflineCoursesTableOrderingComposer
    extends Composer<_$AppDatabase, $OfflineCoursesTable> {
  $$OfflineCoursesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shortDescription => $composableBuilder(
      column: $table.shortDescription,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
      column: $table.thumbnailUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryName => $composableBuilder(
      column: $table.categoryName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get instructorName => $composableBuilder(
      column: $table.instructorName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPaid => $composableBuilder(
      column: $table.isPaid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ratingCount => $composableBuilder(
      column: $table.ratingCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get myRating => $composableBuilder(
      column: $table.myRating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get enrolledCount => $composableBuilder(
      column: $table.enrolledCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalEnrollments => $composableBuilder(
      column: $table.totalEnrollments,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalLessons => $composableBuilder(
      column: $table.totalLessons,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get completionRate => $composableBuilder(
      column: $table.completionRate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagsJson => $composableBuilder(
      column: $table.tagsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get learningOutcomesJson => $composableBuilder(
      column: $table.learningOutcomesJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get featured => $composableBuilder(
      column: $table.featured, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get progressPercent => $composableBuilder(
      column: $table.progressPercent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$OfflineCoursesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OfflineCoursesTable> {
  $$OfflineCoursesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get shortDescription => $composableBuilder(
      column: $table.shortDescription, builder: (column) => column);

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
      column: $table.thumbnailUrl, builder: (column) => column);

  GeneratedColumn<String> get categoryName => $composableBuilder(
      column: $table.categoryName, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<String> get instructorName => $composableBuilder(
      column: $table.instructorName, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isPaid =>
      $composableBuilder(column: $table.isPaid, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes, builder: (column) => column);

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<int> get ratingCount => $composableBuilder(
      column: $table.ratingCount, builder: (column) => column);

  GeneratedColumn<int> get myRating =>
      $composableBuilder(column: $table.myRating, builder: (column) => column);

  GeneratedColumn<int> get enrolledCount => $composableBuilder(
      column: $table.enrolledCount, builder: (column) => column);

  GeneratedColumn<int> get totalEnrollments => $composableBuilder(
      column: $table.totalEnrollments, builder: (column) => column);

  GeneratedColumn<int> get totalLessons => $composableBuilder(
      column: $table.totalLessons, builder: (column) => column);

  GeneratedColumn<int> get completionRate => $composableBuilder(
      column: $table.completionRate, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<String> get learningOutcomesJson => $composableBuilder(
      column: $table.learningOutcomesJson, builder: (column) => column);

  GeneratedColumn<bool> get featured =>
      $composableBuilder(column: $table.featured, builder: (column) => column);

  GeneratedColumn<int> get progressPercent => $composableBuilder(
      column: $table.progressPercent, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$OfflineCoursesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OfflineCoursesTable,
    OfflineCourse,
    $$OfflineCoursesTableFilterComposer,
    $$OfflineCoursesTableOrderingComposer,
    $$OfflineCoursesTableAnnotationComposer,
    $$OfflineCoursesTableCreateCompanionBuilder,
    $$OfflineCoursesTableUpdateCompanionBuilder,
    (
      OfflineCourse,
      BaseReferences<_$AppDatabase, $OfflineCoursesTable, OfflineCourse>
    ),
    OfflineCourse,
    PrefetchHooks Function()> {
  $$OfflineCoursesTableTableManager(
      _$AppDatabase db, $OfflineCoursesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfflineCoursesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OfflineCoursesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OfflineCoursesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> shortDescription = const Value.absent(),
            Value<String?> thumbnailUrl = const Value.absent(),
            Value<String?> categoryName = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<String?> instructorName = const Value.absent(),
            Value<String> level = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<bool> isPaid = const Value.absent(),
            Value<double?> price = const Value.absent(),
            Value<String?> language = const Value.absent(),
            Value<int?> durationMinutes = const Value.absent(),
            Value<double> rating = const Value.absent(),
            Value<int> ratingCount = const Value.absent(),
            Value<int?> myRating = const Value.absent(),
            Value<int> enrolledCount = const Value.absent(),
            Value<int> totalEnrollments = const Value.absent(),
            Value<int> totalLessons = const Value.absent(),
            Value<int> completionRate = const Value.absent(),
            Value<String> tagsJson = const Value.absent(),
            Value<String> learningOutcomesJson = const Value.absent(),
            Value<bool> featured = const Value.absent(),
            Value<int> progressPercent = const Value.absent(),
            Value<DateTime?> serverUpdatedAt = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OfflineCoursesCompanion(
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
            rating: rating,
            ratingCount: ratingCount,
            myRating: myRating,
            enrolledCount: enrolledCount,
            totalEnrollments: totalEnrollments,
            totalLessons: totalLessons,
            completionRate: completionRate,
            tagsJson: tagsJson,
            learningOutcomesJson: learningOutcomesJson,
            featured: featured,
            progressPercent: progressPercent,
            serverUpdatedAt: serverUpdatedAt,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            Value<String?> description = const Value.absent(),
            Value<String?> shortDescription = const Value.absent(),
            Value<String?> thumbnailUrl = const Value.absent(),
            Value<String?> categoryName = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<String?> instructorName = const Value.absent(),
            Value<String> level = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<bool> isPaid = const Value.absent(),
            Value<double?> price = const Value.absent(),
            Value<String?> language = const Value.absent(),
            Value<int?> durationMinutes = const Value.absent(),
            Value<double> rating = const Value.absent(),
            Value<int> ratingCount = const Value.absent(),
            Value<int?> myRating = const Value.absent(),
            Value<int> enrolledCount = const Value.absent(),
            Value<int> totalEnrollments = const Value.absent(),
            Value<int> totalLessons = const Value.absent(),
            Value<int> completionRate = const Value.absent(),
            Value<String> tagsJson = const Value.absent(),
            Value<String> learningOutcomesJson = const Value.absent(),
            Value<bool> featured = const Value.absent(),
            Value<int> progressPercent = const Value.absent(),
            Value<DateTime?> serverUpdatedAt = const Value.absent(),
            required DateTime cachedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              OfflineCoursesCompanion.insert(
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
            rating: rating,
            ratingCount: ratingCount,
            myRating: myRating,
            enrolledCount: enrolledCount,
            totalEnrollments: totalEnrollments,
            totalLessons: totalLessons,
            completionRate: completionRate,
            tagsJson: tagsJson,
            learningOutcomesJson: learningOutcomesJson,
            featured: featured,
            progressPercent: progressPercent,
            serverUpdatedAt: serverUpdatedAt,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OfflineCoursesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OfflineCoursesTable,
    OfflineCourse,
    $$OfflineCoursesTableFilterComposer,
    $$OfflineCoursesTableOrderingComposer,
    $$OfflineCoursesTableAnnotationComposer,
    $$OfflineCoursesTableCreateCompanionBuilder,
    $$OfflineCoursesTableUpdateCompanionBuilder,
    (
      OfflineCourse,
      BaseReferences<_$AppDatabase, $OfflineCoursesTable, OfflineCourse>
    ),
    OfflineCourse,
    PrefetchHooks Function()>;
typedef $$OfflineModulesTableCreateCompanionBuilder = OfflineModulesCompanion
    Function({
  required String id,
  required String courseId,
  required String title,
  Value<String?> description,
  Value<int> displayOrder,
  Value<bool> isPreview,
  required DateTime cachedAt,
  Value<int> rowid,
});
typedef $$OfflineModulesTableUpdateCompanionBuilder = OfflineModulesCompanion
    Function({
  Value<String> id,
  Value<String> courseId,
  Value<String> title,
  Value<String?> description,
  Value<int> displayOrder,
  Value<bool> isPreview,
  Value<DateTime> cachedAt,
  Value<int> rowid,
});

class $$OfflineModulesTableFilterComposer
    extends Composer<_$AppDatabase, $OfflineModulesTable> {
  $$OfflineModulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get courseId => $composableBuilder(
      column: $table.courseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPreview => $composableBuilder(
      column: $table.isPreview, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$OfflineModulesTableOrderingComposer
    extends Composer<_$AppDatabase, $OfflineModulesTable> {
  $$OfflineModulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get courseId => $composableBuilder(
      column: $table.courseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPreview => $composableBuilder(
      column: $table.isPreview, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$OfflineModulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OfflineModulesTable> {
  $$OfflineModulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get courseId =>
      $composableBuilder(column: $table.courseId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder, builder: (column) => column);

  GeneratedColumn<bool> get isPreview =>
      $composableBuilder(column: $table.isPreview, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$OfflineModulesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OfflineModulesTable,
    OfflineModule,
    $$OfflineModulesTableFilterComposer,
    $$OfflineModulesTableOrderingComposer,
    $$OfflineModulesTableAnnotationComposer,
    $$OfflineModulesTableCreateCompanionBuilder,
    $$OfflineModulesTableUpdateCompanionBuilder,
    (
      OfflineModule,
      BaseReferences<_$AppDatabase, $OfflineModulesTable, OfflineModule>
    ),
    OfflineModule,
    PrefetchHooks Function()> {
  $$OfflineModulesTableTableManager(
      _$AppDatabase db, $OfflineModulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfflineModulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OfflineModulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OfflineModulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> courseId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> displayOrder = const Value.absent(),
            Value<bool> isPreview = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OfflineModulesCompanion(
            id: id,
            courseId: courseId,
            title: title,
            description: description,
            displayOrder: displayOrder,
            isPreview: isPreview,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String courseId,
            required String title,
            Value<String?> description = const Value.absent(),
            Value<int> displayOrder = const Value.absent(),
            Value<bool> isPreview = const Value.absent(),
            required DateTime cachedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              OfflineModulesCompanion.insert(
            id: id,
            courseId: courseId,
            title: title,
            description: description,
            displayOrder: displayOrder,
            isPreview: isPreview,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OfflineModulesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OfflineModulesTable,
    OfflineModule,
    $$OfflineModulesTableFilterComposer,
    $$OfflineModulesTableOrderingComposer,
    $$OfflineModulesTableAnnotationComposer,
    $$OfflineModulesTableCreateCompanionBuilder,
    $$OfflineModulesTableUpdateCompanionBuilder,
    (
      OfflineModule,
      BaseReferences<_$AppDatabase, $OfflineModulesTable, OfflineModule>
    ),
    OfflineModule,
    PrefetchHooks Function()>;
typedef $$OfflineLessonsTableCreateCompanionBuilder = OfflineLessonsCompanion
    Function({
  required String id,
  required String courseId,
  Value<String?> moduleId,
  Value<String?> moduleTitle,
  required String title,
  Value<String?> description,
  Value<String> type,
  Value<String?> contentUrl,
  Value<String?> streamingUrl,
  Value<String?> textContent,
  Value<int?> durationMinutes,
  Value<int?> durationSeconds,
  Value<int> displayOrder,
  Value<bool> isPreview,
  Value<bool> isPublished,
  Value<bool> downloadable,
  Value<bool> completed,
  Value<int> watchedSeconds,
  Value<int> progressPercent,
  Value<String?> localFilePath,
  Value<DateTime?> serverUpdatedAt,
  required DateTime cachedAt,
  Value<int> rowid,
});
typedef $$OfflineLessonsTableUpdateCompanionBuilder = OfflineLessonsCompanion
    Function({
  Value<String> id,
  Value<String> courseId,
  Value<String?> moduleId,
  Value<String?> moduleTitle,
  Value<String> title,
  Value<String?> description,
  Value<String> type,
  Value<String?> contentUrl,
  Value<String?> streamingUrl,
  Value<String?> textContent,
  Value<int?> durationMinutes,
  Value<int?> durationSeconds,
  Value<int> displayOrder,
  Value<bool> isPreview,
  Value<bool> isPublished,
  Value<bool> downloadable,
  Value<bool> completed,
  Value<int> watchedSeconds,
  Value<int> progressPercent,
  Value<String?> localFilePath,
  Value<DateTime?> serverUpdatedAt,
  Value<DateTime> cachedAt,
  Value<int> rowid,
});

class $$OfflineLessonsTableFilterComposer
    extends Composer<_$AppDatabase, $OfflineLessonsTable> {
  $$OfflineLessonsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get courseId => $composableBuilder(
      column: $table.courseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get moduleId => $composableBuilder(
      column: $table.moduleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get moduleTitle => $composableBuilder(
      column: $table.moduleTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contentUrl => $composableBuilder(
      column: $table.contentUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get streamingUrl => $composableBuilder(
      column: $table.streamingUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get textContent => $composableBuilder(
      column: $table.textContent, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPreview => $composableBuilder(
      column: $table.isPreview, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPublished => $composableBuilder(
      column: $table.isPublished, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get downloadable => $composableBuilder(
      column: $table.downloadable, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get completed => $composableBuilder(
      column: $table.completed, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get watchedSeconds => $composableBuilder(
      column: $table.watchedSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get progressPercent => $composableBuilder(
      column: $table.progressPercent,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localFilePath => $composableBuilder(
      column: $table.localFilePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$OfflineLessonsTableOrderingComposer
    extends Composer<_$AppDatabase, $OfflineLessonsTable> {
  $$OfflineLessonsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get courseId => $composableBuilder(
      column: $table.courseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get moduleId => $composableBuilder(
      column: $table.moduleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get moduleTitle => $composableBuilder(
      column: $table.moduleTitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contentUrl => $composableBuilder(
      column: $table.contentUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get streamingUrl => $composableBuilder(
      column: $table.streamingUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get textContent => $composableBuilder(
      column: $table.textContent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPreview => $composableBuilder(
      column: $table.isPreview, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPublished => $composableBuilder(
      column: $table.isPublished, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get downloadable => $composableBuilder(
      column: $table.downloadable,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get completed => $composableBuilder(
      column: $table.completed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get watchedSeconds => $composableBuilder(
      column: $table.watchedSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get progressPercent => $composableBuilder(
      column: $table.progressPercent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localFilePath => $composableBuilder(
      column: $table.localFilePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$OfflineLessonsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OfflineLessonsTable> {
  $$OfflineLessonsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get courseId =>
      $composableBuilder(column: $table.courseId, builder: (column) => column);

  GeneratedColumn<String> get moduleId =>
      $composableBuilder(column: $table.moduleId, builder: (column) => column);

  GeneratedColumn<String> get moduleTitle => $composableBuilder(
      column: $table.moduleTitle, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get contentUrl => $composableBuilder(
      column: $table.contentUrl, builder: (column) => column);

  GeneratedColumn<String> get streamingUrl => $composableBuilder(
      column: $table.streamingUrl, builder: (column) => column);

  GeneratedColumn<String> get textContent => $composableBuilder(
      column: $table.textContent, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds, builder: (column) => column);

  GeneratedColumn<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder, builder: (column) => column);

  GeneratedColumn<bool> get isPreview =>
      $composableBuilder(column: $table.isPreview, builder: (column) => column);

  GeneratedColumn<bool> get isPublished => $composableBuilder(
      column: $table.isPublished, builder: (column) => column);

  GeneratedColumn<bool> get downloadable => $composableBuilder(
      column: $table.downloadable, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<int> get watchedSeconds => $composableBuilder(
      column: $table.watchedSeconds, builder: (column) => column);

  GeneratedColumn<int> get progressPercent => $composableBuilder(
      column: $table.progressPercent, builder: (column) => column);

  GeneratedColumn<String> get localFilePath => $composableBuilder(
      column: $table.localFilePath, builder: (column) => column);

  GeneratedColumn<DateTime> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$OfflineLessonsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OfflineLessonsTable,
    OfflineLesson,
    $$OfflineLessonsTableFilterComposer,
    $$OfflineLessonsTableOrderingComposer,
    $$OfflineLessonsTableAnnotationComposer,
    $$OfflineLessonsTableCreateCompanionBuilder,
    $$OfflineLessonsTableUpdateCompanionBuilder,
    (
      OfflineLesson,
      BaseReferences<_$AppDatabase, $OfflineLessonsTable, OfflineLesson>
    ),
    OfflineLesson,
    PrefetchHooks Function()> {
  $$OfflineLessonsTableTableManager(
      _$AppDatabase db, $OfflineLessonsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfflineLessonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OfflineLessonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OfflineLessonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> courseId = const Value.absent(),
            Value<String?> moduleId = const Value.absent(),
            Value<String?> moduleTitle = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> contentUrl = const Value.absent(),
            Value<String?> streamingUrl = const Value.absent(),
            Value<String?> textContent = const Value.absent(),
            Value<int?> durationMinutes = const Value.absent(),
            Value<int?> durationSeconds = const Value.absent(),
            Value<int> displayOrder = const Value.absent(),
            Value<bool> isPreview = const Value.absent(),
            Value<bool> isPublished = const Value.absent(),
            Value<bool> downloadable = const Value.absent(),
            Value<bool> completed = const Value.absent(),
            Value<int> watchedSeconds = const Value.absent(),
            Value<int> progressPercent = const Value.absent(),
            Value<String?> localFilePath = const Value.absent(),
            Value<DateTime?> serverUpdatedAt = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OfflineLessonsCompanion(
            id: id,
            courseId: courseId,
            moduleId: moduleId,
            moduleTitle: moduleTitle,
            title: title,
            description: description,
            type: type,
            contentUrl: contentUrl,
            streamingUrl: streamingUrl,
            textContent: textContent,
            durationMinutes: durationMinutes,
            durationSeconds: durationSeconds,
            displayOrder: displayOrder,
            isPreview: isPreview,
            isPublished: isPublished,
            downloadable: downloadable,
            completed: completed,
            watchedSeconds: watchedSeconds,
            progressPercent: progressPercent,
            localFilePath: localFilePath,
            serverUpdatedAt: serverUpdatedAt,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String courseId,
            Value<String?> moduleId = const Value.absent(),
            Value<String?> moduleTitle = const Value.absent(),
            required String title,
            Value<String?> description = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> contentUrl = const Value.absent(),
            Value<String?> streamingUrl = const Value.absent(),
            Value<String?> textContent = const Value.absent(),
            Value<int?> durationMinutes = const Value.absent(),
            Value<int?> durationSeconds = const Value.absent(),
            Value<int> displayOrder = const Value.absent(),
            Value<bool> isPreview = const Value.absent(),
            Value<bool> isPublished = const Value.absent(),
            Value<bool> downloadable = const Value.absent(),
            Value<bool> completed = const Value.absent(),
            Value<int> watchedSeconds = const Value.absent(),
            Value<int> progressPercent = const Value.absent(),
            Value<String?> localFilePath = const Value.absent(),
            Value<DateTime?> serverUpdatedAt = const Value.absent(),
            required DateTime cachedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              OfflineLessonsCompanion.insert(
            id: id,
            courseId: courseId,
            moduleId: moduleId,
            moduleTitle: moduleTitle,
            title: title,
            description: description,
            type: type,
            contentUrl: contentUrl,
            streamingUrl: streamingUrl,
            textContent: textContent,
            durationMinutes: durationMinutes,
            durationSeconds: durationSeconds,
            displayOrder: displayOrder,
            isPreview: isPreview,
            isPublished: isPublished,
            downloadable: downloadable,
            completed: completed,
            watchedSeconds: watchedSeconds,
            progressPercent: progressPercent,
            localFilePath: localFilePath,
            serverUpdatedAt: serverUpdatedAt,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OfflineLessonsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OfflineLessonsTable,
    OfflineLesson,
    $$OfflineLessonsTableFilterComposer,
    $$OfflineLessonsTableOrderingComposer,
    $$OfflineLessonsTableAnnotationComposer,
    $$OfflineLessonsTableCreateCompanionBuilder,
    $$OfflineLessonsTableUpdateCompanionBuilder,
    (
      OfflineLesson,
      BaseReferences<_$AppDatabase, $OfflineLessonsTable, OfflineLesson>
    ),
    OfflineLesson,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OfflineCoursesTableTableManager get offlineCourses =>
      $$OfflineCoursesTableTableManager(_db, _db.offlineCourses);
  $$OfflineModulesTableTableManager get offlineModules =>
      $$OfflineModulesTableTableManager(_db, _db.offlineModules);
  $$OfflineLessonsTableTableManager get offlineLessons =>
      $$OfflineLessonsTableTableManager(_db, _db.offlineLessons);
}
