// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CassettesTable extends Cassettes
    with TableInfo<$CassettesTable, CassetteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CassettesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleIsUserSetMeta = const VerificationMeta(
    'titleIsUserSet',
  );
  @override
  late final GeneratedColumn<bool> titleIsUserSet = GeneratedColumn<bool>(
    'title_is_user_set',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("title_is_user_set" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _colorSeedMeta = const VerificationMeta(
    'colorSeed',
  );
  @override
  late final GeneratedColumn<int> colorSeed = GeneratedColumn<int>(
    'color_seed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryUpdatedAtMeta = const VerificationMeta(
    'summaryUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> summaryUpdatedAt = GeneratedColumn<int>(
    'summary_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    label,
    titleIsUserSet,
    colorSeed,
    summary,
    summaryUpdatedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cassettes';
  @override
  VerificationContext validateIntegrity(
    Insertable<CassetteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('title_is_user_set')) {
      context.handle(
        _titleIsUserSetMeta,
        titleIsUserSet.isAcceptableOrUnknown(
          data['title_is_user_set']!,
          _titleIsUserSetMeta,
        ),
      );
    }
    if (data.containsKey('color_seed')) {
      context.handle(
        _colorSeedMeta,
        colorSeed.isAcceptableOrUnknown(data['color_seed']!, _colorSeedMeta),
      );
    } else if (isInserting) {
      context.missing(_colorSeedMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('summary_updated_at')) {
      context.handle(
        _summaryUpdatedAtMeta,
        summaryUpdatedAt.isAcceptableOrUnknown(
          data['summary_updated_at']!,
          _summaryUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CassetteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CassetteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      titleIsUserSet: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}title_is_user_set'],
      )!,
      colorSeed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_seed'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      ),
      summaryUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}summary_updated_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CassettesTable createAlias(String alias) {
    return $CassettesTable(attachedDatabase, alias);
  }
}

class CassetteRow extends DataClass implements Insertable<CassetteRow> {
  final String id;
  final String? label;
  final bool titleIsUserSet;
  final int colorSeed;
  final String? summary;
  final int? summaryUpdatedAt;
  final int createdAt;
  final int updatedAt;
  const CassetteRow({
    required this.id,
    this.label,
    required this.titleIsUserSet,
    required this.colorSeed,
    this.summary,
    this.summaryUpdatedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['title_is_user_set'] = Variable<bool>(titleIsUserSet);
    map['color_seed'] = Variable<int>(colorSeed);
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    if (!nullToAbsent || summaryUpdatedAt != null) {
      map['summary_updated_at'] = Variable<int>(summaryUpdatedAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  CassettesCompanion toCompanion(bool nullToAbsent) {
    return CassettesCompanion(
      id: Value(id),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      titleIsUserSet: Value(titleIsUserSet),
      colorSeed: Value(colorSeed),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      summaryUpdatedAt: summaryUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(summaryUpdatedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CassetteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CassetteRow(
      id: serializer.fromJson<String>(json['id']),
      label: serializer.fromJson<String?>(json['label']),
      titleIsUserSet: serializer.fromJson<bool>(json['titleIsUserSet']),
      colorSeed: serializer.fromJson<int>(json['colorSeed']),
      summary: serializer.fromJson<String?>(json['summary']),
      summaryUpdatedAt: serializer.fromJson<int?>(json['summaryUpdatedAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'label': serializer.toJson<String?>(label),
      'titleIsUserSet': serializer.toJson<bool>(titleIsUserSet),
      'colorSeed': serializer.toJson<int>(colorSeed),
      'summary': serializer.toJson<String?>(summary),
      'summaryUpdatedAt': serializer.toJson<int?>(summaryUpdatedAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  CassetteRow copyWith({
    String? id,
    Value<String?> label = const Value.absent(),
    bool? titleIsUserSet,
    int? colorSeed,
    Value<String?> summary = const Value.absent(),
    Value<int?> summaryUpdatedAt = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => CassetteRow(
    id: id ?? this.id,
    label: label.present ? label.value : this.label,
    titleIsUserSet: titleIsUserSet ?? this.titleIsUserSet,
    colorSeed: colorSeed ?? this.colorSeed,
    summary: summary.present ? summary.value : this.summary,
    summaryUpdatedAt: summaryUpdatedAt.present
        ? summaryUpdatedAt.value
        : this.summaryUpdatedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CassetteRow copyWithCompanion(CassettesCompanion data) {
    return CassetteRow(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      titleIsUserSet: data.titleIsUserSet.present
          ? data.titleIsUserSet.value
          : this.titleIsUserSet,
      colorSeed: data.colorSeed.present ? data.colorSeed.value : this.colorSeed,
      summary: data.summary.present ? data.summary.value : this.summary,
      summaryUpdatedAt: data.summaryUpdatedAt.present
          ? data.summaryUpdatedAt.value
          : this.summaryUpdatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CassetteRow(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('titleIsUserSet: $titleIsUserSet, ')
          ..write('colorSeed: $colorSeed, ')
          ..write('summary: $summary, ')
          ..write('summaryUpdatedAt: $summaryUpdatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    titleIsUserSet,
    colorSeed,
    summary,
    summaryUpdatedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CassetteRow &&
          other.id == this.id &&
          other.label == this.label &&
          other.titleIsUserSet == this.titleIsUserSet &&
          other.colorSeed == this.colorSeed &&
          other.summary == this.summary &&
          other.summaryUpdatedAt == this.summaryUpdatedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CassettesCompanion extends UpdateCompanion<CassetteRow> {
  final Value<String> id;
  final Value<String?> label;
  final Value<bool> titleIsUserSet;
  final Value<int> colorSeed;
  final Value<String?> summary;
  final Value<int?> summaryUpdatedAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const CassettesCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.titleIsUserSet = const Value.absent(),
    this.colorSeed = const Value.absent(),
    this.summary = const Value.absent(),
    this.summaryUpdatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CassettesCompanion.insert({
    required String id,
    this.label = const Value.absent(),
    this.titleIsUserSet = const Value.absent(),
    required int colorSeed,
    this.summary = const Value.absent(),
    this.summaryUpdatedAt = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       colorSeed = Value(colorSeed),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CassetteRow> custom({
    Expression<String>? id,
    Expression<String>? label,
    Expression<bool>? titleIsUserSet,
    Expression<int>? colorSeed,
    Expression<String>? summary,
    Expression<int>? summaryUpdatedAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (titleIsUserSet != null) 'title_is_user_set': titleIsUserSet,
      if (colorSeed != null) 'color_seed': colorSeed,
      if (summary != null) 'summary': summary,
      if (summaryUpdatedAt != null) 'summary_updated_at': summaryUpdatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CassettesCompanion copyWith({
    Value<String>? id,
    Value<String?>? label,
    Value<bool>? titleIsUserSet,
    Value<int>? colorSeed,
    Value<String?>? summary,
    Value<int?>? summaryUpdatedAt,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return CassettesCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      titleIsUserSet: titleIsUserSet ?? this.titleIsUserSet,
      colorSeed: colorSeed ?? this.colorSeed,
      summary: summary ?? this.summary,
      summaryUpdatedAt: summaryUpdatedAt ?? this.summaryUpdatedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (titleIsUserSet.present) {
      map['title_is_user_set'] = Variable<bool>(titleIsUserSet.value);
    }
    if (colorSeed.present) {
      map['color_seed'] = Variable<int>(colorSeed.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (summaryUpdatedAt.present) {
      map['summary_updated_at'] = Variable<int>(summaryUpdatedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CassettesCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('titleIsUserSet: $titleIsUserSet, ')
          ..write('colorSeed: $colorSeed, ')
          ..write('summary: $summary, ')
          ..write('summaryUpdatedAt: $summaryUpdatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemosTable extends Memos with TableInfo<$MemosTable, MemoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cassetteIdMeta = const VerificationMeta(
    'cassetteId',
  );
  @override
  late final GeneratedColumn<String> cassetteId = GeneratedColumn<String>(
    'cassette_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cassettes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detectedLangMeta = const VerificationMeta(
    'detectedLang',
  );
  @override
  late final GeneratedColumn<String> detectedLang = GeneratedColumn<String>(
    'detected_lang',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transcriptMeta = const VerificationMeta(
    'transcript',
  );
  @override
  late final GeneratedColumn<String> transcript = GeneratedColumn<String>(
    'transcript',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawTranscriptMeta = const VerificationMeta(
    'rawTranscript',
  );
  @override
  late final GeneratedColumn<String> rawTranscript = GeneratedColumn<String>(
    'raw_transcript',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memoSummaryMeta = const VerificationMeta(
    'memoSummary',
  );
  @override
  late final GeneratedColumn<String> memoSummary = GeneratedColumn<String>(
    'memo_summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _foldedAtMeta = const VerificationMeta(
    'foldedAt',
  );
  @override
  late final GeneratedColumn<int> foldedAt = GeneratedColumn<int>(
    'folded_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uploadStatusMeta = const VerificationMeta(
    'uploadStatus',
  );
  @override
  late final GeneratedColumn<String> uploadStatus = GeneratedColumn<String>(
    'upload_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uploadedAtMeta = const VerificationMeta(
    'uploadedAt',
  );
  @override
  late final GeneratedColumn<int> uploadedAt = GeneratedColumn<int>(
    'uploaded_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cloudConsentAtMeta = const VerificationMeta(
    'cloudConsentAt',
  );
  @override
  late final GeneratedColumn<int> cloudConsentAt = GeneratedColumn<int>(
    'cloud_consent_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cassetteId,
    filePath,
    durationMs,
    createdAt,
    detectedLang,
    transcript,
    rawTranscript,
    memoSummary,
    foldedAt,
    status,
    uploadStatus,
    uploadedAt,
    cloudConsentAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memos';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cassette_id')) {
      context.handle(
        _cassetteIdMeta,
        cassetteId.isAcceptableOrUnknown(data['cassette_id']!, _cassetteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cassetteIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('detected_lang')) {
      context.handle(
        _detectedLangMeta,
        detectedLang.isAcceptableOrUnknown(
          data['detected_lang']!,
          _detectedLangMeta,
        ),
      );
    }
    if (data.containsKey('transcript')) {
      context.handle(
        _transcriptMeta,
        transcript.isAcceptableOrUnknown(data['transcript']!, _transcriptMeta),
      );
    }
    if (data.containsKey('raw_transcript')) {
      context.handle(
        _rawTranscriptMeta,
        rawTranscript.isAcceptableOrUnknown(
          data['raw_transcript']!,
          _rawTranscriptMeta,
        ),
      );
    }
    if (data.containsKey('memo_summary')) {
      context.handle(
        _memoSummaryMeta,
        memoSummary.isAcceptableOrUnknown(
          data['memo_summary']!,
          _memoSummaryMeta,
        ),
      );
    }
    if (data.containsKey('folded_at')) {
      context.handle(
        _foldedAtMeta,
        foldedAt.isAcceptableOrUnknown(data['folded_at']!, _foldedAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('upload_status')) {
      context.handle(
        _uploadStatusMeta,
        uploadStatus.isAcceptableOrUnknown(
          data['upload_status']!,
          _uploadStatusMeta,
        ),
      );
    }
    if (data.containsKey('uploaded_at')) {
      context.handle(
        _uploadedAtMeta,
        uploadedAt.isAcceptableOrUnknown(data['uploaded_at']!, _uploadedAtMeta),
      );
    }
    if (data.containsKey('cloud_consent_at')) {
      context.handle(
        _cloudConsentAtMeta,
        cloudConsentAt.isAcceptableOrUnknown(
          data['cloud_consent_at']!,
          _cloudConsentAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MemoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cassetteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cassette_id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      detectedLang: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detected_lang'],
      ),
      transcript: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcript'],
      ),
      rawTranscript: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_transcript'],
      ),
      memoSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo_summary'],
      ),
      foldedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}folded_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      uploadStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upload_status'],
      ),
      uploadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}uploaded_at'],
      ),
      cloudConsentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cloud_consent_at'],
      ),
    );
  }

  @override
  $MemosTable createAlias(String alias) {
    return $MemosTable(attachedDatabase, alias);
  }
}

class MemoRow extends DataClass implements Insertable<MemoRow> {
  final String id;
  final String cassetteId;
  final String filePath;
  final int durationMs;
  final int createdAt;
  final String? detectedLang;

  /// Transcript stored as a JSON blob per memo (§7.2 — no search in v1).
  final String? transcript;

  /// Legacy LLM-cleanup bookkeeping (§6.8, retired 2026-07-13): the
  /// engine's original take from when cleanup rewrote [transcript]. No
  /// longer written — kept, like [foldedAt], so existing databases need no
  /// migration.
  final String? rawTranscript;
  final String? memoSummary;

  /// Legacy M3 fold bookkeeping — no longer written since the cassette
  /// summary is rebuilt from all gists (§6.7 revised 2026-07-08); kept so
  /// existing databases need no migration.
  final int? foldedAt;
  final String status;

  /// Server-upload surface state (UploadStatus.name); null = the feature has
  /// never touched this memo (upload disabled when it was finalized).
  final String? uploadStatus;

  /// Server-confirmed upload instant (epoch ms); null until then.
  final int? uploadedAt;

  /// The user explicitly approved cloud-processing this exact memo
  /// (epoch ms); audio is content-immutable, so the grant never rebinds.
  /// Null = never asked/never granted; phone-local mode handles it.
  final int? cloudConsentAt;
  const MemoRow({
    required this.id,
    required this.cassetteId,
    required this.filePath,
    required this.durationMs,
    required this.createdAt,
    this.detectedLang,
    this.transcript,
    this.rawTranscript,
    this.memoSummary,
    this.foldedAt,
    required this.status,
    this.uploadStatus,
    this.uploadedAt,
    this.cloudConsentAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['cassette_id'] = Variable<String>(cassetteId);
    map['file_path'] = Variable<String>(filePath);
    map['duration_ms'] = Variable<int>(durationMs);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || detectedLang != null) {
      map['detected_lang'] = Variable<String>(detectedLang);
    }
    if (!nullToAbsent || transcript != null) {
      map['transcript'] = Variable<String>(transcript);
    }
    if (!nullToAbsent || rawTranscript != null) {
      map['raw_transcript'] = Variable<String>(rawTranscript);
    }
    if (!nullToAbsent || memoSummary != null) {
      map['memo_summary'] = Variable<String>(memoSummary);
    }
    if (!nullToAbsent || foldedAt != null) {
      map['folded_at'] = Variable<int>(foldedAt);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || uploadStatus != null) {
      map['upload_status'] = Variable<String>(uploadStatus);
    }
    if (!nullToAbsent || uploadedAt != null) {
      map['uploaded_at'] = Variable<int>(uploadedAt);
    }
    if (!nullToAbsent || cloudConsentAt != null) {
      map['cloud_consent_at'] = Variable<int>(cloudConsentAt);
    }
    return map;
  }

  MemosCompanion toCompanion(bool nullToAbsent) {
    return MemosCompanion(
      id: Value(id),
      cassetteId: Value(cassetteId),
      filePath: Value(filePath),
      durationMs: Value(durationMs),
      createdAt: Value(createdAt),
      detectedLang: detectedLang == null && nullToAbsent
          ? const Value.absent()
          : Value(detectedLang),
      transcript: transcript == null && nullToAbsent
          ? const Value.absent()
          : Value(transcript),
      rawTranscript: rawTranscript == null && nullToAbsent
          ? const Value.absent()
          : Value(rawTranscript),
      memoSummary: memoSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(memoSummary),
      foldedAt: foldedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(foldedAt),
      status: Value(status),
      uploadStatus: uploadStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(uploadStatus),
      uploadedAt: uploadedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(uploadedAt),
      cloudConsentAt: cloudConsentAt == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudConsentAt),
    );
  }

  factory MemoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoRow(
      id: serializer.fromJson<String>(json['id']),
      cassetteId: serializer.fromJson<String>(json['cassetteId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      detectedLang: serializer.fromJson<String?>(json['detectedLang']),
      transcript: serializer.fromJson<String?>(json['transcript']),
      rawTranscript: serializer.fromJson<String?>(json['rawTranscript']),
      memoSummary: serializer.fromJson<String?>(json['memoSummary']),
      foldedAt: serializer.fromJson<int?>(json['foldedAt']),
      status: serializer.fromJson<String>(json['status']),
      uploadStatus: serializer.fromJson<String?>(json['uploadStatus']),
      uploadedAt: serializer.fromJson<int?>(json['uploadedAt']),
      cloudConsentAt: serializer.fromJson<int?>(json['cloudConsentAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cassetteId': serializer.toJson<String>(cassetteId),
      'filePath': serializer.toJson<String>(filePath),
      'durationMs': serializer.toJson<int>(durationMs),
      'createdAt': serializer.toJson<int>(createdAt),
      'detectedLang': serializer.toJson<String?>(detectedLang),
      'transcript': serializer.toJson<String?>(transcript),
      'rawTranscript': serializer.toJson<String?>(rawTranscript),
      'memoSummary': serializer.toJson<String?>(memoSummary),
      'foldedAt': serializer.toJson<int?>(foldedAt),
      'status': serializer.toJson<String>(status),
      'uploadStatus': serializer.toJson<String?>(uploadStatus),
      'uploadedAt': serializer.toJson<int?>(uploadedAt),
      'cloudConsentAt': serializer.toJson<int?>(cloudConsentAt),
    };
  }

  MemoRow copyWith({
    String? id,
    String? cassetteId,
    String? filePath,
    int? durationMs,
    int? createdAt,
    Value<String?> detectedLang = const Value.absent(),
    Value<String?> transcript = const Value.absent(),
    Value<String?> rawTranscript = const Value.absent(),
    Value<String?> memoSummary = const Value.absent(),
    Value<int?> foldedAt = const Value.absent(),
    String? status,
    Value<String?> uploadStatus = const Value.absent(),
    Value<int?> uploadedAt = const Value.absent(),
    Value<int?> cloudConsentAt = const Value.absent(),
  }) => MemoRow(
    id: id ?? this.id,
    cassetteId: cassetteId ?? this.cassetteId,
    filePath: filePath ?? this.filePath,
    durationMs: durationMs ?? this.durationMs,
    createdAt: createdAt ?? this.createdAt,
    detectedLang: detectedLang.present ? detectedLang.value : this.detectedLang,
    transcript: transcript.present ? transcript.value : this.transcript,
    rawTranscript: rawTranscript.present
        ? rawTranscript.value
        : this.rawTranscript,
    memoSummary: memoSummary.present ? memoSummary.value : this.memoSummary,
    foldedAt: foldedAt.present ? foldedAt.value : this.foldedAt,
    status: status ?? this.status,
    uploadStatus: uploadStatus.present ? uploadStatus.value : this.uploadStatus,
    uploadedAt: uploadedAt.present ? uploadedAt.value : this.uploadedAt,
    cloudConsentAt: cloudConsentAt.present
        ? cloudConsentAt.value
        : this.cloudConsentAt,
  );
  MemoRow copyWithCompanion(MemosCompanion data) {
    return MemoRow(
      id: data.id.present ? data.id.value : this.id,
      cassetteId: data.cassetteId.present
          ? data.cassetteId.value
          : this.cassetteId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      detectedLang: data.detectedLang.present
          ? data.detectedLang.value
          : this.detectedLang,
      transcript: data.transcript.present
          ? data.transcript.value
          : this.transcript,
      rawTranscript: data.rawTranscript.present
          ? data.rawTranscript.value
          : this.rawTranscript,
      memoSummary: data.memoSummary.present
          ? data.memoSummary.value
          : this.memoSummary,
      foldedAt: data.foldedAt.present ? data.foldedAt.value : this.foldedAt,
      status: data.status.present ? data.status.value : this.status,
      uploadStatus: data.uploadStatus.present
          ? data.uploadStatus.value
          : this.uploadStatus,
      uploadedAt: data.uploadedAt.present
          ? data.uploadedAt.value
          : this.uploadedAt,
      cloudConsentAt: data.cloudConsentAt.present
          ? data.cloudConsentAt.value
          : this.cloudConsentAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemoRow(')
          ..write('id: $id, ')
          ..write('cassetteId: $cassetteId, ')
          ..write('filePath: $filePath, ')
          ..write('durationMs: $durationMs, ')
          ..write('createdAt: $createdAt, ')
          ..write('detectedLang: $detectedLang, ')
          ..write('transcript: $transcript, ')
          ..write('rawTranscript: $rawTranscript, ')
          ..write('memoSummary: $memoSummary, ')
          ..write('foldedAt: $foldedAt, ')
          ..write('status: $status, ')
          ..write('uploadStatus: $uploadStatus, ')
          ..write('uploadedAt: $uploadedAt, ')
          ..write('cloudConsentAt: $cloudConsentAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cassetteId,
    filePath,
    durationMs,
    createdAt,
    detectedLang,
    transcript,
    rawTranscript,
    memoSummary,
    foldedAt,
    status,
    uploadStatus,
    uploadedAt,
    cloudConsentAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoRow &&
          other.id == this.id &&
          other.cassetteId == this.cassetteId &&
          other.filePath == this.filePath &&
          other.durationMs == this.durationMs &&
          other.createdAt == this.createdAt &&
          other.detectedLang == this.detectedLang &&
          other.transcript == this.transcript &&
          other.rawTranscript == this.rawTranscript &&
          other.memoSummary == this.memoSummary &&
          other.foldedAt == this.foldedAt &&
          other.status == this.status &&
          other.uploadStatus == this.uploadStatus &&
          other.uploadedAt == this.uploadedAt &&
          other.cloudConsentAt == this.cloudConsentAt);
}

class MemosCompanion extends UpdateCompanion<MemoRow> {
  final Value<String> id;
  final Value<String> cassetteId;
  final Value<String> filePath;
  final Value<int> durationMs;
  final Value<int> createdAt;
  final Value<String?> detectedLang;
  final Value<String?> transcript;
  final Value<String?> rawTranscript;
  final Value<String?> memoSummary;
  final Value<int?> foldedAt;
  final Value<String> status;
  final Value<String?> uploadStatus;
  final Value<int?> uploadedAt;
  final Value<int?> cloudConsentAt;
  final Value<int> rowid;
  const MemosCompanion({
    this.id = const Value.absent(),
    this.cassetteId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.detectedLang = const Value.absent(),
    this.transcript = const Value.absent(),
    this.rawTranscript = const Value.absent(),
    this.memoSummary = const Value.absent(),
    this.foldedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.uploadStatus = const Value.absent(),
    this.uploadedAt = const Value.absent(),
    this.cloudConsentAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemosCompanion.insert({
    required String id,
    required String cassetteId,
    required String filePath,
    required int durationMs,
    required int createdAt,
    this.detectedLang = const Value.absent(),
    this.transcript = const Value.absent(),
    this.rawTranscript = const Value.absent(),
    this.memoSummary = const Value.absent(),
    this.foldedAt = const Value.absent(),
    required String status,
    this.uploadStatus = const Value.absent(),
    this.uploadedAt = const Value.absent(),
    this.cloudConsentAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cassetteId = Value(cassetteId),
       filePath = Value(filePath),
       durationMs = Value(durationMs),
       createdAt = Value(createdAt),
       status = Value(status);
  static Insertable<MemoRow> custom({
    Expression<String>? id,
    Expression<String>? cassetteId,
    Expression<String>? filePath,
    Expression<int>? durationMs,
    Expression<int>? createdAt,
    Expression<String>? detectedLang,
    Expression<String>? transcript,
    Expression<String>? rawTranscript,
    Expression<String>? memoSummary,
    Expression<int>? foldedAt,
    Expression<String>? status,
    Expression<String>? uploadStatus,
    Expression<int>? uploadedAt,
    Expression<int>? cloudConsentAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cassetteId != null) 'cassette_id': cassetteId,
      if (filePath != null) 'file_path': filePath,
      if (durationMs != null) 'duration_ms': durationMs,
      if (createdAt != null) 'created_at': createdAt,
      if (detectedLang != null) 'detected_lang': detectedLang,
      if (transcript != null) 'transcript': transcript,
      if (rawTranscript != null) 'raw_transcript': rawTranscript,
      if (memoSummary != null) 'memo_summary': memoSummary,
      if (foldedAt != null) 'folded_at': foldedAt,
      if (status != null) 'status': status,
      if (uploadStatus != null) 'upload_status': uploadStatus,
      if (uploadedAt != null) 'uploaded_at': uploadedAt,
      if (cloudConsentAt != null) 'cloud_consent_at': cloudConsentAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemosCompanion copyWith({
    Value<String>? id,
    Value<String>? cassetteId,
    Value<String>? filePath,
    Value<int>? durationMs,
    Value<int>? createdAt,
    Value<String?>? detectedLang,
    Value<String?>? transcript,
    Value<String?>? rawTranscript,
    Value<String?>? memoSummary,
    Value<int?>? foldedAt,
    Value<String>? status,
    Value<String?>? uploadStatus,
    Value<int?>? uploadedAt,
    Value<int?>? cloudConsentAt,
    Value<int>? rowid,
  }) {
    return MemosCompanion(
      id: id ?? this.id,
      cassetteId: cassetteId ?? this.cassetteId,
      filePath: filePath ?? this.filePath,
      durationMs: durationMs ?? this.durationMs,
      createdAt: createdAt ?? this.createdAt,
      detectedLang: detectedLang ?? this.detectedLang,
      transcript: transcript ?? this.transcript,
      rawTranscript: rawTranscript ?? this.rawTranscript,
      memoSummary: memoSummary ?? this.memoSummary,
      foldedAt: foldedAt ?? this.foldedAt,
      status: status ?? this.status,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      cloudConsentAt: cloudConsentAt ?? this.cloudConsentAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cassetteId.present) {
      map['cassette_id'] = Variable<String>(cassetteId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (detectedLang.present) {
      map['detected_lang'] = Variable<String>(detectedLang.value);
    }
    if (transcript.present) {
      map['transcript'] = Variable<String>(transcript.value);
    }
    if (rawTranscript.present) {
      map['raw_transcript'] = Variable<String>(rawTranscript.value);
    }
    if (memoSummary.present) {
      map['memo_summary'] = Variable<String>(memoSummary.value);
    }
    if (foldedAt.present) {
      map['folded_at'] = Variable<int>(foldedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (uploadStatus.present) {
      map['upload_status'] = Variable<String>(uploadStatus.value);
    }
    if (uploadedAt.present) {
      map['uploaded_at'] = Variable<int>(uploadedAt.value);
    }
    if (cloudConsentAt.present) {
      map['cloud_consent_at'] = Variable<int>(cloudConsentAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemosCompanion(')
          ..write('id: $id, ')
          ..write('cassetteId: $cassetteId, ')
          ..write('filePath: $filePath, ')
          ..write('durationMs: $durationMs, ')
          ..write('createdAt: $createdAt, ')
          ..write('detectedLang: $detectedLang, ')
          ..write('transcript: $transcript, ')
          ..write('rawTranscript: $rawTranscript, ')
          ..write('memoSummary: $memoSummary, ')
          ..write('foldedAt: $foldedAt, ')
          ..write('status: $status, ')
          ..write('uploadStatus: $uploadStatus, ')
          ..write('uploadedAt: $uploadedAt, ')
          ..write('cloudConsentAt: $cloudConsentAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JobsTable extends Jobs with TableInfo<$JobsTable, JobRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
    'target_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _availableAtMeta = const VerificationMeta(
    'availableAt',
  );
  @override
  late final GeneratedColumn<int> availableAt = GeneratedColumn<int>(
    'available_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leaseUntilMeta = const VerificationMeta(
    'leaseUntil',
  );
  @override
  late final GeneratedColumn<int> leaseUntil = GeneratedColumn<int>(
    'lease_until',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    targetId,
    status,
    attempts,
    createdAt,
    availableAt,
    ownerId,
    leaseUntil,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<JobRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('available_at')) {
      context.handle(
        _availableAtMeta,
        availableAt.isAcceptableOrUnknown(
          data['available_at']!,
          _availableAtMeta,
        ),
      );
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('lease_until')) {
      context.handle(
        _leaseUntilMeta,
        leaseUntil.isAcceptableOrUnknown(data['lease_until']!, _leaseUntilMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JobRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JobRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      availableAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}available_at'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      ),
      leaseUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lease_until'],
      )!,
    );
  }

  @override
  $JobsTable createAlias(String alias) {
    return $JobsTable(attachedDatabase, alias);
  }
}

class JobRow extends DataClass implements Insertable<JobRow> {
  final String id;
  final String type;
  final String targetId;
  final String status;
  final int attempts;
  final int createdAt;

  /// Do-not-pick-before instant (epoch ms). Backoff without occupying the
  /// drain loop: a deferred/requeued job parks in 'queued' until then.
  final int availableAt;

  /// Claim token of the process/lane currently working the job — guards
  /// the app process and the WorkManager headless engine from running
  /// each other's jobs concurrently.
  final String? ownerId;

  /// Claim expiry (epoch ms); another lane may take over only afterwards.
  /// NULL/0 = no lease.
  final int leaseUntil;
  const JobRow({
    required this.id,
    required this.type,
    required this.targetId,
    required this.status,
    required this.attempts,
    required this.createdAt,
    required this.availableAt,
    this.ownerId,
    required this.leaseUntil,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['target_id'] = Variable<String>(targetId);
    map['status'] = Variable<String>(status);
    map['attempts'] = Variable<int>(attempts);
    map['created_at'] = Variable<int>(createdAt);
    map['available_at'] = Variable<int>(availableAt);
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    map['lease_until'] = Variable<int>(leaseUntil);
    return map;
  }

  JobsCompanion toCompanion(bool nullToAbsent) {
    return JobsCompanion(
      id: Value(id),
      type: Value(type),
      targetId: Value(targetId),
      status: Value(status),
      attempts: Value(attempts),
      createdAt: Value(createdAt),
      availableAt: Value(availableAt),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      leaseUntil: Value(leaseUntil),
    );
  }

  factory JobRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JobRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      targetId: serializer.fromJson<String>(json['targetId']),
      status: serializer.fromJson<String>(json['status']),
      attempts: serializer.fromJson<int>(json['attempts']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      availableAt: serializer.fromJson<int>(json['availableAt']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      leaseUntil: serializer.fromJson<int>(json['leaseUntil']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'targetId': serializer.toJson<String>(targetId),
      'status': serializer.toJson<String>(status),
      'attempts': serializer.toJson<int>(attempts),
      'createdAt': serializer.toJson<int>(createdAt),
      'availableAt': serializer.toJson<int>(availableAt),
      'ownerId': serializer.toJson<String?>(ownerId),
      'leaseUntil': serializer.toJson<int>(leaseUntil),
    };
  }

  JobRow copyWith({
    String? id,
    String? type,
    String? targetId,
    String? status,
    int? attempts,
    int? createdAt,
    int? availableAt,
    Value<String?> ownerId = const Value.absent(),
    int? leaseUntil,
  }) => JobRow(
    id: id ?? this.id,
    type: type ?? this.type,
    targetId: targetId ?? this.targetId,
    status: status ?? this.status,
    attempts: attempts ?? this.attempts,
    createdAt: createdAt ?? this.createdAt,
    availableAt: availableAt ?? this.availableAt,
    ownerId: ownerId.present ? ownerId.value : this.ownerId,
    leaseUntil: leaseUntil ?? this.leaseUntil,
  );
  JobRow copyWithCompanion(JobsCompanion data) {
    return JobRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      status: data.status.present ? data.status.value : this.status,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      availableAt: data.availableAt.present
          ? data.availableAt.value
          : this.availableAt,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      leaseUntil: data.leaseUntil.present
          ? data.leaseUntil.value
          : this.leaseUntil,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JobRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('targetId: $targetId, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('availableAt: $availableAt, ')
          ..write('ownerId: $ownerId, ')
          ..write('leaseUntil: $leaseUntil')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    targetId,
    status,
    attempts,
    createdAt,
    availableAt,
    ownerId,
    leaseUntil,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JobRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.targetId == this.targetId &&
          other.status == this.status &&
          other.attempts == this.attempts &&
          other.createdAt == this.createdAt &&
          other.availableAt == this.availableAt &&
          other.ownerId == this.ownerId &&
          other.leaseUntil == this.leaseUntil);
}

class JobsCompanion extends UpdateCompanion<JobRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> targetId;
  final Value<String> status;
  final Value<int> attempts;
  final Value<int> createdAt;
  final Value<int> availableAt;
  final Value<String?> ownerId;
  final Value<int> leaseUntil;
  final Value<int> rowid;
  const JobsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.targetId = const Value.absent(),
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.availableAt = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.leaseUntil = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JobsCompanion.insert({
    required String id,
    required String type,
    required String targetId,
    required String status,
    this.attempts = const Value.absent(),
    required int createdAt,
    this.availableAt = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.leaseUntil = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       targetId = Value(targetId),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<JobRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? targetId,
    Expression<String>? status,
    Expression<int>? attempts,
    Expression<int>? createdAt,
    Expression<int>? availableAt,
    Expression<String>? ownerId,
    Expression<int>? leaseUntil,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (targetId != null) 'target_id': targetId,
      if (status != null) 'status': status,
      if (attempts != null) 'attempts': attempts,
      if (createdAt != null) 'created_at': createdAt,
      if (availableAt != null) 'available_at': availableAt,
      if (ownerId != null) 'owner_id': ownerId,
      if (leaseUntil != null) 'lease_until': leaseUntil,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JobsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String>? targetId,
    Value<String>? status,
    Value<int>? attempts,
    Value<int>? createdAt,
    Value<int>? availableAt,
    Value<String?>? ownerId,
    Value<int>? leaseUntil,
    Value<int>? rowid,
  }) {
    return JobsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      targetId: targetId ?? this.targetId,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      createdAt: createdAt ?? this.createdAt,
      availableAt: availableAt ?? this.availableAt,
      ownerId: ownerId ?? this.ownerId,
      leaseUntil: leaseUntil ?? this.leaseUntil,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (availableAt.present) {
      map['available_at'] = Variable<int>(availableAt.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (leaseUntil.present) {
      map['lease_until'] = Variable<int>(leaseUntil.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JobsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('targetId: $targetId, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('availableAt: $availableAt, ')
          ..write('ownerId: $ownerId, ')
          ..write('leaseUntil: $leaseUntil, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CloudJobsTable extends CloudJobs
    with TableInfo<$CloudJobsTable, CloudJobRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CloudJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _memoIdMeta = const VerificationMeta('memoId');
  @override
  late final GeneratedColumn<String> memoId = GeneratedColumn<String>(
    'memo_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES memos (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _requestIdMeta = const VerificationMeta(
    'requestId',
  );
  @override
  late final GeneratedColumn<String> requestId = GeneratedColumn<String>(
    'request_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientRevisionMeta = const VerificationMeta(
    'clientRevision',
  );
  @override
  late final GeneratedColumn<int> clientRevision = GeneratedColumn<int>(
    'client_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audioSha256Meta = const VerificationMeta(
    'audioSha256',
  );
  @override
  late final GeneratedColumn<String> audioSha256 = GeneratedColumn<String>(
    'audio_sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timingPrecisionMeta = const VerificationMeta(
    'timingPrecision',
  );
  @override
  late final GeneratedColumn<String> timingPrecision = GeneratedColumn<String>(
    'timing_precision',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    memoId,
    requestId,
    clientRevision,
    audioSha256,
    state,
    timingPrecision,
    error,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cloud_jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<CloudJobRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('memo_id')) {
      context.handle(
        _memoIdMeta,
        memoId.isAcceptableOrUnknown(data['memo_id']!, _memoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memoIdMeta);
    }
    if (data.containsKey('request_id')) {
      context.handle(
        _requestIdMeta,
        requestId.isAcceptableOrUnknown(data['request_id']!, _requestIdMeta),
      );
    } else if (isInserting) {
      context.missing(_requestIdMeta);
    }
    if (data.containsKey('client_revision')) {
      context.handle(
        _clientRevisionMeta,
        clientRevision.isAcceptableOrUnknown(
          data['client_revision']!,
          _clientRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientRevisionMeta);
    }
    if (data.containsKey('audio_sha256')) {
      context.handle(
        _audioSha256Meta,
        audioSha256.isAcceptableOrUnknown(
          data['audio_sha256']!,
          _audioSha256Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_audioSha256Meta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('timing_precision')) {
      context.handle(
        _timingPrecisionMeta,
        timingPrecision.isAcceptableOrUnknown(
          data['timing_precision']!,
          _timingPrecisionMeta,
        ),
      );
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {memoId};
  @override
  CloudJobRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CloudJobRow(
      memoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo_id'],
      )!,
      requestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_id'],
      )!,
      clientRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}client_revision'],
      )!,
      audioSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_sha256'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      timingPrecision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timing_precision'],
      ),
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CloudJobsTable createAlias(String alias) {
    return $CloudJobsTable(attachedDatabase, alias);
  }
}

class CloudJobRow extends DataClass implements Insertable<CloudJobRow> {
  final String memoId;
  final String requestId;
  final int clientRevision;
  final String audioSha256;

  /// pending → uploading → uploaded → complete | imported_end
  /// (terminal 'cancelled'/'failed' survive so state reads honestly;
  /// code resets them lazily on the next run instead of deleting).
  final String state;
  final String? timingPrecision;
  final String? error;
  final int createdAt;
  final int updatedAt;
  const CloudJobRow({
    required this.memoId,
    required this.requestId,
    required this.clientRevision,
    required this.audioSha256,
    required this.state,
    this.timingPrecision,
    this.error,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['memo_id'] = Variable<String>(memoId);
    map['request_id'] = Variable<String>(requestId);
    map['client_revision'] = Variable<int>(clientRevision);
    map['audio_sha256'] = Variable<String>(audioSha256);
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || timingPrecision != null) {
      map['timing_precision'] = Variable<String>(timingPrecision);
    }
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  CloudJobsCompanion toCompanion(bool nullToAbsent) {
    return CloudJobsCompanion(
      memoId: Value(memoId),
      requestId: Value(requestId),
      clientRevision: Value(clientRevision),
      audioSha256: Value(audioSha256),
      state: Value(state),
      timingPrecision: timingPrecision == null && nullToAbsent
          ? const Value.absent()
          : Value(timingPrecision),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CloudJobRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CloudJobRow(
      memoId: serializer.fromJson<String>(json['memoId']),
      requestId: serializer.fromJson<String>(json['requestId']),
      clientRevision: serializer.fromJson<int>(json['clientRevision']),
      audioSha256: serializer.fromJson<String>(json['audioSha256']),
      state: serializer.fromJson<String>(json['state']),
      timingPrecision: serializer.fromJson<String?>(json['timingPrecision']),
      error: serializer.fromJson<String?>(json['error']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'memoId': serializer.toJson<String>(memoId),
      'requestId': serializer.toJson<String>(requestId),
      'clientRevision': serializer.toJson<int>(clientRevision),
      'audioSha256': serializer.toJson<String>(audioSha256),
      'state': serializer.toJson<String>(state),
      'timingPrecision': serializer.toJson<String?>(timingPrecision),
      'error': serializer.toJson<String?>(error),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  CloudJobRow copyWith({
    String? memoId,
    String? requestId,
    int? clientRevision,
    String? audioSha256,
    String? state,
    Value<String?> timingPrecision = const Value.absent(),
    Value<String?> error = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => CloudJobRow(
    memoId: memoId ?? this.memoId,
    requestId: requestId ?? this.requestId,
    clientRevision: clientRevision ?? this.clientRevision,
    audioSha256: audioSha256 ?? this.audioSha256,
    state: state ?? this.state,
    timingPrecision: timingPrecision.present
        ? timingPrecision.value
        : this.timingPrecision,
    error: error.present ? error.value : this.error,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CloudJobRow copyWithCompanion(CloudJobsCompanion data) {
    return CloudJobRow(
      memoId: data.memoId.present ? data.memoId.value : this.memoId,
      requestId: data.requestId.present ? data.requestId.value : this.requestId,
      clientRevision: data.clientRevision.present
          ? data.clientRevision.value
          : this.clientRevision,
      audioSha256: data.audioSha256.present
          ? data.audioSha256.value
          : this.audioSha256,
      state: data.state.present ? data.state.value : this.state,
      timingPrecision: data.timingPrecision.present
          ? data.timingPrecision.value
          : this.timingPrecision,
      error: data.error.present ? data.error.value : this.error,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CloudJobRow(')
          ..write('memoId: $memoId, ')
          ..write('requestId: $requestId, ')
          ..write('clientRevision: $clientRevision, ')
          ..write('audioSha256: $audioSha256, ')
          ..write('state: $state, ')
          ..write('timingPrecision: $timingPrecision, ')
          ..write('error: $error, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    memoId,
    requestId,
    clientRevision,
    audioSha256,
    state,
    timingPrecision,
    error,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CloudJobRow &&
          other.memoId == this.memoId &&
          other.requestId == this.requestId &&
          other.clientRevision == this.clientRevision &&
          other.audioSha256 == this.audioSha256 &&
          other.state == this.state &&
          other.timingPrecision == this.timingPrecision &&
          other.error == this.error &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CloudJobsCompanion extends UpdateCompanion<CloudJobRow> {
  final Value<String> memoId;
  final Value<String> requestId;
  final Value<int> clientRevision;
  final Value<String> audioSha256;
  final Value<String> state;
  final Value<String?> timingPrecision;
  final Value<String?> error;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const CloudJobsCompanion({
    this.memoId = const Value.absent(),
    this.requestId = const Value.absent(),
    this.clientRevision = const Value.absent(),
    this.audioSha256 = const Value.absent(),
    this.state = const Value.absent(),
    this.timingPrecision = const Value.absent(),
    this.error = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CloudJobsCompanion.insert({
    required String memoId,
    required String requestId,
    required int clientRevision,
    required String audioSha256,
    required String state,
    this.timingPrecision = const Value.absent(),
    this.error = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : memoId = Value(memoId),
       requestId = Value(requestId),
       clientRevision = Value(clientRevision),
       audioSha256 = Value(audioSha256),
       state = Value(state),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CloudJobRow> custom({
    Expression<String>? memoId,
    Expression<String>? requestId,
    Expression<int>? clientRevision,
    Expression<String>? audioSha256,
    Expression<String>? state,
    Expression<String>? timingPrecision,
    Expression<String>? error,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (memoId != null) 'memo_id': memoId,
      if (requestId != null) 'request_id': requestId,
      if (clientRevision != null) 'client_revision': clientRevision,
      if (audioSha256 != null) 'audio_sha256': audioSha256,
      if (state != null) 'state': state,
      if (timingPrecision != null) 'timing_precision': timingPrecision,
      if (error != null) 'error': error,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CloudJobsCompanion copyWith({
    Value<String>? memoId,
    Value<String>? requestId,
    Value<int>? clientRevision,
    Value<String>? audioSha256,
    Value<String>? state,
    Value<String?>? timingPrecision,
    Value<String?>? error,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return CloudJobsCompanion(
      memoId: memoId ?? this.memoId,
      requestId: requestId ?? this.requestId,
      clientRevision: clientRevision ?? this.clientRevision,
      audioSha256: audioSha256 ?? this.audioSha256,
      state: state ?? this.state,
      timingPrecision: timingPrecision ?? this.timingPrecision,
      error: error ?? this.error,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (memoId.present) {
      map['memo_id'] = Variable<String>(memoId.value);
    }
    if (requestId.present) {
      map['request_id'] = Variable<String>(requestId.value);
    }
    if (clientRevision.present) {
      map['client_revision'] = Variable<int>(clientRevision.value);
    }
    if (audioSha256.present) {
      map['audio_sha256'] = Variable<String>(audioSha256.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (timingPrecision.present) {
      map['timing_precision'] = Variable<String>(timingPrecision.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CloudJobsCompanion(')
          ..write('memoId: $memoId, ')
          ..write('requestId: $requestId, ')
          ..write('clientRevision: $clientRevision, ')
          ..write('audioSha256: $audioSha256, ')
          ..write('state: $state, ')
          ..write('timingPrecision: $timingPrecision, ')
          ..write('error: $error, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsEntriesTable extends SettingsEntries
    with TableInfo<$SettingsEntriesTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsEntriesTable createAlias(String alias) {
    return $SettingsEntriesTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsEntriesCompanion toCompanion(bool nullToAbsent) {
    return SettingsEntriesCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingsEntriesCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsEntriesCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsEntriesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CassettesTable cassettes = $CassettesTable(this);
  late final $MemosTable memos = $MemosTable(this);
  late final $JobsTable jobs = $JobsTable(this);
  late final $CloudJobsTable cloudJobs = $CloudJobsTable(this);
  late final $SettingsEntriesTable settingsEntries = $SettingsEntriesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cassettes,
    memos,
    jobs,
    cloudJobs,
    settingsEntries,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cassettes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('memos', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'memos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cloud_jobs', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CassettesTableCreateCompanionBuilder =
    CassettesCompanion Function({
      required String id,
      Value<String?> label,
      Value<bool> titleIsUserSet,
      required int colorSeed,
      Value<String?> summary,
      Value<int?> summaryUpdatedAt,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$CassettesTableUpdateCompanionBuilder =
    CassettesCompanion Function({
      Value<String> id,
      Value<String?> label,
      Value<bool> titleIsUserSet,
      Value<int> colorSeed,
      Value<String?> summary,
      Value<int?> summaryUpdatedAt,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$CassettesTableReferences
    extends BaseReferences<_$AppDatabase, $CassettesTable, CassetteRow> {
  $$CassettesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MemosTable, List<MemoRow>> _memosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.memos,
    aliasName: 'cassettes__id__memos__cassette_id',
  );

  $$MemosTableProcessedTableManager get memosRefs {
    final manager = $$MemosTableTableManager(
      $_db,
      $_db.memos,
    ).filter((f) => f.cassetteId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_memosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CassettesTableFilterComposer
    extends Composer<_$AppDatabase, $CassettesTable> {
  $$CassettesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get titleIsUserSet => $composableBuilder(
    column: $table.titleIsUserSet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorSeed => $composableBuilder(
    column: $table.colorSeed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get summaryUpdatedAt => $composableBuilder(
    column: $table.summaryUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> memosRefs(
    Expression<bool> Function($$MemosTableFilterComposer f) f,
  ) {
    final $$MemosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memos,
      getReferencedColumn: (t) => t.cassetteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemosTableFilterComposer(
            $db: $db,
            $table: $db.memos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CassettesTableOrderingComposer
    extends Composer<_$AppDatabase, $CassettesTable> {
  $$CassettesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get titleIsUserSet => $composableBuilder(
    column: $table.titleIsUserSet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorSeed => $composableBuilder(
    column: $table.colorSeed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get summaryUpdatedAt => $composableBuilder(
    column: $table.summaryUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CassettesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CassettesTable> {
  $$CassettesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<bool> get titleIsUserSet => $composableBuilder(
    column: $table.titleIsUserSet,
    builder: (column) => column,
  );

  GeneratedColumn<int> get colorSeed =>
      $composableBuilder(column: $table.colorSeed, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<int> get summaryUpdatedAt => $composableBuilder(
    column: $table.summaryUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> memosRefs<T extends Object>(
    Expression<T> Function($$MemosTableAnnotationComposer a) f,
  ) {
    final $$MemosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memos,
      getReferencedColumn: (t) => t.cassetteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemosTableAnnotationComposer(
            $db: $db,
            $table: $db.memos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CassettesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CassettesTable,
          CassetteRow,
          $$CassettesTableFilterComposer,
          $$CassettesTableOrderingComposer,
          $$CassettesTableAnnotationComposer,
          $$CassettesTableCreateCompanionBuilder,
          $$CassettesTableUpdateCompanionBuilder,
          (CassetteRow, $$CassettesTableReferences),
          CassetteRow,
          PrefetchHooks Function({bool memosRefs})
        > {
  $$CassettesTableTableManager(_$AppDatabase db, $CassettesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CassettesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CassettesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CassettesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<bool> titleIsUserSet = const Value.absent(),
                Value<int> colorSeed = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<int?> summaryUpdatedAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CassettesCompanion(
                id: id,
                label: label,
                titleIsUserSet: titleIsUserSet,
                colorSeed: colorSeed,
                summary: summary,
                summaryUpdatedAt: summaryUpdatedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> label = const Value.absent(),
                Value<bool> titleIsUserSet = const Value.absent(),
                required int colorSeed,
                Value<String?> summary = const Value.absent(),
                Value<int?> summaryUpdatedAt = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CassettesCompanion.insert(
                id: id,
                label: label,
                titleIsUserSet: titleIsUserSet,
                colorSeed: colorSeed,
                summary: summary,
                summaryUpdatedAt: summaryUpdatedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CassettesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({memosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (memosRefs) db.memos],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (memosRefs)
                    await $_getPrefetchedData<
                      CassetteRow,
                      $CassettesTable,
                      MemoRow
                    >(
                      currentTable: table,
                      referencedTable: $$CassettesTableReferences
                          ._memosRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CassettesTableReferences(db, table, p0).memosRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.cassetteId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CassettesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CassettesTable,
      CassetteRow,
      $$CassettesTableFilterComposer,
      $$CassettesTableOrderingComposer,
      $$CassettesTableAnnotationComposer,
      $$CassettesTableCreateCompanionBuilder,
      $$CassettesTableUpdateCompanionBuilder,
      (CassetteRow, $$CassettesTableReferences),
      CassetteRow,
      PrefetchHooks Function({bool memosRefs})
    >;
typedef $$MemosTableCreateCompanionBuilder =
    MemosCompanion Function({
      required String id,
      required String cassetteId,
      required String filePath,
      required int durationMs,
      required int createdAt,
      Value<String?> detectedLang,
      Value<String?> transcript,
      Value<String?> rawTranscript,
      Value<String?> memoSummary,
      Value<int?> foldedAt,
      required String status,
      Value<String?> uploadStatus,
      Value<int?> uploadedAt,
      Value<int?> cloudConsentAt,
      Value<int> rowid,
    });
typedef $$MemosTableUpdateCompanionBuilder =
    MemosCompanion Function({
      Value<String> id,
      Value<String> cassetteId,
      Value<String> filePath,
      Value<int> durationMs,
      Value<int> createdAt,
      Value<String?> detectedLang,
      Value<String?> transcript,
      Value<String?> rawTranscript,
      Value<String?> memoSummary,
      Value<int?> foldedAt,
      Value<String> status,
      Value<String?> uploadStatus,
      Value<int?> uploadedAt,
      Value<int?> cloudConsentAt,
      Value<int> rowid,
    });

final class $$MemosTableReferences
    extends BaseReferences<_$AppDatabase, $MemosTable, MemoRow> {
  $$MemosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CassettesTable _cassetteIdTable(_$AppDatabase db) =>
      db.cassettes.createAlias('memos__cassette_id__cassettes__id');

  $$CassettesTableProcessedTableManager get cassetteId {
    final $_column = $_itemColumn<String>('cassette_id')!;

    final manager = $$CassettesTableTableManager(
      $_db,
      $_db.cassettes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cassetteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CloudJobsTable, List<CloudJobRow>>
  _cloudJobsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cloudJobs,
    aliasName: 'memos__id__cloud_jobs__memo_id',
  );

  $$CloudJobsTableProcessedTableManager get cloudJobsRefs {
    final manager = $$CloudJobsTableTableManager(
      $_db,
      $_db.cloudJobs,
    ).filter((f) => f.memoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cloudJobsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MemosTableFilterComposer extends Composer<_$AppDatabase, $MemosTable> {
  $$MemosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detectedLang => $composableBuilder(
    column: $table.detectedLang,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawTranscript => $composableBuilder(
    column: $table.rawTranscript,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memoSummary => $composableBuilder(
    column: $table.memoSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get foldedAt => $composableBuilder(
    column: $table.foldedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uploadStatus => $composableBuilder(
    column: $table.uploadStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get uploadedAt => $composableBuilder(
    column: $table.uploadedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cloudConsentAt => $composableBuilder(
    column: $table.cloudConsentAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CassettesTableFilterComposer get cassetteId {
    final $$CassettesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cassetteId,
      referencedTable: $db.cassettes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CassettesTableFilterComposer(
            $db: $db,
            $table: $db.cassettes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> cloudJobsRefs(
    Expression<bool> Function($$CloudJobsTableFilterComposer f) f,
  ) {
    final $$CloudJobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cloudJobs,
      getReferencedColumn: (t) => t.memoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CloudJobsTableFilterComposer(
            $db: $db,
            $table: $db.cloudJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MemosTableOrderingComposer
    extends Composer<_$AppDatabase, $MemosTable> {
  $$MemosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detectedLang => $composableBuilder(
    column: $table.detectedLang,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawTranscript => $composableBuilder(
    column: $table.rawTranscript,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memoSummary => $composableBuilder(
    column: $table.memoSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get foldedAt => $composableBuilder(
    column: $table.foldedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uploadStatus => $composableBuilder(
    column: $table.uploadStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get uploadedAt => $composableBuilder(
    column: $table.uploadedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cloudConsentAt => $composableBuilder(
    column: $table.cloudConsentAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CassettesTableOrderingComposer get cassetteId {
    final $$CassettesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cassetteId,
      referencedTable: $db.cassettes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CassettesTableOrderingComposer(
            $db: $db,
            $table: $db.cassettes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemosTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemosTable> {
  $$MemosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get detectedLang => $composableBuilder(
    column: $table.detectedLang,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawTranscript => $composableBuilder(
    column: $table.rawTranscript,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memoSummary => $composableBuilder(
    column: $table.memoSummary,
    builder: (column) => column,
  );

  GeneratedColumn<int> get foldedAt =>
      $composableBuilder(column: $table.foldedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get uploadStatus => $composableBuilder(
    column: $table.uploadStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get uploadedAt => $composableBuilder(
    column: $table.uploadedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cloudConsentAt => $composableBuilder(
    column: $table.cloudConsentAt,
    builder: (column) => column,
  );

  $$CassettesTableAnnotationComposer get cassetteId {
    final $$CassettesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cassetteId,
      referencedTable: $db.cassettes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CassettesTableAnnotationComposer(
            $db: $db,
            $table: $db.cassettes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> cloudJobsRefs<T extends Object>(
    Expression<T> Function($$CloudJobsTableAnnotationComposer a) f,
  ) {
    final $$CloudJobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cloudJobs,
      getReferencedColumn: (t) => t.memoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CloudJobsTableAnnotationComposer(
            $db: $db,
            $table: $db.cloudJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MemosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MemosTable,
          MemoRow,
          $$MemosTableFilterComposer,
          $$MemosTableOrderingComposer,
          $$MemosTableAnnotationComposer,
          $$MemosTableCreateCompanionBuilder,
          $$MemosTableUpdateCompanionBuilder,
          (MemoRow, $$MemosTableReferences),
          MemoRow,
          PrefetchHooks Function({bool cassetteId, bool cloudJobsRefs})
        > {
  $$MemosTableTableManager(_$AppDatabase db, $MemosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cassetteId = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String?> detectedLang = const Value.absent(),
                Value<String?> transcript = const Value.absent(),
                Value<String?> rawTranscript = const Value.absent(),
                Value<String?> memoSummary = const Value.absent(),
                Value<int?> foldedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> uploadStatus = const Value.absent(),
                Value<int?> uploadedAt = const Value.absent(),
                Value<int?> cloudConsentAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemosCompanion(
                id: id,
                cassetteId: cassetteId,
                filePath: filePath,
                durationMs: durationMs,
                createdAt: createdAt,
                detectedLang: detectedLang,
                transcript: transcript,
                rawTranscript: rawTranscript,
                memoSummary: memoSummary,
                foldedAt: foldedAt,
                status: status,
                uploadStatus: uploadStatus,
                uploadedAt: uploadedAt,
                cloudConsentAt: cloudConsentAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cassetteId,
                required String filePath,
                required int durationMs,
                required int createdAt,
                Value<String?> detectedLang = const Value.absent(),
                Value<String?> transcript = const Value.absent(),
                Value<String?> rawTranscript = const Value.absent(),
                Value<String?> memoSummary = const Value.absent(),
                Value<int?> foldedAt = const Value.absent(),
                required String status,
                Value<String?> uploadStatus = const Value.absent(),
                Value<int?> uploadedAt = const Value.absent(),
                Value<int?> cloudConsentAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemosCompanion.insert(
                id: id,
                cassetteId: cassetteId,
                filePath: filePath,
                durationMs: durationMs,
                createdAt: createdAt,
                detectedLang: detectedLang,
                transcript: transcript,
                rawTranscript: rawTranscript,
                memoSummary: memoSummary,
                foldedAt: foldedAt,
                status: status,
                uploadStatus: uploadStatus,
                uploadedAt: uploadedAt,
                cloudConsentAt: cloudConsentAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$MemosTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({cassetteId = false, cloudJobsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (cloudJobsRefs) db.cloudJobs],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cassetteId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.cassetteId,
                                referencedTable: $$MemosTableReferences
                                    ._cassetteIdTable(db),
                                referencedColumn: $$MemosTableReferences
                                    ._cassetteIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cloudJobsRefs)
                    await $_getPrefetchedData<
                      MemoRow,
                      $MemosTable,
                      CloudJobRow
                    >(
                      currentTable: table,
                      referencedTable: $$MemosTableReferences
                          ._cloudJobsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MemosTableReferences(db, table, p0).cloudJobsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.memoId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MemosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MemosTable,
      MemoRow,
      $$MemosTableFilterComposer,
      $$MemosTableOrderingComposer,
      $$MemosTableAnnotationComposer,
      $$MemosTableCreateCompanionBuilder,
      $$MemosTableUpdateCompanionBuilder,
      (MemoRow, $$MemosTableReferences),
      MemoRow,
      PrefetchHooks Function({bool cassetteId, bool cloudJobsRefs})
    >;
typedef $$JobsTableCreateCompanionBuilder =
    JobsCompanion Function({
      required String id,
      required String type,
      required String targetId,
      required String status,
      Value<int> attempts,
      required int createdAt,
      Value<int> availableAt,
      Value<String?> ownerId,
      Value<int> leaseUntil,
      Value<int> rowid,
    });
typedef $$JobsTableUpdateCompanionBuilder =
    JobsCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<String> targetId,
      Value<String> status,
      Value<int> attempts,
      Value<int> createdAt,
      Value<int> availableAt,
      Value<String?> ownerId,
      Value<int> leaseUntil,
      Value<int> rowid,
    });

class $$JobsTableFilterComposer extends Composer<_$AppDatabase, $JobsTable> {
  $$JobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get availableAt => $composableBuilder(
    column: $table.availableAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get leaseUntil => $composableBuilder(
    column: $table.leaseUntil,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JobsTableOrderingComposer extends Composer<_$AppDatabase, $JobsTable> {
  $$JobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get availableAt => $composableBuilder(
    column: $table.availableAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get leaseUntil => $composableBuilder(
    column: $table.leaseUntil,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $JobsTable> {
  $$JobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get availableAt => $composableBuilder(
    column: $table.availableAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<int> get leaseUntil => $composableBuilder(
    column: $table.leaseUntil,
    builder: (column) => column,
  );
}

class $$JobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JobsTable,
          JobRow,
          $$JobsTableFilterComposer,
          $$JobsTableOrderingComposer,
          $$JobsTableAnnotationComposer,
          $$JobsTableCreateCompanionBuilder,
          $$JobsTableUpdateCompanionBuilder,
          (JobRow, BaseReferences<_$AppDatabase, $JobsTable, JobRow>),
          JobRow,
          PrefetchHooks Function()
        > {
  $$JobsTableTableManager(_$AppDatabase db, $JobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> targetId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> availableAt = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<int> leaseUntil = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobsCompanion(
                id: id,
                type: type,
                targetId: targetId,
                status: status,
                attempts: attempts,
                createdAt: createdAt,
                availableAt: availableAt,
                ownerId: ownerId,
                leaseUntil: leaseUntil,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required String targetId,
                required String status,
                Value<int> attempts = const Value.absent(),
                required int createdAt,
                Value<int> availableAt = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<int> leaseUntil = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobsCompanion.insert(
                id: id,
                type: type,
                targetId: targetId,
                status: status,
                attempts: attempts,
                createdAt: createdAt,
                availableAt: availableAt,
                ownerId: ownerId,
                leaseUntil: leaseUntil,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JobsTable,
      JobRow,
      $$JobsTableFilterComposer,
      $$JobsTableOrderingComposer,
      $$JobsTableAnnotationComposer,
      $$JobsTableCreateCompanionBuilder,
      $$JobsTableUpdateCompanionBuilder,
      (JobRow, BaseReferences<_$AppDatabase, $JobsTable, JobRow>),
      JobRow,
      PrefetchHooks Function()
    >;
typedef $$CloudJobsTableCreateCompanionBuilder =
    CloudJobsCompanion Function({
      required String memoId,
      required String requestId,
      required int clientRevision,
      required String audioSha256,
      required String state,
      Value<String?> timingPrecision,
      Value<String?> error,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$CloudJobsTableUpdateCompanionBuilder =
    CloudJobsCompanion Function({
      Value<String> memoId,
      Value<String> requestId,
      Value<int> clientRevision,
      Value<String> audioSha256,
      Value<String> state,
      Value<String?> timingPrecision,
      Value<String?> error,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $$CloudJobsTableReferences
    extends BaseReferences<_$AppDatabase, $CloudJobsTable, CloudJobRow> {
  $$CloudJobsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MemosTable _memoIdTable(_$AppDatabase db) =>
      db.memos.createAlias('cloud_jobs__memo_id__memos__id');

  $$MemosTableProcessedTableManager get memoId {
    final $_column = $_itemColumn<String>('memo_id')!;

    final manager = $$MemosTableTableManager(
      $_db,
      $_db.memos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_memoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CloudJobsTableFilterComposer
    extends Composer<_$AppDatabase, $CloudJobsTable> {
  $$CloudJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clientRevision => $composableBuilder(
    column: $table.clientRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioSha256 => $composableBuilder(
    column: $table.audioSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timingPrecision => $composableBuilder(
    column: $table.timingPrecision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MemosTableFilterComposer get memoId {
    final $$MemosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memoId,
      referencedTable: $db.memos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemosTableFilterComposer(
            $db: $db,
            $table: $db.memos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CloudJobsTableOrderingComposer
    extends Composer<_$AppDatabase, $CloudJobsTable> {
  $$CloudJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clientRevision => $composableBuilder(
    column: $table.clientRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioSha256 => $composableBuilder(
    column: $table.audioSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timingPrecision => $composableBuilder(
    column: $table.timingPrecision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MemosTableOrderingComposer get memoId {
    final $$MemosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memoId,
      referencedTable: $db.memos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemosTableOrderingComposer(
            $db: $db,
            $table: $db.memos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CloudJobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CloudJobsTable> {
  $$CloudJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get requestId =>
      $composableBuilder(column: $table.requestId, builder: (column) => column);

  GeneratedColumn<int> get clientRevision => $composableBuilder(
    column: $table.clientRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audioSha256 => $composableBuilder(
    column: $table.audioSha256,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get timingPrecision => $composableBuilder(
    column: $table.timingPrecision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$MemosTableAnnotationComposer get memoId {
    final $$MemosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.memoId,
      referencedTable: $db.memos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemosTableAnnotationComposer(
            $db: $db,
            $table: $db.memos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CloudJobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CloudJobsTable,
          CloudJobRow,
          $$CloudJobsTableFilterComposer,
          $$CloudJobsTableOrderingComposer,
          $$CloudJobsTableAnnotationComposer,
          $$CloudJobsTableCreateCompanionBuilder,
          $$CloudJobsTableUpdateCompanionBuilder,
          (CloudJobRow, $$CloudJobsTableReferences),
          CloudJobRow,
          PrefetchHooks Function({bool memoId})
        > {
  $$CloudJobsTableTableManager(_$AppDatabase db, $CloudJobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CloudJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CloudJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CloudJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> memoId = const Value.absent(),
                Value<String> requestId = const Value.absent(),
                Value<int> clientRevision = const Value.absent(),
                Value<String> audioSha256 = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String?> timingPrecision = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CloudJobsCompanion(
                memoId: memoId,
                requestId: requestId,
                clientRevision: clientRevision,
                audioSha256: audioSha256,
                state: state,
                timingPrecision: timingPrecision,
                error: error,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String memoId,
                required String requestId,
                required int clientRevision,
                required String audioSha256,
                required String state,
                Value<String?> timingPrecision = const Value.absent(),
                Value<String?> error = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CloudJobsCompanion.insert(
                memoId: memoId,
                requestId: requestId,
                clientRevision: clientRevision,
                audioSha256: audioSha256,
                state: state,
                timingPrecision: timingPrecision,
                error: error,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CloudJobsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({memoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (memoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.memoId,
                                referencedTable: $$CloudJobsTableReferences
                                    ._memoIdTable(db),
                                referencedColumn: $$CloudJobsTableReferences
                                    ._memoIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CloudJobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CloudJobsTable,
      CloudJobRow,
      $$CloudJobsTableFilterComposer,
      $$CloudJobsTableOrderingComposer,
      $$CloudJobsTableAnnotationComposer,
      $$CloudJobsTableCreateCompanionBuilder,
      $$CloudJobsTableUpdateCompanionBuilder,
      (CloudJobRow, $$CloudJobsTableReferences),
      CloudJobRow,
      PrefetchHooks Function({bool memoId})
    >;
typedef $$SettingsEntriesTableCreateCompanionBuilder =
    SettingsEntriesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsEntriesTableUpdateCompanionBuilder =
    SettingsEntriesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsEntriesTable> {
  $$SettingsEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsEntriesTable> {
  $$SettingsEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsEntriesTable> {
  $$SettingsEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsEntriesTable,
          SettingRow,
          $$SettingsEntriesTableFilterComposer,
          $$SettingsEntriesTableOrderingComposer,
          $$SettingsEntriesTableAnnotationComposer,
          $$SettingsEntriesTableCreateCompanionBuilder,
          $$SettingsEntriesTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $SettingsEntriesTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsEntriesTableTableManager(
    _$AppDatabase db,
    $SettingsEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsEntriesCompanion(
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsEntriesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsEntriesTable,
      SettingRow,
      $$SettingsEntriesTableFilterComposer,
      $$SettingsEntriesTableOrderingComposer,
      $$SettingsEntriesTableAnnotationComposer,
      $$SettingsEntriesTableCreateCompanionBuilder,
      $$SettingsEntriesTableUpdateCompanionBuilder,
      (
        SettingRow,
        BaseReferences<_$AppDatabase, $SettingsEntriesTable, SettingRow>,
      ),
      SettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CassettesTableTableManager get cassettes =>
      $$CassettesTableTableManager(_db, _db.cassettes);
  $$MemosTableTableManager get memos =>
      $$MemosTableTableManager(_db, _db.memos);
  $$JobsTableTableManager get jobs => $$JobsTableTableManager(_db, _db.jobs);
  $$CloudJobsTableTableManager get cloudJobs =>
      $$CloudJobsTableTableManager(_db, _db.cloudJobs);
  $$SettingsEntriesTableTableManager get settingsEntries =>
      $$SettingsEntriesTableTableManager(_db, _db.settingsEntries);
}
