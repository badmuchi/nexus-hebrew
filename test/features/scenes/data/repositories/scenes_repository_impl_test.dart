import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/database/app_database.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/scenes/data/repositories/scenes_repository_impl.dart';

class _MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  group('ScenesRepositoryImpl', () {
    test('getAllScenes and getSceneById work without database', () {
      final repo = ScenesRepositoryImpl();
      final all = repo.getAllScenes();
      expect(all.length, equals(6));

      final supermarket = repo.getSceneById('scene_supermarket');
      expect(supermarket, isNotNull);
      expect(supermarket?.titleRussian, 'Супермаркет и покупки');

      final notFound = repo.getSceneById('unknown_scene_id');
      expect(notFound, isNull);
    });

    test('getCompletedSceneIds and recordSceneCompletion work in in-memory mode', () async {
      final repo = ScenesRepositoryImpl();

      final initial = await repo.getCompletedSceneIds();
      expect(initial, isA<Success<Map<String, bool>, Failure>>());
      expect(initial.getOrNull(), isEmpty);

      final recordRes = await repo.recordSceneCompletion(
        sceneId: 'scene_supermarket',
        wordsMasteredCount: 5,
        challengeScore: 3,
      );
      expect(recordRes, isA<Success<void, Failure>>());

      final updated = await repo.getCompletedSceneIds();
      final map = updated.getOrNull();
      expect(map?['scene_supermarket'], isTrue);
    });

    test('getCompletedSceneIds loads from database when provided', () async {
      final db = _MockAppDatabase();
      final repo = ScenesRepositoryImpl(database: db);

      when(() => db.getAllSceneProgress()).thenAnswer((_) async => [
        SceneProgressRow(
          sceneId: 'scene_supermarket',
          isCompleted: true,
          wordsMasteredCount: 4,
          challengeScore: 3,
          lastVisitedAt: DateTime.utc(2026, 11, 20),
        ),
      ]);

      final res = await repo.getCompletedSceneIds();
      expect(res, isA<Success<Map<String, bool>, Failure>>());
      final map = res.getOrNull()!;
      expect(map['scene_supermarket'], isTrue);
      verify(() => db.getAllSceneProgress()).called(1);
    });

    test('recordSceneCompletion persists to database when provided', () async {
      final db = _MockAppDatabase();
      final repo = ScenesRepositoryImpl(database: db);

      when(() => db.upsertSceneProgress(
        sceneId: any(named: 'sceneId'),
        isCompleted: any(named: 'isCompleted'),
        wordsMasteredCount: any(named: 'wordsMasteredCount'),
        challengeScore: any(named: 'challengeScore'),
        lastVisitedAt: any(named: 'lastVisitedAt'),
      )).thenAnswer((_) async => 1);

      final res = await repo.recordSceneCompletion(
        sceneId: 'scene_cafe',
        wordsMasteredCount: 6,
        challengeScore: 3,
      );

      expect(res, isA<Success<void, Failure>>());
      verify(() => db.upsertSceneProgress(
        sceneId: 'scene_cafe',
        isCompleted: true,
        wordsMasteredCount: 6,
        challengeScore: 3,
        lastVisitedAt: any(named: 'lastVisitedAt'),
      )).called(1);
    });

    test('returns CacheFailure when database throws', () async {
      final db = _MockAppDatabase();
      final repo = ScenesRepositoryImpl(database: db);

      when(() => db.getAllSceneProgress()).thenThrow(Exception('DB disk error'));

      final res = await repo.getCompletedSceneIds();
      expect(res, isA<Error<Map<String, bool>, Failure>>());
      expect((res as Error<Map<String, bool>, Failure>).failure, isA<CacheFailure>());
    });
  });
}
