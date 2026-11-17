import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../entities/learning_progress_summary.dart';
import '../repositories/progress_repository.dart';

/// Parameters for loading the consolidated learning progress summary.
final class GetLearningProgressParams extends Equatable {
  const GetLearningProgressParams({required this.asOf});

  final DateTime asOf;

  @override
  List<Object?> get props => [asOf];
}

/// Fetches unified mastery, streak, and accuracy metrics across all modules.
class GetLearningProgressUseCase {
  const GetLearningProgressUseCase(this._repository);

  final ProgressRepository _repository;

  /// Aggregates local progress metrics as of [params.asOf].
  Future<Result<LearningProgressSummary, Failure>> call(
    GetLearningProgressParams params,
  ) {
    return _repository.getProgressSummary(asOf: params.asOf);
  }
}
