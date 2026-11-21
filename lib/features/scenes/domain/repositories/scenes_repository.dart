import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../entities/israeli_life_scene.dart';

/// Contract for accessing Israeli life scenes and persisting completion progress.
abstract interface class ScenesRepository {
  /// Returns all available pre-seeded life scenes.
  List<IsraeliLifeScene> getAllScenes();

  /// Retrieves a specific scene by its identifier.
  IsraeliLifeScene? getSceneById(String id);

  /// Loads the map of completed scene IDs and their status.
  Future<Result<Map<String, bool>, Failure>> getCompletedSceneIds();

  /// Records scene completion and mastery stats in local SQLite storage.
  Future<Result<void, Failure>> recordSceneCompletion({
    required String sceneId,
    required int wordsMasteredCount,
    required int challengeScore,
  });
}
