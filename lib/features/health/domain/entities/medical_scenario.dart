import 'package:equatable/equatable.dart';

/// Categories of medical situations in Israel.
enum MedicalScenarioCategory {
  doctorClinic(
    id: 'doctor',
    titleRu: 'Семейный врач (רופא משפחה)',
    emoji: '🩺',
  ),
  pharmacy(
    id: 'pharmacy',
    titleRu: 'Аптека (סופר-פארם / מרשם)',
    emoji: '💊',
  ),
  bloodAndLab(
    id: 'lab',
    titleRu: 'Анализы и Лаборатория (בדיקות)',
    emoji: '🩸',
  ),
  emergencyMda(
    id: 'emergency',
    titleRu: 'Неотложка и Скорая (מד״א / טרם)',
    emoji: '🚑',
  );

  final String id;
  final String titleRu;
  final String emoji;

  const MedicalScenarioCategory({
    required this.id,
    required this.titleRu,
    required this.emoji,
  });
}

/// A dialogue question or situation at the Israeli clinic/pharmacy.
final class MedicalCaseQuestion extends Equatable {
  final String id;
  final MedicalScenarioCategory category;
  final String doctorRoleRu;
  final String speechHebrewWithNikkud;
  final String speechHebrewPlain;
  final String transcriptionRu;
  final String translationRu;
  final String patientTipRu;
  final List<String> responseOptions;
  final int bestResponseIndex;
  final String explanationRu;

  const MedicalCaseQuestion({
    required this.id,
    required this.category,
    required this.doctorRoleRu,
    required this.speechHebrewWithNikkud,
    required this.speechHebrewPlain,
    required this.transcriptionRu,
    required this.translationRu,
    required this.patientTipRu,
    required this.responseOptions,
    required this.bestResponseIndex,
    required this.explanationRu,
  });

  String get bestResponse => responseOptions[bestResponseIndex];

  @override
  List<Object?> get props => [
        id,
        category,
        doctorRoleRu,
        speechHebrewWithNikkud,
        speechHebrewPlain,
        transcriptionRu,
        translationRu,
        patientTipRu,
        responseOptions,
        bestResponseIndex,
        explanationRu,
      ];
}
