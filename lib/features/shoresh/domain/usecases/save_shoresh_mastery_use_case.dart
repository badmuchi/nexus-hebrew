import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../repositories/shoresh_repository.dart';

final class SaveShoreshMasteryParams extends Equatable {
  const SaveShoreshMasteryParams({
    required this.rootId,
    required this.isMastered,
    this.quizCorrectIncrement = 0,
  });

  final String rootId;
  final bool isMastered;
  final int quizCorrectIncrement;

  @override
  List<Object?> get props => [rootId, isMastered, quizCorrectIncrement];
}

/// Use case for persisting root mastery or recording successful quiz results.
class SaveShoreshMasteryUseCase {
  const SaveShoreshMasteryUseCase(this._repository);

  final ShoreshRepository _repository;

  Future<Result<void, Failure>> call(SaveShoreshMasteryParams params) {
    if (params.rootId.trim().isEmpty) {
      return Future.value(
        const Error(ValidationFailure('Root ID cannot be empty')),
      );
    }

    return _repository.recordRootMastery(
      rootId: params.rootId,
      isMastered: params.isMastered,
      quizCorrectIncrement: params.quizCorrectIncrement,
    );
  }
}
