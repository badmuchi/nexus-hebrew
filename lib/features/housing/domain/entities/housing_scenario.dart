import 'package:equatable/equatable.dart';

/// Dialogue situations between tenant (שוכר) and landlord (בעל הבית) or house committee (ועד בית).
final class HousingScenarioQuestion extends Equatable {
  final String id;
  final String interlocutorRoleRu;
  final String speechHebrewWithNikkud;
  final String speechHebrewPlain;
  final String transcriptionRu;
  final String translationRu;
  final String tenantTipRu;
  final List<String> responseOptions;
  final int bestResponseIndex;
  final String explanationRu;

  const HousingScenarioQuestion({
    required this.id,
    required this.interlocutorRoleRu,
    required this.speechHebrewWithNikkud,
    required this.speechHebrewPlain,
    required this.transcriptionRu,
    required this.translationRu,
    required this.tenantTipRu,
    required this.responseOptions,
    required this.bestResponseIndex,
    required this.explanationRu,
  });

  String get bestResponse => responseOptions[bestResponseIndex];

  @override
  List<Object?> get props => [
        id,
        interlocutorRoleRu,
        speechHebrewWithNikkud,
        speechHebrewPlain,
        transcriptionRu,
        translationRu,
        tenantTipRu,
        responseOptions,
        bestResponseIndex,
        explanationRu,
      ];
}
