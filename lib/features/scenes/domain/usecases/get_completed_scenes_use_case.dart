import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../repositories/scenes_repository.dart';

/// Use case for fetching the completion status map of all scenes from persistent storage.
class GetCompletedScenesUseCase {
  const GetCompletedScenesUseCase(this._repository);

  final ScenesRepository _repository;

  Future<Result<Map<String, bool>, Failure>> call() {
    return _repository.getCompletedSceneIds();
  }
}
