import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/json_reader.dart';
import '../../../../core/result/result.dart';
import '../../../../core/utils/hebrew_normalizer.dart';
import '../models/dialogue_node_dto.dart';

final class DialogueHistoryRecord {
  final int entryId;
  final String nodeId;
  final String selectedOptionId;
  final DateTime answeredAt;

  const DialogueHistoryRecord({
    required this.entryId,
    required this.nodeId,
    required this.selectedOptionId,
    required this.answeredAt,
  });
}

abstract interface class DialogueLocalDataSource {
  Future<Result<DialogueNodeDto?, Failure>> getCachedNode(String id);
  Future<Result<void, Failure>> cacheNode(DialogueNodeDto node);
  Future<Result<void, Failure>> cacheNodes(List<DialogueNodeDto> nodes);
  Future<Result<List<DialogueNodeDto>, Failure>> searchNodesByNormalizedHebrew(
    String normalizedQuery,
  );
  Future<Result<void, Failure>> recordSelection({
    required String nodeId,
    required String optionId,
    required DateTime answeredAt,
  });
  Future<Result<List<DialogueHistoryRecord>, Failure>> getUnsyncedHistory();
  Future<Result<void, Failure>> markHistorySynced(List<int> entryIds);
}

final class DriftDialogueLocalDataSource implements DialogueLocalDataSource {
  static const String _tag = 'DriftDialogueLocalDataSource';

  final AppDatabase _database;
  final AppLogger _logger;

  const DriftDialogueLocalDataSource({
    required AppDatabase database,
    required AppLogger logger,
  })  : _database = database,
        _logger = logger;

  @override
  Future<Result<DialogueNodeDto?, Failure>> getCachedNode(String id) async {
    try {
      final row = await _database.findDialogueNodeById(id);
      if (row == null) {
        return const Success(null);
      }
      return _rowToDto(row);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to query cached node "$id"',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(CacheFailure('Failed to read local dialogue cache'));
    }
  }

  @override
  Future<Result<void, Failure>> cacheNode(DialogueNodeDto node) async {
    try {
      await _database.upsertDialogueNode(_dtoToCompanion(node));
      return const Success(null);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to cache node "${node.id}"',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(CacheFailure('Failed to cache dialogue node locally'));
    }
  }

  @override
  Future<Result<void, Failure>> cacheNodes(List<DialogueNodeDto> nodes) async {
    if (nodes.isEmpty) {
      return const Success(null);
    }
    try {
      final companions =
          nodes.map(_dtoToCompanion).toList(growable: false);
      await _database.upsertDialogueNodes(companions);
      return const Success(null);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to batch cache ${nodes.length} dialogue nodes',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(CacheFailure('Failed to batch cache dialogue nodes'));
    }
  }

  @override
  Future<Result<List<DialogueNodeDto>, Failure>> searchNodesByNormalizedHebrew(
    String normalizedQuery,
  ) async {
    try {
      final rows = await _database.searchDialogueNodesByNormalizedHebrew(
        normalizedQuery,
      );
      final dtos = <DialogueNodeDto>[];
      for (final row in rows) {
        final dtoRes = _rowToDto(row);
        switch (dtoRes) {
          case Success(:final data):
            dtos.add(data);
          case Error(:final failure):
            return Error(failure);
        }
      }
      return Success(List<DialogueNodeDto>.unmodifiable(dtos));
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to search local dialogue cache',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(CacheFailure('Failed to search offline dialogues'));
    }
  }

  @override
  Future<Result<void, Failure>> recordSelection({
    required String nodeId,
    required String optionId,
    required DateTime answeredAt,
  }) async {
    try {
      await _database.insertDialogueHistoryEntry(
        nodeId: nodeId,
        selectedOptionId: optionId,
        answeredAt: answeredAt,
      );
      return const Success(null);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to insert dialogue history entry',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(
        CacheFailure('Failed to save dialogue progress offline'),
      );
    }
  }

  @override
  Future<Result<List<DialogueHistoryRecord>, Failure>>
      getUnsyncedHistory() async {
    try {
      final rows = await _database.getUnsyncedHistoryEntries();
      final records = rows
          .map(
            (row) => DialogueHistoryRecord(
              entryId: row.id,
              nodeId: row.nodeId,
              selectedOptionId: row.selectedOptionId,
              answeredAt: row.answeredAt,
            ),
          )
          .toList(growable: false);
      return Success(List<DialogueHistoryRecord>.unmodifiable(records));
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to load unsynced dialogue history',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(
        CacheFailure('Failed to read unsynced dialogue history'),
      );
    }
  }

  @override
  Future<Result<void, Failure>> markHistorySynced(List<int> entryIds) async {
    try {
      await _database.markHistoryEntriesSynced(entryIds);
      return const Success(null);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to mark history entries as synced',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(CacheFailure('Failed to update history sync status'));
    }
  }

  DialogueNodesCompanion _dtoToCompanion(DialogueNodeDto node) {
    final speakerMetadata = jsonEncode(<String, Object?>{
      'hebrew': node.speakerHebrew,
      'russian': node.speakerRussian,
    });
    return DialogueNodesCompanion.insert(
      id: node.id,
      characterName: speakerMetadata,
      lineHebrewVocalized: node.lineHebrew,
      lineHebrewNormalized: HebrewNormalizer.normalizeForComparison(
        node.lineHebrew,
      ),
      lineRussian: node.lineRussian,
      audioPath: Value(node.audioPath),
      optionsJson: node.encodeOptionsJson(),
      updatedAt: DateTime.now().toUtc(),
    );
  }

  Result<DialogueNodeDto, Failure> _rowToDto(DialogueNodeRow row) {
    final optionsRes = DialogueNodeDto.decodeOptionsJson(row.optionsJson);
    if (optionsRes case Error(:final failure)) {
      return Error(failure);
    }

    String speakerHebrew = row.characterName;
    String? speakerRussian;

    final speakerJsonRes = JsonReader.parseObject(row.characterName);
    if (speakerJsonRes case Success(:final data)) {
      final hebrewRes = data.requireNonEmptyString('hebrew');
      final russianRes = data.optionalNonEmptyString('russian');
      if (hebrewRes case Success(:final data)) {
        speakerHebrew = data;
      }
      if (russianRes case Success(:final data)) {
        speakerRussian = data;
      }
    }

    return Success(
      DialogueNodeDto(
        id: row.id,
        speakerHebrew: speakerHebrew,
        speakerRussian: speakerRussian,
        lineHebrew: row.lineHebrewVocalized,
        lineRussian: row.lineRussian,
        audioPath: row.audioPath,
        options: optionsRes.getOrNull()!,
      ),
    );
  }
}
