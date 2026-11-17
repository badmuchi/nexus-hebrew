import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/result/result.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../domain/entities/dictionary_entry.dart';
import '../models/dictionary_entry_dto.dart';

abstract interface class DictionaryLocalDataSource {
  Future<Result<int, Failure>> countEntries();
  Future<Result<void, Failure>> insertEntriesIfAbsent(
    List<DictionaryEntryDto> seedDtos, {
    required DateTime createdAt,
  });
  Future<Result<List<DictionaryEntry>, Failure>> getAllEntries();
  Future<Result<Set<String>, Failure>> getSrsNormalizedForms();
  Future<Result<DictionaryEntry, Failure>> upsertEntry(DictionaryEntry entry);
  Future<Result<void, Failure>> cacheOnlineEntries(
    List<DictionaryEntry> entries,
  );
}

final class DriftDictionaryLocalDataSource
    implements DictionaryLocalDataSource {
  static const String _tag = 'DriftDictionaryLocalDataSource';

  const DriftDictionaryLocalDataSource({
    required AppDatabase database,
    required AppLogger logger,
  })  : _database = database,
        _logger = logger;

  final AppDatabase _database;
  final AppLogger _logger;

  @override
  Future<Result<int, Failure>> countEntries() async {
    try {
      final count = await _database.countDictionaryEntries();
      return Success(count);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to count dictionary entries',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(
        CacheFailure('Не удалось прочитать количество слов в словаре'),
      );
    }
  }

  @override
  Future<Result<void, Failure>> insertEntriesIfAbsent(
    List<DictionaryEntryDto> seedDtos, {
    required DateTime createdAt,
  }) async {
    if (seedDtos.isEmpty) {
      return const Success(null);
    }

    try {
      final companions = <DictionaryEntriesCompanion>[];
      for (final dto in seedDtos) {
        final domainRes = dto.toDomain(createdAt: createdAt);
        switch (domainRes) {
          case Error(:final failure):
            return Error(failure);
          case Success(:final data):
            companions.add(_domainToCompanion(data));
        }
      }
      await _database.upsertDictionaryEntriesIfAbsent(companions);
      return const Success(null);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to seed dictionary entries into Drift',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(
        CacheFailure('Не удалось сохранить словарь в локальную БД'),
      );
    }
  }

  @override
  Future<Result<List<DictionaryEntry>, Failure>> getAllEntries() async {
    try {
      final rows = await _database.getAllDictionaryEntries();
      final entries = <DictionaryEntry>[];
      for (final row in rows) {
        final mapped = _rowToDomain(row);
        switch (mapped) {
          case Error(:final failure):
            return Error(failure);
          case Success(:final data):
            entries.add(data);
        }
      }
      return Success(List<DictionaryEntry>.unmodifiable(entries));
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to load dictionary entries from Drift',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(
        CacheFailure('Не удалось загрузить слова из локальной БД'),
      );
    }
  }

  @override
  Future<Result<Set<String>, Failure>> getSrsNormalizedForms() async {
    try {
      final srsRows = await _database.getAllSrsCards();
      return Success(
        Set<String>.unmodifiable(
          srsRows.map((SrsCardRow row) => row.hebrewNormalized),
        ),
      );
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to inspect FSRS deck membership',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(
        CacheFailure('Не удалось проверить статус слов в колоде FSRS'),
      );
    }
  }

  @override
  Future<Result<DictionaryEntry, Failure>> upsertEntry(
    DictionaryEntry entry,
  ) async {
    try {
      await _database.upsertDictionaryEntry(_domainToCompanion(entry));
      return Success(entry);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to upsert custom dictionary entry "${entry.id}"',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(
        CacheFailure('Не удалось сохранить слово в локальный словарь'),
      );
    }
  }

  @override
  Future<Result<void, Failure>> cacheOnlineEntries(
    List<DictionaryEntry> entries,
  ) async {
    if (entries.isEmpty) {
      return const Success(null);
    }
    try {
      final companions =
          entries.map(_domainToCompanion).toList(growable: false);
      await _database.upsertDictionaryEntriesIfAbsent(companions);
      return const Success(null);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to cache online dictionary matches',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(
        CacheFailure('Не удалось сохранить найденные фразы локально'),
      );
    }
  }

  DictionaryEntriesCompanion _domainToCompanion(DictionaryEntry entry) {
    return DictionaryEntriesCompanion(
      id: Value(entry.id),
      hebrewVocalized: Value(entry.hebrew.vocalized),
      hebrewNormalized: Value(entry.hebrew.normalized),
      russianTranslation: Value(entry.russianTranslation),
      transliteration: Value(entry.transliteration),
      category: Value(entry.category.id),
      root: Value(entry.root?.hyphenated),
      binyan: Value(entry.binyan.id),
      formsSummary: Value(entry.formsSummary),
      exampleHebrewVocalized: Value(entry.exampleHebrew?.vocalized),
      exampleHebrewNormalized: Value(entry.exampleHebrew?.normalized),
      exampleRussian: Value(entry.exampleRussian),
      audioUrl: Value(entry.audioUrl),
      frequencyRank: Value(entry.frequencyRank),
      sourceName: Value(entry.attribution.sourceName),
      licenseName: Value(entry.attribution.licenseName),
      attributionText: Value(entry.attribution.attributionText),
      isUserAdded: Value(entry.isUserAdded),
      createdAt: Value(entry.createdAt),
    );
  }

  Result<DictionaryEntry, Failure> _rowToDomain(DictionaryEntryRow row) {
    final hebrewRes = HebrewText.create(row.hebrewVocalized);
    if (hebrewRes case Error(:final failure)) {
      return Error(
        ParsingFailure('Corrupt dictionary entry "${row.id}": ${failure.message}'),
      );
    }

    final categoryRes = LexicalCategory.parseStrict(row.category);
    if (categoryRes case Error(:final failure)) {
      return Error(
        ParsingFailure('Corrupt dictionary entry "${row.id}": ${failure.message}'),
      );
    }

    final binyanRes = Binyan.parseStrict(row.binyan);
    if (binyanRes case Error(:final failure)) {
      return Error(
        ParsingFailure('Corrupt dictionary entry "${row.id}": ${failure.message}'),
      );
    }

    Shoresh? parsedRoot;
    if (row.root != null && row.root!.trim().isNotEmpty) {
      final rootRes = Shoresh.create(row.root!);
      switch (rootRes) {
        case Success(:final data):
          parsedRoot = data;
        case Error(:final failure):
          return Error(
            ParsingFailure('Corrupt root in "${row.id}": ${failure.message}'),
          );
      }
    }

    HebrewText? exampleHeb;
    if (row.exampleHebrewVocalized != null &&
        row.exampleHebrewVocalized!.trim().isNotEmpty) {
      final exRes = HebrewText.create(row.exampleHebrewVocalized!);
      switch (exRes) {
        case Success(:final data):
          exampleHeb = data;
        case Error(:final failure):
          return Error(
            ParsingFailure(
              'Corrupt example in "${row.id}": ${failure.message}',
            ),
          );
      }
    }

    return Success(
      DictionaryEntry(
        id: row.id,
        hebrew: hebrewRes.getOrNull()!,
        russianTranslation: row.russianTranslation,
        transliteration: row.transliteration,
        category: categoryRes.getOrNull()!,
        root: parsedRoot,
        binyan: binyanRes.getOrNull()!,
        formsSummary: row.formsSummary,
        exampleHebrew: exampleHeb,
        exampleRussian: row.exampleRussian,
        audioUrl: row.audioUrl,
        frequencyRank: row.frequencyRank,
        attribution: ContentAttribution(
          sourceName: row.sourceName,
          licenseName: row.licenseName,
          attributionText: row.attributionText,
        ),
        isUserAdded: row.isUserAdded,
        createdAt: row.createdAt,
      ),
    );
  }
}
