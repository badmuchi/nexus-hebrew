import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../entities/listening_exercise.dart';
import '../repositories/listening_repository.dart';

/// Parameters for loading listening exercises.
final class GetListeningExercisesParams extends Equatable {
  const GetListeningExercisesParams({this.difficulty});

  final ListeningDifficulty? difficulty;

  @override
  List<Object?> get props => [difficulty];
}

/// Fetches Hebrew listening exercises optionally filtered by difficulty tier.
class GetListeningExercisesUseCase {
  const GetListeningExercisesUseCase(this._repository);

  final ListeningRepository _repository;

  /// Loads listening exercises from the repository.
  Future<Result<List<ListeningExercise>, Failure>> call(
    GetListeningExercisesParams params,
  ) {
    return _repository.getExercises(difficulty: params.difficulty);
  }
}
