// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DialogueNodesTable extends DialogueNodes
    with TableInfo<$DialogueNodesTable, DialogueNodeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DialogueNodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _characterNameMeta =
      const VerificationMeta('characterName');
  @override
  late final GeneratedColumn<String> characterName = GeneratedColumn<String>(
      'character_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lineHebrewVocalizedMeta =
      const VerificationMeta('lineHebrewVocalized');
  @override
  late final GeneratedColumn<String> lineHebrewVocalized =
      GeneratedColumn<String>('line_hebrew_vocalized', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lineHebrewNormalizedMeta =
      const VerificationMeta('lineHebrewNormalized');
  @override
  late final GeneratedColumn<String> lineHebrewNormalized =
      GeneratedColumn<String>('line_hebrew_normalized', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lineRussianMeta =
      const VerificationMeta('lineRussian');
  @override
  late final GeneratedColumn<String> lineRussian = GeneratedColumn<String>(
      'line_russian', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _audioPathMeta =
      const VerificationMeta('audioPath');
  @override
  late final GeneratedColumn<String> audioPath = GeneratedColumn<String>(
      'audio_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _optionsJsonMeta =
      const VerificationMeta('optionsJson');
  @override
  late final GeneratedColumn<String> optionsJson = GeneratedColumn<String>(
      'options_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        characterName,
        lineHebrewVocalized,
        lineHebrewNormalized,
        lineRussian,
        audioPath,
        optionsJson,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dialogue_nodes';
  @override
  VerificationContext validateIntegrity(Insertable<DialogueNodeRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('character_name')) {
      context.handle(
          _characterNameMeta,
          characterName.isAcceptableOrUnknown(
              data['character_name']!, _characterNameMeta));
    } else if (isInserting) {
      context.missing(_characterNameMeta);
    }
    if (data.containsKey('line_hebrew_vocalized')) {
      context.handle(
          _lineHebrewVocalizedMeta,
          lineHebrewVocalized.isAcceptableOrUnknown(
              data['line_hebrew_vocalized']!, _lineHebrewVocalizedMeta));
    } else if (isInserting) {
      context.missing(_lineHebrewVocalizedMeta);
    }
    if (data.containsKey('line_hebrew_normalized')) {
      context.handle(
          _lineHebrewNormalizedMeta,
          lineHebrewNormalized.isAcceptableOrUnknown(
              data['line_hebrew_normalized']!, _lineHebrewNormalizedMeta));
    } else if (isInserting) {
      context.missing(_lineHebrewNormalizedMeta);
    }
    if (data.containsKey('line_russian')) {
      context.handle(
          _lineRussianMeta,
          lineRussian.isAcceptableOrUnknown(
              data['line_russian']!, _lineRussianMeta));
    } else if (isInserting) {
      context.missing(_lineRussianMeta);
    }
    if (data.containsKey('audio_path')) {
      context.handle(_audioPathMeta,
          audioPath.isAcceptableOrUnknown(data['audio_path']!, _audioPathMeta));
    }
    if (data.containsKey('options_json')) {
      context.handle(
          _optionsJsonMeta,
          optionsJson.isAcceptableOrUnknown(
              data['options_json']!, _optionsJsonMeta));
    } else if (isInserting) {
      context.missing(_optionsJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DialogueNodeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DialogueNodeRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      characterName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}character_name'])!,
      lineHebrewVocalized: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}line_hebrew_vocalized'])!,
      lineHebrewNormalized: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}line_hebrew_normalized'])!,
      lineRussian: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}line_russian'])!,
      audioPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}audio_path']),
      optionsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}options_json'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DialogueNodesTable createAlias(String alias) {
    return $DialogueNodesTable(attachedDatabase, alias);
  }
}

