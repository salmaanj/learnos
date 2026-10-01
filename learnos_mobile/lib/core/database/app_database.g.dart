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
  static const VerificationMeta _thumbnailUrlMeta =
      const VerificationMeta('thumbnailUrl');
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
      'thumbnail_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
        thumbnailUrl,
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
    if (data.containsKey('thumbnail_url')) {
      context.handle(
          _thumbnailUrlMeta,
          thumbnailUrl.isAcceptableOrUnknown(
              data['thumbnail_url']!, _thumbnailUrlMeta));
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
      thumbnailUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thumbnail_url']),
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
  final String? thumbnailUrl;
  final int progressPercent;
  final DateTime? serverUpdatedAt;
  final DateTime cachedAt;
  const OfflineCourse(
      {required this.id,
      required this.title,
      this.description,
      this.thumbnailUrl,
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
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
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
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
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
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
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
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'progressPercent': serializer.toJson<int>(progressPercent),
      'serverUpdatedAt': serializer.toJson<DateTime?>(serverUpdatedAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  OfflineCourse copyWith(
          {String? id,
          String? title,
          Value<String?> description = const Value.absent(),
          Value<String?> thumbnailUrl = const Value.absent(),
          int? progressPercent,
          Value<DateTime?> serverUpdatedAt = const Value.absent(),
          DateTime? cachedAt}) =>
      OfflineCourse(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        thumbnailUrl:
            thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
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
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
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
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('progressPercent: $progressPercent, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, description, thumbnailUrl,
      progressPercent, serverUpdatedAt, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineCourse &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.progressPercent == this.progressPercent &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.cachedAt == this.cachedAt);
}

class OfflineCoursesCompanion extends UpdateCompanion<OfflineCourse> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> thumbnailUrl;
  final Value<int> progressPercent;
  final Value<DateTime?> serverUpdatedAt;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const OfflineCoursesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.progressPercent = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OfflineCoursesCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
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
    Expression<String>? thumbnailUrl,
    Expression<int>? progressPercent,
    Expression<DateTime>? serverUpdatedAt,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
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
      Value<String?>? thumbnailUrl,
      Value<int>? progressPercent,
      Value<DateTime?>? serverUpdatedAt,
      Value<DateTime>? cachedAt,
      Value<int>? rowid}) {
    return OfflineCoursesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
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
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
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
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('progressPercent: $progressPercent, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
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
  static const VerificationMeta _textContentMeta =
      const VerificationMeta('textContent');
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
      'text_content', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _displayOrderMeta =
      const VerificationMeta('displayOrder');
  @override
  late final GeneratedColumn<int> displayOrder = GeneratedColumn<int>(
      'display_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
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
        title,
        description,
        type,
        contentUrl,
        textContent,
        displayOrder,
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
    if (data.containsKey('text_content')) {
      context.handle(
          _textContentMeta,
          textContent.isAcceptableOrUnknown(
              data['text_content']!, _textContentMeta));
    }
    if (data.containsKey('display_order')) {
      context.handle(
          _displayOrderMeta,
          displayOrder.isAcceptableOrUnknown(
              data['display_order']!, _displayOrderMeta));
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
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      contentUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content_url']),
      textContent: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}text_content']),
      displayOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}display_order'])!,
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
  final String title;
  final String? description;
  final String type;
  final String? contentUrl;
  final String? textContent;
  final int displayOrder;
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
      required this.title,
      this.description,
      required this.type,
      this.contentUrl,
      this.textContent,
      required this.displayOrder,
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
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || contentUrl != null) {
      map['content_url'] = Variable<String>(contentUrl);
    }
    if (!nullToAbsent || textContent != null) {
      map['text_content'] = Variable<String>(textContent);
    }
    map['display_order'] = Variable<int>(displayOrder);
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
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      type: Value(type),
      contentUrl: contentUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(contentUrl),
      textContent: textContent == null && nullToAbsent
          ? const Value.absent()
          : Value(textContent),
      displayOrder: Value(displayOrder),
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
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      type: serializer.fromJson<String>(json['type']),
      contentUrl: serializer.fromJson<String?>(json['contentUrl']),
      textContent: serializer.fromJson<String?>(json['textContent']),
      displayOrder: serializer.fromJson<int>(json['displayOrder']),
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
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'type': serializer.toJson<String>(type),
      'contentUrl': serializer.toJson<String?>(contentUrl),
      'textContent': serializer.toJson<String?>(textContent),
      'displayOrder': serializer.toJson<int>(displayOrder),
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
          String? title,
          Value<String?> description = const Value.absent(),
          String? type,
          Value<String?> contentUrl = const Value.absent(),
          Value<String?> textContent = const Value.absent(),
          int? displayOrder,
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
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        type: type ?? this.type,
        contentUrl: contentUrl.present ? contentUrl.value : this.contentUrl,
        textContent: textContent.present ? textContent.value : this.textContent,
        displayOrder: displayOrder ?? this.displayOrder,
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
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      type: data.type.present ? data.type.value : this.type,
      contentUrl:
          data.contentUrl.present ? data.contentUrl.value : this.contentUrl,
      textContent:
          data.textContent.present ? data.textContent.value : this.textContent,
      displayOrder: data.displayOrder.present
          ? data.displayOrder.value
          : this.displayOrder,
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
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('contentUrl: $contentUrl, ')
          ..write('textContent: $textContent, ')
          ..write('displayOrder: $displayOrder, ')
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
  int get hashCode => Object.hash(
      id,
      courseId,
      moduleId,
      title,
      description,
      type,
      contentUrl,
      textContent,
      displayOrder,
      downloadable,
      completed,
      watchedSeconds,
      progressPercent,
      localFilePath,
      serverUpdatedAt,
      cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineLesson &&
          other.id == this.id &&
          other.courseId == this.courseId &&
          other.moduleId == this.moduleId &&
          other.title == this.title &&
          other.description == this.description &&
          other.type == this.type &&
          other.contentUrl == this.contentUrl &&
          other.textContent == this.textContent &&
          other.displayOrder == this.displayOrder &&
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
  final Value<String> title;
  final Value<String?> description;
  final Value<String> type;
  final Value<String?> contentUrl;
  final Value<String?> textContent;
  final Value<int> displayOrder;
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
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.type = const Value.absent(),
    this.contentUrl = const Value.absent(),
    this.textContent = const Value.absent(),
    this.displayOrder = const Value.absent(),
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
    required String title,
    this.description = const Value.absent(),
    this.type = const Value.absent(),
    this.contentUrl = const Value.absent(),
    this.textContent = const Value.absent(),
    this.displayOrder = const Value.absent(),
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
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? type,
    Expression<String>? contentUrl,
    Expression<String>? textContent,
    Expression<int>? displayOrder,
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
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
      if (contentUrl != null) 'content_url': contentUrl,
      if (textContent != null) 'text_content': textContent,
      if (displayOrder != null) 'display_order': displayOrder,
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
      Value<String>? title,
      Value<String?>? description,
      Value<String>? type,
      Value<String?>? contentUrl,
      Value<String?>? textContent,
      Value<int>? displayOrder,
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
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      contentUrl: contentUrl ?? this.contentUrl,
      textContent: textContent ?? this.textContent,
      displayOrder: displayOrder ?? this.displayOrder,
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
    if (textContent.present) {
      map['text_content'] = Variable<String>(textContent.value);
    }
    if (displayOrder.present) {
      map['display_order'] = Variable<int>(displayOrder.value);
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
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('contentUrl: $contentUrl, ')
          ..write('textContent: $textContent, ')
          ..write('displayOrder: $displayOrder, ')
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
  late final $OfflineLessonsTable offlineLessons = $OfflineLessonsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [offlineCourses, offlineLessons];
}

typedef $$OfflineCoursesTableCreateCompanionBuilder = OfflineCoursesCompanion
    Function({
  required String id,
  required String title,
  Value<String?> description,
  Value<String?> thumbnailUrl,
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
  Value<String?> thumbnailUrl,
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

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
      column: $table.thumbnailUrl, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
      column: $table.thumbnailUrl,
      builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
      column: $table.thumbnailUrl, builder: (column) => column);

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
            Value<String?> thumbnailUrl = const Value.absent(),
            Value<int> progressPercent = const Value.absent(),
            Value<DateTime?> serverUpdatedAt = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OfflineCoursesCompanion(
            id: id,
            title: title,
            description: description,
            thumbnailUrl: thumbnailUrl,
            progressPercent: progressPercent,
            serverUpdatedAt: serverUpdatedAt,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            Value<String?> description = const Value.absent(),
            Value<String?> thumbnailUrl = const Value.absent(),
            Value<int> progressPercent = const Value.absent(),
            Value<DateTime?> serverUpdatedAt = const Value.absent(),
            required DateTime cachedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              OfflineCoursesCompanion.insert(
            id: id,
            title: title,
            description: description,
            thumbnailUrl: thumbnailUrl,
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
typedef $$OfflineLessonsTableCreateCompanionBuilder = OfflineLessonsCompanion
    Function({
  required String id,
  required String courseId,
  Value<String?> moduleId,
  required String title,
  Value<String?> description,
  Value<String> type,
  Value<String?> contentUrl,
  Value<String?> textContent,
  Value<int> displayOrder,
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
  Value<String> title,
  Value<String?> description,
  Value<String> type,
  Value<String?> contentUrl,
  Value<String?> textContent,
  Value<int> displayOrder,
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

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contentUrl => $composableBuilder(
      column: $table.contentUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get textContent => $composableBuilder(
      column: $table.textContent, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contentUrl => $composableBuilder(
      column: $table.contentUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get textContent => $composableBuilder(
      column: $table.textContent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder,
      builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get contentUrl => $composableBuilder(
      column: $table.contentUrl, builder: (column) => column);

  GeneratedColumn<String> get textContent => $composableBuilder(
      column: $table.textContent, builder: (column) => column);

  GeneratedColumn<int> get displayOrder => $composableBuilder(
      column: $table.displayOrder, builder: (column) => column);

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
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> contentUrl = const Value.absent(),
            Value<String?> textContent = const Value.absent(),
            Value<int> displayOrder = const Value.absent(),
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
            title: title,
            description: description,
            type: type,
            contentUrl: contentUrl,
            textContent: textContent,
            displayOrder: displayOrder,
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
            required String title,
            Value<String?> description = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> contentUrl = const Value.absent(),
            Value<String?> textContent = const Value.absent(),
            Value<int> displayOrder = const Value.absent(),
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
            title: title,
            description: description,
            type: type,
            contentUrl: contentUrl,
            textContent: textContent,
            displayOrder: displayOrder,
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
  $$OfflineLessonsTableTableManager get offlineLessons =>
      $$OfflineLessonsTableTableManager(_db, _db.offlineLessons);
}
