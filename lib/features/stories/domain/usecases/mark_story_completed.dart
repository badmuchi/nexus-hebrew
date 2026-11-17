import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../repositories/stories_repository.dart';

final class MarkStoryCompletedUseCase {
  final StoriesRepository _repository;

  const MarkStoryCompletedUseCase(this._repository);

  Future<Result<void, Failure>> execute(String id) =>
      _repository.markStoryCompleted(id);
}
