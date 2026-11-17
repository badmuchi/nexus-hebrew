import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../entities/story.dart';
import '../repositories/stories_repository.dart';

final class GetStoriesUseCase {
  final StoriesRepository _repository;

  const GetStoriesUseCase(this._repository);

  Future<Result<List<Story>, Failure>> execute() => _repository.getStories();
}
