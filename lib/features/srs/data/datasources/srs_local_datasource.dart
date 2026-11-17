import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/result/result.dart';
import '../../../../core/utils/hebrew_normalizer.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../../domain/entities/fsrs_models.dart';
import '../../domain/entities/srs_card.dart';
import '../models/srs_card_dto.dart';

abstract interface class SrsLocalDataSource {
  Future<Result<int, Failure>> countCards();
  Future<Result<void, Failure>> insertSeedCardsIfAbsent(
    List<SrsCardDto> seedDtos, {
    required DateTime initialDueAt,
  });
  Future<Result<bool, Failure>> insertCustomCardIfAbsent(SrsCard card);
  Future<Result<List<SrsCard>, Failure>> getDueCards({
    required DateTime asOf,
    required int limit,
  });
  Future<Result<void, Failure>> saveReviewTransaction({
    required SrsCard updatedCard,
    required FsrsRating rating,
    required int scheduledDays,
    required double stabilityBefore,
    required bool wasTypedCheck,
    required bool wasTypedExact,
    required DateTime reviewedAt,
  });
}

final class DriftSrsLocalDataSource implements SrsLocalDataSource {
  static const String _tag = 'DriftSrsLocalDataSource';

  final AppDatabase _database;
  final AppLogger _logger;

  const DriftSrsLocalDataSource({
    required AppDatabase database,
    required AppLogger logger,
  })  : _database = database,
        _logger = logger;

  @override
  Future<Result<int, Failure>> countCards() async {
    try {
      final count = await _database.countAllSrsCards();
      return Success(count);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to count SRS cards',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(CacheFailure('Failed to access local SRS storage'));
    }
  }

  @override
  Future<Result<void, Failure>> insertSeedCardsIfAbsent(
    List<SrsCardDto> seedDtos, {
    required DateTime initialDueAt,
  }) async {
    if (seedDtos.isEmpty) {
      return const Success(null);
    }

    try {
      final companions = <SrsCardsCompanion>[];
      final defaultMemory = FsrsMemoryState.initial(now: initialDueAt);
      for (final dto in seedDtos) {
        final domainRes = dto.toDomain(memory: defaultMemory);
        switch (domainRes) {
          case Error(:final failure):
            return Error(failure);
          case Success(:final data):
            companions.add(_domainToCompanion(data));
        }
      }
      await _database.upsertSrsCardsIfAbsent(companions);
      return const Success(null);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to insert seed SRS cards',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(CacheFailure('Failed to store SRS cards locally'));
    }
  }

  @override
  Future<Result<List<SrsCard>, Failure>> getDueCards({
    required DateTime asOf,
    required int limit,
  }) async {
    try {
      final rows = await _database.getDueSrsCards(asOf: asOf, limit: limit);
      final cards = <SrsCard>[];
      for (final row in rows) {
        final mapped = _rowToDomain(row);
        switch (mapped) {
          case Error(:final failure):
            return Error(failure);
          case Success(:final data):
            cards.add(data);
        }
      }
      return Success(List<SrsCard>.unmodifiable(cards));
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to fetch due SRS cards',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(CacheFailure('Failed to load due SRS flashcards'));
    }
  }

  @override
  Future<Result<void, Failure>> saveReviewTransaction({
    required SrsCard updatedCard,
    required FsrsRating rating,
    required int scheduledDays,
    required double stabilityBefore,
    required bool wasTypedCheck,
    required bool wasTypedExact,
    required DateTime reviewedAt,
  }) async {
    try {
      await _database.saveSrsReviewTransaction(
        updatedCard: _domainToCompanion(updatedCard),
        reviewLog: SrsReviewLogsCompanion.insert(
          cardId: updatedCard.id,
          rating: rating.value,
          stabilityBefore: stabilityBefore,
          stabilityAfter: updatedCard.memory.stability,
          difficultyAfter: updatedCard.memory.difficulty,
          scheduledDays: scheduledDays,
          wasTypedCheck: Value(wasTypedCheck),
          wasTypedExact: Value(wasTypedExact),
          reviewedAt: reviewedAt,
        ),
      );
      return const Success(null);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to persist FSRS review for "${updatedCard.id}"',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(CacheFailure('Failed to save flashcard review state'));
    }
  }

