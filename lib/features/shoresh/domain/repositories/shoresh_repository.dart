import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../entities/shoresh_entity.dart';

/// Contract for accessing Hebrew roots catalog, word families, and progress persistence.
abstract interface class ShoreshRepository {
  /// Returns all available root families.
  List<ShoreshRoot> getAllRoots();

  /// Retrieves a root family by its ID.
  ShoreshRoot? getRootById(String id);

  /// Loads the map of mastered root IDs from local persistent storage.
  Future<Result<Map<String, bool>, Failure>> getMasteredRootIds();

  /// Persists mastery state or quiz completion for a specific root.
  Future<Result<void, Failure>> recordRootMastery({
    required String rootId,
    required bool isMastered,
    required int quizCorrectIncrement,
  });

  /// Generates a set of root extractor challenge questions.
  List<ShoreshQuizQuestion> generateQuizQuestions({int count = 10});
}
