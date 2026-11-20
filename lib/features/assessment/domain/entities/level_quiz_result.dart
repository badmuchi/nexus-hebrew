import 'package:equatable/equatable.dart';

import 'level_quiz_question.dart';

/// Comprehensive evaluation result of a completed Hebrew level assessment.
final class LevelQuizResult extends Equatable {
  final int totalQuestions;
  final int correctAnswers;
  final double scorePercentage;
  final String determinedLevel;
  final String levelTitleRu;
  final String levelTitleHe;
  final Map<SkillFocus, double> skillScores;
  final List<LevelQuizQuestion> mistakes;
  final List<String> recommendations;
  final DateTime completedAt;

  const LevelQuizResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.scorePercentage,
    required this.determinedLevel,
    required this.levelTitleRu,
    required this.levelTitleHe,
    required this.skillScores,
    required this.mistakes,
    required this.recommendations,
    required this.completedAt,
  });

  /// Factory computing the full assessment diagnostic from answers.
  factory LevelQuizResult.evaluate({
    required List<LevelQuizQuestion> questions,
    required Map<String, int> userAnswers,
  }) {
    int correctCount = 0;
    final mistakes = <LevelQuizQuestion>[];

    final skillTotal = <SkillFocus, int>{};
    final skillCorrect = <SkillFocus, int>{};

    for (final q in questions) {
      skillTotal[q.skillFocus] = (skillTotal[q.skillFocus] ?? 0) + 1;

      final selectedIndex = userAnswers[q.id];
      if (selectedIndex != null && q.isCorrect(selectedIndex)) {
        correctCount++;
        skillCorrect[q.skillFocus] = (skillCorrect[q.skillFocus] ?? 0) + 1;
      } else {
        mistakes.add(q);
      }
    }

    final total = questions.isNotEmpty ? questions.length : 1;
    final score = correctCount / total;

    final skillScores = <SkillFocus, double>{};
    for (final skill in SkillFocus.values) {
      final totalForSkill = skillTotal[skill] ?? 0;
      if (totalForSkill > 0) {
        skillScores[skill] = (skillCorrect[skill] ?? 0) / totalForSkill;
      } else {
        skillScores[skill] = 1.0;
      }
    }

    // Determine CEFR sublevel
    final String level;
    final String titleRu;
    final String titleHe;

    if (score >= 0.90) {
      level = 'B1.2';
      titleRu = 'Свободный B1 (Предпродвинутый)';
      titleHe = 'רָמָה ג׳ מִתְקַדֶּמֶת';
    } else if (score >= 0.80) {
      level = 'B1.1';
      titleRu = 'Разговорный средний (B1)';
      titleHe = 'רָמָה ג׳ — בֵּינוֹנִי';
    } else if (score >= 0.65) {
      level = 'A2.2';
      titleRu = 'Уверенный базовый (A2+)';
      titleHe = 'רָמָה ב׳ מִתְקַדֶּמֶת';
    } else if (score >= 0.50) {
      level = 'A2.1';
      titleRu = 'Базовый уровень (A2)';
      titleHe = 'רָמָה ב׳ — בְּסִיסִי';
    } else if (score >= 0.35) {
      level = 'A1.2';
      titleRu = 'Начальный уверенный (A1+)';
      titleHe = 'רָמָה א׳ מִתְקַדֶּמֶת';
    } else {
      level = 'A1.1';
      titleRu = 'Начальный уровень (A1)';
      titleHe = 'רָמָה א׳ — הַתְחָלָתִי';
    }

    // Generate dynamic targeted recommendations
    final recommendations = <String>[];
    final grammarScore = skillScores[SkillFocus.grammar] ?? 1.0;
    final syntaxScore = skillScores[SkillFocus.syntax] ?? 1.0;
    final vocabScore = skillScores[SkillFocus.vocabulary] ?? 1.0;
    final listeningScore = skillScores[SkillFocus.listening] ?? 1.0;

    if (grammarScore < 0.7) {
      recommendations.add(
        'Обрати внимание на породы глаголов: загляни в «7 Биньянов» и «Матрицу корней».',
      );
    }
    if (syntaxScore < 0.7) {
      recommendations.add(
        'Потренируй порядок слов и слияние предлогов в «Конструкторе фраз».',
      );
    }
    if (vocabScore < 0.7) {
      recommendations.add(
        'Пополняй активный словарный запас: читай «Микро-рассказы» и учи «Израильский сленг».',
      );
    }
    if (listeningScore < 0.7) {
      recommendations.add(
        'Слушай носителей: заходи в «Лабораторию речи» и диктанты в разделе «Аудирование».',
      );
    }
    if (recommendations.isEmpty) {
      recommendations.add(
        'Великолепный результат! Все навыки сбалансированы. Продолжай регулярные интервальные повторения FSRS.',
      );
    }

    return LevelQuizResult(
      totalQuestions: questions.length,
      correctAnswers: correctCount,
      scorePercentage: score,
      determinedLevel: level,
      levelTitleRu: titleRu,
      levelTitleHe: titleHe,
      skillScores: skillScores,
      mistakes: mistakes,
      recommendations: recommendations,
      completedAt: DateTime.now(),
    );
  }

  int get scorePercentageRounded => (scorePercentage * 100).round();

  @override
  List<Object?> get props => [
        totalQuestions,
        correctAnswers,
        scorePercentage,
        determinedLevel,
        levelTitleRu,
        levelTitleHe,
        skillScores,
        mistakes,
        recommendations,
        completedAt,
      ];
}
