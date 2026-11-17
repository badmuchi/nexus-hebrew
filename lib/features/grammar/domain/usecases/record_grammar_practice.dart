import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../entities/verb_conjugation.dart';
import '../repositories/grammar_repository.dart';

/// Parameters for logging a grammar conjugation drill attempt.
final class RecordGrammarPracticeParams extends Equatable {
  const RecordGrammarPracticeParams({
    required this.verbId,
    required this.tense,
    required this.person,
    required this.isCorrect,
    required this.practicedAt,
  });

  final String verbId;
  final VerbTense tense;
  final GrammaticalPerson person;
  final bool isCorrect;
  final DateTime practicedAt;

  @override
  List<Object?> get props => [verbId, tense, person, isCorrect, practicedAt];
}

/// Validates and records a grammar drill outcome in the repository.
class RecordGrammarPracticeUseCase {
  const RecordGrammarPracticeUseCase(this._repository);

  final GrammarRepository _repository;

  /// Validates [params.verbId] and saves the practice attempt.
  Future<Result<void, Failure>> call(RecordGrammarPracticeParams params) async {
    final String trimmedVerbId = params.verbId.trim();
    if (trimmedVerbId.isEmpty) {
      return const Error<void, Failure>(
        ValidationFailure('verbId must not be empty.'),
      );
    }

    return _repository.recordPracticeAttempt(
      verbId: trimmedVerbId,
      tense: params.tense,
      person: params.person,
      isCorrect: params.isCorrect,
      practicedAt: params.practicedAt,
    );
  }
}
