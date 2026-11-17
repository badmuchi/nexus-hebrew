import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../repositories/listening_repository.dart';

/// Parameters for persisting a listening dictation attempt.
final class RecordListeningAttemptParams extends Equatable {
  const RecordListeningAttemptParams({
    required this.exerciseId,
    required this.wordAccuracy,
    required this.isExactMatch,
    required this.attemptedAt,
  });

  final String exerciseId;
  final double wordAccuracy;
  final bool isExactMatch;
  final DateTime attemptedAt;

  @override
  List<Object?> get props => [
        exerciseId,
        wordAccuracy,
        isExactMatch,
        attemptedAt,
      ];
}

/// Validates and records a listening dictation attempt in local storage.
class RecordListeningAttemptUseCase {
  const RecordListeningAttemptUseCase(this._repository);

  final ListeningRepository _repository;

  /// Validates fields and persists the attempt outcome.
  Future<Result<void, Failure>> call(
    RecordListeningAttemptParams params,
  ) async {
    final trimmedId = params.exerciseId.trim();
    if (trimmedId.isEmpty) {
      return const Error<void, Failure>(
        ValidationFailure('exerciseId must not be empty.'),
      );
    }
    if (params.wordAccuracy < 0.0 || params.wordAccuracy > 1.0) {
      return const Error<void, Failure>(
        ValidationFailure('wordAccuracy must be between 0.0 and 1.0.'),
      );
    }

    return _repository.recordAttempt(
      exerciseId: trimmedId,
      wordAccuracy: params.wordAccuracy,
      isExactMatch: params.isExactMatch,
      attemptedAt: params.attemptedAt,
    );
  }
}
