import 'package:equatable/equatable.dart';

import '../../domain/entities/israeli_life_scene.dart';

/// Base class for all ScenesBloc events.
sealed class ScenesEvent extends Equatable {
  const ScenesEvent();

  @override
  List<Object?> get props => [];
}

/// Request to load all pre-seeded scenes and completion progress from database.
final class LoadScenesEvent extends ScenesEvent {
  const LoadScenesEvent();
}

/// Filters the loaded scenes list by SceneType category and/or textual search query.
final class FilterScenesEvent extends ScenesEvent {
  const FilterScenesEvent({this.type, this.query = ''});

  final SceneType? type;
  final String query;

  @override
  List<Object?> get props => [type, query];
}

/// Signals that the user successfully completed all challenges in a specific scene.
final class CompleteSceneEvent extends ScenesEvent {
  const CompleteSceneEvent({
    required this.sceneId,
    required this.wordsMasteredCount,
    required this.challengeScore,
  });

  final String sceneId;
  final int wordsMasteredCount;
  final int challengeScore;

  @override
  List<Object?> get props => [sceneId, wordsMasteredCount, challengeScore];
}

/// Toggles whether Hebrew vowels (nikkud) are displayed across scenes.
final class ToggleScenesNikkudEvent extends ScenesEvent {
  const ToggleScenesNikkudEvent();
}
