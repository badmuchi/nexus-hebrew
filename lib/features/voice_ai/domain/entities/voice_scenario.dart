import 'package:flutter/foundation.dart';

/// Suggested answer for the user with pronunciation guidance.
@immutable
class SuggestedVoiceAnswer {
  final String id;
  final String hebrewWithNikkud;
  final String hebrewNormalized;
  final String transcriptionRu;
  final String translationRu;
  final List<String> expectedKeywords;

  const SuggestedVoiceAnswer({
    required this.id,
    required this.hebrewWithNikkud,
    required this.hebrewNormalized,
    required this.transcriptionRu,
    required this.translationRu,
    required this.expectedKeywords,
  });
}

/// A single conversational exchange turn between Sabra and the user.
@immutable
class VoiceTurn {
  final int turnIndex;
  final String sabraSpeechHebrewWithNikkud;
  final String sabraSpeechNormalized;
  final String sabraSpeechRu;
  final String? audioPath;
  final List<SuggestedVoiceAnswer> suggestedAnswers;
  final String culturalTipRu;
  final String grammarHintRu;
  final int bestAnswerIndex;

  const VoiceTurn({
    required this.turnIndex,
    required this.sabraSpeechHebrewWithNikkud,
    required this.sabraSpeechNormalized,
    required this.sabraSpeechRu,
    this.audioPath,
    required this.suggestedAnswers,
    required this.culturalTipRu,
    required this.grammarHintRu,
    this.bestAnswerIndex = 0,
  });
}

/// A complete realistic Israeli scenario with Sabra.
@immutable
class VoiceScenario {
  final String id;
  final String titleRu;
  final String titleHebrewWithNikkud;
  final String locationRu;
  final String iconEmoji;
  final String descriptionRu;
  final List<VoiceTurn> turns;

  const VoiceScenario({
    required this.id,
    required this.titleRu,
    required this.titleHebrewWithNikkud,
    required this.locationRu,
    required this.iconEmoji,
    required this.descriptionRu,
    required this.turns,
  });
}
