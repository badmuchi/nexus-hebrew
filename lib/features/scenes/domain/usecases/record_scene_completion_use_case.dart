import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../repositories/scenes_repository.dart';

/// Parameters for recording progress and completion of an Israeli life scene.
final class RecordSceneCompletionParams extends Equatable {
  const RecordSceneCompletionParams({
    required this.sceneId,
    required this.wordsMasteredCount,
    required this.challengeScore,
  });

  final String sceneId;
  final int wordsMasteredCount;
  final int challengeScore;

  @override
  List<Object?> get props => [sceneId, wordsMasteredCount, challengeScore];
}

/// Use case for persisting scene completion and quiz results to local SQLite storage.
final class RecordSceneCompletionUseCase {
  const RecordSceneCompletionUseCase(this._repository);

  final ScenesRepository _repository;

  Future<Result<void, Failure>> call(RecordSceneCompletionParams params) {
    if (params.sceneId.trim().isEmpty) {
      return Future.value(
        const Error(ValidationFailure('Scene ID cannot be empty')),
      );
    }

    return _repository.recordSceneCompletion(
      sceneId: params.sceneId,
      wordsMasteredCount: params.wordsMasteredCount,
      challengeScore: params.challengeScore,
    );
  }
}
