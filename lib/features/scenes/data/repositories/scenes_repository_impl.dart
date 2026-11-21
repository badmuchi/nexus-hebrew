import '../../../../core/database/app_database.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/israeli_life_scene.dart';
import '../../domain/repositories/scenes_repository.dart';
import '../datasources/israeli_scenes_seed_data.dart';

final class ScenesRepositoryImpl implements ScenesRepository {
  ScenesRepositoryImpl({this.database});

  final AppDatabase? database;
  final Map<String, bool> _inMemoryCompleted = {};

  @override
  List<IsraeliLifeScene> getAllScenes() {
    return IsraeliScenesSeedData.scenes;
  }

  @override
  IsraeliLifeScene? getSceneById(String id) {
    for (final s in IsraeliScenesSeedData.scenes) {
      if (s.id == id) return s;
    }
    return null;
  }

  @override
  Future<Result<Map<String, bool>, Failure>> getCompletedSceneIds() async {
    final db = database;
    if (db == null) {
      return Success(Map.unmodifiable(_inMemoryCompleted));
    }

    try {
      final rows = await db.getAllSceneProgress();
      final map = <String, bool>{};
      for (final r in rows) {
        map[r.sceneId] = r.isCompleted;
      }
      return Success(map);
    } catch (e) {
      return Error(CacheFailure('Failed to load completed scenes: $e'));
    }
  }

  @override
  Future<Result<void, Failure>> recordSceneCompletion({
    required String sceneId,
    required int wordsMasteredCount,
    required int challengeScore,
  }) async {
    _inMemoryCompleted[sceneId] = true;
    final db = database;
    if (db == null) {
      return const Success(null);
    }

    try {
      await db.upsertSceneProgress(
        sceneId: sceneId,
        isCompleted: true,
        wordsMasteredCount: wordsMasteredCount,
        challengeScore: challengeScore,
        lastVisitedAt: DateTime.now().toUtc(),
      );
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure('Failed to persist scene completion: $e'));
    }
  }
}
