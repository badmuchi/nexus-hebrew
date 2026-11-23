import 'package:equatable/equatable.dart';

/// Cultural dialogue and greeting etiquette challenges for Israeli holidays and Shabbat.
final class HolidayScenarioQuestion extends Equatable {
  final String id;
  final String situationRu;
  final String interlocutorRoleRu;
  final String speechHebrewWithNikkud;
  final String speechHebrewPlain;
  final String transcriptionRu;
  final String translationRu;
  final String etiquetteTipRu;
  final List<String> responseOptions;
  final int bestOptionIndex;
  final String explanationRu;

  const HolidayScenarioQuestion({
    required this.id,
    required this.situationRu,
    required this.interlocutorRoleRu,
    required this.speechHebrewWithNikkud,
    required this.speechHebrewPlain,
    required this.transcriptionRu,
    required this.translationRu,
    required this.etiquetteTipRu,
    required this.responseOptions,
    required this.bestOptionIndex,
    required this.explanationRu,
  });

  String get bestResponse => responseOptions[bestOptionIndex];

  @override
  List<Object?> get props => [
        id,
        situationRu,
        interlocutorRoleRu,
        speechHebrewWithNikkud,
        speechHebrewPlain,
        transcriptionRu,
        translationRu,
        etiquetteTipRu,
        responseOptions,
        bestOptionIndex,
        explanationRu,
      ];
}
