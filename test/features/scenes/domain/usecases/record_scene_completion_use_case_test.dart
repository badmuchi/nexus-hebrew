import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/scenes/domain/repositories/scenes_repository.dart';
import 'package:nexus_hebrew_app/features/scenes/domain/usecases/record_scene_completion_use_case.dart';

class _MockScenesRepository extends Mock implements ScenesRepository {}

void main() {
  late _MockScenesRepository repository;
  late RecordSceneCompletionUseCase useCase;

  setUp(() {
    repository = _MockScenesRepository();
    useCase = RecordSceneCompletionUseCase(repository);
  });

  group('RecordSceneCompletionUseCase', () {
    test('calls repository when params are valid', () async {
      when(() => repository.recordSceneCompletion(
        sceneId: any(named: 'sceneId'),
        wordsMasteredCount: any(named: 'wordsMasteredCount'),
        challengeScore: any(named: 'challengeScore'),
      )).thenAnswer((_) async => const Success(null));

      const params = RecordSceneCompletionParams(
        sceneId: 'scene_clinic',
        wordsMasteredCount: 5,
        challengeScore: 3,
      );

      final result = await useCase(params);
      expect(result, isA<Success<void, Failure>>());
      verify(() => repository.recordSceneCompletion(
        sceneId: 'scene_clinic',
        wordsMasteredCount: 5,
        challengeScore: 3,
      )).called(1);
    });

    test('returns ValidationFailure when sceneId is empty', () async {
      const params = RecordSceneCompletionParams(
        sceneId: '   ',
        wordsMasteredCount: 5,
        challengeScore: 3,
      );

      final result = await useCase(params);
      expect(result, isA<Error<void, Failure>>());
      expect((result as Error<void, Failure>).failure, isA<ValidationFailure>());
      verifyNever(() => repository.recordSceneCompletion(
        sceneId: any(named: 'sceneId'),
        wordsMasteredCount: any(named: 'wordsMasteredCount'),
        challengeScore: any(named: 'challengeScore'),
      ));
    });

    test('RecordSceneCompletionParams props work correctly', () {
      const p1 = RecordSceneCompletionParams(
        sceneId: 's1',
        wordsMasteredCount: 2,
        challengeScore: 1,
      );
      const p2 = RecordSceneCompletionParams(
        sceneId: 's1',
        wordsMasteredCount: 2,
        challengeScore: 1,
      );
      const p3 = RecordSceneCompletionParams(
        sceneId: 's2',
        wordsMasteredCount: 2,
        challengeScore: 1,
      );

      expect(p1, equals(p2));
      expect(p1 == p3, isFalse);
    });
  });
}
