import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/features/scenes/data/datasources/israeli_scenes_seed_data.dart';
import 'package:nexus_hebrew_app/features/scenes/domain/entities/israeli_life_scene.dart';
import 'package:nexus_hebrew_app/features/scenes/domain/repositories/scenes_repository.dart';
import 'package:nexus_hebrew_app/features/scenes/domain/usecases/get_scenes_use_case.dart';

class _MockScenesRepository extends Mock implements ScenesRepository {}

void main() {
  late _MockScenesRepository repository;
  late GetScenesUseCase useCase;

  setUp(() {
    repository = _MockScenesRepository();
    useCase = GetScenesUseCase(repository);

    when(() => repository.getAllScenes()).thenReturn(IsraeliScenesSeedData.scenes);
  });

  group('GetScenesUseCase', () {
    test('returns all scenes when no type filter and empty query', () {
      final result = useCase();
      expect(result.length, equals(6));
    });

    test('filters scenes by SceneType', () {
      final result = useCase(type: SceneType.supermarket);
      expect(result.length, equals(1));
      expect(result.first.id, equals('scene_supermarket'));
    });

    test('filters scenes by Russian query in title', () {
      final result = useCase(query: 'Поликлиника');
      expect(result.length, equals(1));
      expect(result.first.id, equals('scene_clinic'));
    });

    test('filters scenes by Hebrew word in vocabulary', () {
      final result = useCase(query: 'עגלה');
      expect(result.isNotEmpty, isTrue);
      expect(result.first.id, equals('scene_supermarket'));
    });

    test('returns empty list when query matches nothing', () {
      final result = useCase(query: 'несуществующий запрос xyz123');
      expect(result, isEmpty);
    });
  });
}
