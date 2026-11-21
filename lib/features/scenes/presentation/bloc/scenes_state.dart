import 'package:equatable/equatable.dart';

import '../../domain/entities/israeli_life_scene.dart';

/// Base class for all ScenesBloc states.
sealed class ScenesState extends Equatable {
  const ScenesState();

  @override
  List<Object?> get props => [];
}

/// Initial state before scenes are loaded.
final class ScenesInitial extends ScenesState {
  const ScenesInitial();
}

/// Loading state while fetching scenes or database progress.
final class ScenesLoading extends ScenesState {
  const ScenesLoading();
}

/// Error state if scenes fail to load.
final class ScenesError extends ScenesState {
  const ScenesError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// State representing successfully loaded and optionally filtered scenes.
final class ScenesLoaded extends ScenesState {
  const ScenesLoaded({
    required this.allScenes,
    required this.filteredScenes,
    required this.completedSceneIds,
    this.selectedType,
    this.searchQuery = '',
    this.showNikkud = true,
    this.transientNotice,
  });

  final List<IsraeliLifeScene> allScenes;
  final List<IsraeliLifeScene> filteredScenes;
  final Map<String, bool> completedSceneIds;
  final SceneType? selectedType;
  final String searchQuery;
  final bool showNikkud;
  final String? transientNotice;

  int get completedCount =>
      allScenes.where((s) => completedSceneIds[s.id] == true).length;

  double get progressRatio =>
      allScenes.isEmpty ? 0.0 : completedCount / allScenes.length;

  ScenesLoaded copyWith({
    List<IsraeliLifeScene>? allScenes,
    List<IsraeliLifeScene>? filteredScenes,
    Map<String, bool>? completedSceneIds,
    SceneType? selectedType,
    bool clearType = false,
    String? searchQuery,
    bool? showNikkud,
    String? transientNotice,
    bool clearNotice = false,
  }) {
    return ScenesLoaded(
      allScenes: allScenes ?? this.allScenes,
      filteredScenes: filteredScenes ?? this.filteredScenes,
      completedSceneIds: completedSceneIds ?? this.completedSceneIds,
      selectedType: clearType ? null : (selectedType ?? this.selectedType),
      searchQuery: searchQuery ?? this.searchQuery,
      showNikkud: showNikkud ?? this.showNikkud,
      transientNotice: clearNotice ? null : (transientNotice ?? this.transientNotice),
    );
  }

  @override
  List<Object?> get props => [
        allScenes,
        filteredScenes,
        completedSceneIds,
        selectedType,
        searchQuery,
        showNikkud,
        transientNotice,
      ];
}