  @override
  Future<Result<bool, Failure>> insertCustomCardIfAbsent(SrsCard card) async {
    try {
      final byId = await _database.findSrsCardById(card.id);
      if (byId != null) {
        return const Success(false);
      }

      final byNormalized = await _database.searchSrsCardsByNormalizedHebrew(
        card.hebrew.normalized,
      );
      final exactDuplicate = byNormalized.any(
        (SrsCardRow row) => row.hebrewNormalized == card.hebrew.normalized,
      );
      if (exactDuplicate) {
        return const Success(false);
      }

      await _database.upsertSrsCard(_domainToCompanion(card));
      return const Success(true);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to insert custom SRS card "${card.id}"',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(CacheFailure('Failed to add card to FSRS deck'));
    }
  }

  SrsCardsCompanion _domainToCompanion(SrsCard card) {
    return SrsCardsCompanion.insert(
      id: card.id,
      hebrewVocalized: card.hebrew.vocalized,
      hebrewNormalized: card.hebrew.normalized,
      russianTranslation: card.russianTranslation,
      root: Value(card.root?.hyphenated),
      binyan: Value(card.binyan.id),
      category: Value(card.category.id),
      exampleHebrewVocalized: Value(card.exampleHebrew?.vocalized),
      exampleHebrewNormalized: Value(card.exampleHebrew?.normalized),
      exampleRussian: Value(card.exampleRussian),
      audioUrl: Value(card.audioUrl),
      sourceName: card.attribution.sourceName,
      licenseName: card.attribution.licenseName,
      attributionText: Value(card.attribution.attributionText),
      fsrsState: Value(card.memory.state.id),
      stability: Value(card.memory.stability),
      difficulty: Value(card.memory.difficulty),
      reps: Value(card.memory.reps),
      lapses: Value(card.memory.lapses),
      dueAt: card.memory.dueAt,
      lastReviewedAt: Value(card.memory.lastReviewedAt),
    );
  }

  Result<SrsCard, Failure> _rowToDomain(SrsCardRow row) {
    final hebrewRes = HebrewText.create(row.hebrewVocalized);
    if (hebrewRes case Error(:final failure)) {
      return Error(ParsingFailure('Row "${row.id}": ${failure.message}'));
    }

    final binyanRes = Binyan.parseStrict(row.binyan);
    if (binyanRes case Error(:final failure)) {
      return Error(failure);
    }

    final categoryRes = LexicalCategory.parseStrict(row.category);
    if (categoryRes case Error(:final failure)) {
      return Error(failure);
    }

    final stateRes = FsrsCardState.parseStrict(row.fsrsState);
    if (stateRes case Error(:final failure)) {
      return Error(failure);
    }

    Shoresh? parsedRoot;
    if (row.root != null && row.root!.trim().isNotEmpty) {
      final rootRes = Shoresh.create(row.root!);
      switch (rootRes) {
        case Success(:final data):
          parsedRoot = data;
        case Error(:final failure):
          return Error(ParsingFailure('Row "${row.id}": ${failure.message}'));
      }
    }

    HebrewText? exampleHeb;
    if (row.exampleHebrewVocalized != null &&
        row.exampleHebrewVocalized!.trim().isNotEmpty) {
      final normalizedEx = row.exampleHebrewNormalized ??
          HebrewNormalizer.normalizeForComparison(row.exampleHebrewVocalized!);
      exampleHeb = HebrewText.fixture(
        vocalized: row.exampleHebrewVocalized!,
        normalized: normalizedEx,
      );
    }

    return Success(
      SrsCard(
        id: row.id,
        hebrew: hebrewRes.getOrNull()!,
        russianTranslation: row.russianTranslation,
        root: parsedRoot,
        binyan: binyanRes.getOrNull()!,
        category: categoryRes.getOrNull()!,
        exampleHebrew: exampleHeb,
        exampleRussian: row.exampleRussian,
        audioUrl: row.audioUrl,
        attribution: ContentAttribution(
          sourceName: row.sourceName,
          licenseName: row.licenseName,
          attributionText: row.attributionText,
        ),
        memory: FsrsMemoryState(
          state: stateRes.getOrNull()!,
          stability: row.stability,
          difficulty: row.difficulty,
          reps: row.reps,
          lapses: row.lapses,
          dueAt: row.dueAt,
          lastReviewedAt: row.lastReviewedAt,
        ),
      ),
    );
  }
}
