import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../entities/learning_progress_summary.dart';

/// Contract for aggregating learner stats and searching across all Hebrew study modules.
abstract interface class ProgressRepository {
  /// Computes progress statistics across FSRS, grammar, and listening as of [asOf].
  Future<Result<LearningProgressSummary, Failure>> getProgressSummary({
    required DateTime asOf,
  });

  /// Searches across flashcards, grammar verbs, dialogue nodes, and listening scripts.
  Future<Result<List<GlobalHebrewSearchResult>, Failure>> searchAcrossLibrary(
    String query,
  );
}
