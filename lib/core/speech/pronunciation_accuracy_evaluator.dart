import 'dart:math' as math;

import 'package:equatable/equatable.dart';

import '../utils/hebrew_normalizer.dart';

enum PronunciationGrade {
  perfect,
  good,
  retry,
}

final class WordPronunciationMatch extends Equatable {
  final String targetWord;
  final String? spokenMatch;
  final bool isMatched;
  final double similarity;

  const WordPronunciationMatch({
    required this.targetWord,
    this.spokenMatch,
    required this.isMatched,
    required this.similarity,
  });

  @override
  List<Object?> get props => [targetWord, spokenMatch, isMatched, similarity];
}

final class PronunciationEvaluationResult extends Equatable {
  final String targetVocalized;
  final String targetNormalized;
  final String spokenText;
  final double accuracyScore;
  final PronunciationGrade grade;
  final List<WordPronunciationMatch> wordMatches;
  final String hebrewFeedback;
  final String russianFeedback;
  final int xpEarned;

  const PronunciationEvaluationResult({
    required this.targetVocalized,
    required this.targetNormalized,
    required this.spokenText,
    required this.accuracyScore,
    required this.grade,
    required this.wordMatches,
    required this.hebrewFeedback,
    required this.russianFeedback,
    required this.xpEarned,
  });

  int get accuracyPercentage => (accuracyScore * 100).round();

  @override
  List<Object?> get props => [
        targetVocalized,
        targetNormalized,
        spokenText,
        accuracyScore,
        grade,
        wordMatches,
        hebrewFeedback,
        russianFeedback,
        xpEarned,
      ];
}

final class PronunciationAccuracyEvaluator {
  const PronunciationAccuracyEvaluator();

  static final RegExp _punctuationRegex = RegExp(r'[.,!?:;"״׳()[\]{}—–\-]');
  static final RegExp _whitespaceRegex = RegExp(r'\s+');

