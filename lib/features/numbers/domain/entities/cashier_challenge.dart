import 'package:equatable/equatable.dart';

enum CashierChallengeMode {
  marketCheckout(
    id: 'market_checkout',
    titleRu: 'Касса и Сдача',
    icon: '🛒',
    description: 'Услышь цену от кассира и собери точную сумму монетами и купюрами',
  ),
  genderDuel(
    id: 'gender_duel',
    titleRu: 'Блиц М.Р. / Ж.Р.',
    icon: '⚖️',
    description: 'Выбери правильное числительное к существительному с учетом рода',
  ),
  clockTime(
    id: 'clock_time',
    titleRu: 'Который час?',
    icon: '⏰',
    description: 'Определи время по разговорным выражениям на иврите',
  ),
  cashierDialogue(
    id: 'cashier_dialogue',
    titleRu: 'Диалог на кассе',
    icon: '💳',
    description: 'Ответь на типичные реплики израильского кассира в супермаркете',
  );

  final String id;
  final String titleRu;
  final String icon;
  final String description;

  const CashierChallengeMode({
    required this.id,
    required this.titleRu,
    required this.icon,
    required this.description,
  });
}

final class CashierChallengeQuestion extends Equatable {
  final String id;
  final CashierChallengeMode mode;
  final String promptRu;
  final String promptHebrewWithNikkud;
  final String transcriptionRu;
  final int? targetAmountShekels;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanationRu;
  final String? audioPath;

  const CashierChallengeQuestion({
    required this.id,
    required this.mode,
    required this.promptRu,
    required this.promptHebrewWithNikkud,
    required this.transcriptionRu,
    this.targetAmountShekels,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanationRu,
    this.audioPath,
  });

  String get correctAnswer => options[correctAnswerIndex];

  @override
  List<Object?> get props => [
        id,
        mode,
        promptRu,
        promptHebrewWithNikkud,
        transcriptionRu,
        targetAmountShekels,
        options,
        correctAnswerIndex,
        explanationRu,
        audioPath,
      ];
}
