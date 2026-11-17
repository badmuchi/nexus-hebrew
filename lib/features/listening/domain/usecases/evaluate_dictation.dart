import 'dart:math' as math;

import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/utils/hebrew_normalizer.dart';
import '../entities/listening_exercise.dart';

/// Parameters for evaluating a Hebrew audio dictation submission.
final class EvaluateDictationParams extends Equatable {
  const EvaluateDictationParams({
    required this.exercise,
    required this.userInput,
  });

  final ListeningExercise exercise;
  final String userInput;

  @override
  List<Object?> get props => [exercise, userInput];
}

/// Pure Domain Use Case scoring Hebrew dictation against normalized target words without nikkud.
class EvaluateDictationUseCase {
  const EvaluateDictationUseCase();

  static final RegExp _punctuationRegex = RegExp(r'[,.\?!:;…\(\)\[\]—–\-"]+');
  static final RegExp _whitespaceRegex = RegExp(r'\s+');

  /// Evaluates [params.userInput] word-by-word against [params.exercise.transcript].
  Result<DictationComparison, Failure> call(EvaluateDictationParams params) {
    final userTokens = _tokenizeNormalized(params.userInput);
    if (userTokens.isEmpty) {
      return const Error<DictationComparison, Failure>(
        ValidationFailure('Введи услышанный текст на иврите для проверки.'),
      );
    }

    final expectedTokens =
        _tokenizeNormalized(params.exercise.transcript.normalized);
    if (expectedTokens.isEmpty) {
      return const Error<DictationComparison, Failure>(
        ValidationFailure('Эталонный текст упражнения пуст.'),
      );
    }

    final remainingUserCounts = <String, int>{};
    for (final token in userTokens) {
      remainingUserCounts[token] = (remainingUserCounts[token] ?? 0) + 1;
    }

    final matchedWords = <String>[];
    final missedWords = <String>[];

    for (final expected in expectedTokens) {
      final count = remainingUserCounts[expected] ?? 0;
      if (count > 0) {
        matchedWords.add(expected);
        remainingUserCounts[expected] = count - 1;
      } else {
        missedWords.add(expected);
      }
    }

    final denominator = math.max(expectedTokens.length, userTokens.length);
    final accuracy = denominator == 0 ? 0.0 : matchedWords.length / denominator;
    final exactMatch = _areTokenListsEqual(expectedTokens, userTokens);

    return Success<DictationComparison, Failure>(
      DictationComparison(
        isExactMatch: exactMatch,
        wordAccuracy: accuracy,
        expectedWords: expectedTokens,
        matchedWords: matchedWords,
        missedWords: missedWords,
        normalizedUserInput: userTokens.join(' '),
        normalizedExpected: expectedTokens.join(' '),
      ),
    );
  }

  List<String> _tokenizeNormalized(String rawText) {
    final normalized = HebrewNormalizer.normalizeForComparison(rawText);
    final withoutPunctuation = normalized.replaceAll(_punctuationRegex, ' ');
    return withoutPunctuation
        .trim()
        .split(_whitespaceRegex)
        .where((String token) => token.isNotEmpty)
        .toList(growable: false);
  }

  bool _areTokenListsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
