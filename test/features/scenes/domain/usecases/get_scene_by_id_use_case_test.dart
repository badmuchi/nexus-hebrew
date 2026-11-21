import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/features/scenes/data/datasources/israeli_scenes_seed_data.dart';
import 'package:nexus_hebrew_app/features/scenes/domain/repositories/scenes_repository.dart';
import 'package:nexus_hebrew_app/features/scenes/domain/usecases/get_scene_by_id_use_case.dart';

class _MockScenesRepository extends Mock implements ScenesRepository {}

void main() {
  late _MockScenesRepository repository;
  late GetSceneByIdUseCase useCase;

  setUp(() {
    repository = _MockScenesRepository();
    useCase = GetSceneByIdUseCase(repository);

    when(() => repository.getSceneById('scene_cafe'))
        .thenReturn(IsraeliScenesSeedData.scenes.firstWhere((s) => s.id == 'scene_cafe'));
    when(() => repository.getSceneById('unknown_id')).thenReturn(null);
  });

  group('GetSceneByIdUseCase', () {
    test('returns scene when ID exists', () {
      final scene = useCase('scene_cafe');
      expect(scene, isNotNull);
      expect(scene?.titleRussian, 'Кафе и заказ');
    });

    test('returns null when ID does not exist', () {
      final scene = useCase('unknown_id');
      expect(scene, isNull);
    });

    test('returns null for blank or empty ID', () {
      expect(useCase(''), isNull);
      expect(useCase('   '), isNull);
      verifyNever(() => repository.getSceneById(any()));
    });
  });
}
