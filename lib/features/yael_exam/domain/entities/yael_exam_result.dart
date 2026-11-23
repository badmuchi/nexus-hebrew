import 'package:equatable/equatable.dart';

import 'yael_question.dart';

/// Level of Hebrew proficiency and academic exemption based on YAEL score (50-150).
enum YaelProficiencyBand {
  preUlpan(
    minScore: 50,
    maxScore: 83,
    hebrewTitle: 'לֹא עָבַר (דָּרוּשׁ אוּלְפָּן בְּסִיסִי)',
    titleRu: 'Ниже проходного (Требуется базовый ульпан)',
    academicExemptionRu: 'Нет допуска к академическим курсам на иврите',
    colorHex: 0xFFE53935,
  ),
  ramaAlef(
    minScore: 84,
    maxScore: 104,
    hebrewTitle: 'רָמָה א׳ (סִיּוּם אוּלְפָּן אָלֶף)',
    titleRu: 'Уровень Рама Алеф (Окончание базового ульпана)',
    academicExemptionRu: 'Условный допуск с обязательными 3 курсами иврита',
    colorHex: 0xFFFB8C00,
  ),
  ramaBet(
    minScore: 105,
    maxScore: 119,
    hebrewTitle: 'רָמָה ב׳ (בֵּינוֹנִי מִתְקַדֵּם)',
    titleRu: 'Уровень Рама Бет (Уверенный средний)',
    academicExemptionRu: 'Освобождение от ульпана Алеф, 2 курса иврита в вузе',
    colorHex: 0xFFFDD835,
  ),
  ramaGimel(
    minScore: 120,
    maxScore: 131,
    hebrewTitle: 'רָמָה ג׳ (גָּבוֹהַּ — לִמּוּדִים אֲקָדֶמִיִּים)',
    titleRu: 'Уровень Рама Гимель (Высокий академический)',
    academicExemptionRu: 'Допуск на большинство факультетов (инженерия, науки)',
    colorHex: 0xFF43A047,
  ),
  ptorAcademic(
    minScore: 132,
    maxScore: 150,
    hebrewTitle: 'פְּטוֹר אֲקָדֶמִי מָלֵא (רָמָה ד׳ / שְׂפַת אֵם)',
    titleRu: 'Полное освобождение — ПТОР (Уровень носителя)',
    academicExemptionRu: 'Безусловный допуск на любые специальности (включая медицину и юриспруденцию)',
    colorHex: 0xFF1E88E5,
  );

  final int minScore;
  final int maxScore;
  final String hebrewTitle;
  final String titleRu;
  final String academicExemptionRu;
  final int colorHex;

  const YaelProficiencyBand({
    required this.minScore,
    required this.maxScore,
    required this.hebrewTitle,
    required this.titleRu,
    required this.academicExemptionRu,
    required this.colorHex,
  });

  static YaelProficiencyBand fromScore(int score) {
    if (score >= 132) return YaelProficiencyBand.ptorAcademic;
    if (score >= 120) return YaelProficiencyBand.ramaGimel;
    if (score >= 105) return YaelProficiencyBand.ramaBet;
    if (score >= 84) return YaelProficiencyBand.ramaAlef;
    return YaelProficiencyBand.preUlpan;
  }
}

/// Evaluated outcome of the YAEL test session.
final class YaelExamResult extends Equatable {
  final int totalQuestions;
  final int correctCount;
  final int scaledScore; // 50 to 150
  final YaelProficiencyBand band;
  final Map<YaelSection, int> sectionCorrectCounts;
  final Map<YaelSection, int> sectionTotals;
  final DateTime completedAt;

  const YaelExamResult({
    required this.totalQuestions,
    required this.correctCount,
    required this.scaledScore,
    required this.band,
    required this.sectionCorrectCounts,
    required this.sectionTotals,
    required this.completedAt,
  });

  factory YaelExamResult.evaluate({
    required List<YaelQuestion> questions,
    required Map<String, int> userAnswers,
  }) {
    int correct = 0;
    final Map<YaelSection, int> sectionCorrect = {};
    final Map<YaelSection, int> sectionTotals = {};

    for (final s in YaelSection.values) {
      sectionCorrect[s] = 0;
      sectionTotals[s] = 0;
    }

    for (final q in questions) {
      final userSelected = userAnswers[q.id];
      sectionTotals[q.section] = (sectionTotals[q.section] ?? 0) + 1;
      if (userSelected != null && q.isCorrect(userSelected)) {
        correct++;
        sectionCorrect[q.section] = (sectionCorrect[q.section] ?? 0) + 1;
      }
    }

    final total = questions.isEmpty ? 1 : questions.length;
    final ratio = correct / total;
    // Scale linearly from 50 to 150
    final scaled = (50 + (ratio * 100)).round().clamp(50, 150);
    final band = YaelProficiencyBand.fromScore(scaled);

    return YaelExamResult(
      totalQuestions: questions.length,
      correctCount: correct,
      scaledScore: scaled,
      band: band,
      sectionCorrectCounts: sectionCorrect,
      sectionTotals: sectionTotals,
      completedAt: DateTime.now(),
    );
  }

  double get accuracyPercent =>
      totalQuestions > 0 ? (correctCount / totalQuestions) * 100 : 0.0;

  @override
  List<Object?> get props => [
        totalQuestions,
        correctCount,
        scaledScore,
        band,
        sectionCorrectCounts,
        sectionTotals,
        completedAt,
      ];
}
