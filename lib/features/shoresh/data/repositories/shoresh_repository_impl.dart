import '../../../../core/database/app_database.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/shoresh_entity.dart';
import '../../domain/repositories/shoresh_repository.dart';
import '../datasources/shoresh_seed_data.dart';

/// Implementation of [ShoreshRepository] providing access to Hebrew root families,
/// root extractor quiz generator, and local progress persistence using [AppDatabase].
final class ShoreshRepositoryImpl implements ShoreshRepository {
  ShoreshRepositoryImpl({this.database});

  final AppDatabase? database;
  final Map<String, bool> _inMemoryMastered = {};

  @override
  List<ShoreshRoot> getAllRoots() {
    return ShoreshSeedData.roots;
  }

  @override
  ShoreshRoot? getRootById(String id) {
    for (final r in ShoreshSeedData.roots) {
      if (r.id == id) return r;
    }
    return null;
  }

  @override
  Future<Result<Map<String, bool>, Failure>> getMasteredRootIds() async {
    final db = database;
    if (db == null) {
      return Success(Map.unmodifiable(_inMemoryMastered));
    }

    try {
      final rows = await db.getAllShoreshProgress();
      final map = <String, bool>{};
      for (final r in rows) {
        map[r.rootId] = r.masteryLevel >= 0.8;
      }
      return Success(map);
    } catch (e) {
      return Error(CacheFailure('Failed to load mastered roots: $e'));
    }
  }

  @override
  Future<Result<void, Failure>> recordRootMastery({
    required String rootId,
    required bool isMastered,
    required int quizCorrectIncrement,
  }) async {
    _inMemoryMastered[rootId] = isMastered;
    final db = database;
    if (db == null) {
      return const Success(null);
    }

    try {
      final existing = await db.getShoreshProgress(rootId);
      final currentCards = existing?.cardsPracticedCount ?? 0;
      final currentCorrect = existing?.quizCorrectCount ?? 0;
      final newLevel = isMastered ? 1.0 : (existing?.masteryLevel ?? 0.0);

      await db.upsertShoreshProgress(
        rootId: rootId,
        masteryLevel: newLevel,
        cardsPracticedCount: currentCards + 1,
        quizCorrectCount: currentCorrect + quizCorrectIncrement,
        lastPracticedAt: DateTime.now().toUtc(),
      );
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure('Failed to persist root mastery: $e'));
    }
  }

  @override
  List<ShoreshQuizQuestion> generateQuizQuestions({int count = 10}) {
    const challenges = ShoreshSeedData.detectiveQuizChallenges;
    if (challenges.length <= count) {
      return List.unmodifiable(challenges);
    }
    return List.unmodifiable(challenges.take(count));
  }
}
