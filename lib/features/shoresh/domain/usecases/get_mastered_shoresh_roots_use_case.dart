import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../repositories/shoresh_repository.dart';

/// Use case for fetching the IDs of mastered Hebrew roots from local storage.
class GetMasteredShoreshRootsUseCase {
  const GetMasteredShoreshRootsUseCase(this._repository);

  final ShoreshRepository _repository;

  Future<Result<Map<String, bool>, Failure>> call() {
    return _repository.getMasteredRootIds();
  }
}
