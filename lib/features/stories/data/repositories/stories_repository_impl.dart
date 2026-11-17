import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/story.dart';
import '../../domain/repositories/stories_repository.dart';
import '../datasources/stories_seed_datasource.dart';

final class StoriesRepositoryImpl implements StoriesRepository {
  static const String _tag = 'StoriesRepositoryImpl';

  final StoriesSeedDataSource _seedDataSource;
  final AppLogger _logger;
  final Set<String> _completedStoryIds = <String>{};

  StoriesRepositoryImpl({
    required StoriesSeedDataSource seedDataSource,
    required AppLogger logger,
  })  : _seedDataSource = seedDataSource,
        _logger = logger;

  @override
  Future<Result<List<Story>, Failure>> getStories() async {
    final seedRes = await _seedDataSource.loadAllSeedStories();
    switch (seedRes) {
      case Success(:final data):
        final domainStories = <Story>[];
        for (final dto in data) {
          final domainRes = dto.toDomain();
          switch (domainRes) {
            case Success(:final data):
              domainStories.add(data);
            case Error(:final failure):
              _logger.warning(
                _tag,
                'Failed to map story dto "${dto.id}" to domain',
                failure: failure,
              );
              return Error(failure);
          }
        }
        return Success(List<Story>.unmodifiable(domainStories));
      case Error(:final failure):
        return Error(failure);
    }
  }

  @override
  Future<Result<Story, Failure>> getStoryById(String id) async {
    final storyRes = await _seedDataSource.findSeedStoryById(id);
    switch (storyRes) {
      case Success(:final data):
        if (data == null) {
          return Error(ValidationFailure('Story with id "$id" not found'));
        }
        return data.toDomain();
      case Error(:final failure):
        return Error(failure);
    }
  }

  @override
  Future<Result<Set<String>, Failure>> getCompletedStoryIds() async {
    return Success(Set<String>.unmodifiable(_completedStoryIds));
  }

  @override
  Future<Result<void, Failure>> markStoryCompleted(String id) async {
    _completedStoryIds.add(id);
    _logger.info(_tag, 'Marked story "$id" as completed');
    return const Success(null);
  }
}
