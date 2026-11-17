import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/json_reader.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/binyan.dart';
import '../../domain/entities/dialogue_node.dart';
import '../../domain/entities/hebrew_text.dart';

final class DialogueOptionDto extends Equatable {
  final String id;
  final String textHebrew;
  final String textRussian;
  final String? root;
  final String binyan;
  final String nextNodeId;

  const DialogueOptionDto({
    required this.id,
    required this.textHebrew,
    required this.textRussian,
    required this.nextNodeId,
    required this.binyan,
    this.root,
  });

  static Result<DialogueOptionDto, ParsingFailure> fromReader(
    JsonReader reader,
  ) {
    final idRes = reader.requireNonEmptyString('id');
    final textHebrewRes = reader.requireNonEmptyString('text_hebrew');
    final textRussianRes = reader.requireNonEmptyString('text_russian');
    final nextNodeIdRes = reader.requireNonEmptyString('next_node_id');
    final binyanRes = reader.optionalNonEmptyString('binyan');
    final rootRes = reader.optionalNonEmptyString('root');

    if (idRes case Error(:final failure)) return Error(failure);
    if (textHebrewRes case Error(:final failure)) return Error(failure);
    if (textRussianRes case Error(:final failure)) return Error(failure);
    if (nextNodeIdRes case Error(:final failure)) return Error(failure);
    if (binyanRes case Error(:final failure)) return Error(failure);
    if (rootRes case Error(:final failure)) return Error(failure);

    return Success(
      DialogueOptionDto(
        id: idRes.getOrNull()!,
        textHebrew: textHebrewRes.getOrNull()!,
        textRussian: textRussianRes.getOrNull()!,
        nextNodeId: nextNodeIdRes.getOrNull()!,
        binyan: binyanRes.getOrNull() ?? 'none',
        root: rootRes.getOrNull(),
      ),
    );
  }

  Map<String, Object?> toJsonMap() => <String, Object?>{
        'id': id,
        'text_hebrew': textHebrew,
        'text_russian': textRussian,
        'next_node_id': nextNodeId,
        'binyan': binyan,
        'root': root,
      };

  Result<DialogueOption, Failure> toDomain() {
    final hebrewRes = HebrewText.create(textHebrew);
    if (hebrewRes case Error(:final failure)) {
      return Error(ParsingFailure('Option "$id": ${failure.message}'));
    }

    final binyanRes = Binyan.parseStrict(binyan);
    if (binyanRes case Error(:final failure)) {
      return Error(ParsingFailure('Option "$id": ${failure.message}'));
    }

    Shoresh? parsedRoot;
    final rawRoot = root;
    if (rawRoot != null) {
      final rootRes = Shoresh.create(rawRoot);
      switch (rootRes) {
        case Success(:final data):
          parsedRoot = data;
        case Error(:final failure):
          return Error(ParsingFailure('Option "$id": ${failure.message}'));
      }
    }

    return Success(
      DialogueOption(
        id: id,
        textHebrew: hebrewRes.getOrNull()!,
        textRussian: textRussian,
        nextNodeId: nextNodeId,
        root: parsedRoot,
        binyan: binyanRes.getOrNull()!,
      ),
    );
  }

  @override
  List<Object?> get props => [
        id,
        textHebrew,
        textRussian,
        root,
        binyan,
        nextNodeId,
      ];
}

final class DialogueNodeDto extends Equatable {
  final String id;
  final String speakerHebrew;
  final String? speakerRussian;
  final String lineHebrew;
  final String lineRussian;
  final String? audioPath;
  final List<DialogueOptionDto> options;

  DialogueNodeDto({
    required this.id,
    required this.speakerHebrew,
    required this.lineHebrew,
    required this.lineRussian,
    required List<DialogueOptionDto> options,
    this.speakerRussian,
    this.audioPath,
  }) : options = List<DialogueOptionDto>.unmodifiable(options);

  static Result<DialogueNodeDto, ParsingFailure> fromJsonString(
    String rawJson,
  ) {
    final readerRes = JsonReader.parseObject(rawJson);
    return switch (readerRes) {
      Success(:final data) => fromReader(data),
      Error(:final failure) => Error(failure),
    };
  }

