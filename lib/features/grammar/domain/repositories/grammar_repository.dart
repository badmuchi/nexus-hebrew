import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../entities/verb_conjugation.dart';

/// Contract for loading, filtering, and logging Hebrew grammar verb paradigms.
abstract interface class GrammarRepository {
  /// Returns verbs optionally filtered by [binyan] and a normalized [query].
  Future<Result<List<VerbLexeme>, Failure>> getVerbs({
    Binyan? binyan,
    String query = '',
  });

  /// Persists a user's conjugation drill outcome in local storage.
  Future<Result<void, Failure>> recordPracticeAttempt({
    required String verbId,
    required VerbTense tense,
    required GrammaticalPerson person,
    required bool isCorrect,
    required DateTime practicedAt,
  });
}
