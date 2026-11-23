import 'package:equatable/equatable.dart';

/// Navigation maneuvers commonly announced by Waze in Israel.
enum WazeManeuverType {
  turnRight,
  turnLeft,
  roundaboutExit,
  uTurn,
  mergeHighway,
  speedCamera,
  speedBump,
  roadHazard,
}

/// A real-life Hebrew voice navigation command from Waze.
final class WazePrompt extends Equatable {
  final String id;
  final WazeManeuverType maneuverType;
  final String hebrewWithNikkud;
  final String hebrewPlain;
  final String transcriptionRu;
  final String translationRu;
  final String correctActionRu;
  final List<String> actionOptionsRu;
  final int correctOptionIndex;
  final String iconEmoji;

  const WazePrompt({
    required this.id,
    required this.maneuverType,
    required this.hebrewWithNikkud,
    required this.hebrewPlain,
    required this.transcriptionRu,
    required this.translationRu,
    required this.correctActionRu,
    required this.actionOptionsRu,
    required this.correctOptionIndex,
    required this.iconEmoji,
  });

  @override
  List<Object?> get props => [
        id,
        maneuverType,
        hebrewWithNikkud,
        hebrewPlain,
        transcriptionRu,
        translationRu,
        correctActionRu,
        actionOptionsRu,
        correctOptionIndex,
        iconEmoji,
      ];
}
