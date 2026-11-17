import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../entities/listening_exercise.dart';

/// Contract for loading, importing, and logging Hebrew listening exercises.
abstract interface class ListeningRepository {
  /// Returns exercises optionally filtered by [difficulty].
  Future<Result<List<ListeningExercise>, Failure>> getExercises({
    ListeningDifficulty? difficulty,
  });

  /// Imports open-licensed (CC0/CC-BY) Hebrew-Russian listening sentences from Tatoeba.
  Future<Result<List<ListeningExercise>, Failure>> importFromTatoeba({
    required String query,
    int limit = 8,
  });

  /// Stores a dictation practice attempt outcome locally.
  Future<Result<void, Failure>> recordAttempt({
    required String exerciseId,
    required double wordAccuracy,
    required bool isExactMatch,
    required DateTime attemptedAt,
  });
}
