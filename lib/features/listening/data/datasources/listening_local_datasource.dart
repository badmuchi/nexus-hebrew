import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/result/result.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../domain/entities/listening_exercise.dart';
import '../models/listening_exercise_dto.dart';

/// Contract for persisting and querying Hebrew listening exercises in Drift.
abstract interface class ListeningLocalDataSource {
  /// Returns total stored listening exercise count.
  Future<Result<int, Failure>> countExercises();

  /// Inserts listening exercises that do not already exist by primary key.
  Future<Result<void, Failure>> insertExercisesIfAbsent(
    List<ListeningExercise> exercises,
  );

  /// Queries stored exercises optionally filtered by [difficulty].
  Future<Result<List<ListeningExercise>, Failure>> getExercises({
    ListeningDifficulty? difficulty,
  });

  /// Persists a dictation attempt outcome in local storage.
  Future<Result<void, Failure>> recordAttempt({
    required String exerciseId,
    required double wordAccuracy,
    required bool isExactMatch,
    required DateTime attemptedAt,
  });
}

/// Drift-backed implementation of [ListeningLocalDataSource].
final class DriftListeningLocalDataSource implements ListeningLocalDataSource {
  static const String _tag = 'DriftListeningLocalDataSource';

  const DriftListeningLocalDataSource({
    required AppDatabase database,
    required AppLogger logger,
  })  : _database = database,
        _logger = logger;

  final AppDatabase _database;
  final AppLogger _logger;

  @override
  Future<Result<int, Failure>> countExercises() async {
    try {
      final count = await _database.countListeningExercises();
      return Success(count);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to count listening exercises',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(
        CacheFailure('Failed to access local listening storage'),
      );
    }
  }

  @override
  Future<Result<void, Failure>> insertExercisesIfAbsent(
    List<ListeningExercise> exercises,
  ) async {
    if (exercises.isEmpty) {
      return const Success(null);
    }

    try {
      final companions = exercises
          .map(
            (ListeningExercise exercise) => ListeningExercisesCompanion.insert(
              id: exercise.id,
              transcriptVocalized: exercise.transcript.vocalized,
              transcriptNormalized: exercise.transcript.normalized,
              russianTranslation: exercise.russianTranslation,
              audioUrl: Value(exercise.audioUrl),
              difficulty: Value(exercise.difficulty.id),
              focusWordsJson:
                  ListeningExerciseDto.encodeFocusWordsJson(exercise.focusWords),
              sourceName: exercise.attribution.sourceName,
              licenseName: exercise.attribution.licenseName,
              attributionText: Value(exercise.attribution.attributionText),
            ),
          )
          .toList(growable: false);
      await _database.upsertListeningExercisesIfAbsent(companions);
      return const Success(null);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to store listening exercises',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(
        CacheFailure('Failed to save listening exercises locally'),
      );
    }
  }

  @override
  Future<Result<List<ListeningExercise>, Failure>> getExercises({
    ListeningDifficulty? difficulty,
  }) async {
    try {
      final rows = await _database.getListeningExercises(
        difficultyFilter: difficulty?.id,
      );
      final domainList = <ListeningExercise>[];
      for (final row in rows) {
        final mappedRes = _mapRowToDomain(row);
        switch (mappedRes) {
          case Success(:final data):
            domainList.add(data);
          case Error(:final failure):
            return Error(failure);
        }
      }
      return Success(List<ListeningExercise>.unmodifiable(domainList));
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to query listening exercises',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(
        CacheFailure('Failed to load local listening exercises'),
      );
    }
  }

  @override
  Future<Result<void, Failure>> recordAttempt({
    required String exerciseId,
    required double wordAccuracy,
    required bool isExactMatch,
    required DateTime attemptedAt,
  }) async {
    try {
      await _database.insertListeningAttemptLog(
        exerciseId: exerciseId,
        wordAccuracy: wordAccuracy,
        isExactMatch: isExactMatch,
        attemptedAt: attemptedAt,
      );
      return const Success(null);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to record listening attempt for "$exerciseId"',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(
        CacheFailure('Failed to save dictation attempt log'),
      );
    }
  }

  Result<ListeningExercise, Failure> _mapRowToDomain(ListeningExerciseRow row) {
    final transcriptRes = HebrewText.create(row.transcriptVocalized);
    if (transcriptRes case Error(:final failure)) {
      return Error(failure);
    }

    final difficultyRes = ListeningDifficulty.parseStrict(row.difficulty);
    if (difficultyRes case Error(:final failure)) {
      return Error(failure);
    }

    final focusWordsRes =
        ListeningExerciseDto.decodeFocusWordsJson(row.focusWordsJson);
    if (focusWordsRes case Error(:final failure)) {
      return Error(failure);
    }

    return Success(
      ListeningExercise(
        id: row.id,
        transcript: transcriptRes.getOrNull()!,
        russianTranslation: row.russianTranslation,
        audioUrl: row.audioUrl,
        difficulty: difficultyRes.getOrNull()!,
        focusWords: focusWordsRes.getOrNull()!,
        attribution: ContentAttribution(
          sourceName: row.sourceName,
          licenseName: row.licenseName,
          attributionText: row.attributionText,
        ),
      ),
    );
  }
}
