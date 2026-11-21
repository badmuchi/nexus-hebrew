import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/scenes/domain/repositories/scenes_repository.dart';
import 'package:nexus_hebrew_app/features/scenes/domain/usecases/get_completed_scenes_use_case.dart';

class _MockScenesRepository extends Mock implements ScenesRepository {}

void main() {
  late _MockScenesRepository repository;
  late GetCompletedScenesUseCase useCase;

  setUp(() {
    repository = _MockScenesRepository();
    useCase = GetCompletedScenesUseCase(repository);
  });

  group('GetCompletedScenesUseCase', () {
    test('returns completed scenes map on success', () async {
      when(() => repository.getCompletedSceneIds()).thenAnswer(
        (_) async => const Success({'scene_supermarket': true, 'scene_cafe': true}),
      );

      final result = await useCase();
      expect(result, isA<Success<Map<String, bool>, Failure>>());
      final map = result.getOrNull();
      expect(map?['scene_supermarket'], isTrue);
      expect(map?['scene_cafe'], isTrue);
      expect(map?['scene_clinic'], isNull);
    });

    test('propagates failure from repository', () async {
      when(() => repository.getCompletedSceneIds()).thenAnswer(
        (_) async => const Error(CacheFailure('Database unreadable')),
      );

      final result = await useCase();
      expect(result, isA<Error<Map<String, bool>, Failure>>());
      expect((result as Error<Map<String, bool>, Failure>).failure, isA<CacheFailure>());
    });
  });
}