class DialogueNodeRow extends DataClass implements Insertable<DialogueNodeRow> {
  final String id;
  final String characterName;
  final String lineHebrewVocalized;
  final String lineHebrewNormalized;
  final String lineRussian;
  final String? audioPath;
  final String optionsJson;
  final DateTime updatedAt;
  const DialogueNodeRow(
      {required this.id,
      required this.characterName,
      required this.lineHebrewVocalized,
      required this.lineHebrewNormalized,
      required this.lineRussian,
      this.audioPath,
      required this.optionsJson,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['character_name'] = Variable<String>(characterName);
    map['line_hebrew_vocalized'] = Variable<String>(lineHebrewVocalized);
    map['line_hebrew_normalized'] = Variable<String>(lineHebrewNormalized);
    map['line_russian'] = Variable<String>(lineRussian);
    if (!nullToAbsent || audioPath != null) {
      map['audio_path'] = Variable<String>(audioPath);
    }
    map['options_json'] = Variable<String>(optionsJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DialogueNodesCompanion toCompanion(bool nullToAbsent) {
    return DialogueNodesCompanion(
      id: Value(id),
      characterName: Value(characterName),
      lineHebrewVocalized: Value(lineHebrewVocalized),
      lineHebrewNormalized: Value(lineHebrewNormalized),
      lineRussian: Value(lineRussian),
      audioPath: audioPath == null && nullToAbsent
          ? const Value.absent()
          : Value(audioPath),
      optionsJson: Value(optionsJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory DialogueNodeRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DialogueNodeRow(
      id: serializer.fromJson<String>(json['id']),
      characterName: serializer.fromJson<String>(json['characterName']),
      lineHebrewVocalized:
          serializer.fromJson<String>(json['lineHebrewVocalized']),
      lineHebrewNormalized:
          serializer.fromJson<String>(json['lineHebrewNormalized']),
      lineRussian: serializer.fromJson<String>(json['lineRussian']),
      audioPath: serializer.fromJson<String?>(json['audioPath']),
      optionsJson: serializer.fromJson<String>(json['optionsJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'characterName': serializer.toJson<String>(characterName),
      'lineHebrewVocalized': serializer.toJson<String>(lineHebrewVocalized),
      'lineHebrewNormalized': serializer.toJson<String>(lineHebrewNormalized),
      'lineRussian': serializer.toJson<String>(lineRussian),
      'audioPath': serializer.toJson<String?>(audioPath),
      'optionsJson': serializer.toJson<String>(optionsJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DialogueNodeRow copyWith(
          {String? id,
          String? characterName,
          String? lineHebrewVocalized,
          String? lineHebrewNormalized,
          String? lineRussian,
          Value<String?> audioPath = const Value.absent(),
          String? optionsJson,
          DateTime? updatedAt}) =>
      DialogueNodeRow(
        id: id ?? this.id,
        characterName: characterName ?? this.characterName,
        lineHebrewVocalized: lineHebrewVocalized ?? this.lineHebrewVocalized,
        lineHebrewNormalized: lineHebrewNormalized ?? this.lineHebrewNormalized,
        lineRussian: lineRussian ?? this.lineRussian,
        audioPath: audioPath.present ? audioPath.value : this.audioPath,
        optionsJson: optionsJson ?? this.optionsJson,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DialogueNodeRow copyWithCompanion(DialogueNodesCompanion data) {
    return DialogueNodeRow(
      id: data.id.present ? data.id.value : this.id,
      characterName: data.characterName.present
          ? data.characterName.value
          : this.characterName,
      lineHebrewVocalized: data.lineHebrewVocalized.present
          ? data.lineHebrewVocalized.value
          : this.lineHebrewVocalized,
      lineHebrewNormalized: data.lineHebrewNormalized.present
          ? data.lineHebrewNormalized.value
          : this.lineHebrewNormalized,
      lineRussian:
          data.lineRussian.present ? data.lineRussian.value : this.lineRussian,
      audioPath: data.audioPath.present ? data.audioPath.value : this.audioPath,
      optionsJson:
          data.optionsJson.present ? data.optionsJson.value : this.optionsJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DialogueNodeRow(')
          ..write('id: $id, ')
          ..write('characterName: $characterName, ')
          ..write('lineHebrewVocalized: $lineHebrewVocalized, ')
          ..write('lineHebrewNormalized: $lineHebrewNormalized, ')
          ..write('lineRussian: $lineRussian, ')
          ..write('audioPath: $audioPath, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, characterName, lineHebrewVocalized,
      lineHebrewNormalized, lineRussian, audioPath, optionsJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DialogueNodeRow &&
          other.id == this.id &&
          other.characterName == this.characterName &&
          other.lineHebrewVocalized == this.lineHebrewVocalized &&
          other.lineHebrewNormalized == this.lineHebrewNormalized &&
          other.lineRussian == this.lineRussian &&
          other.audioPath == this.audioPath &&
          other.optionsJson == this.optionsJson &&
          other.updatedAt == this.updatedAt);
}

class DialogueNodesCompanion extends UpdateCompanion<DialogueNodeRow> {
  final Value<String> id;
  final Value<String> characterName;
  final Value<String> lineHebrewVocalized;
  final Value<String> lineHebrewNormalized;
  final Value<String> lineRussian;
  final Value<String?> audioPath;
  final Value<String> optionsJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DialogueNodesCompanion({
    this.id = const Value.absent(),
    this.characterName = const Value.absent(),
    this.lineHebrewVocalized = const Value.absent(),
    this.lineHebrewNormalized = const Value.absent(),
    this.lineRussian = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.optionsJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DialogueNodesCompanion.insert({
    required String id,
    required String characterName,
    required String lineHebrewVocalized,
    required String lineHebrewNormalized,
    required String lineRussian,
    this.audioPath = const Value.absent(),
    required String optionsJson,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        characterName = Value(characterName),
        lineHebrewVocalized = Value(lineHebrewVocalized),
        lineHebrewNormalized = Value(lineHebrewNormalized),
        lineRussian = Value(lineRussian),
        optionsJson = Value(optionsJson),
        updatedAt = Value(updatedAt);
  static Insertable<DialogueNodeRow> custom({
    Expression<String>? id,
    Expression<String>? characterName,
    Expression<String>? lineHebrewVocalized,
    Expression<String>? lineHebrewNormalized,
    Expression<String>? lineRussian,
    Expression<String>? audioPath,
    Expression<String>? optionsJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (characterName != null) 'character_name': characterName,
      if (lineHebrewVocalized != null)
        'line_hebrew_vocalized': lineHebrewVocalized,
      if (lineHebrewNormalized != null)
        'line_hebrew_normalized': lineHebrewNormalized,
      if (lineRussian != null) 'line_russian': lineRussian,
      if (audioPath != null) 'audio_path': audioPath,
      if (optionsJson != null) 'options_json': optionsJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DialogueNodesCompanion copyWith(
      {Value<String>? id,
      Value<String>? characterName,
      Value<String>? lineHebrewVocalized,
      Value<String>? lineHebrewNormalized,
      Value<String>? lineRussian,
      Value<String?>? audioPath,
      Value<String>? optionsJson,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return DialogueNodesCompanion(
      id: id ?? this.id,
      characterName: characterName ?? this.characterName,
      lineHebrewVocalized: lineHebrewVocalized ?? this.lineHebrewVocalized,
      lineHebrewNormalized: lineHebrewNormalized ?? this.lineHebrewNormalized,
      lineRussian: lineRussian ?? this.lineRussian,
      audioPath: audioPath ?? this.audioPath,
      optionsJson: optionsJson ?? this.optionsJson,
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
    if (characterName.present) {
      map['character_name'] = Variable<String>(characterName.value);
    }
    if (lineHebrewVocalized.present) {
      map['line_hebrew_vocalized'] =
          Variable<String>(lineHebrewVocalized.value);
    }
    if (lineHebrewNormalized.present) {
      map['line_hebrew_normalized'] =
          Variable<String>(lineHebrewNormalized.value);
    }
    if (lineRussian.present) {
      map['line_russian'] = Variable<String>(lineRussian.value);
    }
    if (audioPath.present) {
      map['audio_path'] = Variable<String>(audioPath.value);
    }
    if (optionsJson.present) {
      map['options_json'] = Variable<String>(optionsJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DialogueNodesCompanion(')
          ..write('id: $id, ')
          ..write('characterName: $characterName, ')
          ..write('lineHebrewVocalized: $lineHebrewVocalized, ')
          ..write('lineHebrewNormalized: $lineHebrewNormalized, ')
          ..write('lineRussian: $lineRussian, ')
          ..write('audioPath: $audioPath, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DialogueHistoryEntriesTable extends DialogueHistoryEntries
    with TableInfo<$DialogueHistoryEntriesTable, DialogueHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DialogueHistoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nodeIdMeta = const VerificationMeta('nodeId');
  @override
  late final GeneratedColumn<String> nodeId = GeneratedColumn<String>(
      'node_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _selectedOptionIdMeta =
      const VerificationMeta('selectedOptionId');
  @override
  late final GeneratedColumn<String> selectedOptionId = GeneratedColumn<String>(
      'selected_option_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _answeredAtMeta =
      const VerificationMeta('answeredAt');
  @override
  late final GeneratedColumn<DateTime> answeredAt = GeneratedColumn<DateTime>(
      'answered_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, nodeId, selectedOptionId, answeredAt, synced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dialogue_history_entries';
  @override
  VerificationContext validateIntegrity(Insertable<DialogueHistoryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('node_id')) {
      context.handle(_nodeIdMeta,
          nodeId.isAcceptableOrUnknown(data['node_id']!, _nodeIdMeta));
    } else if (isInserting) {
      context.missing(_nodeIdMeta);
    }
    if (data.containsKey('selected_option_id')) {
      context.handle(
          _selectedOptionIdMeta,
          selectedOptionId.isAcceptableOrUnknown(
              data['selected_option_id']!, _selectedOptionIdMeta));
    } else if (isInserting) {
      context.missing(_selectedOptionIdMeta);
    }
    if (data.containsKey('answered_at')) {
      context.handle(
          _answeredAtMeta,
          answeredAt.isAcceptableOrUnknown(
              data['answered_at']!, _answeredAtMeta));
    } else if (isInserting) {
      context.missing(_answeredAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DialogueHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DialogueHistoryRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nodeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}node_id'])!,
      selectedOptionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}selected_option_id'])!,
      answeredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}answered_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $DialogueHistoryEntriesTable createAlias(String alias) {
    return $DialogueHistoryEntriesTable(attachedDatabase, alias);
  }
}

class DialogueHistoryRow extends DataClass
    implements Insertable<DialogueHistoryRow> {
  final int id;
  final String nodeId;
  final String selectedOptionId;
  final DateTime answeredAt;
  final bool synced;
  const DialogueHistoryRow(
      {required this.id,
      required this.nodeId,
      required this.selectedOptionId,
      required this.answeredAt,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['node_id'] = Variable<String>(nodeId);
    map['selected_option_id'] = Variable<String>(selectedOptionId);
    map['answered_at'] = Variable<DateTime>(answeredAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  DialogueHistoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return DialogueHistoryEntriesCompanion(
      id: Value(id),
      nodeId: Value(nodeId),
      selectedOptionId: Value(selectedOptionId),
      answeredAt: Value(answeredAt),
      synced: Value(synced),
    );
  }

  factory DialogueHistoryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DialogueHistoryRow(
      id: serializer.fromJson<int>(json['id']),
      nodeId: serializer.fromJson<String>(json['nodeId']),
      selectedOptionId: serializer.fromJson<String>(json['selectedOptionId']),
      answeredAt: serializer.fromJson<DateTime>(json['answeredAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nodeId': serializer.toJson<String>(nodeId),
      'selectedOptionId': serializer.toJson<String>(selectedOptionId),
      'answeredAt': serializer.toJson<DateTime>(answeredAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  DialogueHistoryRow copyWith(
          {int? id,
          String? nodeId,
          String? selectedOptionId,
          DateTime? answeredAt,
          bool? synced}) =>
      DialogueHistoryRow(
        id: id ?? this.id,
        nodeId: nodeId ?? this.nodeId,
        selectedOptionId: selectedOptionId ?? this.selectedOptionId,
        answeredAt: answeredAt ?? this.answeredAt,
        synced: synced ?? this.synced,
      );
  DialogueHistoryRow copyWithCompanion(DialogueHistoryEntriesCompanion data) {
    return DialogueHistoryRow(
      id: data.id.present ? data.id.value : this.id,
      nodeId: data.nodeId.present ? data.nodeId.value : this.nodeId,
      selectedOptionId: data.selectedOptionId.present
          ? data.selectedOptionId.value
          : this.selectedOptionId,
      answeredAt:
          data.answeredAt.present ? data.answeredAt.value : this.answeredAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DialogueHistoryRow(')
          ..write('id: $id, ')
          ..write('nodeId: $nodeId, ')
          ..write('selectedOptionId: $selectedOptionId, ')
          ..write('answeredAt: $answeredAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nodeId, selectedOptionId, answeredAt, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DialogueHistoryRow &&
          other.id == this.id &&
          other.nodeId == this.nodeId &&
          other.selectedOptionId == this.selectedOptionId &&
          other.answeredAt == this.answeredAt &&
          other.synced == this.synced);
}

class DialogueHistoryEntriesCompanion
    extends UpdateCompanion<DialogueHistoryRow> {
  final Value<int> id;
  final Value<String> nodeId;
  final Value<String> selectedOptionId;
  final Value<DateTime> answeredAt;
  final Value<bool> synced;
  const DialogueHistoryEntriesCompanion({
    this.id = const Value.absent(),
    this.nodeId = const Value.absent(),
    this.selectedOptionId = const Value.absent(),
    this.answeredAt = const Value.absent(),
    this.synced = const Value.absent(),
  });
  DialogueHistoryEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String nodeId,
    required String selectedOptionId,
    required DateTime answeredAt,
    this.synced = const Value.absent(),
  })  : nodeId = Value(nodeId),
        selectedOptionId = Value(selectedOptionId),
        answeredAt = Value(answeredAt);
  static Insertable<DialogueHistoryRow> custom({
    Expression<int>? id,
    Expression<String>? nodeId,
    Expression<String>? selectedOptionId,
    Expression<DateTime>? answeredAt,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nodeId != null) 'node_id': nodeId,
      if (selectedOptionId != null) 'selected_option_id': selectedOptionId,
      if (answeredAt != null) 'answered_at': answeredAt,
      if (synced != null) 'synced': synced,
    });
  }

  DialogueHistoryEntriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? nodeId,
      Value<String>? selectedOptionId,
      Value<DateTime>? answeredAt,
      Value<bool>? synced}) {
    return DialogueHistoryEntriesCompanion(
      id: id ?? this.id,
      nodeId: nodeId ?? this.nodeId,
      selectedOptionId: selectedOptionId ?? this.selectedOptionId,
      answeredAt: answeredAt ?? this.answeredAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nodeId.present) {
      map['node_id'] = Variable<String>(nodeId.value);
    }
    if (selectedOptionId.present) {
      map['selected_option_id'] = Variable<String>(selectedOptionId.value);
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<DateTime>(answeredAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DialogueHistoryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('nodeId: $nodeId, ')
          ..write('selectedOptionId: $selectedOptionId, ')
          ..write('answeredAt: $answeredAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

class $SrsCardsTable extends SrsCards
    with TableInfo<$SrsCardsTable, SrsCardRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SrsCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hebrewVocalizedMeta =
      const VerificationMeta('hebrewVocalized');
  @override
  late final GeneratedColumn<String> hebrewVocalized = GeneratedColumn<String>(
      'hebrew_vocalized', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hebrewNormalizedMeta =
      const VerificationMeta('hebrewNormalized');
  @override
  late final GeneratedColumn<String> hebrewNormalized = GeneratedColumn<String>(
      'hebrew_normalized', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _russianTranslationMeta =
      const VerificationMeta('russianTranslation');
  @override
  late final GeneratedColumn<String> russianTranslation =
      GeneratedColumn<String>('russian_translation', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rootMeta = const VerificationMeta('root');
  @override
  late final GeneratedColumn<String> root = GeneratedColumn<String>(
      'root', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _binyanMeta = const VerificationMeta('binyan');
  @override
  late final GeneratedColumn<String> binyan = GeneratedColumn<String>(
      'binyan', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('none'));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('phrase'));
  static const VerificationMeta _exampleHebrewVocalizedMeta =
      const VerificationMeta('exampleHebrewVocalized');
  @override
  late final GeneratedColumn<String> exampleHebrewVocalized =
      GeneratedColumn<String>('example_hebrew_vocalized', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _exampleHebrewNormalizedMeta =
      const VerificationMeta('exampleHebrewNormalized');
  @override
  late final GeneratedColumn<String> exampleHebrewNormalized =
      GeneratedColumn<String>('example_hebrew_normalized', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _exampleRussianMeta =
      const VerificationMeta('exampleRussian');
  @override
  late final GeneratedColumn<String> exampleRussian = GeneratedColumn<String>(
      'example_russian', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _audioUrlMeta =
      const VerificationMeta('audioUrl');
  @override
  late final GeneratedColumn<String> audioUrl = GeneratedColumn<String>(
      'audio_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceNameMeta =
      const VerificationMeta('sourceName');
  @override
  late final GeneratedColumn<String> sourceName = GeneratedColumn<String>(
      'source_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _licenseNameMeta =
      const VerificationMeta('licenseName');
  @override
  late final GeneratedColumn<String> licenseName = GeneratedColumn<String>(
      'license_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _attributionTextMeta =
      const VerificationMeta('attributionText');
  @override
  late final GeneratedColumn<String> attributionText = GeneratedColumn<String>(
      'attribution_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fsrsStateMeta =
      const VerificationMeta('fsrsState');
  @override
  late final GeneratedColumn<String> fsrsState = GeneratedColumn<String>(
      'fsrs_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('newCard'));
  static const VerificationMeta _stabilityMeta =
      const VerificationMeta('stability');
  @override
  late final GeneratedColumn<double> stability = GeneratedColumn<double>(
      'stability', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _difficultyMeta =
      const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<double> difficulty = GeneratedColumn<double>(
      'difficulty', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
      'reps', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lapsesMeta = const VerificationMeta('lapses');
  @override
  late final GeneratedColumn<int> lapses = GeneratedColumn<int>(
      'lapses', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
      'due_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastReviewedAtMeta =
      const VerificationMeta('lastReviewedAt');
  @override
  late final GeneratedColumn<DateTime> lastReviewedAt =
      GeneratedColumn<DateTime>('last_reviewed_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        hebrewVocalized,
        hebrewNormalized,
        russianTranslation,
        root,
        binyan,
        category,
        exampleHebrewVocalized,
        exampleHebrewNormalized,
        exampleRussian,
        audioUrl,
        sourceName,
        licenseName,
        attributionText,
        fsrsState,
        stability,
        difficulty,
        reps,
        lapses,
        dueAt,
        lastReviewedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'srs_cards';
  @override
  VerificationContext validateIntegrity(Insertable<SrsCardRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('hebrew_vocalized')) {
      context.handle(
          _hebrewVocalizedMeta,
          hebrewVocalized.isAcceptableOrUnknown(
              data['hebrew_vocalized']!, _hebrewVocalizedMeta));
    } else if (isInserting) {
      context.missing(_hebrewVocalizedMeta);
    }
    if (data.containsKey('hebrew_normalized')) {
      context.handle(
          _hebrewNormalizedMeta,
          hebrewNormalized.isAcceptableOrUnknown(
              data['hebrew_normalized']!, _hebrewNormalizedMeta));
    } else if (isInserting) {
      context.missing(_hebrewNormalizedMeta);
    }
    if (data.containsKey('russian_translation')) {
      context.handle(
          _russianTranslationMeta,
          russianTranslation.isAcceptableOrUnknown(
              data['russian_translation']!, _russianTranslationMeta));
    } else if (isInserting) {
      context.missing(_russianTranslationMeta);
    }
    if (data.containsKey('root')) {
      context.handle(
          _rootMeta, root.isAcceptableOrUnknown(data['root']!, _rootMeta));
    }
    if (data.containsKey('binyan')) {
      context.handle(_binyanMeta,
          binyan.isAcceptableOrUnknown(data['binyan']!, _binyanMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('example_hebrew_vocalized')) {
      context.handle(
          _exampleHebrewVocalizedMeta,
          exampleHebrewVocalized.isAcceptableOrUnknown(
              data['example_hebrew_vocalized']!, _exampleHebrewVocalizedMeta));
    }
    if (data.containsKey('example_hebrew_normalized')) {
      context.handle(
          _exampleHebrewNormalizedMeta,
          exampleHebrewNormalized.isAcceptableOrUnknown(
              data['example_hebrew_normalized']!,
              _exampleHebrewNormalizedMeta));
    }
    if (data.containsKey('example_russian')) {
      context.handle(
          _exampleRussianMeta,
          exampleRussian.isAcceptableOrUnknown(
              data['example_russian']!, _exampleRussianMeta));
    }
    if (data.containsKey('audio_url')) {
      context.handle(_audioUrlMeta,
          audioUrl.isAcceptableOrUnknown(data['audio_url']!, _audioUrlMeta));
    }
    if (data.containsKey('source_name')) {
      context.handle(
          _sourceNameMeta,
          sourceName.isAcceptableOrUnknown(
              data['source_name']!, _sourceNameMeta));
    } else if (isInserting) {
      context.missing(_sourceNameMeta);
    }
    if (data.containsKey('license_name')) {
      context.handle(
          _licenseNameMeta,
          licenseName.isAcceptableOrUnknown(
              data['license_name']!, _licenseNameMeta));
    } else if (isInserting) {
      context.missing(_licenseNameMeta);
    }
    if (data.containsKey('attribution_text')) {
      context.handle(
          _attributionTextMeta,
          attributionText.isAcceptableOrUnknown(
              data['attribution_text']!, _attributionTextMeta));
    }
    if (data.containsKey('fsrs_state')) {
      context.handle(_fsrsStateMeta,
          fsrsState.isAcceptableOrUnknown(data['fsrs_state']!, _fsrsStateMeta));
    }
    if (data.containsKey('stability')) {
      context.handle(_stabilityMeta,
          stability.isAcceptableOrUnknown(data['stability']!, _stabilityMeta));
    }
    if (data.containsKey('difficulty')) {
      context.handle(
          _difficultyMeta,
          difficulty.isAcceptableOrUnknown(
              data['difficulty']!, _difficultyMeta));
    }
    if (data.containsKey('reps')) {
      context.handle(
          _repsMeta, reps.isAcceptableOrUnknown(data['reps']!, _repsMeta));
    }
    if (data.containsKey('lapses')) {
      context.handle(_lapsesMeta,
          lapses.isAcceptableOrUnknown(data['lapses']!, _lapsesMeta));
    }
    if (data.containsKey('due_at')) {
      context.handle(
          _dueAtMeta, dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta));
    } else if (isInserting) {
      context.missing(_dueAtMeta);
    }
    if (data.containsKey('last_reviewed_at')) {
      context.handle(
          _lastReviewedAtMeta,
          lastReviewedAt.isAcceptableOrUnknown(
              data['last_reviewed_at']!, _lastReviewedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SrsCardRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SrsCardRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      hebrewVocalized: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}hebrew_vocalized'])!,
      hebrewNormalized: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}hebrew_normalized'])!,
      russianTranslation: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}russian_translation'])!,
      root: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}root']),
      binyan: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}binyan'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      exampleHebrewVocalized: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}example_hebrew_vocalized']),
      exampleHebrewNormalized: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}example_hebrew_normalized']),
      exampleRussian: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}example_russian']),
      audioUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}audio_url']),
      sourceName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_name'])!,
      licenseName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}license_name'])!,
      attributionText: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}attribution_text']),
      fsrsState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fsrs_state'])!,
      stability: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}stability'])!,
      difficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}difficulty'])!,
      reps: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reps'])!,
      lapses: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}lapses'])!,
      dueAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_at'])!,
      lastReviewedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_reviewed_at']),
    );
  }

  @override
  $SrsCardsTable createAlias(String alias) {
    return $SrsCardsTable(attachedDatabase, alias);
  }
}

class SrsCardRow extends DataClass implements Insertable<SrsCardRow> {
  final String id;
  final String hebrewVocalized;
  final String hebrewNormalized;
  final String russianTranslation;
  final String? root;
  final String binyan;
  final String category;
  final String? exampleHebrewVocalized;
  final String? exampleHebrewNormalized;
  final String? exampleRussian;
  final String? audioUrl;
  final String sourceName;
  final String licenseName;
  final String? attributionText;
  final String fsrsState;
  final double stability;
  final double difficulty;
  final int reps;
  final int lapses;
  final DateTime dueAt;
  final DateTime? lastReviewedAt;
  const SrsCardRow(
      {required this.id,
      required this.hebrewVocalized,
      required this.hebrewNormalized,
      required this.russianTranslation,
      this.root,
      required this.binyan,
      required this.category,
      this.exampleHebrewVocalized,
      this.exampleHebrewNormalized,
      this.exampleRussian,
      this.audioUrl,
      required this.sourceName,
      required this.licenseName,
      this.attributionText,
      required this.fsrsState,
      required this.stability,
      required this.difficulty,
      required this.reps,
      required this.lapses,
      required this.dueAt,
      this.lastReviewedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hebrew_vocalized'] = Variable<String>(hebrewVocalized);
    map['hebrew_normalized'] = Variable<String>(hebrewNormalized);
    map['russian_translation'] = Variable<String>(russianTranslation);
    if (!nullToAbsent || root != null) {
      map['root'] = Variable<String>(root);
    }
    map['binyan'] = Variable<String>(binyan);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || exampleHebrewVocalized != null) {
      map['example_hebrew_vocalized'] =
          Variable<String>(exampleHebrewVocalized);
    }
    if (!nullToAbsent || exampleHebrewNormalized != null) {
      map['example_hebrew_normalized'] =
          Variable<String>(exampleHebrewNormalized);
    }
    if (!nullToAbsent || exampleRussian != null) {
      map['example_russian'] = Variable<String>(exampleRussian);
    }
    if (!nullToAbsent || audioUrl != null) {
      map['audio_url'] = Variable<String>(audioUrl);
    }
    map['source_name'] = Variable<String>(sourceName);
    map['license_name'] = Variable<String>(licenseName);
    if (!nullToAbsent || attributionText != null) {
      map['attribution_text'] = Variable<String>(attributionText);
    }
    map['fsrs_state'] = Variable<String>(fsrsState);
    map['stability'] = Variable<double>(stability);
    map['difficulty'] = Variable<double>(difficulty);
    map['reps'] = Variable<int>(reps);
    map['lapses'] = Variable<int>(lapses);
    map['due_at'] = Variable<DateTime>(dueAt);
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt);
    }
    return map;
  }

  SrsCardsCompanion toCompanion(bool nullToAbsent) {
    return SrsCardsCompanion(
      id: Value(id),
      hebrewVocalized: Value(hebrewVocalized),
      hebrewNormalized: Value(hebrewNormalized),
      russianTranslation: Value(russianTranslation),
      root: root == null && nullToAbsent ? const Value.absent() : Value(root),
      binyan: Value(binyan),
      category: Value(category),
      exampleHebrewVocalized: exampleHebrewVocalized == null && nullToAbsent
          ? const Value.absent()
          : Value(exampleHebrewVocalized),
      exampleHebrewNormalized: exampleHebrewNormalized == null && nullToAbsent
          ? const Value.absent()
          : Value(exampleHebrewNormalized),
      exampleRussian: exampleRussian == null && nullToAbsent
          ? const Value.absent()
          : Value(exampleRussian),
      audioUrl: audioUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(audioUrl),
      sourceName: Value(sourceName),
      licenseName: Value(licenseName),
      attributionText: attributionText == null && nullToAbsent
          ? const Value.absent()
          : Value(attributionText),
      fsrsState: Value(fsrsState),
      stability: Value(stability),
      difficulty: Value(difficulty),
      reps: Value(reps),
      lapses: Value(lapses),
      dueAt: Value(dueAt),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
    );
  }

  factory SrsCardRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SrsCardRow(
      id: serializer.fromJson<String>(json['id']),
      hebrewVocalized: serializer.fromJson<String>(json['hebrewVocalized']),
      hebrewNormalized: serializer.fromJson<String>(json['hebrewNormalized']),
      russianTranslation:
          serializer.fromJson<String>(json['russianTranslation']),
      root: serializer.fromJson<String?>(json['root']),
      binyan: serializer.fromJson<String>(json['binyan']),
      category: serializer.fromJson<String>(json['category']),
      exampleHebrewVocalized:
          serializer.fromJson<String?>(json['exampleHebrewVocalized']),
      exampleHebrewNormalized:
          serializer.fromJson<String?>(json['exampleHebrewNormalized']),
      exampleRussian: serializer.fromJson<String?>(json['exampleRussian']),
      audioUrl: serializer.fromJson<String?>(json['audioUrl']),
      sourceName: serializer.fromJson<String>(json['sourceName']),
      licenseName: serializer.fromJson<String>(json['licenseName']),
      attributionText: serializer.fromJson<String?>(json['attributionText']),
      fsrsState: serializer.fromJson<String>(json['fsrsState']),
      stability: serializer.fromJson<double>(json['stability']),
      difficulty: serializer.fromJson<double>(json['difficulty']),
      reps: serializer.fromJson<int>(json['reps']),
      lapses: serializer.fromJson<int>(json['lapses']),
      dueAt: serializer.fromJson<DateTime>(json['dueAt']),
      lastReviewedAt: serializer.fromJson<DateTime?>(json['lastReviewedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hebrewVocalized': serializer.toJson<String>(hebrewVocalized),
      'hebrewNormalized': serializer.toJson<String>(hebrewNormalized),
      'russianTranslation': serializer.toJson<String>(russianTranslation),
      'root': serializer.toJson<String?>(root),
      'binyan': serializer.toJson<String>(binyan),
      'category': serializer.toJson<String>(category),
      'exampleHebrewVocalized':
          serializer.toJson<String?>(exampleHebrewVocalized),
      'exampleHebrewNormalized':
          serializer.toJson<String?>(exampleHebrewNormalized),
      'exampleRussian': serializer.toJson<String?>(exampleRussian),
      'audioUrl': serializer.toJson<String?>(audioUrl),
      'sourceName': serializer.toJson<String>(sourceName),
      'licenseName': serializer.toJson<String>(licenseName),
      'attributionText': serializer.toJson<String?>(attributionText),
      'fsrsState': serializer.toJson<String>(fsrsState),
      'stability': serializer.toJson<double>(stability),
      'difficulty': serializer.toJson<double>(difficulty),
      'reps': serializer.toJson<int>(reps),
      'lapses': serializer.toJson<int>(lapses),
      'dueAt': serializer.toJson<DateTime>(dueAt),
      'lastReviewedAt': serializer.toJson<DateTime?>(lastReviewedAt),
    };
  }

  SrsCardRow copyWith(
          {String? id,
          String? hebrewVocalized,
          String? hebrewNormalized,
          String? russianTranslation,
          Value<String?> root = const Value.absent(),
          String? binyan,
          String? category,
          Value<String?> exampleHebrewVocalized = const Value.absent(),
          Value<String?> exampleHebrewNormalized = const Value.absent(),
          Value<String?> exampleRussian = const Value.absent(),
          Value<String?> audioUrl = const Value.absent(),
          String? sourceName,
          String? licenseName,
          Value<String?> attributionText = const Value.absent(),
          String? fsrsState,
          double? stability,
          double? difficulty,
          int? reps,
          int? lapses,
          DateTime? dueAt,
          Value<DateTime?> lastReviewedAt = const Value.absent()}) =>
      SrsCardRow(
        id: id ?? this.id,
        hebrewVocalized: hebrewVocalized ?? this.hebrewVocalized,
        hebrewNormalized: hebrewNormalized ?? this.hebrewNormalized,
        russianTranslation: russianTranslation ?? this.russianTranslation,
        root: root.present ? root.value : this.root,
        binyan: binyan ?? this.binyan,
        category: category ?? this.category,
        exampleHebrewVocalized: exampleHebrewVocalized.present
            ? exampleHebrewVocalized.value
            : this.exampleHebrewVocalized,
        exampleHebrewNormalized: exampleHebrewNormalized.present
            ? exampleHebrewNormalized.value
            : this.exampleHebrewNormalized,
        exampleRussian:
            exampleRussian.present ? exampleRussian.value : this.exampleRussian,
        audioUrl: audioUrl.present ? audioUrl.value : this.audioUrl,
        sourceName: sourceName ?? this.sourceName,
        licenseName: licenseName ?? this.licenseName,
        attributionText: attributionText.present
            ? attributionText.value
            : this.attributionText,
        fsrsState: fsrsState ?? this.fsrsState,
        stability: stability ?? this.stability,
        difficulty: difficulty ?? this.difficulty,
        reps: reps ?? this.reps,
        lapses: lapses ?? this.lapses,
        dueAt: dueAt ?? this.dueAt,
        lastReviewedAt:
            lastReviewedAt.present ? lastReviewedAt.value : this.lastReviewedAt,
      );
  SrsCardRow copyWithCompanion(SrsCardsCompanion data) {
    return SrsCardRow(
      id: data.id.present ? data.id.value : this.id,
      hebrewVocalized: data.hebrewVocalized.present
          ? data.hebrewVocalized.value
          : this.hebrewVocalized,
      hebrewNormalized: data.hebrewNormalized.present
          ? data.hebrewNormalized.value
          : this.hebrewNormalized,
      russianTranslation: data.russianTranslation.present
          ? data.russianTranslation.value
          : this.russianTranslation,
      root: data.root.present ? data.root.value : this.root,
      binyan: data.binyan.present ? data.binyan.value : this.binyan,
      category: data.category.present ? data.category.value : this.category,
      exampleHebrewVocalized: data.exampleHebrewVocalized.present
          ? data.exampleHebrewVocalized.value
          : this.exampleHebrewVocalized,
      exampleHebrewNormalized: data.exampleHebrewNormalized.present
          ? data.exampleHebrewNormalized.value
          : this.exampleHebrewNormalized,
      exampleRussian: data.exampleRussian.present
          ? data.exampleRussian.value
          : this.exampleRussian,
      audioUrl: data.audioUrl.present ? data.audioUrl.value : this.audioUrl,
      sourceName:
          data.sourceName.present ? data.sourceName.value : this.sourceName,
      licenseName:
          data.licenseName.present ? data.licenseName.value : this.licenseName,
      attributionText: data.attributionText.present
          ? data.attributionText.value
          : this.attributionText,
      fsrsState: data.fsrsState.present ? data.fsrsState.value : this.fsrsState,
      stability: data.stability.present ? data.stability.value : this.stability,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      reps: data.reps.present ? data.reps.value : this.reps,
      lapses: data.lapses.present ? data.lapses.value : this.lapses,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SrsCardRow(')
          ..write('id: $id, ')
          ..write('hebrewVocalized: $hebrewVocalized, ')
          ..write('hebrewNormalized: $hebrewNormalized, ')
          ..write('russianTranslation: $russianTranslation, ')
          ..write('root: $root, ')
          ..write('binyan: $binyan, ')
          ..write('category: $category, ')
          ..write('exampleHebrewVocalized: $exampleHebrewVocalized, ')
          ..write('exampleHebrewNormalized: $exampleHebrewNormalized, ')
          ..write('exampleRussian: $exampleRussian, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('sourceName: $sourceName, ')
          ..write('licenseName: $licenseName, ')
          ..write('attributionText: $attributionText, ')
          ..write('fsrsState: $fsrsState, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('dueAt: $dueAt, ')
          ..write('lastReviewedAt: $lastReviewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        hebrewVocalized,
        hebrewNormalized,
        russianTranslation,
        root,
        binyan,
        category,
        exampleHebrewVocalized,
        exampleHebrewNormalized,
        exampleRussian,
        audioUrl,
        sourceName,
        licenseName,
        attributionText,
        fsrsState,
        stability,
        difficulty,
        reps,
        lapses,
        dueAt,
        lastReviewedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SrsCardRow &&
          other.id == this.id &&
          other.hebrewVocalized == this.hebrewVocalized &&
          other.hebrewNormalized == this.hebrewNormalized &&
          other.russianTranslation == this.russianTranslation &&
          other.root == this.root &&
          other.binyan == this.binyan &&
          other.category == this.category &&
          other.exampleHebrewVocalized == this.exampleHebrewVocalized &&
          other.exampleHebrewNormalized == this.exampleHebrewNormalized &&
          other.exampleRussian == this.exampleRussian &&
          other.audioUrl == this.audioUrl &&
          other.sourceName == this.sourceName &&
          other.licenseName == this.licenseName &&
          other.attributionText == this.attributionText &&
          other.fsrsState == this.fsrsState &&
          other.stability == this.stability &&
          other.difficulty == this.difficulty &&
          other.reps == this.reps &&
          other.lapses == this.lapses &&
          other.dueAt == this.dueAt &&
          other.lastReviewedAt == this.lastReviewedAt);
}

class SrsCardsCompanion extends UpdateCompanion<SrsCardRow> {
  final Value<String> id;
  final Value<String> hebrewVocalized;
  final Value<String> hebrewNormalized;
  final Value<String> russianTranslation;
  final Value<String?> root;
  final Value<String> binyan;
  final Value<String> category;
  final Value<String?> exampleHebrewVocalized;
  final Value<String?> exampleHebrewNormalized;
  final Value<String?> exampleRussian;
  final Value<String?> audioUrl;
  final Value<String> sourceName;
  final Value<String> licenseName;
  final Value<String?> attributionText;
  final Value<String> fsrsState;
  final Value<double> stability;
  final Value<double> difficulty;
  final Value<int> reps;
  final Value<int> lapses;
  final Value<DateTime> dueAt;
  final Value<DateTime?> lastReviewedAt;
  final Value<int> rowid;
  const SrsCardsCompanion({
    this.id = const Value.absent(),
    this.hebrewVocalized = const Value.absent(),
    this.hebrewNormalized = const Value.absent(),
    this.russianTranslation = const Value.absent(),
    this.root = const Value.absent(),
    this.binyan = const Value.absent(),
    this.category = const Value.absent(),
    this.exampleHebrewVocalized = const Value.absent(),
    this.exampleHebrewNormalized = const Value.absent(),
    this.exampleRussian = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.sourceName = const Value.absent(),
    this.licenseName = const Value.absent(),
    this.attributionText = const Value.absent(),
    this.fsrsState = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SrsCardsCompanion.insert({
    required String id,
    required String hebrewVocalized,
    required String hebrewNormalized,
    required String russianTranslation,
    this.root = const Value.absent(),
    this.binyan = const Value.absent(),
    this.category = const Value.absent(),
    this.exampleHebrewVocalized = const Value.absent(),
    this.exampleHebrewNormalized = const Value.absent(),
    this.exampleRussian = const Value.absent(),
    this.audioUrl = const Value.absent(),
    required String sourceName,
    required String licenseName,
    this.attributionText = const Value.absent(),
    this.fsrsState = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    required DateTime dueAt,
    this.lastReviewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        hebrewVocalized = Value(hebrewVocalized),
        hebrewNormalized = Value(hebrewNormalized),
        russianTranslation = Value(russianTranslation),
        sourceName = Value(sourceName),
        licenseName = Value(licenseName),
        dueAt = Value(dueAt);
  static Insertable<SrsCardRow> custom({
    Expression<String>? id,
    Expression<String>? hebrewVocalized,
    Expression<String>? hebrewNormalized,
    Expression<String>? russianTranslation,
    Expression<String>? root,
    Expression<String>? binyan,
    Expression<String>? category,
    Expression<String>? exampleHebrewVocalized,
    Expression<String>? exampleHebrewNormalized,
    Expression<String>? exampleRussian,
    Expression<String>? audioUrl,
    Expression<String>? sourceName,
    Expression<String>? licenseName,
    Expression<String>? attributionText,
    Expression<String>? fsrsState,
    Expression<double>? stability,
    Expression<double>? difficulty,
    Expression<int>? reps,
    Expression<int>? lapses,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? lastReviewedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hebrewVocalized != null) 'hebrew_vocalized': hebrewVocalized,
      if (hebrewNormalized != null) 'hebrew_normalized': hebrewNormalized,
      if (russianTranslation != null) 'russian_translation': russianTranslation,
      if (root != null) 'root': root,
      if (binyan != null) 'binyan': binyan,
      if (category != null) 'category': category,
      if (exampleHebrewVocalized != null)
        'example_hebrew_vocalized': exampleHebrewVocalized,
      if (exampleHebrewNormalized != null)
        'example_hebrew_normalized': exampleHebrewNormalized,
      if (exampleRussian != null) 'example_russian': exampleRussian,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (sourceName != null) 'source_name': sourceName,
      if (licenseName != null) 'license_name': licenseName,
      if (attributionText != null) 'attribution_text': attributionText,
      if (fsrsState != null) 'fsrs_state': fsrsState,
      if (stability != null) 'stability': stability,
      if (difficulty != null) 'difficulty': difficulty,
      if (reps != null) 'reps': reps,
      if (lapses != null) 'lapses': lapses,
      if (dueAt != null) 'due_at': dueAt,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SrsCardsCompanion copyWith(
      {Value<String>? id,
      Value<String>? hebrewVocalized,
      Value<String>? hebrewNormalized,
      Value<String>? russianTranslation,
      Value<String?>? root,
      Value<String>? binyan,
      Value<String>? category,
      Value<String?>? exampleHebrewVocalized,
      Value<String?>? exampleHebrewNormalized,
      Value<String?>? exampleRussian,
      Value<String?>? audioUrl,
      Value<String>? sourceName,
      Value<String>? licenseName,
      Value<String?>? attributionText,
      Value<String>? fsrsState,
      Value<double>? stability,
      Value<double>? difficulty,
      Value<int>? reps,
      Value<int>? lapses,
      Value<DateTime>? dueAt,
      Value<DateTime?>? lastReviewedAt,
      Value<int>? rowid}) {
    return SrsCardsCompanion(
      id: id ?? this.id,
      hebrewVocalized: hebrewVocalized ?? this.hebrewVocalized,
      hebrewNormalized: hebrewNormalized ?? this.hebrewNormalized,
      russianTranslation: russianTranslation ?? this.russianTranslation,
      root: root ?? this.root,
      binyan: binyan ?? this.binyan,
      category: category ?? this.category,
      exampleHebrewVocalized:
          exampleHebrewVocalized ?? this.exampleHebrewVocalized,
      exampleHebrewNormalized:
          exampleHebrewNormalized ?? this.exampleHebrewNormalized,
      exampleRussian: exampleRussian ?? this.exampleRussian,
      audioUrl: audioUrl ?? this.audioUrl,
      sourceName: sourceName ?? this.sourceName,
      licenseName: licenseName ?? this.licenseName,
      attributionText: attributionText ?? this.attributionText,
      fsrsState: fsrsState ?? this.fsrsState,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      dueAt: dueAt ?? this.dueAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hebrewVocalized.present) {
      map['hebrew_vocalized'] = Variable<String>(hebrewVocalized.value);
    }
    if (hebrewNormalized.present) {
      map['hebrew_normalized'] = Variable<String>(hebrewNormalized.value);
    }
    if (russianTranslation.present) {
      map['russian_translation'] = Variable<String>(russianTranslation.value);
    }
    if (root.present) {
      map['root'] = Variable<String>(root.value);
    }
    if (binyan.present) {
      map['binyan'] = Variable<String>(binyan.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (exampleHebrewVocalized.present) {
      map['example_hebrew_vocalized'] =
          Variable<String>(exampleHebrewVocalized.value);
    }
    if (exampleHebrewNormalized.present) {
      map['example_hebrew_normalized'] =
          Variable<String>(exampleHebrewNormalized.value);
    }
    if (exampleRussian.present) {
      map['example_russian'] = Variable<String>(exampleRussian.value);
    }
    if (audioUrl.present) {
      map['audio_url'] = Variable<String>(audioUrl.value);
    }
    if (sourceName.present) {
      map['source_name'] = Variable<String>(sourceName.value);
    }
    if (licenseName.present) {
      map['license_name'] = Variable<String>(licenseName.value);
    }
    if (attributionText.present) {
      map['attribution_text'] = Variable<String>(attributionText.value);
    }
    if (fsrsState.present) {
      map['fsrs_state'] = Variable<String>(fsrsState.value);
    }
    if (stability.present) {
      map['stability'] = Variable<double>(stability.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<double>(difficulty.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (lapses.present) {
      map['lapses'] = Variable<int>(lapses.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SrsCardsCompanion(')
          ..write('id: $id, ')
          ..write('hebrewVocalized: $hebrewVocalized, ')
          ..write('hebrewNormalized: $hebrewNormalized, ')
          ..write('russianTranslation: $russianTranslation, ')
          ..write('root: $root, ')
          ..write('binyan: $binyan, ')
          ..write('category: $category, ')
          ..write('exampleHebrewVocalized: $exampleHebrewVocalized, ')
          ..write('exampleHebrewNormalized: $exampleHebrewNormalized, ')
          ..write('exampleRussian: $exampleRussian, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('sourceName: $sourceName, ')
          ..write('licenseName: $licenseName, ')
          ..write('attributionText: $attributionText, ')
          ..write('fsrsState: $fsrsState, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('dueAt: $dueAt, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SrsReviewLogsTable extends SrsReviewLogs
    with TableInfo<$SrsReviewLogsTable, SrsReviewLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SrsReviewLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
      'card_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
      'rating', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _stabilityBeforeMeta =
      const VerificationMeta('stabilityBefore');
  @override
  late final GeneratedColumn<double> stabilityBefore = GeneratedColumn<double>(
      'stability_before', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _stabilityAfterMeta =
      const VerificationMeta('stabilityAfter');
  @override
  late final GeneratedColumn<double> stabilityAfter = GeneratedColumn<double>(
      'stability_after', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _difficultyAfterMeta =
      const VerificationMeta('difficultyAfter');
  @override
  late final GeneratedColumn<double> difficultyAfter = GeneratedColumn<double>(
      'difficulty_after', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _scheduledDaysMeta =
      const VerificationMeta('scheduledDays');
  @override
  late final GeneratedColumn<int> scheduledDays = GeneratedColumn<int>(
      'scheduled_days', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _wasTypedCheckMeta =
      const VerificationMeta('wasTypedCheck');
  @override
  late final GeneratedColumn<bool> wasTypedCheck = GeneratedColumn<bool>(
      'was_typed_check', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("was_typed_check" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _wasTypedExactMeta =
      const VerificationMeta('wasTypedExact');
  @override
  late final GeneratedColumn<bool> wasTypedExact = GeneratedColumn<bool>(
      'was_typed_exact', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("was_typed_exact" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _reviewedAtMeta =
      const VerificationMeta('reviewedAt');
  @override
  late final GeneratedColumn<DateTime> reviewedAt = GeneratedColumn<DateTime>(
      'reviewed_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        cardId,
        rating,
        stabilityBefore,
        stabilityAfter,
        difficultyAfter,
        scheduledDays,
        wasTypedCheck,
        wasTypedExact,
        reviewedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'srs_review_logs';
  @override
  VerificationContext validateIntegrity(Insertable<SrsReviewLogRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('card_id')) {
      context.handle(_cardIdMeta,
          cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta));
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(_ratingMeta,
          rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));
    } else if (isInserting) {
      context.missing(_ratingMeta);
    }
    if (data.containsKey('stability_before')) {
      context.handle(
          _stabilityBeforeMeta,
          stabilityBefore.isAcceptableOrUnknown(
              data['stability_before']!, _stabilityBeforeMeta));
    } else if (isInserting) {
      context.missing(_stabilityBeforeMeta);
    }
    if (data.containsKey('stability_after')) {
      context.handle(
          _stabilityAfterMeta,
          stabilityAfter.isAcceptableOrUnknown(
              data['stability_after']!, _stabilityAfterMeta));
    } else if (isInserting) {
      context.missing(_stabilityAfterMeta);
    }
    if (data.containsKey('difficulty_after')) {
      context.handle(
          _difficultyAfterMeta,
          difficultyAfter.isAcceptableOrUnknown(
              data['difficulty_after']!, _difficultyAfterMeta));
    } else if (isInserting) {
      context.missing(_difficultyAfterMeta);
    }
    if (data.containsKey('scheduled_days')) {
      context.handle(
          _scheduledDaysMeta,
          scheduledDays.isAcceptableOrUnknown(
              data['scheduled_days']!, _scheduledDaysMeta));
    } else if (isInserting) {
      context.missing(_scheduledDaysMeta);
    }
    if (data.containsKey('was_typed_check')) {
      context.handle(
          _wasTypedCheckMeta,
          wasTypedCheck.isAcceptableOrUnknown(
              data['was_typed_check']!, _wasTypedCheckMeta));
    }
    if (data.containsKey('was_typed_exact')) {
      context.handle(
          _wasTypedExactMeta,
          wasTypedExact.isAcceptableOrUnknown(
              data['was_typed_exact']!, _wasTypedExactMeta));
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
          _reviewedAtMeta,
          reviewedAt.isAcceptableOrUnknown(
              data['reviewed_at']!, _reviewedAtMeta));
    } else if (isInserting) {
      context.missing(_reviewedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SrsReviewLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SrsReviewLogRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      cardId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}card_id'])!,
      rating: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rating'])!,
      stabilityBefore: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}stability_before'])!,
      stabilityAfter: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}stability_after'])!,
      difficultyAfter: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}difficulty_after'])!,
      scheduledDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}scheduled_days'])!,
      wasTypedCheck: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}was_typed_check'])!,
      wasTypedExact: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}was_typed_exact'])!,
      reviewedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}reviewed_at'])!,
    );
  }

  @override
  $SrsReviewLogsTable createAlias(String alias) {
    return $SrsReviewLogsTable(attachedDatabase, alias);
  }
}

class SrsReviewLogRow extends DataClass implements Insertable<SrsReviewLogRow> {
  final int id;
  final String cardId;
  final int rating;
  final double stabilityBefore;
  final double stabilityAfter;
  final double difficultyAfter;
  final int scheduledDays;
  final bool wasTypedCheck;
  final bool wasTypedExact;
  final DateTime reviewedAt;
  const SrsReviewLogRow(
      {required this.id,
      required this.cardId,
      required this.rating,
      required this.stabilityBefore,
      required this.stabilityAfter,
      required this.difficultyAfter,
      required this.scheduledDays,
      required this.wasTypedCheck,
      required this.wasTypedExact,
      required this.reviewedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['card_id'] = Variable<String>(cardId);
    map['rating'] = Variable<int>(rating);
    map['stability_before'] = Variable<double>(stabilityBefore);
    map['stability_after'] = Variable<double>(stabilityAfter);
    map['difficulty_after'] = Variable<double>(difficultyAfter);
    map['scheduled_days'] = Variable<int>(scheduledDays);
    map['was_typed_check'] = Variable<bool>(wasTypedCheck);
    map['was_typed_exact'] = Variable<bool>(wasTypedExact);
    map['reviewed_at'] = Variable<DateTime>(reviewedAt);
    return map;
  }

  SrsReviewLogsCompanion toCompanion(bool nullToAbsent) {
    return SrsReviewLogsCompanion(
      id: Value(id),
      cardId: Value(cardId),
      rating: Value(rating),
      stabilityBefore: Value(stabilityBefore),
      stabilityAfter: Value(stabilityAfter),
      difficultyAfter: Value(difficultyAfter),
      scheduledDays: Value(scheduledDays),
      wasTypedCheck: Value(wasTypedCheck),
      wasTypedExact: Value(wasTypedExact),
      reviewedAt: Value(reviewedAt),
    );
  }

  factory SrsReviewLogRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SrsReviewLogRow(
      id: serializer.fromJson<int>(json['id']),
      cardId: serializer.fromJson<String>(json['cardId']),
      rating: serializer.fromJson<int>(json['rating']),
      stabilityBefore: serializer.fromJson<double>(json['stabilityBefore']),
      stabilityAfter: serializer.fromJson<double>(json['stabilityAfter']),
      difficultyAfter: serializer.fromJson<double>(json['difficultyAfter']),
      scheduledDays: serializer.fromJson<int>(json['scheduledDays']),
      wasTypedCheck: serializer.fromJson<bool>(json['wasTypedCheck']),
      wasTypedExact: serializer.fromJson<bool>(json['wasTypedExact']),
      reviewedAt: serializer.fromJson<DateTime>(json['reviewedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cardId': serializer.toJson<String>(cardId),
      'rating': serializer.toJson<int>(rating),
      'stabilityBefore': serializer.toJson<double>(stabilityBefore),
      'stabilityAfter': serializer.toJson<double>(stabilityAfter),
      'difficultyAfter': serializer.toJson<double>(difficultyAfter),
      'scheduledDays': serializer.toJson<int>(scheduledDays),
      'wasTypedCheck': serializer.toJson<bool>(wasTypedCheck),
      'wasTypedExact': serializer.toJson<bool>(wasTypedExact),
      'reviewedAt': serializer.toJson<DateTime>(reviewedAt),
    };
  }

  SrsReviewLogRow copyWith(
          {int? id,
          String? cardId,
          int? rating,
          double? stabilityBefore,
          double? stabilityAfter,
          double? difficultyAfter,
          int? scheduledDays,
          bool? wasTypedCheck,
          bool? wasTypedExact,
          DateTime? reviewedAt}) =>
      SrsReviewLogRow(
        id: id ?? this.id,
        cardId: cardId ?? this.cardId,
        rating: rating ?? this.rating,
        stabilityBefore: stabilityBefore ?? this.stabilityBefore,
        stabilityAfter: stabilityAfter ?? this.stabilityAfter,
        difficultyAfter: difficultyAfter ?? this.difficultyAfter,
        scheduledDays: scheduledDays ?? this.scheduledDays,
        wasTypedCheck: wasTypedCheck ?? this.wasTypedCheck,
        wasTypedExact: wasTypedExact ?? this.wasTypedExact,
        reviewedAt: reviewedAt ?? this.reviewedAt,
      );
  SrsReviewLogRow copyWithCompanion(SrsReviewLogsCompanion data) {
    return SrsReviewLogRow(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      rating: data.rating.present ? data.rating.value : this.rating,
      stabilityBefore: data.stabilityBefore.present
          ? data.stabilityBefore.value
          : this.stabilityBefore,
      stabilityAfter: data.stabilityAfter.present
          ? data.stabilityAfter.value
          : this.stabilityAfter,
      difficultyAfter: data.difficultyAfter.present
          ? data.difficultyAfter.value
          : this.difficultyAfter,
      scheduledDays: data.scheduledDays.present
          ? data.scheduledDays.value
          : this.scheduledDays,
      wasTypedCheck: data.wasTypedCheck.present
          ? data.wasTypedCheck.value
          : this.wasTypedCheck,
      wasTypedExact: data.wasTypedExact.present
          ? data.wasTypedExact.value
          : this.wasTypedExact,
      reviewedAt:
          data.reviewedAt.present ? data.reviewedAt.value : this.reviewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SrsReviewLogRow(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('rating: $rating, ')
          ..write('stabilityBefore: $stabilityBefore, ')
          ..write('stabilityAfter: $stabilityAfter, ')
          ..write('difficultyAfter: $difficultyAfter, ')
          ..write('scheduledDays: $scheduledDays, ')
          ..write('wasTypedCheck: $wasTypedCheck, ')
          ..write('wasTypedExact: $wasTypedExact, ')
          ..write('reviewedAt: $reviewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      cardId,
      rating,
      stabilityBefore,
      stabilityAfter,
      difficultyAfter,
      scheduledDays,
      wasTypedCheck,
      wasTypedExact,
      reviewedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SrsReviewLogRow &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.rating == this.rating &&
          other.stabilityBefore == this.stabilityBefore &&
          other.stabilityAfter == this.stabilityAfter &&
          other.difficultyAfter == this.difficultyAfter &&
          other.scheduledDays == this.scheduledDays &&
          other.wasTypedCheck == this.wasTypedCheck &&
          other.wasTypedExact == this.wasTypedExact &&
          other.reviewedAt == this.reviewedAt);
}

class SrsReviewLogsCompanion extends UpdateCompanion<SrsReviewLogRow> {
  final Value<int> id;
  final Value<String> cardId;
  final Value<int> rating;
  final Value<double> stabilityBefore;
  final Value<double> stabilityAfter;
  final Value<double> difficultyAfter;
  final Value<int> scheduledDays;
  final Value<bool> wasTypedCheck;
  final Value<bool> wasTypedExact;
  final Value<DateTime> reviewedAt;
  const SrsReviewLogsCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.rating = const Value.absent(),
    this.stabilityBefore = const Value.absent(),
    this.stabilityAfter = const Value.absent(),
    this.difficultyAfter = const Value.absent(),
    this.scheduledDays = const Value.absent(),
    this.wasTypedCheck = const Value.absent(),
    this.wasTypedExact = const Value.absent(),
    this.reviewedAt = const Value.absent(),
  });
  SrsReviewLogsCompanion.insert({
    this.id = const Value.absent(),
    required String cardId,
    required int rating,
    required double stabilityBefore,
    required double stabilityAfter,
    required double difficultyAfter,
    required int scheduledDays,
    this.wasTypedCheck = const Value.absent(),
    this.wasTypedExact = const Value.absent(),
    required DateTime reviewedAt,
  })  : cardId = Value(cardId),
        rating = Value(rating),
        stabilityBefore = Value(stabilityBefore),
        stabilityAfter = Value(stabilityAfter),
        difficultyAfter = Value(difficultyAfter),
        scheduledDays = Value(scheduledDays),
        reviewedAt = Value(reviewedAt);
  static Insertable<SrsReviewLogRow> custom({
    Expression<int>? id,
    Expression<String>? cardId,
    Expression<int>? rating,
    Expression<double>? stabilityBefore,
    Expression<double>? stabilityAfter,
    Expression<double>? difficultyAfter,
    Expression<int>? scheduledDays,
    Expression<bool>? wasTypedCheck,
    Expression<bool>? wasTypedExact,
    Expression<DateTime>? reviewedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (rating != null) 'rating': rating,
      if (stabilityBefore != null) 'stability_before': stabilityBefore,
      if (stabilityAfter != null) 'stability_after': stabilityAfter,
      if (difficultyAfter != null) 'difficulty_after': difficultyAfter,
      if (scheduledDays != null) 'scheduled_days': scheduledDays,
      if (wasTypedCheck != null) 'was_typed_check': wasTypedCheck,
      if (wasTypedExact != null) 'was_typed_exact': wasTypedExact,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
    });
  }

  SrsReviewLogsCompanion copyWith(
      {Value<int>? id,
      Value<String>? cardId,
      Value<int>? rating,
      Value<double>? stabilityBefore,
      Value<double>? stabilityAfter,
      Value<double>? difficultyAfter,
      Value<int>? scheduledDays,
      Value<bool>? wasTypedCheck,
      Value<bool>? wasTypedExact,
      Value<DateTime>? reviewedAt}) {
    return SrsReviewLogsCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      rating: rating ?? this.rating,
      stabilityBefore: stabilityBefore ?? this.stabilityBefore,
      stabilityAfter: stabilityAfter ?? this.stabilityAfter,
      difficultyAfter: difficultyAfter ?? this.difficultyAfter,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      wasTypedCheck: wasTypedCheck ?? this.wasTypedCheck,
      wasTypedExact: wasTypedExact ?? this.wasTypedExact,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (stabilityBefore.present) {
      map['stability_before'] = Variable<double>(stabilityBefore.value);
    }
    if (stabilityAfter.present) {
      map['stability_after'] = Variable<double>(stabilityAfter.value);
    }
    if (difficultyAfter.present) {
      map['difficulty_after'] = Variable<double>(difficultyAfter.value);
    }
    if (scheduledDays.present) {
      map['scheduled_days'] = Variable<int>(scheduledDays.value);
    }
    if (wasTypedCheck.present) {
      map['was_typed_check'] = Variable<bool>(wasTypedCheck.value);
    }
    if (wasTypedExact.present) {
      map['was_typed_exact'] = Variable<bool>(wasTypedExact.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SrsReviewLogsCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('rating: $rating, ')
          ..write('stabilityBefore: $stabilityBefore, ')
          ..write('stabilityAfter: $stabilityAfter, ')
          ..write('difficultyAfter: $difficultyAfter, ')
          ..write('scheduledDays: $scheduledDays, ')
          ..write('wasTypedCheck: $wasTypedCheck, ')
          ..write('wasTypedExact: $wasTypedExact, ')
          ..write('reviewedAt: $reviewedAt')
          ..write(')'))
        .toString();
  }
}

class $GrammarVerbsTable extends GrammarVerbs
    with TableInfo<$GrammarVerbsTable, GrammarVerbRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GrammarVerbsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lemmaVocalizedMeta =
      const VerificationMeta('lemmaVocalized');
  @override
  late final GeneratedColumn<String> lemmaVocalized = GeneratedColumn<String>(
      'lemma_vocalized', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lemmaNormalizedMeta =
      const VerificationMeta('lemmaNormalized');
  @override
  late final GeneratedColumn<String> lemmaNormalized = GeneratedColumn<String>(
      'lemma_normalized', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _infinitiveVocalizedMeta =
      const VerificationMeta('infinitiveVocalized');
  @override
  late final GeneratedColumn<String> infinitiveVocalized =
      GeneratedColumn<String>('infinitive_vocalized', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _rootMeta = const VerificationMeta('root');
  @override
  late final GeneratedColumn<String> root = GeneratedColumn<String>(
      'root', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _binyanMeta = const VerificationMeta('binyan');
  @override
  late final GeneratedColumn<String> binyan = GeneratedColumn<String>(
      'binyan', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _russianMeaningMeta =
      const VerificationMeta('russianMeaning');
  @override
  late final GeneratedColumn<String> russianMeaning = GeneratedColumn<String>(
      'russian_meaning', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _grammarNotesRuMeta =
      const VerificationMeta('grammarNotesRu');
  @override
  late final GeneratedColumn<String> grammarNotesRu = GeneratedColumn<String>(
      'grammar_notes_ru', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _conjugationsJsonMeta =
      const VerificationMeta('conjugationsJson');
  @override
  late final GeneratedColumn<String> conjugationsJson = GeneratedColumn<String>(
      'conjugations_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceNameMeta =
      const VerificationMeta('sourceName');
  @override
  late final GeneratedColumn<String> sourceName = GeneratedColumn<String>(
      'source_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _licenseNameMeta =
      const VerificationMeta('licenseName');
  @override
  late final GeneratedColumn<String> licenseName = GeneratedColumn<String>(
      'license_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _attributionTextMeta =
      const VerificationMeta('attributionText');
  @override
  late final GeneratedColumn<String> attributionText = GeneratedColumn<String>(
      'attribution_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        lemmaVocalized,
        lemmaNormalized,
        infinitiveVocalized,
        root,
        binyan,
        russianMeaning,
        grammarNotesRu,
        conjugationsJson,
        sourceName,
        licenseName,
        attributionText
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grammar_verbs';
  @override
  VerificationContext validateIntegrity(Insertable<GrammarVerbRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('lemma_vocalized')) {
      context.handle(
          _lemmaVocalizedMeta,
          lemmaVocalized.isAcceptableOrUnknown(
              data['lemma_vocalized']!, _lemmaVocalizedMeta));
    } else if (isInserting) {
      context.missing(_lemmaVocalizedMeta);
    }
    if (data.containsKey('lemma_normalized')) {
      context.handle(
          _lemmaNormalizedMeta,
          lemmaNormalized.isAcceptableOrUnknown(
              data['lemma_normalized']!, _lemmaNormalizedMeta));
    } else if (isInserting) {
      context.missing(_lemmaNormalizedMeta);
    }
    if (data.containsKey('infinitive_vocalized')) {
      context.handle(
          _infinitiveVocalizedMeta,
          infinitiveVocalized.isAcceptableOrUnknown(
              data['infinitive_vocalized']!, _infinitiveVocalizedMeta));
    }
    if (data.containsKey('root')) {
      context.handle(
          _rootMeta, root.isAcceptableOrUnknown(data['root']!, _rootMeta));
    } else if (isInserting) {
      context.missing(_rootMeta);
    }
    if (data.containsKey('binyan')) {
      context.handle(_binyanMeta,
          binyan.isAcceptableOrUnknown(data['binyan']!, _binyanMeta));
    } else if (isInserting) {
      context.missing(_binyanMeta);
    }
    if (data.containsKey('russian_meaning')) {
      context.handle(
          _russianMeaningMeta,
          russianMeaning.isAcceptableOrUnknown(
              data['russian_meaning']!, _russianMeaningMeta));
    } else if (isInserting) {
      context.missing(_russianMeaningMeta);
    }
    if (data.containsKey('grammar_notes_ru')) {
      context.handle(
          _grammarNotesRuMeta,
          grammarNotesRu.isAcceptableOrUnknown(
              data['grammar_notes_ru']!, _grammarNotesRuMeta));
    } else if (isInserting) {
      context.missing(_grammarNotesRuMeta);
    }
    if (data.containsKey('conjugations_json')) {
      context.handle(
          _conjugationsJsonMeta,
          conjugationsJson.isAcceptableOrUnknown(
              data['conjugations_json']!, _conjugationsJsonMeta));
    } else if (isInserting) {
      context.missing(_conjugationsJsonMeta);
    }
    if (data.containsKey('source_name')) {
      context.handle(
          _sourceNameMeta,
          sourceName.isAcceptableOrUnknown(
              data['source_name']!, _sourceNameMeta));
    } else if (isInserting) {
      context.missing(_sourceNameMeta);
    }
    if (data.containsKey('license_name')) {
      context.handle(
          _licenseNameMeta,
          licenseName.isAcceptableOrUnknown(
              data['license_name']!, _licenseNameMeta));
    } else if (isInserting) {
      context.missing(_licenseNameMeta);
    }
    if (data.containsKey('attribution_text')) {
      context.handle(
          _attributionTextMeta,
          attributionText.isAcceptableOrUnknown(
              data['attribution_text']!, _attributionTextMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GrammarVerbRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GrammarVerbRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      lemmaVocalized: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}lemma_vocalized'])!,
      lemmaNormalized: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}lemma_normalized'])!,
      infinitiveVocalized: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}infinitive_vocalized']),
      root: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}root'])!,
      binyan: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}binyan'])!,
      russianMeaning: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}russian_meaning'])!,
      grammarNotesRu: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}grammar_notes_ru'])!,
      conjugationsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}conjugations_json'])!,
      sourceName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_name'])!,
      licenseName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}license_name'])!,
      attributionText: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}attribution_text']),
    );
  }

  @override
  $GrammarVerbsTable createAlias(String alias) {
    return $GrammarVerbsTable(attachedDatabase, alias);
  }
}

class GrammarVerbRow extends DataClass implements Insertable<GrammarVerbRow> {
  final String id;
  final String lemmaVocalized;
  final String lemmaNormalized;
  final String? infinitiveVocalized;
  final String root;
  final String binyan;
  final String russianMeaning;
  final String grammarNotesRu;
  final String conjugationsJson;
  final String sourceName;
  final String licenseName;
  final String? attributionText;
  const GrammarVerbRow(
      {required this.id,
      required this.lemmaVocalized,
      required this.lemmaNormalized,
      this.infinitiveVocalized,
      required this.root,
      required this.binyan,
      required this.russianMeaning,
      required this.grammarNotesRu,
      required this.conjugationsJson,
      required this.sourceName,
      required this.licenseName,
      this.attributionText});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['lemma_vocalized'] = Variable<String>(lemmaVocalized);
    map['lemma_normalized'] = Variable<String>(lemmaNormalized);
    if (!nullToAbsent || infinitiveVocalized != null) {
      map['infinitive_vocalized'] = Variable<String>(infinitiveVocalized);
    }
    map['root'] = Variable<String>(root);
    map['binyan'] = Variable<String>(binyan);
    map['russian_meaning'] = Variable<String>(russianMeaning);
    map['grammar_notes_ru'] = Variable<String>(grammarNotesRu);
    map['conjugations_json'] = Variable<String>(conjugationsJson);
    map['source_name'] = Variable<String>(sourceName);
    map['license_name'] = Variable<String>(licenseName);
    if (!nullToAbsent || attributionText != null) {
      map['attribution_text'] = Variable<String>(attributionText);
    }
    return map;
  }

  GrammarVerbsCompanion toCompanion(bool nullToAbsent) {
    return GrammarVerbsCompanion(
      id: Value(id),
      lemmaVocalized: Value(lemmaVocalized),
      lemmaNormalized: Value(lemmaNormalized),
      infinitiveVocalized: infinitiveVocalized == null && nullToAbsent
          ? const Value.absent()
          : Value(infinitiveVocalized),
      root: Value(root),
      binyan: Value(binyan),
      russianMeaning: Value(russianMeaning),
      grammarNotesRu: Value(grammarNotesRu),
      conjugationsJson: Value(conjugationsJson),
      sourceName: Value(sourceName),
      licenseName: Value(licenseName),
      attributionText: attributionText == null && nullToAbsent
          ? const Value.absent()
          : Value(attributionText),
    );
  }

  factory GrammarVerbRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GrammarVerbRow(
      id: serializer.fromJson<String>(json['id']),
      lemmaVocalized: serializer.fromJson<String>(json['lemmaVocalized']),
      lemmaNormalized: serializer.fromJson<String>(json['lemmaNormalized']),
      infinitiveVocalized:
          serializer.fromJson<String?>(json['infinitiveVocalized']),
      root: serializer.fromJson<String>(json['root']),
      binyan: serializer.fromJson<String>(json['binyan']),
      russianMeaning: serializer.fromJson<String>(json['russianMeaning']),
      grammarNotesRu: serializer.fromJson<String>(json['grammarNotesRu']),
      conjugationsJson: serializer.fromJson<String>(json['conjugationsJson']),
      sourceName: serializer.fromJson<String>(json['sourceName']),
      licenseName: serializer.fromJson<String>(json['licenseName']),
      attributionText: serializer.fromJson<String?>(json['attributionText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'lemmaVocalized': serializer.toJson<String>(lemmaVocalized),
      'lemmaNormalized': serializer.toJson<String>(lemmaNormalized),
      'infinitiveVocalized': serializer.toJson<String?>(infinitiveVocalized),
      'root': serializer.toJson<String>(root),
      'binyan': serializer.toJson<String>(binyan),
      'russianMeaning': serializer.toJson<String>(russianMeaning),
      'grammarNotesRu': serializer.toJson<String>(grammarNotesRu),
      'conjugationsJson': serializer.toJson<String>(conjugationsJson),
      'sourceName': serializer.toJson<String>(sourceName),
      'licenseName': serializer.toJson<String>(licenseName),
      'attributionText': serializer.toJson<String?>(attributionText),
    };
  }

  GrammarVerbRow copyWith(
          {String? id,
          String? lemmaVocalized,
          String? lemmaNormalized,
          Value<String?> infinitiveVocalized = const Value.absent(),
          String? root,
          String? binyan,
          String? russianMeaning,
          String? grammarNotesRu,
          String? conjugationsJson,
          String? sourceName,
          String? licenseName,
          Value<String?> attributionText = const Value.absent()}) =>
      GrammarVerbRow(
        id: id ?? this.id,
        lemmaVocalized: lemmaVocalized ?? this.lemmaVocalized,
        lemmaNormalized: lemmaNormalized ?? this.lemmaNormalized,
        infinitiveVocalized: infinitiveVocalized.present
            ? infinitiveVocalized.value
            : this.infinitiveVocalized,
        root: root ?? this.root,
        binyan: binyan ?? this.binyan,
        russianMeaning: russianMeaning ?? this.russianMeaning,
        grammarNotesRu: grammarNotesRu ?? this.grammarNotesRu,
        conjugationsJson: conjugationsJson ?? this.conjugationsJson,
        sourceName: sourceName ?? this.sourceName,
        licenseName: licenseName ?? this.licenseName,
        attributionText: attributionText.present
            ? attributionText.value
            : this.attributionText,
      );
  GrammarVerbRow copyWithCompanion(GrammarVerbsCompanion data) {
    return GrammarVerbRow(
      id: data.id.present ? data.id.value : this.id,
      lemmaVocalized: data.lemmaVocalized.present
          ? data.lemmaVocalized.value
          : this.lemmaVocalized,
      lemmaNormalized: data.lemmaNormalized.present
          ? data.lemmaNormalized.value
          : this.lemmaNormalized,
      infinitiveVocalized: data.infinitiveVocalized.present
          ? data.infinitiveVocalized.value
          : this.infinitiveVocalized,
      root: data.root.present ? data.root.value : this.root,
      binyan: data.binyan.present ? data.binyan.value : this.binyan,
      russianMeaning: data.russianMeaning.present
          ? data.russianMeaning.value
          : this.russianMeaning,
      grammarNotesRu: data.grammarNotesRu.present
          ? data.grammarNotesRu.value
          : this.grammarNotesRu,
      conjugationsJson: data.conjugationsJson.present
          ? data.conjugationsJson.value
          : this.conjugationsJson,
      sourceName:
          data.sourceName.present ? data.sourceName.value : this.sourceName,
      licenseName:
          data.licenseName.present ? data.licenseName.value : this.licenseName,
      attributionText: data.attributionText.present
          ? data.attributionText.value
          : this.attributionText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GrammarVerbRow(')
          ..write('id: $id, ')
          ..write('lemmaVocalized: $lemmaVocalized, ')
          ..write('lemmaNormalized: $lemmaNormalized, ')
          ..write('infinitiveVocalized: $infinitiveVocalized, ')
          ..write('root: $root, ')
          ..write('binyan: $binyan, ')
          ..write('russianMeaning: $russianMeaning, ')
          ..write('grammarNotesRu: $grammarNotesRu, ')
          ..write('conjugationsJson: $conjugationsJson, ')
          ..write('sourceName: $sourceName, ')
          ..write('licenseName: $licenseName, ')
          ..write('attributionText: $attributionText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      lemmaVocalized,
      lemmaNormalized,
      infinitiveVocalized,
      root,
      binyan,
      russianMeaning,
      grammarNotesRu,
      conjugationsJson,
      sourceName,
      licenseName,
      attributionText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GrammarVerbRow &&
          other.id == this.id &&
          other.lemmaVocalized == this.lemmaVocalized &&
          other.lemmaNormalized == this.lemmaNormalized &&
          other.infinitiveVocalized == this.infinitiveVocalized &&
          other.root == this.root &&
          other.binyan == this.binyan &&
          other.russianMeaning == this.russianMeaning &&
          other.grammarNotesRu == this.grammarNotesRu &&
          other.conjugationsJson == this.conjugationsJson &&
          other.sourceName == this.sourceName &&
          other.licenseName == this.licenseName &&
          other.attributionText == this.attributionText);
}

class GrammarVerbsCompanion extends UpdateCompanion<GrammarVerbRow> {
  final Value<String> id;
  final Value<String> lemmaVocalized;
  final Value<String> lemmaNormalized;
  final Value<String?> infinitiveVocalized;
  final Value<String> root;
  final Value<String> binyan;
  final Value<String> russianMeaning;
  final Value<String> grammarNotesRu;
  final Value<String> conjugationsJson;
  final Value<String> sourceName;
  final Value<String> licenseName;
  final Value<String?> attributionText;
  final Value<int> rowid;
  const GrammarVerbsCompanion({
    this.id = const Value.absent(),
    this.lemmaVocalized = const Value.absent(),
    this.lemmaNormalized = const Value.absent(),
    this.infinitiveVocalized = const Value.absent(),
    this.root = const Value.absent(),
    this.binyan = const Value.absent(),
    this.russianMeaning = const Value.absent(),
    this.grammarNotesRu = const Value.absent(),
    this.conjugationsJson = const Value.absent(),
    this.sourceName = const Value.absent(),
    this.licenseName = const Value.absent(),
    this.attributionText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GrammarVerbsCompanion.insert({
    required String id,
    required String lemmaVocalized,
    required String lemmaNormalized,
    this.infinitiveVocalized = const Value.absent(),
    required String root,
    required String binyan,
    required String russianMeaning,
    required String grammarNotesRu,
    required String conjugationsJson,
    required String sourceName,
    required String licenseName,
    this.attributionText = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        lemmaVocalized = Value(lemmaVocalized),
        lemmaNormalized = Value(lemmaNormalized),
        root = Value(root),
        binyan = Value(binyan),
        russianMeaning = Value(russianMeaning),
        grammarNotesRu = Value(grammarNotesRu),
        conjugationsJson = Value(conjugationsJson),
        sourceName = Value(sourceName),
        licenseName = Value(licenseName);
  static Insertable<GrammarVerbRow> custom({
    Expression<String>? id,
    Expression<String>? lemmaVocalized,
    Expression<String>? lemmaNormalized,
    Expression<String>? infinitiveVocalized,
    Expression<String>? root,
    Expression<String>? binyan,
    Expression<String>? russianMeaning,
    Expression<String>? grammarNotesRu,
    Expression<String>? conjugationsJson,
    Expression<String>? sourceName,
    Expression<String>? licenseName,
    Expression<String>? attributionText,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lemmaVocalized != null) 'lemma_vocalized': lemmaVocalized,
      if (lemmaNormalized != null) 'lemma_normalized': lemmaNormalized,
      if (infinitiveVocalized != null)
        'infinitive_vocalized': infinitiveVocalized,
      if (root != null) 'root': root,
      if (binyan != null) 'binyan': binyan,
      if (russianMeaning != null) 'russian_meaning': russianMeaning,
      if (grammarNotesRu != null) 'grammar_notes_ru': grammarNotesRu,
      if (conjugationsJson != null) 'conjugations_json': conjugationsJson,
      if (sourceName != null) 'source_name': sourceName,
      if (licenseName != null) 'license_name': licenseName,
      if (attributionText != null) 'attribution_text': attributionText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GrammarVerbsCompanion copyWith(
      {Value<String>? id,
      Value<String>? lemmaVocalized,
      Value<String>? lemmaNormalized,
      Value<String?>? infinitiveVocalized,
      Value<String>? root,
      Value<String>? binyan,
      Value<String>? russianMeaning,
      Value<String>? grammarNotesRu,
      Value<String>? conjugationsJson,
      Value<String>? sourceName,
      Value<String>? licenseName,
      Value<String?>? attributionText,
      Value<int>? rowid}) {
    return GrammarVerbsCompanion(
      id: id ?? this.id,
      lemmaVocalized: lemmaVocalized ?? this.lemmaVocalized,
      lemmaNormalized: lemmaNormalized ?? this.lemmaNormalized,
      infinitiveVocalized: infinitiveVocalized ?? this.infinitiveVocalized,
      root: root ?? this.root,
      binyan: binyan ?? this.binyan,
      russianMeaning: russianMeaning ?? this.russianMeaning,
      grammarNotesRu: grammarNotesRu ?? this.grammarNotesRu,
      conjugationsJson: conjugationsJson ?? this.conjugationsJson,
      sourceName: sourceName ?? this.sourceName,
      licenseName: licenseName ?? this.licenseName,
      attributionText: attributionText ?? this.attributionText,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (lemmaVocalized.present) {
      map['lemma_vocalized'] = Variable<String>(lemmaVocalized.value);
    }
    if (lemmaNormalized.present) {
      map['lemma_normalized'] = Variable<String>(lemmaNormalized.value);
    }
    if (infinitiveVocalized.present) {
      map['infinitive_vocalized'] = Variable<String>(infinitiveVocalized.value);
    }
    if (root.present) {
      map['root'] = Variable<String>(root.value);
    }
    if (binyan.present) {
      map['binyan'] = Variable<String>(binyan.value);
    }
    if (russianMeaning.present) {
      map['russian_meaning'] = Variable<String>(russianMeaning.value);
    }
    if (grammarNotesRu.present) {
      map['grammar_notes_ru'] = Variable<String>(grammarNotesRu.value);
    }
    if (conjugationsJson.present) {
      map['conjugations_json'] = Variable<String>(conjugationsJson.value);
    }
    if (sourceName.present) {
      map['source_name'] = Variable<String>(sourceName.value);
    }
    if (licenseName.present) {
      map['license_name'] = Variable<String>(licenseName.value);
    }
    if (attributionText.present) {
      map['attribution_text'] = Variable<String>(attributionText.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GrammarVerbsCompanion(')
          ..write('id: $id, ')
          ..write('lemmaVocalized: $lemmaVocalized, ')
          ..write('lemmaNormalized: $lemmaNormalized, ')
          ..write('infinitiveVocalized: $infinitiveVocalized, ')
          ..write('root: $root, ')
          ..write('binyan: $binyan, ')
          ..write('russianMeaning: $russianMeaning, ')
          ..write('grammarNotesRu: $grammarNotesRu, ')
          ..write('conjugationsJson: $conjugationsJson, ')
          ..write('sourceName: $sourceName, ')
          ..write('licenseName: $licenseName, ')
          ..write('attributionText: $attributionText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GrammarPracticeLogsTable extends GrammarPracticeLogs
    with TableInfo<$GrammarPracticeLogsTable, GrammarPracticeLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GrammarPracticeLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _verbIdMeta = const VerificationMeta('verbId');
  @override
  late final GeneratedColumn<String> verbId = GeneratedColumn<String>(
      'verb_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tenseMeta = const VerificationMeta('tense');
  @override
  late final GeneratedColumn<String> tense = GeneratedColumn<String>(
      'tense', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _personMeta = const VerificationMeta('person');
  @override
  late final GeneratedColumn<String> person = GeneratedColumn<String>(
      'person', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isCorrectMeta =
      const VerificationMeta('isCorrect');
  @override
  late final GeneratedColumn<bool> isCorrect = GeneratedColumn<bool>(
      'is_correct', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_correct" IN (0, 1))'));
  static const VerificationMeta _practicedAtMeta =
      const VerificationMeta('practicedAt');
  @override
  late final GeneratedColumn<DateTime> practicedAt = GeneratedColumn<DateTime>(
      'practiced_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, verbId, tense, person, isCorrect, practicedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grammar_practice_logs';
  @override
  VerificationContext validateIntegrity(
      Insertable<GrammarPracticeLogRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('verb_id')) {
      context.handle(_verbIdMeta,
          verbId.isAcceptableOrUnknown(data['verb_id']!, _verbIdMeta));
    } else if (isInserting) {
      context.missing(_verbIdMeta);
    }
    if (data.containsKey('tense')) {
      context.handle(
          _tenseMeta, tense.isAcceptableOrUnknown(data['tense']!, _tenseMeta));
    } else if (isInserting) {
      context.missing(_tenseMeta);
    }
    if (data.containsKey('person')) {
      context.handle(_personMeta,
          person.isAcceptableOrUnknown(data['person']!, _personMeta));
    } else if (isInserting) {
      context.missing(_personMeta);
    }
    if (data.containsKey('is_correct')) {
      context.handle(_isCorrectMeta,
          isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta));
    } else if (isInserting) {
      context.missing(_isCorrectMeta);
    }
    if (data.containsKey('practiced_at')) {
      context.handle(
          _practicedAtMeta,
          practicedAt.isAcceptableOrUnknown(
              data['practiced_at']!, _practicedAtMeta));
    } else if (isInserting) {
      context.missing(_practicedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GrammarPracticeLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GrammarPracticeLogRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      verbId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}verb_id'])!,
      tense: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tense'])!,
      person: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}person'])!,
      isCorrect: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_correct'])!,
      practicedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}practiced_at'])!,
    );
  }

  @override
  $GrammarPracticeLogsTable createAlias(String alias) {
    return $GrammarPracticeLogsTable(attachedDatabase, alias);
  }
}

class GrammarPracticeLogRow extends DataClass
    implements Insertable<GrammarPracticeLogRow> {
  final int id;
  final String verbId;
  final String tense;
  final String person;
  final bool isCorrect;
  final DateTime practicedAt;
  const GrammarPracticeLogRow(
      {required this.id,
      required this.verbId,
      required this.tense,
      required this.person,
      required this.isCorrect,
      required this.practicedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['verb_id'] = Variable<String>(verbId);
    map['tense'] = Variable<String>(tense);
    map['person'] = Variable<String>(person);
    map['is_correct'] = Variable<bool>(isCorrect);
    map['practiced_at'] = Variable<DateTime>(practicedAt);
    return map;
  }

  GrammarPracticeLogsCompanion toCompanion(bool nullToAbsent) {
    return GrammarPracticeLogsCompanion(
      id: Value(id),
      verbId: Value(verbId),
      tense: Value(tense),
      person: Value(person),
      isCorrect: Value(isCorrect),
      practicedAt: Value(practicedAt),
    );
  }

  factory GrammarPracticeLogRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GrammarPracticeLogRow(
      id: serializer.fromJson<int>(json['id']),
      verbId: serializer.fromJson<String>(json['verbId']),
      tense: serializer.fromJson<String>(json['tense']),
      person: serializer.fromJson<String>(json['person']),
      isCorrect: serializer.fromJson<bool>(json['isCorrect']),
      practicedAt: serializer.fromJson<DateTime>(json['practicedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'verbId': serializer.toJson<String>(verbId),
      'tense': serializer.toJson<String>(tense),
      'person': serializer.toJson<String>(person),
      'isCorrect': serializer.toJson<bool>(isCorrect),
      'practicedAt': serializer.toJson<DateTime>(practicedAt),
    };
  }

  GrammarPracticeLogRow copyWith(
          {int? id,
          String? verbId,
          String? tense,
          String? person,
          bool? isCorrect,
          DateTime? practicedAt}) =>
      GrammarPracticeLogRow(
        id: id ?? this.id,
        verbId: verbId ?? this.verbId,
        tense: tense ?? this.tense,
        person: person ?? this.person,
        isCorrect: isCorrect ?? this.isCorrect,
        practicedAt: practicedAt ?? this.practicedAt,
      );
  GrammarPracticeLogRow copyWithCompanion(GrammarPracticeLogsCompanion data) {
    return GrammarPracticeLogRow(
      id: data.id.present ? data.id.value : this.id,
      verbId: data.verbId.present ? data.verbId.value : this.verbId,
      tense: data.tense.present ? data.tense.value : this.tense,
      person: data.person.present ? data.person.value : this.person,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
      practicedAt:
          data.practicedAt.present ? data.practicedAt.value : this.practicedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GrammarPracticeLogRow(')
          ..write('id: $id, ')
          ..write('verbId: $verbId, ')
          ..write('tense: $tense, ')
          ..write('person: $person, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('practicedAt: $practicedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, verbId, tense, person, isCorrect, practicedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GrammarPracticeLogRow &&
          other.id == this.id &&
          other.verbId == this.verbId &&
          other.tense == this.tense &&
          other.person == this.person &&
          other.isCorrect == this.isCorrect &&
          other.practicedAt == this.practicedAt);
}

class GrammarPracticeLogsCompanion
    extends UpdateCompanion<GrammarPracticeLogRow> {
  final Value<int> id;
  final Value<String> verbId;
  final Value<String> tense;
  final Value<String> person;
  final Value<bool> isCorrect;
  final Value<DateTime> practicedAt;
  const GrammarPracticeLogsCompanion({
    this.id = const Value.absent(),
    this.verbId = const Value.absent(),
    this.tense = const Value.absent(),
    this.person = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.practicedAt = const Value.absent(),
  });
  GrammarPracticeLogsCompanion.insert({
    this.id = const Value.absent(),
    required String verbId,
    required String tense,
    required String person,
    required bool isCorrect,
    required DateTime practicedAt,
  })  : verbId = Value(verbId),
        tense = Value(tense),
        person = Value(person),
        isCorrect = Value(isCorrect),
        practicedAt = Value(practicedAt);
  static Insertable<GrammarPracticeLogRow> custom({
    Expression<int>? id,
    Expression<String>? verbId,
    Expression<String>? tense,
    Expression<String>? person,
    Expression<bool>? isCorrect,
    Expression<DateTime>? practicedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (verbId != null) 'verb_id': verbId,
      if (tense != null) 'tense': tense,
      if (person != null) 'person': person,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (practicedAt != null) 'practiced_at': practicedAt,
    });
  }

  GrammarPracticeLogsCompanion copyWith(
      {Value<int>? id,
      Value<String>? verbId,
      Value<String>? tense,
      Value<String>? person,
      Value<bool>? isCorrect,
      Value<DateTime>? practicedAt}) {
    return GrammarPracticeLogsCompanion(
      id: id ?? this.id,
      verbId: verbId ?? this.verbId,
      tense: tense ?? this.tense,
      person: person ?? this.person,
      isCorrect: isCorrect ?? this.isCorrect,
      practicedAt: practicedAt ?? this.practicedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (verbId.present) {
      map['verb_id'] = Variable<String>(verbId.value);
    }
    if (tense.present) {
      map['tense'] = Variable<String>(tense.value);
    }
    if (person.present) {
      map['person'] = Variable<String>(person.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<bool>(isCorrect.value);
    }
    if (practicedAt.present) {
      map['practiced_at'] = Variable<DateTime>(practicedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GrammarPracticeLogsCompanion(')
          ..write('id: $id, ')
          ..write('verbId: $verbId, ')
          ..write('tense: $tense, ')
          ..write('person: $person, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('practicedAt: $practicedAt')
          ..write(')'))
        .toString();
  }
}

class $ListeningExercisesTable extends ListeningExercises
    with TableInfo<$ListeningExercisesTable, ListeningExerciseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ListeningExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _transcriptVocalizedMeta =
      const VerificationMeta('transcriptVocalized');
  @override
  late final GeneratedColumn<String> transcriptVocalized =
      GeneratedColumn<String>('transcript_vocalized', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _transcriptNormalizedMeta =
      const VerificationMeta('transcriptNormalized');
  @override
  late final GeneratedColumn<String> transcriptNormalized =
      GeneratedColumn<String>('transcript_normalized', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _russianTranslationMeta =
      const VerificationMeta('russianTranslation');
  @override
  late final GeneratedColumn<String> russianTranslation =
      GeneratedColumn<String>('russian_translation', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _audioUrlMeta =
      const VerificationMeta('audioUrl');
  @override
  late final GeneratedColumn<String> audioUrl = GeneratedColumn<String>(
      'audio_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _difficultyMeta =
      const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
      'difficulty', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('beginner'));
  static const VerificationMeta _focusWordsJsonMeta =
      const VerificationMeta('focusWordsJson');
  @override
  late final GeneratedColumn<String> focusWordsJson = GeneratedColumn<String>(
      'focus_words_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceNameMeta =
      const VerificationMeta('sourceName');
  @override
  late final GeneratedColumn<String> sourceName = GeneratedColumn<String>(
      'source_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _licenseNameMeta =
      const VerificationMeta('licenseName');
  @override
  late final GeneratedColumn<String> licenseName = GeneratedColumn<String>(
      'license_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _attributionTextMeta =
      const VerificationMeta('attributionText');
  @override
  late final GeneratedColumn<String> attributionText = GeneratedColumn<String>(
      'attribution_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        transcriptVocalized,
        transcriptNormalized,
        russianTranslation,
        audioUrl,
        difficulty,
        focusWordsJson,
        sourceName,
        licenseName,
        attributionText
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'listening_exercises';
  @override
  VerificationContext validateIntegrity(
      Insertable<ListeningExerciseRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transcript_vocalized')) {
      context.handle(
          _transcriptVocalizedMeta,
          transcriptVocalized.isAcceptableOrUnknown(
              data['transcript_vocalized']!, _transcriptVocalizedMeta));
    } else if (isInserting) {
      context.missing(_transcriptVocalizedMeta);
    }
    if (data.containsKey('transcript_normalized')) {
      context.handle(
          _transcriptNormalizedMeta,
          transcriptNormalized.isAcceptableOrUnknown(
              data['transcript_normalized']!, _transcriptNormalizedMeta));
    } else if (isInserting) {
      context.missing(_transcriptNormalizedMeta);
    }
    if (data.containsKey('russian_translation')) {
      context.handle(
          _russianTranslationMeta,
          russianTranslation.isAcceptableOrUnknown(
              data['russian_translation']!, _russianTranslationMeta));
    } else if (isInserting) {
      context.missing(_russianTranslationMeta);
    }
    if (data.containsKey('audio_url')) {
      context.handle(_audioUrlMeta,
          audioUrl.isAcceptableOrUnknown(data['audio_url']!, _audioUrlMeta));
    }
    if (data.containsKey('difficulty')) {
      context.handle(
          _difficultyMeta,
          difficulty.isAcceptableOrUnknown(
              data['difficulty']!, _difficultyMeta));
    }
    if (data.containsKey('focus_words_json')) {
      context.handle(
          _focusWordsJsonMeta,
          focusWordsJson.isAcceptableOrUnknown(
              data['focus_words_json']!, _focusWordsJsonMeta));
    } else if (isInserting) {
      context.missing(_focusWordsJsonMeta);
    }
    if (data.containsKey('source_name')) {
      context.handle(
          _sourceNameMeta,
          sourceName.isAcceptableOrUnknown(
              data['source_name']!, _sourceNameMeta));
    } else if (isInserting) {
      context.missing(_sourceNameMeta);
    }
    if (data.containsKey('license_name')) {
      context.handle(
          _licenseNameMeta,
          licenseName.isAcceptableOrUnknown(
              data['license_name']!, _licenseNameMeta));
    } else if (isInserting) {
      context.missing(_licenseNameMeta);
    }
    if (data.containsKey('attribution_text')) {
      context.handle(
          _attributionTextMeta,
          attributionText.isAcceptableOrUnknown(
              data['attribution_text']!, _attributionTextMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ListeningExerciseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ListeningExerciseRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      transcriptVocalized: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}transcript_vocalized'])!,
      transcriptNormalized: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}transcript_normalized'])!,
      russianTranslation: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}russian_translation'])!,
      audioUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}audio_url']),
      difficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}difficulty'])!,
      focusWordsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}focus_words_json'])!,
      sourceName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_name'])!,
      licenseName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}license_name'])!,
      attributionText: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}attribution_text']),
    );
  }

  @override
  $ListeningExercisesTable createAlias(String alias) {
    return $ListeningExercisesTable(attachedDatabase, alias);
  }
}

class ListeningExerciseRow extends DataClass
    implements Insertable<ListeningExerciseRow> {
  final String id;
  final String transcriptVocalized;
  final String transcriptNormalized;
  final String russianTranslation;
  final String? audioUrl;
  final String difficulty;
  final String focusWordsJson;
  final String sourceName;
  final String licenseName;
  final String? attributionText;
  const ListeningExerciseRow(
      {required this.id,
      required this.transcriptVocalized,
      required this.transcriptNormalized,
      required this.russianTranslation,
      this.audioUrl,
      required this.difficulty,
      required this.focusWordsJson,
      required this.sourceName,
      required this.licenseName,
      this.attributionText});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transcript_vocalized'] = Variable<String>(transcriptVocalized);
    map['transcript_normalized'] = Variable<String>(transcriptNormalized);
    map['russian_translation'] = Variable<String>(russianTranslation);
    if (!nullToAbsent || audioUrl != null) {
      map['audio_url'] = Variable<String>(audioUrl);
    }
    map['difficulty'] = Variable<String>(difficulty);
    map['focus_words_json'] = Variable<String>(focusWordsJson);
    map['source_name'] = Variable<String>(sourceName);
    map['license_name'] = Variable<String>(licenseName);
    if (!nullToAbsent || attributionText != null) {
      map['attribution_text'] = Variable<String>(attributionText);
    }
    return map;
  }

  ListeningExercisesCompanion toCompanion(bool nullToAbsent) {
    return ListeningExercisesCompanion(
      id: Value(id),
      transcriptVocalized: Value(transcriptVocalized),
      transcriptNormalized: Value(transcriptNormalized),
      russianTranslation: Value(russianTranslation),
      audioUrl: audioUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(audioUrl),
      difficulty: Value(difficulty),
      focusWordsJson: Value(focusWordsJson),
      sourceName: Value(sourceName),
      licenseName: Value(licenseName),
      attributionText: attributionText == null && nullToAbsent
          ? const Value.absent()
          : Value(attributionText),
    );
  }

  factory ListeningExerciseRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ListeningExerciseRow(
      id: serializer.fromJson<String>(json['id']),
      transcriptVocalized:
          serializer.fromJson<String>(json['transcriptVocalized']),
      transcriptNormalized:
          serializer.fromJson<String>(json['transcriptNormalized']),
      russianTranslation:
          serializer.fromJson<String>(json['russianTranslation']),
      audioUrl: serializer.fromJson<String?>(json['audioUrl']),
      difficulty: serializer.fromJson<String>(json['difficulty']),
      focusWordsJson: serializer.fromJson<String>(json['focusWordsJson']),
      sourceName: serializer.fromJson<String>(json['sourceName']),
      licenseName: serializer.fromJson<String>(json['licenseName']),
      attributionText: serializer.fromJson<String?>(json['attributionText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transcriptVocalized': serializer.toJson<String>(transcriptVocalized),
      'transcriptNormalized': serializer.toJson<String>(transcriptNormalized),
      'russianTranslation': serializer.toJson<String>(russianTranslation),
      'audioUrl': serializer.toJson<String?>(audioUrl),
      'difficulty': serializer.toJson<String>(difficulty),
      'focusWordsJson': serializer.toJson<String>(focusWordsJson),
      'sourceName': serializer.toJson<String>(sourceName),
      'licenseName': serializer.toJson<String>(licenseName),
      'attributionText': serializer.toJson<String?>(attributionText),
    };
  }

  ListeningExerciseRow copyWith(
          {String? id,
          String? transcriptVocalized,
          String? transcriptNormalized,
          String? russianTranslation,
          Value<String?> audioUrl = const Value.absent(),
          String? difficulty,
          String? focusWordsJson,
          String? sourceName,
          String? licenseName,
          Value<String?> attributionText = const Value.absent()}) =>
      ListeningExerciseRow(
        id: id ?? this.id,
        transcriptVocalized: transcriptVocalized ?? this.transcriptVocalized,
        transcriptNormalized: transcriptNormalized ?? this.transcriptNormalized,
        russianTranslation: russianTranslation ?? this.russianTranslation,
        audioUrl: audioUrl.present ? audioUrl.value : this.audioUrl,
        difficulty: difficulty ?? this.difficulty,
        focusWordsJson: focusWordsJson ?? this.focusWordsJson,
        sourceName: sourceName ?? this.sourceName,
        licenseName: licenseName ?? this.licenseName,
        attributionText: attributionText.present
            ? attributionText.value
            : this.attributionText,
      );
  ListeningExerciseRow copyWithCompanion(ListeningExercisesCompanion data) {
    return ListeningExerciseRow(
      id: data.id.present ? data.id.value : this.id,
      transcriptVocalized: data.transcriptVocalized.present
          ? data.transcriptVocalized.value
          : this.transcriptVocalized,
      transcriptNormalized: data.transcriptNormalized.present
          ? data.transcriptNormalized.value
          : this.transcriptNormalized,
      russianTranslation: data.russianTranslation.present
          ? data.russianTranslation.value
          : this.russianTranslation,
      audioUrl: data.audioUrl.present ? data.audioUrl.value : this.audioUrl,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      focusWordsJson: data.focusWordsJson.present
          ? data.focusWordsJson.value
          : this.focusWordsJson,
      sourceName:
          data.sourceName.present ? data.sourceName.value : this.sourceName,
      licenseName:
          data.licenseName.present ? data.licenseName.value : this.licenseName,
      attributionText: data.attributionText.present
          ? data.attributionText.value
          : this.attributionText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ListeningExerciseRow(')
          ..write('id: $id, ')
          ..write('transcriptVocalized: $transcriptVocalized, ')
          ..write('transcriptNormalized: $transcriptNormalized, ')
          ..write('russianTranslation: $russianTranslation, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('difficulty: $difficulty, ')
          ..write('focusWordsJson: $focusWordsJson, ')
          ..write('sourceName: $sourceName, ')
          ..write('licenseName: $licenseName, ')
          ..write('attributionText: $attributionText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      transcriptVocalized,
      transcriptNormalized,
      russianTranslation,
      audioUrl,
      difficulty,
      focusWordsJson,
      sourceName,
      licenseName,
      attributionText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListeningExerciseRow &&
          other.id == this.id &&
          other.transcriptVocalized == this.transcriptVocalized &&
          other.transcriptNormalized == this.transcriptNormalized &&
          other.russianTranslation == this.russianTranslation &&
          other.audioUrl == this.audioUrl &&
          other.difficulty == this.difficulty &&
          other.focusWordsJson == this.focusWordsJson &&
          other.sourceName == this.sourceName &&
          other.licenseName == this.licenseName &&
          other.attributionText == this.attributionText);
}

class ListeningExercisesCompanion
    extends UpdateCompanion<ListeningExerciseRow> {
  final Value<String> id;
  final Value<String> transcriptVocalized;
  final Value<String> transcriptNormalized;
  final Value<String> russianTranslation;
  final Value<String?> audioUrl;
  final Value<String> difficulty;
  final Value<String> focusWordsJson;
  final Value<String> sourceName;
  final Value<String> licenseName;
  final Value<String?> attributionText;
  final Value<int> rowid;
  const ListeningExercisesCompanion({
    this.id = const Value.absent(),
    this.transcriptVocalized = const Value.absent(),
    this.transcriptNormalized = const Value.absent(),
    this.russianTranslation = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.focusWordsJson = const Value.absent(),
    this.sourceName = const Value.absent(),
    this.licenseName = const Value.absent(),
    this.attributionText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ListeningExercisesCompanion.insert({
    required String id,
    required String transcriptVocalized,
    required String transcriptNormalized,
    required String russianTranslation,
    this.audioUrl = const Value.absent(),
    this.difficulty = const Value.absent(),
    required String focusWordsJson,
    required String sourceName,
    required String licenseName,
    this.attributionText = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        transcriptVocalized = Value(transcriptVocalized),
        transcriptNormalized = Value(transcriptNormalized),
        russianTranslation = Value(russianTranslation),
        focusWordsJson = Value(focusWordsJson),
        sourceName = Value(sourceName),
        licenseName = Value(licenseName);
  static Insertable<ListeningExerciseRow> custom({
    Expression<String>? id,
    Expression<String>? transcriptVocalized,
    Expression<String>? transcriptNormalized,
    Expression<String>? russianTranslation,
    Expression<String>? audioUrl,
    Expression<String>? difficulty,
    Expression<String>? focusWordsJson,
    Expression<String>? sourceName,
    Expression<String>? licenseName,
    Expression<String>? attributionText,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transcriptVocalized != null)
        'transcript_vocalized': transcriptVocalized,
      if (transcriptNormalized != null)
        'transcript_normalized': transcriptNormalized,
      if (russianTranslation != null) 'russian_translation': russianTranslation,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (difficulty != null) 'difficulty': difficulty,
      if (focusWordsJson != null) 'focus_words_json': focusWordsJson,
      if (sourceName != null) 'source_name': sourceName,
      if (licenseName != null) 'license_name': licenseName,
      if (attributionText != null) 'attribution_text': attributionText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ListeningExercisesCompanion copyWith(
      {Value<String>? id,
      Value<String>? transcriptVocalized,
      Value<String>? transcriptNormalized,
      Value<String>? russianTranslation,
      Value<String?>? audioUrl,
      Value<String>? difficulty,
      Value<String>? focusWordsJson,
      Value<String>? sourceName,
      Value<String>? licenseName,
      Value<String?>? attributionText,
      Value<int>? rowid}) {
    return ListeningExercisesCompanion(
      id: id ?? this.id,
      transcriptVocalized: transcriptVocalized ?? this.transcriptVocalized,
      transcriptNormalized: transcriptNormalized ?? this.transcriptNormalized,
      russianTranslation: russianTranslation ?? this.russianTranslation,
      audioUrl: audioUrl ?? this.audioUrl,
      difficulty: difficulty ?? this.difficulty,
      focusWordsJson: focusWordsJson ?? this.focusWordsJson,
      sourceName: sourceName ?? this.sourceName,
      licenseName: licenseName ?? this.licenseName,
      attributionText: attributionText ?? this.attributionText,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transcriptVocalized.present) {
      map['transcript_vocalized'] = Variable<String>(transcriptVocalized.value);
    }
    if (transcriptNormalized.present) {
      map['transcript_normalized'] =
          Variable<String>(transcriptNormalized.value);
    }
    if (russianTranslation.present) {
      map['russian_translation'] = Variable<String>(russianTranslation.value);
    }
    if (audioUrl.present) {
      map['audio_url'] = Variable<String>(audioUrl.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (focusWordsJson.present) {
      map['focus_words_json'] = Variable<String>(focusWordsJson.value);
    }
    if (sourceName.present) {
      map['source_name'] = Variable<String>(sourceName.value);
    }
    if (licenseName.present) {
      map['license_name'] = Variable<String>(licenseName.value);
    }
    if (attributionText.present) {
      map['attribution_text'] = Variable<String>(attributionText.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ListeningExercisesCompanion(')
          ..write('id: $id, ')
          ..write('transcriptVocalized: $transcriptVocalized, ')
          ..write('transcriptNormalized: $transcriptNormalized, ')
          ..write('russianTranslation: $russianTranslation, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('difficulty: $difficulty, ')
          ..write('focusWordsJson: $focusWordsJson, ')
          ..write('sourceName: $sourceName, ')
          ..write('licenseName: $licenseName, ')
          ..write('attributionText: $attributionText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ListeningAttemptLogsTable extends ListeningAttemptLogs
    with TableInfo<$ListeningAttemptLogsTable, ListeningAttemptLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ListeningAttemptLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _exerciseIdMeta =
      const VerificationMeta('exerciseId');
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
      'exercise_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _wordAccuracyMeta =
      const VerificationMeta('wordAccuracy');
  @override
  late final GeneratedColumn<double> wordAccuracy = GeneratedColumn<double>(
      'word_accuracy', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _isExactMatchMeta =
      const VerificationMeta('isExactMatch');
  @override
  late final GeneratedColumn<bool> isExactMatch = GeneratedColumn<bool>(
      'is_exact_match', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_exact_match" IN (0, 1))'));
  static const VerificationMeta _attemptedAtMeta =
      const VerificationMeta('attemptedAt');
  @override
  late final GeneratedColumn<DateTime> attemptedAt = GeneratedColumn<DateTime>(
      'attempted_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, exerciseId, wordAccuracy, isExactMatch, attemptedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'listening_attempt_logs';
  @override
  VerificationContext validateIntegrity(
      Insertable<ListeningAttemptLogRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
          _exerciseIdMeta,
          exerciseId.isAcceptableOrUnknown(
              data['exercise_id']!, _exerciseIdMeta));
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('word_accuracy')) {
      context.handle(
          _wordAccuracyMeta,
          wordAccuracy.isAcceptableOrUnknown(
              data['word_accuracy']!, _wordAccuracyMeta));
    } else if (isInserting) {
      context.missing(_wordAccuracyMeta);
    }
    if (data.containsKey('is_exact_match')) {
      context.handle(
          _isExactMatchMeta,
          isExactMatch.isAcceptableOrUnknown(
              data['is_exact_match']!, _isExactMatchMeta));
    } else if (isInserting) {
      context.missing(_isExactMatchMeta);
    }
    if (data.containsKey('attempted_at')) {
      context.handle(
          _attemptedAtMeta,
          attemptedAt.isAcceptableOrUnknown(
              data['attempted_at']!, _attemptedAtMeta));
    } else if (isInserting) {
      context.missing(_attemptedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ListeningAttemptLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ListeningAttemptLogRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      exerciseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}exercise_id'])!,
      wordAccuracy: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}word_accuracy'])!,
      isExactMatch: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_exact_match'])!,
      attemptedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}attempted_at'])!,
    );
  }

  @override
  $ListeningAttemptLogsTable createAlias(String alias) {
    return $ListeningAttemptLogsTable(attachedDatabase, alias);
  }
}

class ListeningAttemptLogRow extends DataClass
    implements Insertable<ListeningAttemptLogRow> {
  final int id;
  final String exerciseId;
  final double wordAccuracy;
  final bool isExactMatch;
  final DateTime attemptedAt;
  const ListeningAttemptLogRow(
      {required this.id,
      required this.exerciseId,
      required this.wordAccuracy,
      required this.isExactMatch,
      required this.attemptedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['word_accuracy'] = Variable<double>(wordAccuracy);
    map['is_exact_match'] = Variable<bool>(isExactMatch);
    map['attempted_at'] = Variable<DateTime>(attemptedAt);
    return map;
  }

  ListeningAttemptLogsCompanion toCompanion(bool nullToAbsent) {
    return ListeningAttemptLogsCompanion(
      id: Value(id),
      exerciseId: Value(exerciseId),
      wordAccuracy: Value(wordAccuracy),
      isExactMatch: Value(isExactMatch),
      attemptedAt: Value(attemptedAt),
    );
  }

  factory ListeningAttemptLogRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ListeningAttemptLogRow(
      id: serializer.fromJson<int>(json['id']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      wordAccuracy: serializer.fromJson<double>(json['wordAccuracy']),
      isExactMatch: serializer.fromJson<bool>(json['isExactMatch']),
      attemptedAt: serializer.fromJson<DateTime>(json['attemptedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'wordAccuracy': serializer.toJson<double>(wordAccuracy),
      'isExactMatch': serializer.toJson<bool>(isExactMatch),
      'attemptedAt': serializer.toJson<DateTime>(attemptedAt),
    };
  }

  ListeningAttemptLogRow copyWith(
          {int? id,
          String? exerciseId,
          double? wordAccuracy,
          bool? isExactMatch,
          DateTime? attemptedAt}) =>
      ListeningAttemptLogRow(
        id: id ?? this.id,
        exerciseId: exerciseId ?? this.exerciseId,
        wordAccuracy: wordAccuracy ?? this.wordAccuracy,
        isExactMatch: isExactMatch ?? this.isExactMatch,
        attemptedAt: attemptedAt ?? this.attemptedAt,
      );
  ListeningAttemptLogRow copyWithCompanion(ListeningAttemptLogsCompanion data) {
    return ListeningAttemptLogRow(
      id: data.id.present ? data.id.value : this.id,
      exerciseId:
          data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      wordAccuracy: data.wordAccuracy.present
          ? data.wordAccuracy.value
          : this.wordAccuracy,
      isExactMatch: data.isExactMatch.present
          ? data.isExactMatch.value
          : this.isExactMatch,
      attemptedAt:
          data.attemptedAt.present ? data.attemptedAt.value : this.attemptedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ListeningAttemptLogRow(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('wordAccuracy: $wordAccuracy, ')
          ..write('isExactMatch: $isExactMatch, ')
          ..write('attemptedAt: $attemptedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, exerciseId, wordAccuracy, isExactMatch, attemptedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListeningAttemptLogRow &&
          other.id == this.id &&
          other.exerciseId == this.exerciseId &&
          other.wordAccuracy == this.wordAccuracy &&
          other.isExactMatch == this.isExactMatch &&
          other.attemptedAt == this.attemptedAt);
}

class ListeningAttemptLogsCompanion
    extends UpdateCompanion<ListeningAttemptLogRow> {
  final Value<int> id;
  final Value<String> exerciseId;
  final Value<double> wordAccuracy;
  final Value<bool> isExactMatch;
  final Value<DateTime> attemptedAt;
  const ListeningAttemptLogsCompanion({
    this.id = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.wordAccuracy = const Value.absent(),
    this.isExactMatch = const Value.absent(),
    this.attemptedAt = const Value.absent(),
  });
  ListeningAttemptLogsCompanion.insert({
    this.id = const Value.absent(),
    required String exerciseId,
    required double wordAccuracy,
    required bool isExactMatch,
    required DateTime attemptedAt,
  })  : exerciseId = Value(exerciseId),
        wordAccuracy = Value(wordAccuracy),
        isExactMatch = Value(isExactMatch),
        attemptedAt = Value(attemptedAt);
  static Insertable<ListeningAttemptLogRow> custom({
    Expression<int>? id,
    Expression<String>? exerciseId,
    Expression<double>? wordAccuracy,
    Expression<bool>? isExactMatch,
    Expression<DateTime>? attemptedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (wordAccuracy != null) 'word_accuracy': wordAccuracy,
      if (isExactMatch != null) 'is_exact_match': isExactMatch,
      if (attemptedAt != null) 'attempted_at': attemptedAt,
    });
  }

  ListeningAttemptLogsCompanion copyWith(
      {Value<int>? id,
      Value<String>? exerciseId,
      Value<double>? wordAccuracy,
      Value<bool>? isExactMatch,
      Value<DateTime>? attemptedAt}) {
    return ListeningAttemptLogsCompanion(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      wordAccuracy: wordAccuracy ?? this.wordAccuracy,
      isExactMatch: isExactMatch ?? this.isExactMatch,
      attemptedAt: attemptedAt ?? this.attemptedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (wordAccuracy.present) {
      map['word_accuracy'] = Variable<double>(wordAccuracy.value);
    }
    if (isExactMatch.present) {
      map['is_exact_match'] = Variable<bool>(isExactMatch.value);
    }
    if (attemptedAt.present) {
      map['attempted_at'] = Variable<DateTime>(attemptedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ListeningAttemptLogsCompanion(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('wordAccuracy: $wordAccuracy, ')
          ..write('isExactMatch: $isExactMatch, ')
          ..write('attemptedAt: $attemptedAt')
          ..write(')'))
        .toString();
  }
}

class $DictionaryEntriesTable extends DictionaryEntries
    with TableInfo<$DictionaryEntriesTable, DictionaryEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DictionaryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hebrewVocalizedMeta =
      const VerificationMeta('hebrewVocalized');
  @override
  late final GeneratedColumn<String> hebrewVocalized = GeneratedColumn<String>(
      'hebrew_vocalized', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hebrewNormalizedMeta =
      const VerificationMeta('hebrewNormalized');
  @override
  late final GeneratedColumn<String> hebrewNormalized = GeneratedColumn<String>(
      'hebrew_normalized', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _russianTranslationMeta =
      const VerificationMeta('russianTranslation');
  @override
  late final GeneratedColumn<String> russianTranslation =
      GeneratedColumn<String>('russian_translation', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _transliterationMeta =
      const VerificationMeta('transliteration');
  @override
  late final GeneratedColumn<String> transliteration = GeneratedColumn<String>(
      'transliteration', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('noun'));
  static const VerificationMeta _rootMeta = const VerificationMeta('root');
  @override
  late final GeneratedColumn<String> root = GeneratedColumn<String>(
      'root', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _binyanMeta = const VerificationMeta('binyan');
  @override
  late final GeneratedColumn<String> binyan = GeneratedColumn<String>(
      'binyan', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('none'));
  static const VerificationMeta _formsSummaryMeta =
      const VerificationMeta('formsSummary');
  @override
  late final GeneratedColumn<String> formsSummary = GeneratedColumn<String>(
      'forms_summary', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _exampleHebrewVocalizedMeta =
      const VerificationMeta('exampleHebrewVocalized');
  @override
  late final GeneratedColumn<String> exampleHebrewVocalized =
      GeneratedColumn<String>('example_hebrew_vocalized', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _exampleHebrewNormalizedMeta =
      const VerificationMeta('exampleHebrewNormalized');
  @override
  late final GeneratedColumn<String> exampleHebrewNormalized =
      GeneratedColumn<String>('example_hebrew_normalized', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _exampleRussianMeta =
      const VerificationMeta('exampleRussian');
  @override
  late final GeneratedColumn<String> exampleRussian = GeneratedColumn<String>(
      'example_russian', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _audioUrlMeta =
      const VerificationMeta('audioUrl');
  @override
  late final GeneratedColumn<String> audioUrl = GeneratedColumn<String>(
      'audio_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _frequencyRankMeta =
      const VerificationMeta('frequencyRank');
  @override
  late final GeneratedColumn<int> frequencyRank = GeneratedColumn<int>(
      'frequency_rank', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _sourceNameMeta =
      const VerificationMeta('sourceName');
  @override
  late final GeneratedColumn<String> sourceName = GeneratedColumn<String>(
      'source_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _licenseNameMeta =
      const VerificationMeta('licenseName');
  @override
  late final GeneratedColumn<String> licenseName = GeneratedColumn<String>(
      'license_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _attributionTextMeta =
      const VerificationMeta('attributionText');
  @override
  late final GeneratedColumn<String> attributionText = GeneratedColumn<String>(
      'attribution_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isUserAddedMeta =
      const VerificationMeta('isUserAdded');
  @override
  late final GeneratedColumn<bool> isUserAdded = GeneratedColumn<bool>(
      'is_user_added', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_user_added" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        hebrewVocalized,
        hebrewNormalized,
        russianTranslation,
        transliteration,
        category,
        root,
        binyan,
        formsSummary,
        exampleHebrewVocalized,
        exampleHebrewNormalized,
        exampleRussian,
        audioUrl,
        frequencyRank,
        sourceName,
        licenseName,
        attributionText,
        isUserAdded,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dictionary_entries';
  @override
  VerificationContext validateIntegrity(Insertable<DictionaryEntryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('hebrew_vocalized')) {
      context.handle(
          _hebrewVocalizedMeta,
          hebrewVocalized.isAcceptableOrUnknown(
              data['hebrew_vocalized']!, _hebrewVocalizedMeta));
    } else if (isInserting) {
      context.missing(_hebrewVocalizedMeta);
    }
    if (data.containsKey('hebrew_normalized')) {
      context.handle(
          _hebrewNormalizedMeta,
          hebrewNormalized.isAcceptableOrUnknown(
              data['hebrew_normalized']!, _hebrewNormalizedMeta));
    } else if (isInserting) {
      context.missing(_hebrewNormalizedMeta);
    }
    if (data.containsKey('russian_translation')) {
      context.handle(
          _russianTranslationMeta,
          russianTranslation.isAcceptableOrUnknown(
              data['russian_translation']!, _russianTranslationMeta));
    } else if (isInserting) {
      context.missing(_russianTranslationMeta);
    }
    if (data.containsKey('transliteration')) {
      context.handle(
          _transliterationMeta,
          transliteration.isAcceptableOrUnknown(
              data['transliteration']!, _transliterationMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('root')) {
      context.handle(
          _rootMeta, root.isAcceptableOrUnknown(data['root']!, _rootMeta));
    }
    if (data.containsKey('binyan')) {
      context.handle(_binyanMeta,
          binyan.isAcceptableOrUnknown(data['binyan']!, _binyanMeta));
    }
    if (data.containsKey('forms_summary')) {
      context.handle(
          _formsSummaryMeta,
          formsSummary.isAcceptableOrUnknown(
              data['forms_summary']!, _formsSummaryMeta));
    }
    if (data.containsKey('example_hebrew_vocalized')) {
      context.handle(
          _exampleHebrewVocalizedMeta,
          exampleHebrewVocalized.isAcceptableOrUnknown(
              data['example_hebrew_vocalized']!, _exampleHebrewVocalizedMeta));
    }
    if (data.containsKey('example_hebrew_normalized')) {
      context.handle(
          _exampleHebrewNormalizedMeta,
          exampleHebrewNormalized.isAcceptableOrUnknown(
              data['example_hebrew_normalized']!,
              _exampleHebrewNormalizedMeta));
    }
    if (data.containsKey('example_russian')) {
      context.handle(
          _exampleRussianMeta,
          exampleRussian.isAcceptableOrUnknown(
              data['example_russian']!, _exampleRussianMeta));
    }
    if (data.containsKey('audio_url')) {
      context.handle(_audioUrlMeta,
          audioUrl.isAcceptableOrUnknown(data['audio_url']!, _audioUrlMeta));
    }
    if (data.containsKey('frequency_rank')) {
      context.handle(
          _frequencyRankMeta,
          frequencyRank.isAcceptableOrUnknown(
              data['frequency_rank']!, _frequencyRankMeta));
    }
    if (data.containsKey('source_name')) {
      context.handle(
          _sourceNameMeta,
          sourceName.isAcceptableOrUnknown(
              data['source_name']!, _sourceNameMeta));
    } else if (isInserting) {
      context.missing(_sourceNameMeta);
    }
    if (data.containsKey('license_name')) {
      context.handle(
          _licenseNameMeta,
          licenseName.isAcceptableOrUnknown(
              data['license_name']!, _licenseNameMeta));
    } else if (isInserting) {
      context.missing(_licenseNameMeta);
    }
    if (data.containsKey('attribution_text')) {
      context.handle(
          _attributionTextMeta,
          attributionText.isAcceptableOrUnknown(
              data['attribution_text']!, _attributionTextMeta));
    }
    if (data.containsKey('is_user_added')) {
      context.handle(
          _isUserAddedMeta,
          isUserAdded.isAcceptableOrUnknown(
              data['is_user_added']!, _isUserAddedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DictionaryEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DictionaryEntryRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      hebrewVocalized: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}hebrew_vocalized'])!,
      hebrewNormalized: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}hebrew_normalized'])!,
      russianTranslation: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}russian_translation'])!,
      transliteration: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}transliteration']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      root: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}root']),
      binyan: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}binyan'])!,
      formsSummary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}forms_summary']),
      exampleHebrewVocalized: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}example_hebrew_vocalized']),
      exampleHebrewNormalized: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}example_hebrew_normalized']),
      exampleRussian: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}example_russian']),
      audioUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}audio_url']),
      frequencyRank: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}frequency_rank']),
      sourceName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_name'])!,
      licenseName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}license_name'])!,
      attributionText: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}attribution_text']),
      isUserAdded: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_user_added'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $DictionaryEntriesTable createAlias(String alias) {
    return $DictionaryEntriesTable(attachedDatabase, alias);
  }
}

class DictionaryEntryRow extends DataClass
    implements Insertable<DictionaryEntryRow> {
  final String id;
  final String hebrewVocalized;
  final String hebrewNormalized;
  final String russianTranslation;
  final String? transliteration;
  final String category;
  final String? root;
  final String binyan;
  final String? formsSummary;
  final String? exampleHebrewVocalized;
  final String? exampleHebrewNormalized;
  final String? exampleRussian;
  final String? audioUrl;
  final int? frequencyRank;
  final String sourceName;
  final String licenseName;
  final String? attributionText;
  final bool isUserAdded;
  final DateTime createdAt;
  const DictionaryEntryRow(
      {required this.id,
      required this.hebrewVocalized,
      required this.hebrewNormalized,
      required this.russianTranslation,
      this.transliteration,
      required this.category,
      this.root,
      required this.binyan,
      this.formsSummary,
      this.exampleHebrewVocalized,
      this.exampleHebrewNormalized,
      this.exampleRussian,
      this.audioUrl,
      this.frequencyRank,
      required this.sourceName,
      required this.licenseName,
      this.attributionText,
      required this.isUserAdded,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hebrew_vocalized'] = Variable<String>(hebrewVocalized);
    map['hebrew_normalized'] = Variable<String>(hebrewNormalized);
    map['russian_translation'] = Variable<String>(russianTranslation);
    if (!nullToAbsent || transliteration != null) {
      map['transliteration'] = Variable<String>(transliteration);
    }
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || root != null) {
      map['root'] = Variable<String>(root);
    }
    map['binyan'] = Variable<String>(binyan);
    if (!nullToAbsent || formsSummary != null) {
      map['forms_summary'] = Variable<String>(formsSummary);
    }
    if (!nullToAbsent || exampleHebrewVocalized != null) {
      map['example_hebrew_vocalized'] =
          Variable<String>(exampleHebrewVocalized);
    }
    if (!nullToAbsent || exampleHebrewNormalized != null) {
      map['example_hebrew_normalized'] =
          Variable<String>(exampleHebrewNormalized);
    }
    if (!nullToAbsent || exampleRussian != null) {
      map['example_russian'] = Variable<String>(exampleRussian);
    }
    if (!nullToAbsent || audioUrl != null) {
      map['audio_url'] = Variable<String>(audioUrl);
    }
    if (!nullToAbsent || frequencyRank != null) {
      map['frequency_rank'] = Variable<int>(frequencyRank);
    }
    map['source_name'] = Variable<String>(sourceName);
    map['license_name'] = Variable<String>(licenseName);
    if (!nullToAbsent || attributionText != null) {
      map['attribution_text'] = Variable<String>(attributionText);
    }
    map['is_user_added'] = Variable<bool>(isUserAdded);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DictionaryEntriesCompanion toCompanion(bool nullToAbsent) {
    return DictionaryEntriesCompanion(
      id: Value(id),
      hebrewVocalized: Value(hebrewVocalized),
      hebrewNormalized: Value(hebrewNormalized),
      russianTranslation: Value(russianTranslation),
      transliteration: transliteration == null && nullToAbsent
          ? const Value.absent()
          : Value(transliteration),
      category: Value(category),
      root: root == null && nullToAbsent ? const Value.absent() : Value(root),
      binyan: Value(binyan),
      formsSummary: formsSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(formsSummary),
      exampleHebrewVocalized: exampleHebrewVocalized == null && nullToAbsent
          ? const Value.absent()
          : Value(exampleHebrewVocalized),
      exampleHebrewNormalized: exampleHebrewNormalized == null && nullToAbsent
          ? const Value.absent()
          : Value(exampleHebrewNormalized),
      exampleRussian: exampleRussian == null && nullToAbsent
          ? const Value.absent()
          : Value(exampleRussian),
      audioUrl: audioUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(audioUrl),
      frequencyRank: frequencyRank == null && nullToAbsent
          ? const Value.absent()
          : Value(frequencyRank),
      sourceName: Value(sourceName),
      licenseName: Value(licenseName),
      attributionText: attributionText == null && nullToAbsent
          ? const Value.absent()
          : Value(attributionText),
      isUserAdded: Value(isUserAdded),
      createdAt: Value(createdAt),
    );
  }

  factory DictionaryEntryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DictionaryEntryRow(
      id: serializer.fromJson<String>(json['id']),
      hebrewVocalized: serializer.fromJson<String>(json['hebrewVocalized']),
      hebrewNormalized: serializer.fromJson<String>(json['hebrewNormalized']),
      russianTranslation:
          serializer.fromJson<String>(json['russianTranslation']),
      transliteration: serializer.fromJson<String?>(json['transliteration']),
      category: serializer.fromJson<String>(json['category']),
      root: serializer.fromJson<String?>(json['root']),
      binyan: serializer.fromJson<String>(json['binyan']),
      formsSummary: serializer.fromJson<String?>(json['formsSummary']),
      exampleHebrewVocalized:
          serializer.fromJson<String?>(json['exampleHebrewVocalized']),
      exampleHebrewNormalized:
          serializer.fromJson<String?>(json['exampleHebrewNormalized']),
      exampleRussian: serializer.fromJson<String?>(json['exampleRussian']),
      audioUrl: serializer.fromJson<String?>(json['audioUrl']),
      frequencyRank: serializer.fromJson<int?>(json['frequencyRank']),
      sourceName: serializer.fromJson<String>(json['sourceName']),
      licenseName: serializer.fromJson<String>(json['licenseName']),
      attributionText: serializer.fromJson<String?>(json['attributionText']),
      isUserAdded: serializer.fromJson<bool>(json['isUserAdded']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hebrewVocalized': serializer.toJson<String>(hebrewVocalized),
      'hebrewNormalized': serializer.toJson<String>(hebrewNormalized),
      'russianTranslation': serializer.toJson<String>(russianTranslation),
      'transliteration': serializer.toJson<String?>(transliteration),
      'category': serializer.toJson<String>(category),
      'root': serializer.toJson<String?>(root),
      'binyan': serializer.toJson<String>(binyan),
      'formsSummary': serializer.toJson<String?>(formsSummary),
      'exampleHebrewVocalized':
          serializer.toJson<String?>(exampleHebrewVocalized),
      'exampleHebrewNormalized':
          serializer.toJson<String?>(exampleHebrewNormalized),
      'exampleRussian': serializer.toJson<String?>(exampleRussian),
      'audioUrl': serializer.toJson<String?>(audioUrl),
      'frequencyRank': serializer.toJson<int?>(frequencyRank),
      'sourceName': serializer.toJson<String>(sourceName),
      'licenseName': serializer.toJson<String>(licenseName),
      'attributionText': serializer.toJson<String?>(attributionText),
      'isUserAdded': serializer.toJson<bool>(isUserAdded),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DictionaryEntryRow copyWith(
          {String? id,
          String? hebrewVocalized,
          String? hebrewNormalized,
          String? russianTranslation,
          Value<String?> transliteration = const Value.absent(),
          String? category,
          Value<String?> root = const Value.absent(),
          String? binyan,
          Value<String?> formsSummary = const Value.absent(),
          Value<String?> exampleHebrewVocalized = const Value.absent(),
          Value<String?> exampleHebrewNormalized = const Value.absent(),
          Value<String?> exampleRussian = const Value.absent(),
          Value<String?> audioUrl = const Value.absent(),
          Value<int?> frequencyRank = const Value.absent(),
          String? sourceName,
          String? licenseName,
          Value<String?> attributionText = const Value.absent(),
          bool? isUserAdded,
          DateTime? createdAt}) =>
      DictionaryEntryRow(
        id: id ?? this.id,
        hebrewVocalized: hebrewVocalized ?? this.hebrewVocalized,
        hebrewNormalized: hebrewNormalized ?? this.hebrewNormalized,
        russianTranslation: russianTranslation ?? this.russianTranslation,
        transliteration: transliteration.present
            ? transliteration.value
            : this.transliteration,
        category: category ?? this.category,
        root: root.present ? root.value : this.root,
        binyan: binyan ?? this.binyan,
        formsSummary:
            formsSummary.present ? formsSummary.value : this.formsSummary,
        exampleHebrewVocalized: exampleHebrewVocalized.present
            ? exampleHebrewVocalized.value
            : this.exampleHebrewVocalized,
        exampleHebrewNormalized: exampleHebrewNormalized.present
            ? exampleHebrewNormalized.value
            : this.exampleHebrewNormalized,
        exampleRussian:
            exampleRussian.present ? exampleRussian.value : this.exampleRussian,
        audioUrl: audioUrl.present ? audioUrl.value : this.audioUrl,
        frequencyRank:
            frequencyRank.present ? frequencyRank.value : this.frequencyRank,
        sourceName: sourceName ?? this.sourceName,
        licenseName: licenseName ?? this.licenseName,
        attributionText: attributionText.present
            ? attributionText.value
            : this.attributionText,
        isUserAdded: isUserAdded ?? this.isUserAdded,
        createdAt: createdAt ?? this.createdAt,
      );
  DictionaryEntryRow copyWithCompanion(DictionaryEntriesCompanion data) {
    return DictionaryEntryRow(
      id: data.id.present ? data.id.value : this.id,
      hebrewVocalized: data.hebrewVocalized.present
          ? data.hebrewVocalized.value
          : this.hebrewVocalized,
      hebrewNormalized: data.hebrewNormalized.present
          ? data.hebrewNormalized.value
          : this.hebrewNormalized,
      russianTranslation: data.russianTranslation.present
          ? data.russianTranslation.value
          : this.russianTranslation,
      transliteration: data.transliteration.present
          ? data.transliteration.value
          : this.transliteration,
      category: data.category.present ? data.category.value : this.category,
      root: data.root.present ? data.root.value : this.root,
      binyan: data.binyan.present ? data.binyan.value : this.binyan,
      formsSummary: data.formsSummary.present
          ? data.formsSummary.value
          : this.formsSummary,
      exampleHebrewVocalized: data.exampleHebrewVocalized.present
          ? data.exampleHebrewVocalized.value
          : this.exampleHebrewVocalized,
      exampleHebrewNormalized: data.exampleHebrewNormalized.present
          ? data.exampleHebrewNormalized.value
          : this.exampleHebrewNormalized,
      exampleRussian: data.exampleRussian.present
          ? data.exampleRussian.value
          : this.exampleRussian,
      audioUrl: data.audioUrl.present ? data.audioUrl.value : this.audioUrl,
      frequencyRank: data.frequencyRank.present
          ? data.frequencyRank.value
          : this.frequencyRank,
      sourceName:
          data.sourceName.present ? data.sourceName.value : this.sourceName,
      licenseName:
          data.licenseName.present ? data.licenseName.value : this.licenseName,
      attributionText: data.attributionText.present
          ? data.attributionText.value
          : this.attributionText,
      isUserAdded:
          data.isUserAdded.present ? data.isUserAdded.value : this.isUserAdded,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DictionaryEntryRow(')
          ..write('id: $id, ')
          ..write('hebrewVocalized: $hebrewVocalized, ')
          ..write('hebrewNormalized: $hebrewNormalized, ')
          ..write('russianTranslation: $russianTranslation, ')
          ..write('transliteration: $transliteration, ')
          ..write('category: $category, ')
          ..write('root: $root, ')
          ..write('binyan: $binyan, ')
          ..write('formsSummary: $formsSummary, ')
          ..write('exampleHebrewVocalized: $exampleHebrewVocalized, ')
          ..write('exampleHebrewNormalized: $exampleHebrewNormalized, ')
          ..write('exampleRussian: $exampleRussian, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('frequencyRank: $frequencyRank, ')
          ..write('sourceName: $sourceName, ')
          ..write('licenseName: $licenseName, ')
          ..write('attributionText: $attributionText, ')
          ..write('isUserAdded: $isUserAdded, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      hebrewVocalized,
      hebrewNormalized,
      russianTranslation,
      transliteration,
      category,
      root,
      binyan,
      formsSummary,
      exampleHebrewVocalized,
      exampleHebrewNormalized,
      exampleRussian,
      audioUrl,
      frequencyRank,
      sourceName,
      licenseName,
      attributionText,
      isUserAdded,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DictionaryEntryRow &&
          other.id == this.id &&
          other.hebrewVocalized == this.hebrewVocalized &&
          other.hebrewNormalized == this.hebrewNormalized &&
          other.russianTranslation == this.russianTranslation &&
          other.transliteration == this.transliteration &&
          other.category == this.category &&
          other.root == this.root &&
          other.binyan == this.binyan &&
          other.formsSummary == this.formsSummary &&
          other.exampleHebrewVocalized == this.exampleHebrewVocalized &&
          other.exampleHebrewNormalized == this.exampleHebrewNormalized &&
          other.exampleRussian == this.exampleRussian &&
          other.audioUrl == this.audioUrl &&
          other.frequencyRank == this.frequencyRank &&
          other.sourceName == this.sourceName &&
          other.licenseName == this.licenseName &&
          other.attributionText == this.attributionText &&
          other.isUserAdded == this.isUserAdded &&
          other.createdAt == this.createdAt);
}

class DictionaryEntriesCompanion extends UpdateCompanion<DictionaryEntryRow> {
  final Value<String> id;
  final Value<String> hebrewVocalized;
  final Value<String> hebrewNormalized;
  final Value<String> russianTranslation;
  final Value<String?> transliteration;
  final Value<String> category;
  final Value<String?> root;
  final Value<String> binyan;
  final Value<String?> formsSummary;
  final Value<String?> exampleHebrewVocalized;
  final Value<String?> exampleHebrewNormalized;
  final Value<String?> exampleRussian;
  final Value<String?> audioUrl;
  final Value<int?> frequencyRank;
  final Value<String> sourceName;
  final Value<String> licenseName;
  final Value<String?> attributionText;
  final Value<bool> isUserAdded;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DictionaryEntriesCompanion({
    this.id = const Value.absent(),
    this.hebrewVocalized = const Value.absent(),
    this.hebrewNormalized = const Value.absent(),
    this.russianTranslation = const Value.absent(),
    this.transliteration = const Value.absent(),
    this.category = const Value.absent(),
    this.root = const Value.absent(),
    this.binyan = const Value.absent(),
    this.formsSummary = const Value.absent(),
    this.exampleHebrewVocalized = const Value.absent(),
    this.exampleHebrewNormalized = const Value.absent(),
    this.exampleRussian = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.frequencyRank = const Value.absent(),
    this.sourceName = const Value.absent(),
    this.licenseName = const Value.absent(),
    this.attributionText = const Value.absent(),
    this.isUserAdded = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DictionaryEntriesCompanion.insert({
    required String id,
    required String hebrewVocalized,
    required String hebrewNormalized,
    required String russianTranslation,
    this.transliteration = const Value.absent(),
    this.category = const Value.absent(),
    this.root = const Value.absent(),
    this.binyan = const Value.absent(),
    this.formsSummary = const Value.absent(),
    this.exampleHebrewVocalized = const Value.absent(),
    this.exampleHebrewNormalized = const Value.absent(),
    this.exampleRussian = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.frequencyRank = const Value.absent(),
    required String sourceName,
    required String licenseName,
    this.attributionText = const Value.absent(),
    this.isUserAdded = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        hebrewVocalized = Value(hebrewVocalized),
        hebrewNormalized = Value(hebrewNormalized),
        russianTranslation = Value(russianTranslation),
        sourceName = Value(sourceName),
        licenseName = Value(licenseName),
        createdAt = Value(createdAt);
  static Insertable<DictionaryEntryRow> custom({
    Expression<String>? id,
    Expression<String>? hebrewVocalized,
    Expression<String>? hebrewNormalized,
    Expression<String>? russianTranslation,
    Expression<String>? transliteration,
    Expression<String>? category,
    Expression<String>? root,
    Expression<String>? binyan,
    Expression<String>? formsSummary,
    Expression<String>? exampleHebrewVocalized,
    Expression<String>? exampleHebrewNormalized,
    Expression<String>? exampleRussian,
    Expression<String>? audioUrl,
    Expression<int>? frequencyRank,
    Expression<String>? sourceName,
    Expression<String>? licenseName,
    Expression<String>? attributionText,
    Expression<bool>? isUserAdded,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hebrewVocalized != null) 'hebrew_vocalized': hebrewVocalized,
      if (hebrewNormalized != null) 'hebrew_normalized': hebrewNormalized,
      if (russianTranslation != null) 'russian_translation': russianTranslation,
      if (transliteration != null) 'transliteration': transliteration,
      if (category != null) 'category': category,
      if (root != null) 'root': root,
      if (binyan != null) 'binyan': binyan,
      if (formsSummary != null) 'forms_summary': formsSummary,
      if (exampleHebrewVocalized != null)
        'example_hebrew_vocalized': exampleHebrewVocalized,
      if (exampleHebrewNormalized != null)
        'example_hebrew_normalized': exampleHebrewNormalized,
      if (exampleRussian != null) 'example_russian': exampleRussian,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (frequencyRank != null) 'frequency_rank': frequencyRank,
      if (sourceName != null) 'source_name': sourceName,
      if (licenseName != null) 'license_name': licenseName,
      if (attributionText != null) 'attribution_text': attributionText,
      if (isUserAdded != null) 'is_user_added': isUserAdded,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DictionaryEntriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? hebrewVocalized,
      Value<String>? hebrewNormalized,
      Value<String>? russianTranslation,
      Value<String?>? transliteration,
      Value<String>? category,
      Value<String?>? root,
      Value<String>? binyan,
      Value<String?>? formsSummary,
      Value<String?>? exampleHebrewVocalized,
      Value<String?>? exampleHebrewNormalized,
      Value<String?>? exampleRussian,
      Value<String?>? audioUrl,
      Value<int?>? frequencyRank,
      Value<String>? sourceName,
      Value<String>? licenseName,
      Value<String?>? attributionText,
      Value<bool>? isUserAdded,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return DictionaryEntriesCompanion(
      id: id ?? this.id,
      hebrewVocalized: hebrewVocalized ?? this.hebrewVocalized,
      hebrewNormalized: hebrewNormalized ?? this.hebrewNormalized,
      russianTranslation: russianTranslation ?? this.russianTranslation,
      transliteration: transliteration ?? this.transliteration,
      category: category ?? this.category,
      root: root ?? this.root,
      binyan: binyan ?? this.binyan,
      formsSummary: formsSummary ?? this.formsSummary,
      exampleHebrewVocalized:
          exampleHebrewVocalized ?? this.exampleHebrewVocalized,
      exampleHebrewNormalized:
          exampleHebrewNormalized ?? this.exampleHebrewNormalized,
      exampleRussian: exampleRussian ?? this.exampleRussian,
      audioUrl: audioUrl ?? this.audioUrl,
      frequencyRank: frequencyRank ?? this.frequencyRank,
      sourceName: sourceName ?? this.sourceName,
      licenseName: licenseName ?? this.licenseName,
      attributionText: attributionText ?? this.attributionText,
      isUserAdded: isUserAdded ?? this.isUserAdded,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hebrewVocalized.present) {
      map['hebrew_vocalized'] = Variable<String>(hebrewVocalized.value);
    }
    if (hebrewNormalized.present) {
      map['hebrew_normalized'] = Variable<String>(hebrewNormalized.value);
    }
    if (russianTranslation.present) {
      map['russian_translation'] = Variable<String>(russianTranslation.value);
    }
    if (transliteration.present) {
      map['transliteration'] = Variable<String>(transliteration.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (root.present) {
      map['root'] = Variable<String>(root.value);
    }
    if (binyan.present) {
      map['binyan'] = Variable<String>(binyan.value);
    }
    if (formsSummary.present) {
      map['forms_summary'] = Variable<String>(formsSummary.value);
    }
    if (exampleHebrewVocalized.present) {
      map['example_hebrew_vocalized'] =
          Variable<String>(exampleHebrewVocalized.value);
    }
    if (exampleHebrewNormalized.present) {
      map['example_hebrew_normalized'] =
          Variable<String>(exampleHebrewNormalized.value);
    }
    if (exampleRussian.present) {
      map['example_russian'] = Variable<String>(exampleRussian.value);
    }
    if (audioUrl.present) {
      map['audio_url'] = Variable<String>(audioUrl.value);
    }
    if (frequencyRank.present) {
      map['frequency_rank'] = Variable<int>(frequencyRank.value);
    }
    if (sourceName.present) {
      map['source_name'] = Variable<String>(sourceName.value);
    }
    if (licenseName.present) {
      map['license_name'] = Variable<String>(licenseName.value);
    }
    if (attributionText.present) {
      map['attribution_text'] = Variable<String>(attributionText.value);
    }
    if (isUserAdded.present) {
      map['is_user_added'] = Variable<bool>(isUserAdded.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DictionaryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('hebrewVocalized: $hebrewVocalized, ')
          ..write('hebrewNormalized: $hebrewNormalized, ')
          ..write('russianTranslation: $russianTranslation, ')
          ..write('transliteration: $transliteration, ')
          ..write('category: $category, ')
          ..write('root: $root, ')
          ..write('binyan: $binyan, ')
          ..write('formsSummary: $formsSummary, ')
          ..write('exampleHebrewVocalized: $exampleHebrewVocalized, ')
          ..write('exampleHebrewNormalized: $exampleHebrewNormalized, ')
          ..write('exampleRussian: $exampleRussian, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('frequencyRank: $frequencyRank, ')
          ..write('sourceName: $sourceName, ')
          ..write('licenseName: $licenseName, ')
          ..write('attributionText: $attributionText, ')
          ..write('isUserAdded: $isUserAdded, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SceneProgressEntriesTable extends SceneProgressEntries
    with TableInfo<$SceneProgressEntriesTable, SceneProgressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SceneProgressEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sceneIdMeta =
      const VerificationMeta('sceneId');
  @override
  late final GeneratedColumn<String> sceneId = GeneratedColumn<String>(
      'scene_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _wordsMasteredCountMeta =
      const VerificationMeta('wordsMasteredCount');
  @override
  late final GeneratedColumn<int> wordsMasteredCount = GeneratedColumn<int>(
      'words_mastered_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _challengeScoreMeta =
      const VerificationMeta('challengeScore');
  @override
  late final GeneratedColumn<int> challengeScore = GeneratedColumn<int>(
      'challenge_score', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastVisitedAtMeta =
      const VerificationMeta('lastVisitedAt');
  @override
  late final GeneratedColumn<DateTime> lastVisitedAt =
      GeneratedColumn<DateTime>('last_visited_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [sceneId, isCompleted, wordsMasteredCount, challengeScore, lastVisitedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scene_progress_entries';
  @override
  VerificationContext validateIntegrity(Insertable<SceneProgressRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('scene_id')) {
      context.handle(_sceneIdMeta,
          sceneId.isAcceptableOrUnknown(data['scene_id']!, _sceneIdMeta));
    } else if (isInserting) {
      context.missing(_sceneIdMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('words_mastered_count')) {
      context.handle(
          _wordsMasteredCountMeta,
          wordsMasteredCount.isAcceptableOrUnknown(
              data['words_mastered_count']!, _wordsMasteredCountMeta));
    }
    if (data.containsKey('challenge_score')) {
      context.handle(
          _challengeScoreMeta,
          challengeScore.isAcceptableOrUnknown(
              data['challenge_score']!, _challengeScoreMeta));
    }
    if (data.containsKey('last_visited_at')) {
      context.handle(
          _lastVisitedAtMeta,
          lastVisitedAt.isAcceptableOrUnknown(
              data['last_visited_at']!, _lastVisitedAtMeta));
    } else if (isInserting) {
      context.missing(_lastVisitedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sceneId};
  @override
  SceneProgressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SceneProgressRow(
      sceneId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scene_id'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      wordsMasteredCount: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}words_mastered_count'])!,
      challengeScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}challenge_score'])!,
      lastVisitedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_visited_at'])!,
    );
  }

  @override
  $SceneProgressEntriesTable createAlias(String alias) {
    return $SceneProgressEntriesTable(attachedDatabase, alias);
  }
}

class SceneProgressRow extends DataClass
    implements Insertable<SceneProgressRow> {
  final String sceneId;
  final bool isCompleted;
  final int wordsMasteredCount;
  final int challengeScore;
  final DateTime lastVisitedAt;
  const SceneProgressRow(
      {required this.sceneId,
      required this.isCompleted,
      required this.wordsMasteredCount,
      required this.challengeScore,
      required this.lastVisitedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['scene_id'] = Variable<String>(sceneId);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['words_mastered_count'] = Variable<int>(wordsMasteredCount);
    map['challenge_score'] = Variable<int>(challengeScore);
    map['last_visited_at'] = Variable<DateTime>(lastVisitedAt);
    return map;
  }

  SceneProgressEntriesCompanion toCompanion(bool nullToAbsent) {
    return SceneProgressEntriesCompanion(
      sceneId: Value(sceneId),
      isCompleted: Value(isCompleted),
      wordsMasteredCount: Value(wordsMasteredCount),
      challengeScore: Value(challengeScore),
      lastVisitedAt: Value(lastVisitedAt),
    );
  }

  factory SceneProgressRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SceneProgressRow(
      sceneId: serializer.fromJson<String>(json['sceneId']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      wordsMasteredCount: serializer.fromJson<int>(json['wordsMasteredCount']),
      challengeScore: serializer.fromJson<int>(json['challengeScore']),
      lastVisitedAt: serializer.fromJson<DateTime>(json['lastVisitedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sceneId': serializer.toJson<String>(sceneId),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'wordsMasteredCount': serializer.toJson<int>(wordsMasteredCount),
      'challengeScore': serializer.toJson<int>(challengeScore),
      'lastVisitedAt': serializer.toJson<DateTime>(lastVisitedAt),
    };
  }

  SceneProgressRow copyWith(
          {String? sceneId,
          bool? isCompleted,
          int? wordsMasteredCount,
          int? challengeScore,
          DateTime? lastVisitedAt}) =>
      SceneProgressRow(
        sceneId: sceneId ?? this.sceneId,
        isCompleted: isCompleted ?? this.isCompleted,
        wordsMasteredCount: wordsMasteredCount ?? this.wordsMasteredCount,
        challengeScore: challengeScore ?? this.challengeScore,
        lastVisitedAt: lastVisitedAt ?? this.lastVisitedAt,
      );
  SceneProgressRow copyWithCompanion(SceneProgressEntriesCompanion data) {
    return SceneProgressRow(
      sceneId: data.sceneId.present ? data.sceneId.value : this.sceneId,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      wordsMasteredCount: data.wordsMasteredCount.present
          ? data.wordsMasteredCount.value
          : this.wordsMasteredCount,
      challengeScore: data.challengeScore.present
          ? data.challengeScore.value
          : this.challengeScore,
      lastVisitedAt: data.lastVisitedAt.present
          ? data.lastVisitedAt.value
          : this.lastVisitedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SceneProgressRow(')
          ..write('sceneId: $sceneId, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('wordsMasteredCount: $wordsMasteredCount, ')
          ..write('challengeScore: $challengeScore, ')
          ..write('lastVisitedAt: $lastVisitedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      sceneId, isCompleted, wordsMasteredCount, challengeScore, lastVisitedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SceneProgressRow &&
          other.sceneId == this.sceneId &&
          other.isCompleted == this.isCompleted &&
          other.wordsMasteredCount == this.wordsMasteredCount &&
          other.challengeScore == this.challengeScore &&
          other.lastVisitedAt == this.lastVisitedAt);
}

class SceneProgressEntriesCompanion extends UpdateCompanion<SceneProgressRow> {
  final Value<String> sceneId;
  final Value<bool> isCompleted;
  final Value<int> wordsMasteredCount;
  final Value<int> challengeScore;
  final Value<DateTime> lastVisitedAt;
  final Value<int> rowid;
  const SceneProgressEntriesCompanion({
    this.sceneId = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.wordsMasteredCount = const Value.absent(),
    this.challengeScore = const Value.absent(),
    this.lastVisitedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SceneProgressEntriesCompanion.insert({
    required String sceneId,
    this.isCompleted = const Value.absent(),
    this.wordsMasteredCount = const Value.absent(),
    this.challengeScore = const Value.absent(),
    required DateTime lastVisitedAt,
    this.rowid = const Value.absent(),
  })  : sceneId = Value(sceneId),
        lastVisitedAt = Value(lastVisitedAt);
  static Insertable<SceneProgressRow> custom({
    Expression<String>? sceneId,
    Expression<bool>? isCompleted,
    Expression<int>? wordsMasteredCount,
    Expression<int>? challengeScore,
    Expression<DateTime>? lastVisitedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sceneId != null) 'scene_id': sceneId,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (wordsMasteredCount != null)
        'words_mastered_count': wordsMasteredCount,
      if (challengeScore != null) 'challenge_score': challengeScore,
      if (lastVisitedAt != null) 'last_visited_at': lastVisitedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SceneProgressEntriesCompanion copyWith(
      {Value<String>? sceneId,
      Value<bool>? isCompleted,
      Value<int>? wordsMasteredCount,
      Value<int>? challengeScore,
      Value<DateTime>? lastVisitedAt,
      Value<int>? rowid}) {
    return SceneProgressEntriesCompanion(
      sceneId: sceneId ?? this.sceneId,
      isCompleted: isCompleted ?? this.isCompleted,
      wordsMasteredCount: wordsMasteredCount ?? this.wordsMasteredCount,
      challengeScore: challengeScore ?? this.challengeScore,
      lastVisitedAt: lastVisitedAt ?? this.lastVisitedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sceneId.present) {
      map['scene_id'] = Variable<String>(sceneId.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (wordsMasteredCount.present) {
      map['words_mastered_count'] = Variable<int>(wordsMasteredCount.value);
    }
    if (challengeScore.present) {
      map['challenge_score'] = Variable<int>(challengeScore.value);
    }
    if (lastVisitedAt.present) {
      map['last_visited_at'] = Variable<DateTime>(lastVisitedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SceneProgressEntriesCompanion(')
          ..write('sceneId: $sceneId, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('wordsMasteredCount: $wordsMasteredCount, ')
          ..write('challengeScore: $challengeScore, ')
          ..write('lastVisitedAt: $lastVisitedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DialogueNodesTable dialogueNodes = $DialogueNodesTable(this);
  late final $DialogueHistoryEntriesTable dialogueHistoryEntries =
      $DialogueHistoryEntriesTable(this);
  late final $SrsCardsTable srsCards = $SrsCardsTable(this);
  late final $SrsReviewLogsTable srsReviewLogs = $SrsReviewLogsTable(this);
  late final $GrammarVerbsTable grammarVerbs = $GrammarVerbsTable(this);
  late final $GrammarPracticeLogsTable grammarPracticeLogs =
      $GrammarPracticeLogsTable(this);
  late final $ListeningExercisesTable listeningExercises =
      $ListeningExercisesTable(this);
  late final $ListeningAttemptLogsTable listeningAttemptLogs =
      $ListeningAttemptLogsTable(this);
  late final $DictionaryEntriesTable dictionaryEntries =
      $DictionaryEntriesTable(this);
  late final $SceneProgressEntriesTable sceneProgressEntries =
      $SceneProgressEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        dialogueNodes,
        dialogueHistoryEntries,
        srsCards,
        srsReviewLogs,
        grammarVerbs,
        grammarPracticeLogs,
        listeningExercises,
        listeningAttemptLogs,
        dictionaryEntries,
        sceneProgressEntries
      ];
}

typedef $$DialogueNodesTableCreateCompanionBuilder = DialogueNodesCompanion
    Function({
  required String id,
  required String characterName,
  required String lineHebrewVocalized,
  required String lineHebrewNormalized,
  required String lineRussian,
  Value<String?> audioPath,
  required String optionsJson,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$DialogueNodesTableUpdateCompanionBuilder = DialogueNodesCompanion
    Function({
  Value<String> id,
  Value<String> characterName,
  Value<String> lineHebrewVocalized,
  Value<String> lineHebrewNormalized,
  Value<String> lineRussian,
  Value<String?> audioPath,
  Value<String> optionsJson,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$DialogueNodesTableFilterComposer
    extends Composer<_$AppDatabase, $DialogueNodesTable> {
  $$DialogueNodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get characterName => $composableBuilder(
      column: $table.characterName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lineHebrewVocalized => $composableBuilder(
      column: $table.lineHebrewVocalized,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lineHebrewNormalized => $composableBuilder(
      column: $table.lineHebrewNormalized,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lineRussian => $composableBuilder(
      column: $table.lineRussian, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get audioPath => $composableBuilder(
      column: $table.audioPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get optionsJson => $composableBuilder(
      column: $table.optionsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$DialogueNodesTableOrderingComposer
    extends Composer<_$AppDatabase, $DialogueNodesTable> {
  $$DialogueNodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get characterName => $composableBuilder(
      column: $table.characterName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lineHebrewVocalized => $composableBuilder(
      column: $table.lineHebrewVocalized,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lineHebrewNormalized => $composableBuilder(
      column: $table.lineHebrewNormalized,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lineRussian => $composableBuilder(
      column: $table.lineRussian, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get audioPath => $composableBuilder(
      column: $table.audioPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get optionsJson => $composableBuilder(
      column: $table.optionsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$DialogueNodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DialogueNodesTable> {
  $$DialogueNodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get characterName => $composableBuilder(
      column: $table.characterName, builder: (column) => column);

  GeneratedColumn<String> get lineHebrewVocalized => $composableBuilder(
      column: $table.lineHebrewVocalized, builder: (column) => column);

  GeneratedColumn<String> get lineHebrewNormalized => $composableBuilder(
      column: $table.lineHebrewNormalized, builder: (column) => column);

  GeneratedColumn<String> get lineRussian => $composableBuilder(
      column: $table.lineRussian, builder: (column) => column);

  GeneratedColumn<String> get audioPath =>
      $composableBuilder(column: $table.audioPath, builder: (column) => column);

  GeneratedColumn<String> get optionsJson => $composableBuilder(
      column: $table.optionsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DialogueNodesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DialogueNodesTable,
    DialogueNodeRow,
    $$DialogueNodesTableFilterComposer,
    $$DialogueNodesTableOrderingComposer,
    $$DialogueNodesTableAnnotationComposer,
    $$DialogueNodesTableCreateCompanionBuilder,
    $$DialogueNodesTableUpdateCompanionBuilder,
    (
      DialogueNodeRow,
      BaseReferences<_$AppDatabase, $DialogueNodesTable, DialogueNodeRow>
    ),
    DialogueNodeRow,
    PrefetchHooks Function()> {
  $$DialogueNodesTableTableManager(_$AppDatabase db, $DialogueNodesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DialogueNodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DialogueNodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DialogueNodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> characterName = const Value.absent(),
            Value<String> lineHebrewVocalized = const Value.absent(),
            Value<String> lineHebrewNormalized = const Value.absent(),
            Value<String> lineRussian = const Value.absent(),
            Value<String?> audioPath = const Value.absent(),
            Value<String> optionsJson = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DialogueNodesCompanion(
            id: id,
            characterName: characterName,
            lineHebrewVocalized: lineHebrewVocalized,
            lineHebrewNormalized: lineHebrewNormalized,
            lineRussian: lineRussian,
            audioPath: audioPath,
            optionsJson: optionsJson,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String characterName,
            required String lineHebrewVocalized,
            required String lineHebrewNormalized,
            required String lineRussian,
            Value<String?> audioPath = const Value.absent(),
            required String optionsJson,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DialogueNodesCompanion.insert(
            id: id,
            characterName: characterName,
            lineHebrewVocalized: lineHebrewVocalized,
            lineHebrewNormalized: lineHebrewNormalized,
            lineRussian: lineRussian,
            audioPath: audioPath,
            optionsJson: optionsJson,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$DialogueNodesTable, DialogueNodeRow>(table),
                    BaseReferences<_$AppDatabase, $DialogueNodesTable,
                        DialogueNodeRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DialogueNodesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DialogueNodesTable,
    DialogueNodeRow,
    $$DialogueNodesTableFilterComposer,
    $$DialogueNodesTableOrderingComposer,
    $$DialogueNodesTableAnnotationComposer,
    $$DialogueNodesTableCreateCompanionBuilder,
    $$DialogueNodesTableUpdateCompanionBuilder,
    (
      DialogueNodeRow,
      BaseReferences<_$AppDatabase, $DialogueNodesTable, DialogueNodeRow>
    ),
    DialogueNodeRow,
    PrefetchHooks Function()>;
typedef $$DialogueHistoryEntriesTableCreateCompanionBuilder
    = DialogueHistoryEntriesCompanion Function({
  Value<int> id,
  required String nodeId,
  required String selectedOptionId,
  required DateTime answeredAt,
  Value<bool> synced,
});
typedef $$DialogueHistoryEntriesTableUpdateCompanionBuilder
    = DialogueHistoryEntriesCompanion Function({
  Value<int> id,
  Value<String> nodeId,
  Value<String> selectedOptionId,
  Value<DateTime> answeredAt,
  Value<bool> synced,
});

class $$DialogueHistoryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DialogueHistoryEntriesTable> {
  $$DialogueHistoryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nodeId => $composableBuilder(
      column: $table.nodeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get selectedOptionId => $composableBuilder(
      column: $table.selectedOptionId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get answeredAt => $composableBuilder(
      column: $table.answeredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$DialogueHistoryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DialogueHistoryEntriesTable> {
  $$DialogueHistoryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nodeId => $composableBuilder(
      column: $table.nodeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get selectedOptionId => $composableBuilder(
      column: $table.selectedOptionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get answeredAt => $composableBuilder(
      column: $table.answeredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$DialogueHistoryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DialogueHistoryEntriesTable> {
  $$DialogueHistoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nodeId =>
      $composableBuilder(column: $table.nodeId, builder: (column) => column);

  GeneratedColumn<String> get selectedOptionId => $composableBuilder(
      column: $table.selectedOptionId, builder: (column) => column);

  GeneratedColumn<DateTime> get answeredAt => $composableBuilder(
      column: $table.answeredAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$DialogueHistoryEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DialogueHistoryEntriesTable,
    DialogueHistoryRow,
    $$DialogueHistoryEntriesTableFilterComposer,
    $$DialogueHistoryEntriesTableOrderingComposer,
    $$DialogueHistoryEntriesTableAnnotationComposer,
    $$DialogueHistoryEntriesTableCreateCompanionBuilder,
    $$DialogueHistoryEntriesTableUpdateCompanionBuilder,
    (
      DialogueHistoryRow,
      BaseReferences<_$AppDatabase, $DialogueHistoryEntriesTable,
          DialogueHistoryRow>
    ),
    DialogueHistoryRow,
    PrefetchHooks Function()> {
  $$DialogueHistoryEntriesTableTableManager(
      _$AppDatabase db, $DialogueHistoryEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DialogueHistoryEntriesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$DialogueHistoryEntriesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DialogueHistoryEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nodeId = const Value.absent(),
            Value<String> selectedOptionId = const Value.absent(),
            Value<DateTime> answeredAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
          }) =>
              DialogueHistoryEntriesCompanion(
            id: id,
            nodeId: nodeId,
            selectedOptionId: selectedOptionId,
            answeredAt: answeredAt,
            synced: synced,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nodeId,
            required String selectedOptionId,
            required DateTime answeredAt,
            Value<bool> synced = const Value.absent(),
          }) =>
              DialogueHistoryEntriesCompanion.insert(
            id: id,
            nodeId: nodeId,
            selectedOptionId: selectedOptionId,
            answeredAt: answeredAt,
            synced: synced,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$DialogueHistoryEntriesTable,
                        DialogueHistoryRow>(table),
                    BaseReferences<_$AppDatabase, $DialogueHistoryEntriesTable,
                        DialogueHistoryRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DialogueHistoryEntriesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $DialogueHistoryEntriesTable,
        DialogueHistoryRow,
        $$DialogueHistoryEntriesTableFilterComposer,
        $$DialogueHistoryEntriesTableOrderingComposer,
        $$DialogueHistoryEntriesTableAnnotationComposer,
        $$DialogueHistoryEntriesTableCreateCompanionBuilder,
        $$DialogueHistoryEntriesTableUpdateCompanionBuilder,
        (
          DialogueHistoryRow,
          BaseReferences<_$AppDatabase, $DialogueHistoryEntriesTable,
              DialogueHistoryRow>
        ),
        DialogueHistoryRow,
        PrefetchHooks Function()>;
typedef $$SrsCardsTableCreateCompanionBuilder = SrsCardsCompanion Function({
  required String id,
  required String hebrewVocalized,
  required String hebrewNormalized,
  required String russianTranslation,
  Value<String?> root,
  Value<String> binyan,
  Value<String> category,
  Value<String?> exampleHebrewVocalized,
  Value<String?> exampleHebrewNormalized,
  Value<String?> exampleRussian,
  Value<String?> audioUrl,
  required String sourceName,
  required String licenseName,
  Value<String?> attributionText,
  Value<String> fsrsState,
  Value<double> stability,
  Value<double> difficulty,
  Value<int> reps,
  Value<int> lapses,
  required DateTime dueAt,
  Value<DateTime?> lastReviewedAt,
  Value<int> rowid,
});
typedef $$SrsCardsTableUpdateCompanionBuilder = SrsCardsCompanion Function({
  Value<String> id,
  Value<String> hebrewVocalized,
  Value<String> hebrewNormalized,
  Value<String> russianTranslation,
  Value<String?> root,
  Value<String> binyan,
  Value<String> category,
  Value<String?> exampleHebrewVocalized,
  Value<String?> exampleHebrewNormalized,
  Value<String?> exampleRussian,
  Value<String?> audioUrl,
  Value<String> sourceName,
  Value<String> licenseName,
  Value<String?> attributionText,
  Value<String> fsrsState,
  Value<double> stability,
  Value<double> difficulty,
  Value<int> reps,
  Value<int> lapses,
  Value<DateTime> dueAt,
  Value<DateTime?> lastReviewedAt,
  Value<int> rowid,
});

class $$SrsCardsTableFilterComposer
    extends Composer<_$AppDatabase, $SrsCardsTable> {
  $$SrsCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hebrewVocalized => $composableBuilder(
      column: $table.hebrewVocalized,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hebrewNormalized => $composableBuilder(
      column: $table.hebrewNormalized,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get russianTranslation => $composableBuilder(
      column: $table.russianTranslation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get root => $composableBuilder(
      column: $table.root, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get binyan => $composableBuilder(
      column: $table.binyan, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exampleHebrewVocalized => $composableBuilder(
      column: $table.exampleHebrewVocalized,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exampleHebrewNormalized => $composableBuilder(
      column: $table.exampleHebrewNormalized,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exampleRussian => $composableBuilder(
      column: $table.exampleRussian,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get audioUrl => $composableBuilder(
      column: $table.audioUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceName => $composableBuilder(
      column: $table.sourceName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get licenseName => $composableBuilder(
      column: $table.licenseName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get attributionText => $composableBuilder(
      column: $table.attributionText,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fsrsState => $composableBuilder(
      column: $table.fsrsState, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get stability => $composableBuilder(
      column: $table.stability, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reps => $composableBuilder(
      column: $table.reps, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lapses => $composableBuilder(
      column: $table.lapses, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
      column: $table.dueAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastReviewedAt => $composableBuilder(
      column: $table.lastReviewedAt,
      builder: (column) => ColumnFilters(column));
}

class $$SrsCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $SrsCardsTable> {
  $$SrsCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hebrewVocalized => $composableBuilder(
      column: $table.hebrewVocalized,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hebrewNormalized => $composableBuilder(
      column: $table.hebrewNormalized,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get russianTranslation => $composableBuilder(
      column: $table.russianTranslation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get root => $composableBuilder(
      column: $table.root, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get binyan => $composableBuilder(
      column: $table.binyan, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exampleHebrewVocalized => $composableBuilder(
      column: $table.exampleHebrewVocalized,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exampleHebrewNormalized => $composableBuilder(
      column: $table.exampleHebrewNormalized,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exampleRussian => $composableBuilder(
      column: $table.exampleRussian,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get audioUrl => $composableBuilder(
      column: $table.audioUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceName => $composableBuilder(
      column: $table.sourceName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get licenseName => $composableBuilder(
      column: $table.licenseName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get attributionText => $composableBuilder(
      column: $table.attributionText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fsrsState => $composableBuilder(
      column: $table.fsrsState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get stability => $composableBuilder(
      column: $table.stability, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reps => $composableBuilder(
      column: $table.reps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lapses => $composableBuilder(
      column: $table.lapses, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
      column: $table.dueAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastReviewedAt => $composableBuilder(
      column: $table.lastReviewedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$SrsCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SrsCardsTable> {
  $$SrsCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hebrewVocalized => $composableBuilder(
      column: $table.hebrewVocalized, builder: (column) => column);

  GeneratedColumn<String> get hebrewNormalized => $composableBuilder(
      column: $table.hebrewNormalized, builder: (column) => column);

  GeneratedColumn<String> get russianTranslation => $composableBuilder(
      column: $table.russianTranslation, builder: (column) => column);

  GeneratedColumn<String> get root =>
      $composableBuilder(column: $table.root, builder: (column) => column);

  GeneratedColumn<String> get binyan =>
      $composableBuilder(column: $table.binyan, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get exampleHebrewVocalized => $composableBuilder(
      column: $table.exampleHebrewVocalized, builder: (column) => column);

  GeneratedColumn<String> get exampleHebrewNormalized => $composableBuilder(
      column: $table.exampleHebrewNormalized, builder: (column) => column);

  GeneratedColumn<String> get exampleRussian => $composableBuilder(
      column: $table.exampleRussian, builder: (column) => column);

  GeneratedColumn<String> get audioUrl =>
      $composableBuilder(column: $table.audioUrl, builder: (column) => column);

  GeneratedColumn<String> get sourceName => $composableBuilder(
      column: $table.sourceName, builder: (column) => column);

  GeneratedColumn<String> get licenseName => $composableBuilder(
      column: $table.licenseName, builder: (column) => column);

  GeneratedColumn<String> get attributionText => $composableBuilder(
      column: $table.attributionText, builder: (column) => column);

  GeneratedColumn<String> get fsrsState =>
      $composableBuilder(column: $table.fsrsState, builder: (column) => column);

  GeneratedColumn<double> get stability =>
      $composableBuilder(column: $table.stability, builder: (column) => column);

  GeneratedColumn<double> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get lapses =>
      $composableBuilder(column: $table.lapses, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReviewedAt => $composableBuilder(
      column: $table.lastReviewedAt, builder: (column) => column);
}

class $$SrsCardsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SrsCardsTable,
    SrsCardRow,
    $$SrsCardsTableFilterComposer,
    $$SrsCardsTableOrderingComposer,
    $$SrsCardsTableAnnotationComposer,
    $$SrsCardsTableCreateCompanionBuilder,
    $$SrsCardsTableUpdateCompanionBuilder,
    (SrsCardRow, BaseReferences<_$AppDatabase, $SrsCardsTable, SrsCardRow>),
    SrsCardRow,
    PrefetchHooks Function()> {
  $$SrsCardsTableTableManager(_$AppDatabase db, $SrsCardsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SrsCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SrsCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SrsCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> hebrewVocalized = const Value.absent(),
            Value<String> hebrewNormalized = const Value.absent(),
            Value<String> russianTranslation = const Value.absent(),
            Value<String?> root = const Value.absent(),
            Value<String> binyan = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String?> exampleHebrewVocalized = const Value.absent(),
            Value<String?> exampleHebrewNormalized = const Value.absent(),
            Value<String?> exampleRussian = const Value.absent(),
            Value<String?> audioUrl = const Value.absent(),
            Value<String> sourceName = const Value.absent(),
            Value<String> licenseName = const Value.absent(),
            Value<String?> attributionText = const Value.absent(),
            Value<String> fsrsState = const Value.absent(),
            Value<double> stability = const Value.absent(),
            Value<double> difficulty = const Value.absent(),
            Value<int> reps = const Value.absent(),
            Value<int> lapses = const Value.absent(),
            Value<DateTime> dueAt = const Value.absent(),
            Value<DateTime?> lastReviewedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SrsCardsCompanion(
            id: id,
            hebrewVocalized: hebrewVocalized,
            hebrewNormalized: hebrewNormalized,
            russianTranslation: russianTranslation,
            root: root,
            binyan: binyan,
            category: category,
            exampleHebrewVocalized: exampleHebrewVocalized,
            exampleHebrewNormalized: exampleHebrewNormalized,
            exampleRussian: exampleRussian,
            audioUrl: audioUrl,
            sourceName: sourceName,
            licenseName: licenseName,
            attributionText: attributionText,
            fsrsState: fsrsState,
            stability: stability,
            difficulty: difficulty,
            reps: reps,
            lapses: lapses,
            dueAt: dueAt,
            lastReviewedAt: lastReviewedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String hebrewVocalized,
            required String hebrewNormalized,
            required String russianTranslation,
            Value<String?> root = const Value.absent(),
            Value<String> binyan = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String?> exampleHebrewVocalized = const Value.absent(),
            Value<String?> exampleHebrewNormalized = const Value.absent(),
            Value<String?> exampleRussian = const Value.absent(),
            Value<String?> audioUrl = const Value.absent(),
            required String sourceName,
            required String licenseName,
            Value<String?> attributionText = const Value.absent(),
            Value<String> fsrsState = const Value.absent(),
            Value<double> stability = const Value.absent(),
            Value<double> difficulty = const Value.absent(),
            Value<int> reps = const Value.absent(),
            Value<int> lapses = const Value.absent(),
            required DateTime dueAt,
            Value<DateTime?> lastReviewedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SrsCardsCompanion.insert(
            id: id,
            hebrewVocalized: hebrewVocalized,
            hebrewNormalized: hebrewNormalized,
            russianTranslation: russianTranslation,
            root: root,
            binyan: binyan,
            category: category,
            exampleHebrewVocalized: exampleHebrewVocalized,
            exampleHebrewNormalized: exampleHebrewNormalized,
            exampleRussian: exampleRussian,
            audioUrl: audioUrl,
            sourceName: sourceName,
            licenseName: licenseName,
            attributionText: attributionText,
            fsrsState: fsrsState,
            stability: stability,
            difficulty: difficulty,
            reps: reps,
            lapses: lapses,
            dueAt: dueAt,
            lastReviewedAt: lastReviewedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SrsCardsTable, SrsCardRow>(table),
                    BaseReferences<_$AppDatabase, $SrsCardsTable, SrsCardRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SrsCardsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SrsCardsTable,
    SrsCardRow,
    $$SrsCardsTableFilterComposer,
    $$SrsCardsTableOrderingComposer,
    $$SrsCardsTableAnnotationComposer,
    $$SrsCardsTableCreateCompanionBuilder,
    $$SrsCardsTableUpdateCompanionBuilder,
    (SrsCardRow, BaseReferences<_$AppDatabase, $SrsCardsTable, SrsCardRow>),
    SrsCardRow,
    PrefetchHooks Function()>;
typedef $$SrsReviewLogsTableCreateCompanionBuilder = SrsReviewLogsCompanion
    Function({
  Value<int> id,
  required String cardId,
  required int rating,
  required double stabilityBefore,
  required double stabilityAfter,
  required double difficultyAfter,
  required int scheduledDays,
  Value<bool> wasTypedCheck,
  Value<bool> wasTypedExact,
  required DateTime reviewedAt,
});
typedef $$SrsReviewLogsTableUpdateCompanionBuilder = SrsReviewLogsCompanion
    Function({
  Value<int> id,
  Value<String> cardId,
  Value<int> rating,
  Value<double> stabilityBefore,
  Value<double> stabilityAfter,
  Value<double> difficultyAfter,
  Value<int> scheduledDays,
  Value<bool> wasTypedCheck,
  Value<bool> wasTypedExact,
  Value<DateTime> reviewedAt,
});

class $$SrsReviewLogsTableFilterComposer
    extends Composer<_$AppDatabase, $SrsReviewLogsTable> {
  $$SrsReviewLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cardId => $composableBuilder(
      column: $table.cardId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get stabilityBefore => $composableBuilder(
      column: $table.stabilityBefore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get stabilityAfter => $composableBuilder(
      column: $table.stabilityAfter,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get difficultyAfter => $composableBuilder(
      column: $table.difficultyAfter,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get scheduledDays => $composableBuilder(
      column: $table.scheduledDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get wasTypedCheck => $composableBuilder(
      column: $table.wasTypedCheck, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get wasTypedExact => $composableBuilder(
      column: $table.wasTypedExact, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get reviewedAt => $composableBuilder(
      column: $table.reviewedAt, builder: (column) => ColumnFilters(column));
}

class $$SrsReviewLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $SrsReviewLogsTable> {
  $$SrsReviewLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cardId => $composableBuilder(
      column: $table.cardId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get stabilityBefore => $composableBuilder(
      column: $table.stabilityBefore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get stabilityAfter => $composableBuilder(
      column: $table.stabilityAfter,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get difficultyAfter => $composableBuilder(
      column: $table.difficultyAfter,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get scheduledDays => $composableBuilder(
      column: $table.scheduledDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get wasTypedCheck => $composableBuilder(
      column: $table.wasTypedCheck,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get wasTypedExact => $composableBuilder(
      column: $table.wasTypedExact,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get reviewedAt => $composableBuilder(
      column: $table.reviewedAt, builder: (column) => ColumnOrderings(column));
}

class $$SrsReviewLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SrsReviewLogsTable> {
  $$SrsReviewLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<double> get stabilityBefore => $composableBuilder(
      column: $table.stabilityBefore, builder: (column) => column);

  GeneratedColumn<double> get stabilityAfter => $composableBuilder(
      column: $table.stabilityAfter, builder: (column) => column);

  GeneratedColumn<double> get difficultyAfter => $composableBuilder(
      column: $table.difficultyAfter, builder: (column) => column);

  GeneratedColumn<int> get scheduledDays => $composableBuilder(
      column: $table.scheduledDays, builder: (column) => column);

  GeneratedColumn<bool> get wasTypedCheck => $composableBuilder(
      column: $table.wasTypedCheck, builder: (column) => column);

  GeneratedColumn<bool> get wasTypedExact => $composableBuilder(
      column: $table.wasTypedExact, builder: (column) => column);

  GeneratedColumn<DateTime> get reviewedAt => $composableBuilder(
      column: $table.reviewedAt, builder: (column) => column);
}

class $$SrsReviewLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SrsReviewLogsTable,
    SrsReviewLogRow,
    $$SrsReviewLogsTableFilterComposer,
    $$SrsReviewLogsTableOrderingComposer,
    $$SrsReviewLogsTableAnnotationComposer,
    $$SrsReviewLogsTableCreateCompanionBuilder,
    $$SrsReviewLogsTableUpdateCompanionBuilder,
    (
      SrsReviewLogRow,
      BaseReferences<_$AppDatabase, $SrsReviewLogsTable, SrsReviewLogRow>
    ),
    SrsReviewLogRow,
    PrefetchHooks Function()> {
  $$SrsReviewLogsTableTableManager(_$AppDatabase db, $SrsReviewLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SrsReviewLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SrsReviewLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SrsReviewLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> cardId = const Value.absent(),
            Value<int> rating = const Value.absent(),
            Value<double> stabilityBefore = const Value.absent(),
            Value<double> stabilityAfter = const Value.absent(),
            Value<double> difficultyAfter = const Value.absent(),
            Value<int> scheduledDays = const Value.absent(),
            Value<bool> wasTypedCheck = const Value.absent(),
            Value<bool> wasTypedExact = const Value.absent(),
            Value<DateTime> reviewedAt = const Value.absent(),
          }) =>
              SrsReviewLogsCompanion(
            id: id,
            cardId: cardId,
            rating: rating,
            stabilityBefore: stabilityBefore,
            stabilityAfter: stabilityAfter,
            difficultyAfter: difficultyAfter,
            scheduledDays: scheduledDays,
            wasTypedCheck: wasTypedCheck,
            wasTypedExact: wasTypedExact,
            reviewedAt: reviewedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String cardId,
            required int rating,
            required double stabilityBefore,
            required double stabilityAfter,
            required double difficultyAfter,
            required int scheduledDays,
            Value<bool> wasTypedCheck = const Value.absent(),
            Value<bool> wasTypedExact = const Value.absent(),
            required DateTime reviewedAt,
          }) =>
              SrsReviewLogsCompanion.insert(
            id: id,
            cardId: cardId,
            rating: rating,
            stabilityBefore: stabilityBefore,
            stabilityAfter: stabilityAfter,
            difficultyAfter: difficultyAfter,
            scheduledDays: scheduledDays,
            wasTypedCheck: wasTypedCheck,
            wasTypedExact: wasTypedExact,
            reviewedAt: reviewedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SrsReviewLogsTable, SrsReviewLogRow>(table),
                    BaseReferences<_$AppDatabase, $SrsReviewLogsTable,
                        SrsReviewLogRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SrsReviewLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SrsReviewLogsTable,
    SrsReviewLogRow,
    $$SrsReviewLogsTableFilterComposer,
    $$SrsReviewLogsTableOrderingComposer,
    $$SrsReviewLogsTableAnnotationComposer,
    $$SrsReviewLogsTableCreateCompanionBuilder,
    $$SrsReviewLogsTableUpdateCompanionBuilder,
    (
      SrsReviewLogRow,
      BaseReferences<_$AppDatabase, $SrsReviewLogsTable, SrsReviewLogRow>
    ),
    SrsReviewLogRow,
    PrefetchHooks Function()>;
typedef $$GrammarVerbsTableCreateCompanionBuilder = GrammarVerbsCompanion
    Function({
  required String id,
  required String lemmaVocalized,
  required String lemmaNormalized,
  Value<String?> infinitiveVocalized,
  required String root,
  required String binyan,
  required String russianMeaning,
  required String grammarNotesRu,
  required String conjugationsJson,
  required String sourceName,
  required String licenseName,
  Value<String?> attributionText,
  Value<int> rowid,
});
typedef $$GrammarVerbsTableUpdateCompanionBuilder = GrammarVerbsCompanion
    Function({
  Value<String> id,
  Value<String> lemmaVocalized,
  Value<String> lemmaNormalized,
  Value<String?> infinitiveVocalized,
  Value<String> root,
  Value<String> binyan,
  Value<String> russianMeaning,
  Value<String> grammarNotesRu,
  Value<String> conjugationsJson,
  Value<String> sourceName,
  Value<String> licenseName,
  Value<String?> attributionText,
  Value<int> rowid,
});

class $$GrammarVerbsTableFilterComposer
    extends Composer<_$AppDatabase, $GrammarVerbsTable> {
  $$GrammarVerbsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lemmaVocalized => $composableBuilder(
      column: $table.lemmaVocalized,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lemmaNormalized => $composableBuilder(
      column: $table.lemmaNormalized,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get infinitiveVocalized => $composableBuilder(
      column: $table.infinitiveVocalized,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get root => $composableBuilder(
      column: $table.root, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get binyan => $composableBuilder(
      column: $table.binyan, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get russianMeaning => $composableBuilder(
      column: $table.russianMeaning,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get grammarNotesRu => $composableBuilder(
      column: $table.grammarNotesRu,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conjugationsJson => $composableBuilder(
      column: $table.conjugationsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceName => $composableBuilder(
      column: $table.sourceName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get licenseName => $composableBuilder(
      column: $table.licenseName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get attributionText => $composableBuilder(
      column: $table.attributionText,
      builder: (column) => ColumnFilters(column));
}

class $$GrammarVerbsTableOrderingComposer
    extends Composer<_$AppDatabase, $GrammarVerbsTable> {
  $$GrammarVerbsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lemmaVocalized => $composableBuilder(
      column: $table.lemmaVocalized,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lemmaNormalized => $composableBuilder(
      column: $table.lemmaNormalized,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get infinitiveVocalized => $composableBuilder(
      column: $table.infinitiveVocalized,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get root => $composableBuilder(
      column: $table.root, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get binyan => $composableBuilder(
      column: $table.binyan, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get russianMeaning => $composableBuilder(
      column: $table.russianMeaning,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get grammarNotesRu => $composableBuilder(
      column: $table.grammarNotesRu,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conjugationsJson => $composableBuilder(
      column: $table.conjugationsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceName => $composableBuilder(
      column: $table.sourceName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get licenseName => $composableBuilder(
      column: $table.licenseName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get attributionText => $composableBuilder(
      column: $table.attributionText,
      builder: (column) => ColumnOrderings(column));
}

class $$GrammarVerbsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GrammarVerbsTable> {
  $$GrammarVerbsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lemmaVocalized => $composableBuilder(
      column: $table.lemmaVocalized, builder: (column) => column);

  GeneratedColumn<String> get lemmaNormalized => $composableBuilder(
      column: $table.lemmaNormalized, builder: (column) => column);

  GeneratedColumn<String> get infinitiveVocalized => $composableBuilder(
      column: $table.infinitiveVocalized, builder: (column) => column);

  GeneratedColumn<String> get root =>
      $composableBuilder(column: $table.root, builder: (column) => column);

  GeneratedColumn<String> get binyan =>
      $composableBuilder(column: $table.binyan, builder: (column) => column);

  GeneratedColumn<String> get russianMeaning => $composableBuilder(
      column: $table.russianMeaning, builder: (column) => column);

  GeneratedColumn<String> get grammarNotesRu => $composableBuilder(
      column: $table.grammarNotesRu, builder: (column) => column);

  GeneratedColumn<String> get conjugationsJson => $composableBuilder(
      column: $table.conjugationsJson, builder: (column) => column);

  GeneratedColumn<String> get sourceName => $composableBuilder(
      column: $table.sourceName, builder: (column) => column);

  GeneratedColumn<String> get licenseName => $composableBuilder(
      column: $table.licenseName, builder: (column) => column);

  GeneratedColumn<String> get attributionText => $composableBuilder(
      column: $table.attributionText, builder: (column) => column);
}

class $$GrammarVerbsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GrammarVerbsTable,
    GrammarVerbRow,
    $$GrammarVerbsTableFilterComposer,
    $$GrammarVerbsTableOrderingComposer,
    $$GrammarVerbsTableAnnotationComposer,
    $$GrammarVerbsTableCreateCompanionBuilder,
    $$GrammarVerbsTableUpdateCompanionBuilder,
    (
      GrammarVerbRow,
      BaseReferences<_$AppDatabase, $GrammarVerbsTable, GrammarVerbRow>
    ),
    GrammarVerbRow,
    PrefetchHooks Function()> {
  $$GrammarVerbsTableTableManager(_$AppDatabase db, $GrammarVerbsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GrammarVerbsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GrammarVerbsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GrammarVerbsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> lemmaVocalized = const Value.absent(),
            Value<String> lemmaNormalized = const Value.absent(),
            Value<String?> infinitiveVocalized = const Value.absent(),
            Value<String> root = const Value.absent(),
            Value<String> binyan = const Value.absent(),
            Value<String> russianMeaning = const Value.absent(),
            Value<String> grammarNotesRu = const Value.absent(),
            Value<String> conjugationsJson = const Value.absent(),
            Value<String> sourceName = const Value.absent(),
            Value<String> licenseName = const Value.absent(),
            Value<String?> attributionText = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GrammarVerbsCompanion(
            id: id,
            lemmaVocalized: lemmaVocalized,
            lemmaNormalized: lemmaNormalized,
            infinitiveVocalized: infinitiveVocalized,
            root: root,
            binyan: binyan,
            russianMeaning: russianMeaning,
            grammarNotesRu: grammarNotesRu,
            conjugationsJson: conjugationsJson,
            sourceName: sourceName,
            licenseName: licenseName,
            attributionText: attributionText,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String lemmaVocalized,
            required String lemmaNormalized,
            Value<String?> infinitiveVocalized = const Value.absent(),
            required String root,
            required String binyan,
            required String russianMeaning,
            required String grammarNotesRu,
            required String conjugationsJson,
            required String sourceName,
            required String licenseName,
            Value<String?> attributionText = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GrammarVerbsCompanion.insert(
            id: id,
            lemmaVocalized: lemmaVocalized,
            lemmaNormalized: lemmaNormalized,
            infinitiveVocalized: infinitiveVocalized,
            root: root,
            binyan: binyan,
            russianMeaning: russianMeaning,
            grammarNotesRu: grammarNotesRu,
            conjugationsJson: conjugationsJson,
            sourceName: sourceName,
            licenseName: licenseName,
            attributionText: attributionText,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$GrammarVerbsTable, GrammarVerbRow>(table),
                    BaseReferences<_$AppDatabase, $GrammarVerbsTable,
                        GrammarVerbRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GrammarVerbsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GrammarVerbsTable,
    GrammarVerbRow,
    $$GrammarVerbsTableFilterComposer,
    $$GrammarVerbsTableOrderingComposer,
    $$GrammarVerbsTableAnnotationComposer,
    $$GrammarVerbsTableCreateCompanionBuilder,
    $$GrammarVerbsTableUpdateCompanionBuilder,
    (
      GrammarVerbRow,
      BaseReferences<_$AppDatabase, $GrammarVerbsTable, GrammarVerbRow>
    ),
    GrammarVerbRow,
    PrefetchHooks Function()>;
typedef $$GrammarPracticeLogsTableCreateCompanionBuilder
    = GrammarPracticeLogsCompanion Function({
  Value<int> id,
  required String verbId,
  required String tense,
  required String person,
  required bool isCorrect,
  required DateTime practicedAt,
});
typedef $$GrammarPracticeLogsTableUpdateCompanionBuilder
    = GrammarPracticeLogsCompanion Function({
  Value<int> id,
  Value<String> verbId,
  Value<String> tense,
  Value<String> person,
  Value<bool> isCorrect,
  Value<DateTime> practicedAt,
});

class $$GrammarPracticeLogsTableFilterComposer
    extends Composer<_$AppDatabase, $GrammarPracticeLogsTable> {
  $$GrammarPracticeLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get verbId => $composableBuilder(
      column: $table.verbId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tense => $composableBuilder(
      column: $table.tense, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get person => $composableBuilder(
      column: $table.person, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCorrect => $composableBuilder(
      column: $table.isCorrect, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get practicedAt => $composableBuilder(
      column: $table.practicedAt, builder: (column) => ColumnFilters(column));
}

class $$GrammarPracticeLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $GrammarPracticeLogsTable> {
  $$GrammarPracticeLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get verbId => $composableBuilder(
      column: $table.verbId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tense => $composableBuilder(
      column: $table.tense, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get person => $composableBuilder(
      column: $table.person, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCorrect => $composableBuilder(
      column: $table.isCorrect, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get practicedAt => $composableBuilder(
      column: $table.practicedAt, builder: (column) => ColumnOrderings(column));
}

class $$GrammarPracticeLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GrammarPracticeLogsTable> {
  $$GrammarPracticeLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get verbId =>
      $composableBuilder(column: $table.verbId, builder: (column) => column);

  GeneratedColumn<String> get tense =>
      $composableBuilder(column: $table.tense, builder: (column) => column);

  GeneratedColumn<String> get person =>
      $composableBuilder(column: $table.person, builder: (column) => column);

  GeneratedColumn<bool> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);

  GeneratedColumn<DateTime> get practicedAt => $composableBuilder(
      column: $table.practicedAt, builder: (column) => column);
}

class $$GrammarPracticeLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GrammarPracticeLogsTable,
    GrammarPracticeLogRow,
    $$GrammarPracticeLogsTableFilterComposer,
    $$GrammarPracticeLogsTableOrderingComposer,
    $$GrammarPracticeLogsTableAnnotationComposer,
    $$GrammarPracticeLogsTableCreateCompanionBuilder,
    $$GrammarPracticeLogsTableUpdateCompanionBuilder,
    (
      GrammarPracticeLogRow,
      BaseReferences<_$AppDatabase, $GrammarPracticeLogsTable,
          GrammarPracticeLogRow>
    ),
    GrammarPracticeLogRow,
    PrefetchHooks Function()> {
  $$GrammarPracticeLogsTableTableManager(
      _$AppDatabase db, $GrammarPracticeLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GrammarPracticeLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GrammarPracticeLogsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GrammarPracticeLogsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> verbId = const Value.absent(),
            Value<String> tense = const Value.absent(),
            Value<String> person = const Value.absent(),
            Value<bool> isCorrect = const Value.absent(),
            Value<DateTime> practicedAt = const Value.absent(),
          }) =>
              GrammarPracticeLogsCompanion(
            id: id,
            verbId: verbId,
            tense: tense,
            person: person,
            isCorrect: isCorrect,
            practicedAt: practicedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String verbId,
            required String tense,
            required String person,
            required bool isCorrect,
            required DateTime practicedAt,
          }) =>
              GrammarPracticeLogsCompanion.insert(
            id: id,
            verbId: verbId,
            tense: tense,
            person: person,
            isCorrect: isCorrect,
            practicedAt: practicedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$GrammarPracticeLogsTable,
                        GrammarPracticeLogRow>(table),
                    BaseReferences<_$AppDatabase, $GrammarPracticeLogsTable,
                        GrammarPracticeLogRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GrammarPracticeLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GrammarPracticeLogsTable,
    GrammarPracticeLogRow,
    $$GrammarPracticeLogsTableFilterComposer,
    $$GrammarPracticeLogsTableOrderingComposer,
    $$GrammarPracticeLogsTableAnnotationComposer,
    $$GrammarPracticeLogsTableCreateCompanionBuilder,
    $$GrammarPracticeLogsTableUpdateCompanionBuilder,
    (
      GrammarPracticeLogRow,
      BaseReferences<_$AppDatabase, $GrammarPracticeLogsTable,
          GrammarPracticeLogRow>
    ),
    GrammarPracticeLogRow,
    PrefetchHooks Function()>;
typedef $$ListeningExercisesTableCreateCompanionBuilder
    = ListeningExercisesCompanion Function({
  required String id,
  required String transcriptVocalized,
  required String transcriptNormalized,
  required String russianTranslation,
  Value<String?> audioUrl,
  Value<String> difficulty,
  required String focusWordsJson,
  required String sourceName,
  required String licenseName,
  Value<String?> attributionText,
  Value<int> rowid,
});
typedef $$ListeningExercisesTableUpdateCompanionBuilder
    = ListeningExercisesCompanion Function({
  Value<String> id,
  Value<String> transcriptVocalized,
  Value<String> transcriptNormalized,
  Value<String> russianTranslation,
  Value<String?> audioUrl,
  Value<String> difficulty,
  Value<String> focusWordsJson,
  Value<String> sourceName,
  Value<String> licenseName,
  Value<String?> attributionText,
  Value<int> rowid,
});

class $$ListeningExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ListeningExercisesTable> {
  $$ListeningExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transcriptVocalized => $composableBuilder(
      column: $table.transcriptVocalized,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transcriptNormalized => $composableBuilder(
      column: $table.transcriptNormalized,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get russianTranslation => $composableBuilder(
      column: $table.russianTranslation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get audioUrl => $composableBuilder(
      column: $table.audioUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get focusWordsJson => $composableBuilder(
      column: $table.focusWordsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceName => $composableBuilder(
      column: $table.sourceName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get licenseName => $composableBuilder(
      column: $table.licenseName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get attributionText => $composableBuilder(
      column: $table.attributionText,
      builder: (column) => ColumnFilters(column));
}

class $$ListeningExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ListeningExercisesTable> {
  $$ListeningExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transcriptVocalized => $composableBuilder(
      column: $table.transcriptVocalized,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transcriptNormalized => $composableBuilder(
      column: $table.transcriptNormalized,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get russianTranslation => $composableBuilder(
      column: $table.russianTranslation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get audioUrl => $composableBuilder(
      column: $table.audioUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get focusWordsJson => $composableBuilder(
      column: $table.focusWordsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceName => $composableBuilder(
      column: $table.sourceName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get licenseName => $composableBuilder(
      column: $table.licenseName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get attributionText => $composableBuilder(
      column: $table.attributionText,
      builder: (column) => ColumnOrderings(column));
}

class $$ListeningExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ListeningExercisesTable> {
  $$ListeningExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get transcriptVocalized => $composableBuilder(
      column: $table.transcriptVocalized, builder: (column) => column);

  GeneratedColumn<String> get transcriptNormalized => $composableBuilder(
      column: $table.transcriptNormalized, builder: (column) => column);

  GeneratedColumn<String> get russianTranslation => $composableBuilder(
      column: $table.russianTranslation, builder: (column) => column);

  GeneratedColumn<String> get audioUrl =>
      $composableBuilder(column: $table.audioUrl, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<String> get focusWordsJson => $composableBuilder(
      column: $table.focusWordsJson, builder: (column) => column);

  GeneratedColumn<String> get sourceName => $composableBuilder(
      column: $table.sourceName, builder: (column) => column);

  GeneratedColumn<String> get licenseName => $composableBuilder(
      column: $table.licenseName, builder: (column) => column);

  GeneratedColumn<String> get attributionText => $composableBuilder(
      column: $table.attributionText, builder: (column) => column);
}

class $$ListeningExercisesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ListeningExercisesTable,
    ListeningExerciseRow,
    $$ListeningExercisesTableFilterComposer,
    $$ListeningExercisesTableOrderingComposer,
    $$ListeningExercisesTableAnnotationComposer,
    $$ListeningExercisesTableCreateCompanionBuilder,
    $$ListeningExercisesTableUpdateCompanionBuilder,
    (
      ListeningExerciseRow,
      BaseReferences<_$AppDatabase, $ListeningExercisesTable,
          ListeningExerciseRow>
    ),
    ListeningExerciseRow,
    PrefetchHooks Function()> {
  $$ListeningExercisesTableTableManager(
      _$AppDatabase db, $ListeningExercisesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ListeningExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ListeningExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ListeningExercisesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> transcriptVocalized = const Value.absent(),
            Value<String> transcriptNormalized = const Value.absent(),
            Value<String> russianTranslation = const Value.absent(),
            Value<String?> audioUrl = const Value.absent(),
            Value<String> difficulty = const Value.absent(),
            Value<String> focusWordsJson = const Value.absent(),
            Value<String> sourceName = const Value.absent(),
            Value<String> licenseName = const Value.absent(),
            Value<String?> attributionText = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ListeningExercisesCompanion(
            id: id,
            transcriptVocalized: transcriptVocalized,
            transcriptNormalized: transcriptNormalized,
            russianTranslation: russianTranslation,
            audioUrl: audioUrl,
            difficulty: difficulty,
            focusWordsJson: focusWordsJson,
            sourceName: sourceName,
            licenseName: licenseName,
            attributionText: attributionText,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String transcriptVocalized,
            required String transcriptNormalized,
            required String russianTranslation,
            Value<String?> audioUrl = const Value.absent(),
            Value<String> difficulty = const Value.absent(),
            required String focusWordsJson,
            required String sourceName,
            required String licenseName,
            Value<String?> attributionText = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ListeningExercisesCompanion.insert(
            id: id,
            transcriptVocalized: transcriptVocalized,
            transcriptNormalized: transcriptNormalized,
            russianTranslation: russianTranslation,
            audioUrl: audioUrl,
            difficulty: difficulty,
            focusWordsJson: focusWordsJson,
            sourceName: sourceName,
            licenseName: licenseName,
            attributionText: attributionText,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ListeningExercisesTable, ListeningExerciseRow>(
                        table),
                    BaseReferences<_$AppDatabase, $ListeningExercisesTable,
                        ListeningExerciseRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ListeningExercisesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ListeningExercisesTable,
    ListeningExerciseRow,
    $$ListeningExercisesTableFilterComposer,
    $$ListeningExercisesTableOrderingComposer,
    $$ListeningExercisesTableAnnotationComposer,
    $$ListeningExercisesTableCreateCompanionBuilder,
    $$ListeningExercisesTableUpdateCompanionBuilder,
    (
      ListeningExerciseRow,
      BaseReferences<_$AppDatabase, $ListeningExercisesTable,
          ListeningExerciseRow>
    ),
    ListeningExerciseRow,
    PrefetchHooks Function()>;
typedef $$ListeningAttemptLogsTableCreateCompanionBuilder
    = ListeningAttemptLogsCompanion Function({
  Value<int> id,
  required String exerciseId,
  required double wordAccuracy,
  required bool isExactMatch,
  required DateTime attemptedAt,
});
typedef $$ListeningAttemptLogsTableUpdateCompanionBuilder
    = ListeningAttemptLogsCompanion Function({
  Value<int> id,
  Value<String> exerciseId,
  Value<double> wordAccuracy,
  Value<bool> isExactMatch,
  Value<DateTime> attemptedAt,
});

class $$ListeningAttemptLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ListeningAttemptLogsTable> {
  $$ListeningAttemptLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exerciseId => $composableBuilder(
      column: $table.exerciseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get wordAccuracy => $composableBuilder(
      column: $table.wordAccuracy, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isExactMatch => $composableBuilder(
      column: $table.isExactMatch, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get attemptedAt => $composableBuilder(
      column: $table.attemptedAt, builder: (column) => ColumnFilters(column));
}

class $$ListeningAttemptLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ListeningAttemptLogsTable> {
  $$ListeningAttemptLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exerciseId => $composableBuilder(
      column: $table.exerciseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get wordAccuracy => $composableBuilder(
      column: $table.wordAccuracy,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isExactMatch => $composableBuilder(
      column: $table.isExactMatch,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get attemptedAt => $composableBuilder(
      column: $table.attemptedAt, builder: (column) => ColumnOrderings(column));
}

class $$ListeningAttemptLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ListeningAttemptLogsTable> {
  $$ListeningAttemptLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get exerciseId => $composableBuilder(
      column: $table.exerciseId, builder: (column) => column);

  GeneratedColumn<double> get wordAccuracy => $composableBuilder(
      column: $table.wordAccuracy, builder: (column) => column);

  GeneratedColumn<bool> get isExactMatch => $composableBuilder(
      column: $table.isExactMatch, builder: (column) => column);

  GeneratedColumn<DateTime> get attemptedAt => $composableBuilder(
      column: $table.attemptedAt, builder: (column) => column);
}

class $$ListeningAttemptLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ListeningAttemptLogsTable,
    ListeningAttemptLogRow,
    $$ListeningAttemptLogsTableFilterComposer,
    $$ListeningAttemptLogsTableOrderingComposer,
    $$ListeningAttemptLogsTableAnnotationComposer,
    $$ListeningAttemptLogsTableCreateCompanionBuilder,
    $$ListeningAttemptLogsTableUpdateCompanionBuilder,
    (
      ListeningAttemptLogRow,
      BaseReferences<_$AppDatabase, $ListeningAttemptLogsTable,
          ListeningAttemptLogRow>
    ),
    ListeningAttemptLogRow,
    PrefetchHooks Function()> {
  $$ListeningAttemptLogsTableTableManager(
      _$AppDatabase db, $ListeningAttemptLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ListeningAttemptLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ListeningAttemptLogsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ListeningAttemptLogsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> exerciseId = const Value.absent(),
            Value<double> wordAccuracy = const Value.absent(),
            Value<bool> isExactMatch = const Value.absent(),
            Value<DateTime> attemptedAt = const Value.absent(),
          }) =>
              ListeningAttemptLogsCompanion(
            id: id,
            exerciseId: exerciseId,
            wordAccuracy: wordAccuracy,
            isExactMatch: isExactMatch,
            attemptedAt: attemptedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String exerciseId,
            required double wordAccuracy,
            required bool isExactMatch,
            required DateTime attemptedAt,
          }) =>
              ListeningAttemptLogsCompanion.insert(
            id: id,
            exerciseId: exerciseId,
            wordAccuracy: wordAccuracy,
            isExactMatch: isExactMatch,
            attemptedAt: attemptedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ListeningAttemptLogsTable,
                        ListeningAttemptLogRow>(table),
                    BaseReferences<_$AppDatabase, $ListeningAttemptLogsTable,
                        ListeningAttemptLogRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ListeningAttemptLogsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ListeningAttemptLogsTable,
        ListeningAttemptLogRow,
        $$ListeningAttemptLogsTableFilterComposer,
        $$ListeningAttemptLogsTableOrderingComposer,
        $$ListeningAttemptLogsTableAnnotationComposer,
        $$ListeningAttemptLogsTableCreateCompanionBuilder,
        $$ListeningAttemptLogsTableUpdateCompanionBuilder,
        (
          ListeningAttemptLogRow,
          BaseReferences<_$AppDatabase, $ListeningAttemptLogsTable,
              ListeningAttemptLogRow>
        ),
        ListeningAttemptLogRow,
        PrefetchHooks Function()>;
typedef $$DictionaryEntriesTableCreateCompanionBuilder
    = DictionaryEntriesCompanion Function({
  required String id,
  required String hebrewVocalized,
  required String hebrewNormalized,
  required String russianTranslation,
  Value<String?> transliteration,
  Value<String> category,
  Value<String?> root,
  Value<String> binyan,
  Value<String?> formsSummary,
  Value<String?> exampleHebrewVocalized,
  Value<String?> exampleHebrewNormalized,
  Value<String?> exampleRussian,
  Value<String?> audioUrl,
  Value<int?> frequencyRank,
  required String sourceName,
  required String licenseName,
  Value<String?> attributionText,
  Value<bool> isUserAdded,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$DictionaryEntriesTableUpdateCompanionBuilder
    = DictionaryEntriesCompanion Function({
  Value<String> id,
  Value<String> hebrewVocalized,
  Value<String> hebrewNormalized,
  Value<String> russianTranslation,
  Value<String?> transliteration,
  Value<String> category,
  Value<String?> root,
  Value<String> binyan,
  Value<String?> formsSummary,
  Value<String?> exampleHebrewVocalized,
  Value<String?> exampleHebrewNormalized,
  Value<String?> exampleRussian,
  Value<String?> audioUrl,
  Value<int?> frequencyRank,
  Value<String> sourceName,
  Value<String> licenseName,
  Value<String?> attributionText,
  Value<bool> isUserAdded,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$DictionaryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DictionaryEntriesTable> {
  $$DictionaryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hebrewVocalized => $composableBuilder(
      column: $table.hebrewVocalized,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hebrewNormalized => $composableBuilder(
      column: $table.hebrewNormalized,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get russianTranslation => $composableBuilder(
      column: $table.russianTranslation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transliteration => $composableBuilder(
      column: $table.transliteration,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get root => $composableBuilder(
      column: $table.root, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get binyan => $composableBuilder(
      column: $table.binyan, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get formsSummary => $composableBuilder(
      column: $table.formsSummary, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exampleHebrewVocalized => $composableBuilder(
      column: $table.exampleHebrewVocalized,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exampleHebrewNormalized => $composableBuilder(
      column: $table.exampleHebrewNormalized,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exampleRussian => $composableBuilder(
      column: $table.exampleRussian,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get audioUrl => $composableBuilder(
      column: $table.audioUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get frequencyRank => $composableBuilder(
      column: $table.frequencyRank, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceName => $composableBuilder(
      column: $table.sourceName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get licenseName => $composableBuilder(
      column: $table.licenseName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get attributionText => $composableBuilder(
      column: $table.attributionText,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isUserAdded => $composableBuilder(
      column: $table.isUserAdded, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$DictionaryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DictionaryEntriesTable> {
  $$DictionaryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hebrewVocalized => $composableBuilder(
      column: $table.hebrewVocalized,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hebrewNormalized => $composableBuilder(
      column: $table.hebrewNormalized,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get russianTranslation => $composableBuilder(
      column: $table.russianTranslation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transliteration => $composableBuilder(
      column: $table.transliteration,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get root => $composableBuilder(
      column: $table.root, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get binyan => $composableBuilder(
      column: $table.binyan, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get formsSummary => $composableBuilder(
      column: $table.formsSummary,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exampleHebrewVocalized => $composableBuilder(
      column: $table.exampleHebrewVocalized,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exampleHebrewNormalized => $composableBuilder(
      column: $table.exampleHebrewNormalized,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exampleRussian => $composableBuilder(
      column: $table.exampleRussian,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get audioUrl => $composableBuilder(
      column: $table.audioUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get frequencyRank => $composableBuilder(
      column: $table.frequencyRank,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceName => $composableBuilder(
      column: $table.sourceName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get licenseName => $composableBuilder(
      column: $table.licenseName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get attributionText => $composableBuilder(
      column: $table.attributionText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isUserAdded => $composableBuilder(
      column: $table.isUserAdded, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$DictionaryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DictionaryEntriesTable> {
  $$DictionaryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hebrewVocalized => $composableBuilder(
      column: $table.hebrewVocalized, builder: (column) => column);

  GeneratedColumn<String> get hebrewNormalized => $composableBuilder(
      column: $table.hebrewNormalized, builder: (column) => column);

  GeneratedColumn<String> get russianTranslation => $composableBuilder(
      column: $table.russianTranslation, builder: (column) => column);

  GeneratedColumn<String> get transliteration => $composableBuilder(
      column: $table.transliteration, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get root =>
      $composableBuilder(column: $table.root, builder: (column) => column);

  GeneratedColumn<String> get binyan =>
      $composableBuilder(column: $table.binyan, builder: (column) => column);

  GeneratedColumn<String> get formsSummary => $composableBuilder(
      column: $table.formsSummary, builder: (column) => column);

  GeneratedColumn<String> get exampleHebrewVocalized => $composableBuilder(
      column: $table.exampleHebrewVocalized, builder: (column) => column);

  GeneratedColumn<String> get exampleHebrewNormalized => $composableBuilder(
      column: $table.exampleHebrewNormalized, builder: (column) => column);

  GeneratedColumn<String> get exampleRussian => $composableBuilder(
      column: $table.exampleRussian, builder: (column) => column);

  GeneratedColumn<String> get audioUrl =>
      $composableBuilder(column: $table.audioUrl, builder: (column) => column);

  GeneratedColumn<int> get frequencyRank => $composableBuilder(
      column: $table.frequencyRank, builder: (column) => column);

  GeneratedColumn<String> get sourceName => $composableBuilder(
      column: $table.sourceName, builder: (column) => column);

  GeneratedColumn<String> get licenseName => $composableBuilder(
      column: $table.licenseName, builder: (column) => column);

  GeneratedColumn<String> get attributionText => $composableBuilder(
      column: $table.attributionText, builder: (column) => column);

  GeneratedColumn<bool> get isUserAdded => $composableBuilder(
      column: $table.isUserAdded, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DictionaryEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DictionaryEntriesTable,
    DictionaryEntryRow,
    $$DictionaryEntriesTableFilterComposer,
    $$DictionaryEntriesTableOrderingComposer,
    $$DictionaryEntriesTableAnnotationComposer,
    $$DictionaryEntriesTableCreateCompanionBuilder,
    $$DictionaryEntriesTableUpdateCompanionBuilder,
    (
      DictionaryEntryRow,
      BaseReferences<_$AppDatabase, $DictionaryEntriesTable, DictionaryEntryRow>
    ),
    DictionaryEntryRow,
    PrefetchHooks Function()> {
  $$DictionaryEntriesTableTableManager(
      _$AppDatabase db, $DictionaryEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DictionaryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DictionaryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DictionaryEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> hebrewVocalized = const Value.absent(),
            Value<String> hebrewNormalized = const Value.absent(),
            Value<String> russianTranslation = const Value.absent(),
            Value<String?> transliteration = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String?> root = const Value.absent(),
            Value<String> binyan = const Value.absent(),
            Value<String?> formsSummary = const Value.absent(),
            Value<String?> exampleHebrewVocalized = const Value.absent(),
            Value<String?> exampleHebrewNormalized = const Value.absent(),
            Value<String?> exampleRussian = const Value.absent(),
            Value<String?> audioUrl = const Value.absent(),
            Value<int?> frequencyRank = const Value.absent(),
            Value<String> sourceName = const Value.absent(),
            Value<String> licenseName = const Value.absent(),
            Value<String?> attributionText = const Value.absent(),
            Value<bool> isUserAdded = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DictionaryEntriesCompanion(
            id: id,
            hebrewVocalized: hebrewVocalized,
            hebrewNormalized: hebrewNormalized,
            russianTranslation: russianTranslation,
            transliteration: transliteration,
            category: category,
            root: root,
            binyan: binyan,
            formsSummary: formsSummary,
            exampleHebrewVocalized: exampleHebrewVocalized,
            exampleHebrewNormalized: exampleHebrewNormalized,
            exampleRussian: exampleRussian,
            audioUrl: audioUrl,
            frequencyRank: frequencyRank,
            sourceName: sourceName,
            licenseName: licenseName,
            attributionText: attributionText,
            isUserAdded: isUserAdded,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String hebrewVocalized,
            required String hebrewNormalized,
            required String russianTranslation,
            Value<String?> transliteration = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String?> root = const Value.absent(),
            Value<String> binyan = const Value.absent(),
            Value<String?> formsSummary = const Value.absent(),
            Value<String?> exampleHebrewVocalized = const Value.absent(),
            Value<String?> exampleHebrewNormalized = const Value.absent(),
            Value<String?> exampleRussian = const Value.absent(),
            Value<String?> audioUrl = const Value.absent(),
            Value<int?> frequencyRank = const Value.absent(),
            required String sourceName,
            required String licenseName,
            Value<String?> attributionText = const Value.absent(),
            Value<bool> isUserAdded = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DictionaryEntriesCompanion.insert(
            id: id,
            hebrewVocalized: hebrewVocalized,
            hebrewNormalized: hebrewNormalized,
            russianTranslation: russianTranslation,
            transliteration: transliteration,
            category: category,
            root: root,
            binyan: binyan,
            formsSummary: formsSummary,
            exampleHebrewVocalized: exampleHebrewVocalized,
            exampleHebrewNormalized: exampleHebrewNormalized,
            exampleRussian: exampleRussian,
            audioUrl: audioUrl,
            frequencyRank: frequencyRank,
            sourceName: sourceName,
            licenseName: licenseName,
            attributionText: attributionText,
            isUserAdded: isUserAdded,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$DictionaryEntriesTable, DictionaryEntryRow>(
                        table),
                    BaseReferences<_$AppDatabase, $DictionaryEntriesTable,
                        DictionaryEntryRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DictionaryEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DictionaryEntriesTable,
    DictionaryEntryRow,
    $$DictionaryEntriesTableFilterComposer,
    $$DictionaryEntriesTableOrderingComposer,
    $$DictionaryEntriesTableAnnotationComposer,
    $$DictionaryEntriesTableCreateCompanionBuilder,
    $$DictionaryEntriesTableUpdateCompanionBuilder,
    (
      DictionaryEntryRow,
      BaseReferences<_$AppDatabase, $DictionaryEntriesTable, DictionaryEntryRow>
    ),
    DictionaryEntryRow,
    PrefetchHooks Function()>;
typedef $$SceneProgressEntriesTableCreateCompanionBuilder
    = SceneProgressEntriesCompanion Function({
  required String sceneId,
  Value<bool> isCompleted,
  Value<int> wordsMasteredCount,
  Value<int> challengeScore,
  required DateTime lastVisitedAt,
  Value<int> rowid,
});
typedef $$SceneProgressEntriesTableUpdateCompanionBuilder
    = SceneProgressEntriesCompanion Function({
  Value<String> sceneId,
  Value<bool> isCompleted,
  Value<int> wordsMasteredCount,
  Value<int> challengeScore,
  Value<DateTime> lastVisitedAt,
  Value<int> rowid,
});

class $$SceneProgressEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SceneProgressEntriesTable> {
  $$SceneProgressEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sceneId => $composableBuilder(
      column: $table.sceneId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wordsMasteredCount => $composableBuilder(
      column: $table.wordsMasteredCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get challengeScore => $composableBuilder(
      column: $table.challengeScore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastVisitedAt => $composableBuilder(
      column: $table.lastVisitedAt, builder: (column) => ColumnFilters(column));
}

class $$SceneProgressEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SceneProgressEntriesTable> {
  $$SceneProgressEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sceneId => $composableBuilder(
      column: $table.sceneId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wordsMasteredCount => $composableBuilder(
      column: $table.wordsMasteredCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get challengeScore => $composableBuilder(
      column: $table.challengeScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastVisitedAt => $composableBuilder(
      column: $table.lastVisitedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$SceneProgressEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SceneProgressEntriesTable> {
  $$SceneProgressEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sceneId =>
      $composableBuilder(column: $table.sceneId, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<int> get wordsMasteredCount => $composableBuilder(
      column: $table.wordsMasteredCount, builder: (column) => column);

  GeneratedColumn<int> get challengeScore => $composableBuilder(
      column: $table.challengeScore, builder: (column) => column);

  GeneratedColumn<DateTime> get lastVisitedAt => $composableBuilder(
      column: $table.lastVisitedAt, builder: (column) => column);
}

class $$SceneProgressEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SceneProgressEntriesTable,
    SceneProgressRow,
    $$SceneProgressEntriesTableFilterComposer,
    $$SceneProgressEntriesTableOrderingComposer,
    $$SceneProgressEntriesTableAnnotationComposer,
    $$SceneProgressEntriesTableCreateCompanionBuilder,
    $$SceneProgressEntriesTableUpdateCompanionBuilder,
    (
      SceneProgressRow,
      BaseReferences<_$AppDatabase, $SceneProgressEntriesTable,
          SceneProgressRow>
    ),
    SceneProgressRow,
    PrefetchHooks Function()> {
  $$SceneProgressEntriesTableTableManager(
      _$AppDatabase db, $SceneProgressEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SceneProgressEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SceneProgressEntriesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SceneProgressEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> sceneId = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<int> wordsMasteredCount = const Value.absent(),
            Value<int> challengeScore = const Value.absent(),
            Value<DateTime> lastVisitedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SceneProgressEntriesCompanion(
            sceneId: sceneId,
            isCompleted: isCompleted,
            wordsMasteredCount: wordsMasteredCount,
            challengeScore: challengeScore,
            lastVisitedAt: lastVisitedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String sceneId,
            Value<bool> isCompleted = const Value.absent(),
            Value<int> wordsMasteredCount = const Value.absent(),
            Value<int> challengeScore = const Value.absent(),
            required DateTime lastVisitedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SceneProgressEntriesCompanion.insert(
            sceneId: sceneId,
            isCompleted: isCompleted,
            wordsMasteredCount: wordsMasteredCount,
            challengeScore: challengeScore,
            lastVisitedAt: lastVisitedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SceneProgressEntriesTable, SceneProgressRow>(
                        table),
                    BaseReferences<_$AppDatabase, $SceneProgressEntriesTable,
                        SceneProgressRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SceneProgressEntriesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $SceneProgressEntriesTable,
        SceneProgressRow,
        $$SceneProgressEntriesTableFilterComposer,
        $$SceneProgressEntriesTableOrderingComposer,
        $$SceneProgressEntriesTableAnnotationComposer,
        $$SceneProgressEntriesTableCreateCompanionBuilder,
        $$SceneProgressEntriesTableUpdateCompanionBuilder,
        (
          SceneProgressRow,
          BaseReferences<_$AppDatabase, $SceneProgressEntriesTable,
              SceneProgressRow>
        ),
        SceneProgressRow,
        PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DialogueNodesTableTableManager get dialogueNodes =>
      $$DialogueNodesTableTableManager(_db, _db.dialogueNodes);
  $$DialogueHistoryEntriesTableTableManager get dialogueHistoryEntries =>
      $$DialogueHistoryEntriesTableTableManager(
          _db, _db.dialogueHistoryEntries);
  $$SrsCardsTableTableManager get srsCards =>
      $$SrsCardsTableTableManager(_db, _db.srsCards);
  $$SrsReviewLogsTableTableManager get srsReviewLogs =>
      $$SrsReviewLogsTableTableManager(_db, _db.srsReviewLogs);
  $$GrammarVerbsTableTableManager get grammarVerbs =>
      $$GrammarVerbsTableTableManager(_db, _db.grammarVerbs);
  $$GrammarPracticeLogsTableTableManager get grammarPracticeLogs =>
      $$GrammarPracticeLogsTableTableManager(_db, _db.grammarPracticeLogs);
  $$ListeningExercisesTableTableManager get listeningExercises =>
      $$ListeningExercisesTableTableManager(_db, _db.listeningExercises);
  $$ListeningAttemptLogsTableTableManager get listeningAttemptLogs =>
      $$ListeningAttemptLogsTableTableManager(_db, _db.listeningAttemptLogs);
  $$DictionaryEntriesTableTableManager get dictionaryEntries =>
      $$DictionaryEntriesTableTableManager(_db, _db.dictionaryEntries);
  $$SceneProgressEntriesTableTableManager get sceneProgressEntries =>
      $$SceneProgressEntriesTableTableManager(_db, _db.sceneProgressEntries);
}
