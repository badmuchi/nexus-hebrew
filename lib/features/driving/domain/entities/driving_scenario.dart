import 'package:equatable/equatable.dart';

/// Categories of driving and road situations in Israel.
enum DrivingScenarioCategory {
  gasStation(
    id: 'gas_station',
    titleRu: 'Заправка (תחנת דלק)',
    emoji: '⛽',
  ),
  policeStop(
    id: 'police',
    titleRu: 'Дорожная полиция (משטרת תנועה)',
    emoji: '👮',
  ),
  carInspection(
    id: 'inspection',
    titleRu: 'Техосмотр и Гараж (טסט ומוסך)',
    emoji: '🔧',
  ),
  accidentExchange(
    id: 'accident',
    titleRu: 'ДТП и Страховка (דוח תאונה)',
    emoji: '📑',
  );

  final String id;
  final String titleRu;
  final String emoji;

  const DrivingScenarioCategory({
    required this.id,
    required this.titleRu,
    required this.emoji,
  });
}

/// A dialogue question or situation on Israeli roads.
final class DrivingScenarioQuestion extends Equatable {
  final String id;
  final DrivingScenarioCategory category;
  final String interlocutorRoleRu;
  final String speechHebrewWithNikkud;
  final String speechHebrewPlain;
  final String transcriptionRu;
  final String translationRu;
  final String driverTipRu;
  final List<String> responseOptions;
  final int bestResponseIndex;
  final String explanationRu;

  const DrivingScenarioQuestion({
    required this.id,
    required this.category,
    required this.interlocutorRoleRu,
    required this.speechHebrewWithNikkud,
    required this.speechHebrewPlain,
    required this.transcriptionRu,
    required this.translationRu,
    required this.driverTipRu,
    required this.responseOptions,
    required this.bestResponseIndex,
    required this.explanationRu,
  });

  String get bestResponse => responseOptions[bestResponseIndex];

  @override
  List<Object?> get props => [
        id,
        category,
        interlocutorRoleRu,
        speechHebrewWithNikkud,
        speechHebrewPlain,
        transcriptionRu,
        translationRu,
        driverTipRu,
        responseOptions,
        bestResponseIndex,
        explanationRu,
      ];
}