  static Result<DialogueNodeDto, ParsingFailure> fromReader(
    JsonReader reader,
  ) {
    final idRes = reader.requireNonEmptyString('id');
    final lineHebrewRes = reader.requireNonEmptyString('line_hebrew');
    final lineRussianRes = reader.requireNonEmptyString('line_russian');
    final audioPathRes = reader.optionalNonEmptyString('audio_path');
    final optionsReadersRes = reader.requireObjectList('options');

    if (idRes case Error(:final failure)) return Error(failure);
    if (lineHebrewRes case Error(:final failure)) return Error(failure);
    if (lineRussianRes case Error(:final failure)) return Error(failure);
    if (audioPathRes case Error(:final failure)) return Error(failure);
    if (optionsReadersRes case Error(:final failure)) return Error(failure);

    final speakerRes = _extractSpeakerFields(reader);
    if (speakerRes case Error(:final failure)) return Error(failure);

    final parsedOptions = <DialogueOptionDto>[];
    for (final optionReader in optionsReadersRes.getOrNull()!) {
      final optRes = DialogueOptionDto.fromReader(optionReader);
      switch (optRes) {
        case Success(:final data):
          parsedOptions.add(data);
        case Error(:final failure):
          return Error(failure);
      }
    }

    final speaker = speakerRes.getOrNull()!;
    return Success(
      DialogueNodeDto(
        id: idRes.getOrNull()!,
        speakerHebrew: speaker.hebrew,
        speakerRussian: speaker.russian,
        lineHebrew: lineHebrewRes.getOrNull()!,
        lineRussian: lineRussianRes.getOrNull()!,
        audioPath: audioPathRes.getOrNull(),
        options: parsedOptions,
      ),
    );
  }

  static Result<({String hebrew, String? russian}), ParsingFailure>
      _extractSpeakerFields(JsonReader reader) {
    final hebrewRes = reader.optionalNonEmptyString('speaker_hebrew');
    final russianRes = reader.optionalNonEmptyString('speaker_russian');

    if (hebrewRes case Error(:final failure)) return Error(failure);
    if (russianRes case Error(:final failure)) return Error(failure);

    final hebrew = hebrewRes.getOrNull();
    final russian = russianRes.getOrNull();
    if (hebrew != null) {
      return Success((hebrew: hebrew, russian: russian));
    }

    // Legacy fallback if remote sends combined "character_name": "מוֹכֵר (Продавец)"
    final legacyRes = reader.requireNonEmptyString('character_name');
    if (legacyRes case Error(:final failure)) return Error(failure);

    final legacy = legacyRes.getOrNull()!;
    final match = RegExp(r'^(.+?)\s*\(([^)]+)\)\s*$').firstMatch(legacy);
    if (match != null) {
      final parsedHebrew = match.group(1)?.trim() ?? legacy;
      final parsedRussian = match.group(2)?.trim();
      return Success((hebrew: parsedHebrew, russian: parsedRussian));
    }
    return Success((hebrew: legacy, russian: null));
  }

  static Result<List<DialogueOptionDto>, ParsingFailure> decodeOptionsJson(
    String rawOptionsJson,
  ) {
    final readersRes = JsonReader.parseObjectList(rawOptionsJson);
    if (readersRes case Error(:final failure)) {
      return Error(failure);
    }
    final result = <DialogueOptionDto>[];
    for (final reader in readersRes.getOrNull()!) {
      final dtoRes = DialogueOptionDto.fromReader(reader);
      switch (dtoRes) {
        case Success(:final data):
          result.add(data);
        case Error(:final failure):
          return Error(failure);
      }
    }
    return Success(List<DialogueOptionDto>.unmodifiable(result));
  }

  String encodeOptionsJson() {
    return jsonEncode(
      options.map((option) => option.toJsonMap()).toList(growable: false),
    );
  }

  Map<String, Object?> toJsonMap() => <String, Object?>{
        'id': id,
        'speaker_hebrew': speakerHebrew,
        'speaker_russian': speakerRussian,
        'line_hebrew': lineHebrew,
        'line_russian': lineRussian,
        'audio_path': audioPath,
        'options': options.map((e) => e.toJsonMap()).toList(growable: false),
      };

  Result<DialogueNode, Failure> toDomain() {
    final speakerHebRes = HebrewText.create(speakerHebrew);
    if (speakerHebRes case Error(:final failure)) {
      return Error(ParsingFailure('Node "$id" speaker: ${failure.message}'));
    }

    final lineHebRes = HebrewText.create(lineHebrew);
    if (lineHebRes case Error(:final failure)) {
      return Error(ParsingFailure('Node "$id" line: ${failure.message}'));
    }

    final domainOptions = <DialogueOption>[];
    for (final optionDto in options) {
      final optDomainRes = optionDto.toDomain();
      switch (optDomainRes) {
        case Success(:final data):
          domainOptions.add(data);
        case Error(:final failure):
          return Error(failure);
      }
    }

    return Success(
      DialogueNode(
        id: id,
        speaker: SpeakerName(
          hebrew: speakerHebRes.getOrNull()!,
          russian: speakerRussian,
        ),
        lineHebrew: lineHebRes.getOrNull()!,
        lineRussian: lineRussian,
        audioPath: audioPath,
        options: domainOptions,
      ),
    );
  }

  @override
  List<Object?> get props => [
        id,
        speakerHebrew,
        speakerRussian,
        lineHebrew,
        lineRussian,
        audioPath,
        options,
      ];
}
