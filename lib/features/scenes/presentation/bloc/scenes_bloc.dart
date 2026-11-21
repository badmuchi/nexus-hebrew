import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_completed_scenes_use_case.dart';
import '../../domain/usecases/get_scenes_use_case.dart';
import '../../domain/usecases/record_scene_completion_use_case.dart';
import 'scenes_event.dart';
import 'scenes_state.dart';

/// Business logic component managing Israeli life scenes catalog, filtering, and progress.
class ScenesBloc extends Bloc<ScenesEvent, ScenesState> {
  ScenesBloc({
    required GetScenesUseCase getScenesUseCase,
    required GetCompletedScenesUseCase getCompletedScenesUseCase,
    required RecordSceneCompletionUseCase recordSceneCompletionUseCase,
  })  : _getScenesUseCase = getScenesUseCase,
        _getCompletedScenesUseCase = getCompletedScenesUseCase,
        _recordSceneCompletionUseCase = recordSceneCompletionUseCase,
        super(const ScenesInitial()) {
    on<LoadScenesEvent>(_onLoadScenes);
    on<FilterScenesEvent>(_onFilterScenes);
    on<CompleteSceneEvent>(_onCompleteScene);
    on<ToggleScenesNikkudEvent>(_onToggleNikkud);
  }

  final GetScenesUseCase _getScenesUseCase;
  final GetCompletedScenesUseCase _getCompletedScenesUseCase;
  final RecordSceneCompletionUseCase _recordSceneCompletionUseCase;

  Future<void> _onLoadScenes(
    LoadScenesEvent event,
    Emitter<ScenesState> emit,
  ) async {
    emit(const ScenesLoading());

    final scenes = _getScenesUseCase();
    final completedRes = await _getCompletedScenesUseCase();

    final completedMap = completedRes.fold(
      (failure) => <String, bool>{},
      (map) => map,
    );

    emit(
      ScenesLoaded(
        allScenes: scenes,
        filteredScenes: scenes,
        completedSceneIds: completedMap,
      ),
    );
  }

  void _onFilterScenes(
    FilterScenesEvent event,
    Emitter<ScenesState> emit,
  ) {
    final current = state;
    if (current is! ScenesLoaded) return;

    final filtered = _getScenesUseCase(
      type: event.type,
      query: event.query,
    );

    emit(
      current.copyWith(
        filteredScenes: filtered,
        selectedType: event.type,
        clearType: event.type == null,
        searchQuery: event.query,
      ),
    );
  }

  Future<void> _onCompleteScene(
    CompleteSceneEvent event,
    Emitter<ScenesState> emit,
  ) async {
    final current = state;
    if (current is! ScenesLoaded) return;

    final params = RecordSceneCompletionParams(
      sceneId: event.sceneId,
      wordsMasteredCount: event.wordsMasteredCount,
      challengeScore: event.challengeScore,
    );

    final res = await _recordSceneCompletionUseCase(params);

    res.fold(
      (failure) {
        emit(current.copyWith(transientNotice: 'Ошибка сохранения: ${failure.message}'));
      },
      (_) {
        final updatedMap = Map<String, bool>.from(current.completedSceneIds)
          ..[event.sceneId] = true;

        emit(
          current.copyWith(
            completedSceneIds: updatedMap,
            transientNotice: 'Локация успешно освоена!',
          ),
        );
      },
    );
  }

  void _onToggleNikkud(
    ToggleScenesNikkudEvent event,
    Emitter<ScenesState> emit,
  ) {
    final current = state;
    if (current is! ScenesLoaded) return;

    emit(current.copyWith(showNikkud: !current.showNikkud));
  }
}
