import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/result/result.dart';
import '../../../../core/utils/hebrew_normalizer.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../domain/entities/verb_conjugation.dart';
import '../models/verb_lexeme_dto.dart';

/// Contract for persisting and querying Hebrew verb paradigms in local storage.
abstract interface class GrammarLocalDataSource {
  /// Returns the count of stored verb lexemes.
  Future<Result<int, Failure>> countVerbs();

  /// Inserts or updates a batch of [VerbLexeme] entries.
  Future<Result<void, Failure>> upsertVerbs(List<VerbLexeme> verbs);

  /// Queries stored verbs optionally filtered by [binyan] and search [query].
  Future<Result<List<VerbLexeme>, Failure>> getVerbs({
    Binyan? binyan,
    String query = '',
  });

  /// Stores a conjugation drill practice log row.
  Future<Result<void, Failure>> recordPracticeAttempt({
    required String verbId,
    required VerbTense tense,
    required GrammaticalPerson person,
    required bool isCorrect,
    required DateTime practicedAt,
  });
}

/// Drift-backed implementation of [GrammarLocalDataSource].
final class DriftGrammarLocalDataSource implements GrammarLocalDataSource {
  static const String _tag = 'DriftGrammarLocalDataSource';

  const DriftGrammarLocalDataSource({
    required AppDatabase database,
    required AppLogger logger,
  })  : _database = database,
        _logger = logger;

  final AppDatabase _database;
  final AppLogger _logger;

  @override
  Future<Result<int, Failure>> countVerbs() async {
    try {
      final count = await _database.countGrammarVerbs();
      return Success(count);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to count grammar verbs',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(CacheFailure('Failed to access local grammar storage'));
    }
  }

  @override
  Future<Result<void, Failure>> upsertVerbs(List<VerbLexeme> verbs) async {
    if (verbs.isEmpty) {
      return const Success(null);
    }

    try {
      final companions = verbs
          .map(
            (VerbLexeme verb) => GrammarVerbsCompanion.insert(
              id: verb.id,
              lemmaVocalized: verb.lemma.vocalized,
              lemmaNormalized: verb.lemma.normalized,
              infinitiveVocalized: Value(verb.infinitive?.vocalized),
              root: verb.root.hyphenated,
              binyan: verb.binyan.id,
              russianMeaning: verb.russianMeaning,
              grammarNotesRu: verb.grammarNotesRu,
              conjugationsJson:
                  VerbLexemeDto.encodeConjugationsJson(verb.conjugations),
              sourceName: verb.attribution.sourceName,
              licenseName: verb.attribution.licenseName,
              attributionText: Value(verb.attribution.attributionText),
            ),
          )
          .toList(growable: false);
      await _database.upsertGrammarVerbs(companions);
      return const Success(null);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to upsert grammar verbs',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(CacheFailure('Failed to store Hebrew grammar verbs'));
    }
  }

  @override
  Future<Result<List<VerbLexeme>, Failure>> getVerbs({
    Binyan? binyan,
    String query = '',
  }) async {
    try {
      final rows = await _database.getGrammarVerbs(binyanFilter: binyan?.id);
      final domainVerbs = <VerbLexeme>[];
      for (final row in rows) {
        final mappedRes = _mapRowToDomain(row);
        switch (mappedRes) {
          case Success(:final data):
            domainVerbs.add(data);
          case Error(:final failure):
            return Error(failure);
        }
      }

      final trimmedQuery = query.trim();
      if (trimmedQuery.isEmpty) {
        return Success(List<VerbLexeme>.unmodifiable(domainVerbs));
      }

      final normalizedHebrewQuery =
          HebrewNormalizer.normalizeForComparison(trimmedQuery);
      final normalizedLettersOnly =
          HebrewNormalizer.extractHebrewLetters(trimmedQuery);
      final lowerRussianQuery = trimmedQuery.toLowerCase();

      final filtered = domainVerbs.where((VerbLexeme verb) {
        if (verb.russianMeaning.toLowerCase().contains(lowerRussianQuery)) {
          return true;
        }
        if (normalizedHebrewQuery.isNotEmpty) {
          if (verb.lemma.normalized.contains(normalizedHebrewQuery) ||
              (verb.infinitive?.normalized.contains(normalizedHebrewQuery) ??
                  false) ||
              verb.root.hyphenated.contains(normalizedHebrewQuery)) {
            return true;
          }
        }
        if (normalizedLettersOnly.isNotEmpty &&
            verb.root.compact.contains(normalizedLettersOnly)) {
          return true;
        }
        return false;
      }).toList(growable: false);

      return Success(List<VerbLexeme>.unmodifiable(filtered));
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to load grammar verbs',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(CacheFailure('Failed to query local grammar verbs'));
    }
  }

  @override
  Future<Result<void, Failure>> recordPracticeAttempt({
    required String verbId,
    required VerbTense tense,
    required GrammaticalPerson person,
    required bool isCorrect,
    required DateTime practicedAt,
  }) async {
    try {
      await _database.insertGrammarPracticeLog(
        verbId: verbId,
        tense: tense.id,
        person: person.id,
        isCorrect: isCorrect,
        practicedAt: practicedAt,
      );
      return const Success(null);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to record grammar practice log for verb "$verbId"',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(
        CacheFailure('Failed to save grammar practice attempt'),
      );
    }
  }

  Result<VerbLexeme, Failure> _mapRowToDomain(GrammarVerbRow row) {
    final lemmaRes = HebrewText.create(row.lemmaVocalized);
    if (lemmaRes case Error(:final failure)) {
      return Error(failure);
    }

    HebrewText? infinitive;
    final rawInf = row.infinitiveVocalized;
    if (rawInf != null && rawInf.trim().isNotEmpty) {
      final infRes = HebrewText.create(rawInf);
      switch (infRes) {
        case Success(:final data):
          infinitive = data;
        case Error(:final failure):
          return Error(failure);
      }
    }

    final rootRes = Shoresh.create(row.root);
    if (rootRes case Error(:final failure)) {
      return Error(failure);
    }

    final binyanRes = Binyan.parseStrict(row.binyan);
    if (binyanRes case Error(:final failure)) {
      return Error(failure);
    }

    final conjugationsRes =
        VerbLexemeDto.decodeConjugationsJson(row.conjugationsJson);
    if (conjugationsRes case Error(:final failure)) {
      return Error(failure);
    }

    return Success(
      VerbLexeme(
        id: row.id,
        lemma: lemmaRes.getOrNull()!,
        infinitive: infinitive,
        root: rootRes.getOrNull()!,
        binyan: binyanRes.getOrNull()!,
        russianMeaning: row.russianMeaning,
        grammarNotesRu: row.grammarNotesRu,
        conjugations: conjugationsRes.getOrNull()!,
        attribution: ContentAttribution(
          sourceName: row.sourceName,
          licenseName: row.licenseName,
          attributionText: row.attributionText,
        ),
      ),
    );
  }
}
