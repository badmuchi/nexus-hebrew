import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../entities/story.dart';

abstract interface class StoriesRepository {
  Future<Result<List<Story>, Failure>> getStories();
  Future<Result<Story, Failure>> getStoryById(String id);
  Future<Result<Set<String>, Failure>> getCompletedStoryIds();
  Future<Result<void, Failure>> markStoryCompleted(String id);
}