  PronunciationEvaluationResult evaluate({
    required String targetVocalized,
    required String spokenRaw,
  }) {
    final targetNorm = HebrewNormalizer.normalizeForComparison(
      targetVocalized.replaceAll(_punctuationRegex, ' '),
    );
    final spokenNorm = HebrewNormalizer.normalizeForComparison(
      spokenRaw.replaceAll(_punctuationRegex, ' '),
    );

    final targetTokens = targetNorm.split(_whitespaceRegex).where((t) => t.isNotEmpty).toList();
    final spokenTokens = spokenNorm.split(_whitespaceRegex).where((t) => t.isNotEmpty).toList();

    if (targetTokens.isEmpty) {
      return PronunciationEvaluationResult(
        targetVocalized: targetVocalized,
        targetNormalized: targetNorm,
        spokenText: spokenRaw,
        accuracyScore: 1.0,
        grade: PronunciationGrade.perfect,
        wordMatches: const [],
        hebrewFeedback: '!מוּשְׁלָם',
        russianFeedback: 'Идеально!',
        xpEarned: 15,
      );
    }

    if (spokenTokens.isEmpty) {
      final matches = targetTokens
          .map((t) => WordPronunciationMatch(
                targetWord: t,
                spokenMatch: null,
                isMatched: false,
                similarity: 0.0,
              ))
          .toList();
      return PronunciationEvaluationResult(
        targetVocalized: targetVocalized,
        targetNormalized: targetNorm,
        spokenText: spokenRaw,
        accuracyScore: 0.0,
        grade: PronunciationGrade.retry,
        wordMatches: matches,
        hebrewFeedback: '!נַסֵּה שׁוּב',
        russianFeedback: 'Речь не распознана. Нажмите на микрофон и произнесите фразу.',
        xpEarned: 0,
      );
    }

    final wordMatches = <WordPronunciationMatch>[];
    var matchedWordsCount = 0.0;

    for (final targetToken in targetTokens) {
      double bestSimilarity = 0.0;
      String? bestMatch;

      for (final spokenToken in spokenTokens) {
        if (targetToken == spokenToken) {
          bestSimilarity = 1.0;
          bestMatch = spokenToken;
          break;
        }

        final sim = calculateSimilarity(targetToken, spokenToken);
        final ktivSim = _calculateKtivMaleSimilarity(targetToken, spokenToken);
        final effectiveSim = math.max(sim, ktivSim);

        if (effectiveSim > bestSimilarity) {
          bestSimilarity = effectiveSim;
          bestMatch = spokenToken;
        }
      }

      final isMatched = bestSimilarity >= 0.70;
      if (isMatched) {
        matchedWordsCount += bestSimilarity;
      }

      wordMatches.add(
        WordPronunciationMatch(
          targetWord: targetToken,
          spokenMatch: bestMatch,
          isMatched: isMatched,
          similarity: bestSimilarity,
        ),
      );
    }

    final wordScore = matchedWordsCount / targetTokens.length;
    final fullSentenceSim = calculateSimilarity(targetNorm, spokenNorm);

    // Взвешенная точность (70% пословная, 30% общее сходство строки)
    final finalScore = (wordScore * 0.70) + (fullSentenceSim * 0.30);
    final clampedScore = finalScore.clamp(0.0, 1.0);

    PronunciationGrade grade;
    String hebrewFb;
    String russianFb;
    int xp;

    if (clampedScore >= 0.85) {
      grade = PronunciationGrade.perfect;
      hebrewFb = '!מוּשְׁלָם';
      russianFb = 'Отличное произношение! (+15 XP)';
      xp = 15;
    } else if (clampedScore >= 0.65) {
      grade = PronunciationGrade.good;
      hebrewFb = '!יוֹפִי';
      russianFb = 'Хорошо! Звучит разборчиво (+10 XP)';
      xp = 10;
    } else {
      grade = PronunciationGrade.retry;
      hebrewFb = '!נַסֵּה שׁוּב';
      russianFb = 'Попробуй ещё раз, говори чуть ближе к микрофону (+3 XP)';
      xp = 3;
    }

    return PronunciationEvaluationResult(
      targetVocalized: targetVocalized,
      targetNormalized: targetNorm,
      spokenText: spokenRaw,
      accuracyScore: clampedScore,
      grade: grade,
      wordMatches: wordMatches,
      hebrewFeedback: hebrewFb,
      russianFeedback: russianFb,
      xpEarned: xp,
    );
  }

  static double _calculateKtivMaleSimilarity(String a, String b) {
    if (a.length < 3 || b.length < 3) return 0.0;
    // Удаляем огласовочные гласные буквы 'ו' и 'י', если они не в начале слова
    final strippedA = a[0] + a.substring(1).replaceAll(RegExp(r'[וי]'), '');
    final strippedB = b[0] + b.substring(1).replaceAll(RegExp(r'[וי]'), '');
    if (strippedA == strippedB) {
      return 0.95;
    }
    return calculateSimilarity(strippedA, strippedB) * 0.90;
  }

  static double calculateSimilarity(String a, String b) {
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;

    final distance = _levenshteinDistance(a, b);
    final maxLength = math.max(a.length, b.length);
    return 1.0 - (distance / maxLength);
  }

  static int _levenshteinDistance(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    final sRunes = s.runes.toList(growable: false);
    final tRunes = t.runes.toList(growable: false);

    final m = sRunes.length;
    final n = tRunes.length;

    var v0 = List<int>.generate(n + 1, (i) => i);
    var v1 = List<int>.filled(n + 1, 0);

    for (var i = 0; i < m; i++) {
      v1[0] = i + 1;

      for (var j = 0; j < n; j++) {
        final cost = sRunes[i] == tRunes[j] ? 0 : 1;
        v1[j + 1] = math.min(
          v1[j] + 1,
          math.min(v0[j + 1] + 1, v0[j] + cost),
        );
      }

      final temp = v0;
      v0 = v1;
      v1 = temp;
    }

    return v0[n];
  }
}
