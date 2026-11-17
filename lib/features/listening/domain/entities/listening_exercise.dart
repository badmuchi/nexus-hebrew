import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../../../srs/domain/entities/srs_card.dart';

/// Listening comprehension difficulty tier.
enum ListeningDifficulty {
  beginner(id: 'beginner', russianLabel: 'Начальный (א׳)'),
  intermediate(id: 'intermediate', russianLabel: 'Средний (ב׳)'),
  advanced(id: 'advanced', russianLabel: 'Продвинутый (ג׳)');

  const ListeningDifficulty({
    required this.id,
    required this.russianLabel,
  });

  final String id;
  final String russianLabel;

  /// Parses an external difficulty string into [ListeningDifficulty].
  static Result<ListeningDifficulty, ParsingFailure> parseStrict(
    String rawValue,
  ) {
    final normalized = rawValue.trim().toLowerCase();
    for (final level in ListeningDifficulty.values) {
      if (level.id == normalized) {
        return Success<ListeningDifficulty, ParsingFailure>(level);
      }
    }
    return Error<ListeningDifficulty, ParsingFailure>(
      ParsingFailure('Unknown listening difficulty: "$rawValue"'),
    );
  }
}

/// Immutable Hebrew listening comprehension & dictation exercise.
final class ListeningExercise extends Equatable {
  ListeningExercise({
    required this.id,
    required this.transcript,
    required this.russianTranslation,
    this.audioUrl,
    required this.difficulty,
    required List<String> focusWords,
    required this.attribution,
  }) : focusWords = List<String>.unmodifiable(focusWords);

  final String id;
  final HebrewText transcript;
  final String russianTranslation;
  final String? audioUrl;
  final ListeningDifficulty difficulty;
  final List<String> focusWords;
  final ContentAttribution attribution;

  @override
  List<Object?> get props => [
        id,
        transcript,
        russianTranslation,
        audioUrl,
        difficulty,
        focusWords,
        attribution,
      ];
}

/// Word-level comparison result for a user's Hebrew dictation attempt.
final class DictationComparison extends Equatable {
  DictationComparison({
    required this.isExactMatch,
    required this.wordAccuracy,
    required List<String> expectedWords,
    required List<String> matchedWords,
    required List<String> missedWords,
    required this.normalizedUserInput,
    required this.normalizedExpected,
  })  : expectedWords = List<String>.unmodifiable(expectedWords),
        matchedWords = List<String>.unmodifiable(matchedWords),
        missedWords = List<String>.unmodifiable(missedWords);

  final bool isExactMatch;

  /// Accuracy ratio in `[0.0, 1.0]` penalized for both missing and extra tokens.
  final double wordAccuracy;
  final List<String> expectedWords;
  final List<String> matchedWords;
  final List<String> missedWords;
  final String normalizedUserInput;
  final String normalizedExpected;

  @override
  List<Object?> get props => [
        isExactMatch,
        wordAccuracy,
        expectedWords,
        matchedWords,
        missedWords,
        normalizedUserInput,
        normalizedExpected,
      ];
}
