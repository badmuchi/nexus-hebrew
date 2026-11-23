import 'package:equatable/equatable.dart';

/// Sections of the Israeli YAEL (יע״ל) standardized Hebrew exam.
enum YaelSection {
  readingComprehension(
    id: 'reading',
    titleRu: 'Понимание прочитанного текста (הֲבָנַת הַנִּקְרָא)',
    iconEmoji: '📖',
    targetMinutes: 10,
  ),
  sentenceCompletion(
    id: 'completion',
    titleRu: 'Заполнение пропусков и предлоги (הַשְׁלָמַת מִשְׁפָּטִים)',
    iconEmoji: '🧩',
    targetMinutes: 7,
  ),
  restatement(
    id: 'restatement',
    titleRu: 'Перефразирование и академический стиль (נִסּוּחַ מֵחָדָשׁ)',
    iconEmoji: '✍️',
    targetMinutes: 8,
  );

  final String id;
  final String titleRu;
  final String iconEmoji;
  final int targetMinutes;

  const YaelSection({
    required this.id,
    required this.titleRu,
    required this.iconEmoji,
    required this.targetMinutes,
  });
}

/// A diagnostic question from the YAEL / Ulpan Alef academic examination.
final class YaelQuestion extends Equatable {
  final String id;
  final YaelSection section;
  final String? readingPassageTitleRu;
  final String? readingPassageHebrewWithNikkud;
  final String promptHebrewWithNikkud;
  final String promptHebrewPlain;
  final String promptRussian;
  final List<String> options;
  final int correctOptionIndex;
  final String explanationRu;
  final String keyGrammarRuleRu;
  final int pointsWeight;

  const YaelQuestion({
    required this.id,
    required this.section,
    this.readingPassageTitleRu,
    this.readingPassageHebrewWithNikkud,
    required this.promptHebrewWithNikkud,
    required this.promptHebrewPlain,
    required this.promptRussian,
    required this.options,
    required this.correctOptionIndex,
    required this.explanationRu,
    required this.keyGrammarRuleRu,
    this.pointsWeight = 10,
  });

  bool isCorrect(int selectedIndex) => selectedIndex == correctOptionIndex;

  @override
  List<Object?> get props => [
        id,
        section,
        readingPassageTitleRu,
        readingPassageHebrewWithNikkud,
        promptHebrewWithNikkud,
        promptHebrewPlain,
        promptRussian,
        options,
        correctOptionIndex,
        explanationRu,
        keyGrammarRuleRu,
        pointsWeight,
      ];
}
