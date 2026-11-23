import 'package:equatable/equatable.dart';

/// Region of the body for categorization.
enum BodyRegion {
  headAndFace(
    id: 'head_face',
    titleRu: 'Голова и лицо',
    emoji: '🗣️',
  ),
  torsoAndBack(
    id: 'torso_back',
    titleRu: 'Корпус и спина',
    emoji: '🫁',
  ),
  limbs(
    id: 'limbs',
    titleRu: 'Руки и ноги',
    emoji: '🦵',
  ),
  internalAndGeneral(
    id: 'internal',
    titleRu: 'Органы и симптомы',
    emoji: '🩺',
  );

  final String id;
  final String titleRu;
  final String emoji;

  const BodyRegion({
    required this.id,
    required this.titleRu,
    required this.emoji,
  });
}

/// Represents a human body part in Hebrew with dual form and pain phrasing rules.
final class BodyPart extends Equatable {
  final String id;
  final BodyRegion region;
  final String hebrewWithNikkud;
  final String hebrewPlain;
  final String transcriptionRu;
  final String russianName;
  final String? pluralOrDualHebrewWithNikkud;
  final String? pluralOrDualTranscriptionRu;
  final bool isDualForm; // e.g. עיניים, אוזניים, ידיים, רגליים
  final bool isFeminine; // Dual forms in Hebrew are almost always feminine!
  final String painPhraseHebrewWithNikkud;
  final String painPhraseTranscriptionRu;
  final String painPhraseRussian;
  final String grammaticalTipRu;
  final String iconEmoji;

  const BodyPart({
    required this.id,
    required this.region,
    required this.hebrewWithNikkud,
    required this.hebrewPlain,
    required this.transcriptionRu,
    required this.russianName,
    this.pluralOrDualHebrewWithNikkud,
    this.pluralOrDualTranscriptionRu,
    required this.isDualForm,
    required this.isFeminine,
    required this.painPhraseHebrewWithNikkud,
    required this.painPhraseTranscriptionRu,
    required this.painPhraseRussian,
    required this.grammaticalTipRu,
    required this.iconEmoji,
  });

  @override
  List<Object?> get props => [
        id,
        region,
        hebrewWithNikkud,
        hebrewPlain,
        transcriptionRu,
        russianName,
        pluralOrDualHebrewWithNikkud,
        pluralOrDualTranscriptionRu,
        isDualForm,
        isFeminine,
        painPhraseHebrewWithNikkud,
        painPhraseTranscriptionRu,
        painPhraseRussian,
        grammaticalTipRu,
        iconEmoji,
      ];
}
