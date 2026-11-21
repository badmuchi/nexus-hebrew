import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/scenes/data/datasources/israeli_scenes_seed_data.dart';
import 'package:nexus_hebrew_app/features/scenes/domain/entities/israeli_life_scene.dart';
import 'package:nexus_hebrew_app/features/scenes/domain/usecases/get_completed_scenes_use_case.dart';
import 'package:nexus_hebrew_app/features/scenes/domain/usecases/get_scenes_use_case.dart';
import 'package:nexus_hebrew_app/features/scenes/domain/usecases/record_scene_completion_use_case.dart';
import 'package:nexus_hebrew_app/features/scenes/presentation/bloc/scenes_bloc.dart';
import 'package:nexus_hebrew_app/features/scenes/presentation/bloc/scenes_event.dart';
import 'package:nexus_hebrew_app/features/scenes/presentation/bloc/scenes_state.dart';

class _MockGetScenesUseCase extends Mock implements GetScenesUseCase {}
class _MockGetCompletedScenesUseCase extends Mock implements GetCompletedScenesUseCase {}
class _MockRecordSceneCompletionUseCase extends Mock implements RecordSceneCompletionUseCase {}

void main() {
  late _MockGetScenesUseCase getScenesUseCase;
  late _MockGetCompletedScenesUseCase getCompletedScenesUseCase;
  late _MockRecordSceneCompletionUseCase recordSceneCompletionUseCase;

  const scenes = IsraeliScenesSeedData.scenes;

  setUpAll(() {
    registerFallbackValue(
      const RecordSceneCompletionParams(
        sceneId: 'fallback',
        wordsMasteredCount: 1,
        challengeScore: 1,
      ),
    );
  });

  setUp(() {
    getScenesUseCase = _MockGetScenesUseCase();
    getCompletedScenesUseCase = _MockGetCompletedScenesUseCase();
    recordSceneCompletionUseCase = _MockRecordSceneCompletionUseCase();
  });

  ScenesBloc buildBloc() {
    return ScenesBloc(
      getScenesUseCase: getScenesUseCase,
      getCompletedScenesUseCase: getCompletedScenesUseCase,
      recordSceneCompletionUseCase: recordSceneCompletionUseCase,
    );
  }

  group('ScenesBloc', () {
    test('initial state is ScenesInitial', () {
      expect(buildBloc().state, equals(const ScenesInitial()));
    });

    blocTest<ScenesBloc, ScenesState>(
      'emits [ScenesLoading, ScenesLoaded] on LoadScenesEvent',
      build: () {
        when(() => getScenesUseCase()).thenReturn(scenes);
        when(() => getCompletedScenesUseCase()).thenAnswer(
          (_) async => const Success({'scene_supermarket': true}),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadScenesEvent()),
      expect: () => [
        const ScenesLoading(),
        isA<ScenesLoaded>()
            .having((s) => s.allScenes.length, 'allScenes.length', 6)
            .having((s) => s.completedSceneIds['scene_supermarket'], 'completed', true)
            .having((s) => s.completedCount, 'completedCount', 1)
            .having((s) => s.showNikkud, 'showNikkud', true),
      ],
    );

    blocTest<ScenesBloc, ScenesState>(
      'filters scenes by type on FilterScenesEvent',
      build: () {
        when(() => getScenesUseCase()).thenReturn(scenes);
        when(() => getCompletedScenesUseCase()).thenAnswer(
          (_) async => const Success({}),
        );
        when(() => getScenesUseCase(type: SceneType.clinic, query: '')).thenReturn(
          [scenes.firstWhere((s) => s.id == 'scene_clinic')],
        );
        return buildBloc();
      },
      seed: () => const ScenesLoaded(
        allScenes: scenes,
        filteredScenes: scenes,
        completedSceneIds: {},
      ),
      act: (bloc) => bloc.add(const FilterScenesEvent(type: SceneType.clinic)),
      expect: () => [
        isA<ScenesLoaded>()
            .having((s) => s.filteredScenes.length, 'filtered.length', 1)
            .having((s) => s.selectedType, 'selectedType', SceneType.clinic),
      ],
    );

    blocTest<ScenesBloc, ScenesState>(
      'updates completedSceneIds on successful CompleteSceneEvent',
      build: () {
        when(() => recordSceneCompletionUseCase(any())).thenAnswer(
          (_) async => const Success(null),
        );
        return buildBloc();
      },
      seed: () => const ScenesLoaded(
        allScenes: scenes,
        filteredScenes: scenes,
        completedSceneIds: {},
      ),
      act: (bloc) => bloc.add(
        const CompleteSceneEvent(
          sceneId: 'scene_cafe',
          wordsMasteredCount: 6,
          challengeScore: 3,
        ),
      ),
      expect: () => [
        isA<ScenesLoaded>()
            .having((s) => s.completedSceneIds['scene_cafe'], 'completed', true)
            .having((s) => s.completedCount, 'completedCount', 1)
            .having((s) => s.transientNotice, 'notice', 'Локация успешно освоена!'),
      ],
    );

    blocTest<ScenesBloc, ScenesState>(
      'toggles showNikkud on ToggleScenesNikkudEvent',
      build: () => buildBloc(),
      seed: () => const ScenesLoaded(
        allScenes: scenes,
        filteredScenes: scenes,
        completedSceneIds: {},
        showNikkud: true,
      ),
      act: (bloc) => bloc.add(const ToggleScenesNikkudEvent()),
      expect: () => [
        isA<ScenesLoaded>().having((s) => s.showNikkud, 'showNikkud', false),
      ],
    );
  });
}
