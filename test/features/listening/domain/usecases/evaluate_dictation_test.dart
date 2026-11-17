import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/listening/domain/entities/listening_exercise.dart';
import 'package:nexus_hebrew_app/features/listening/domain/usecases/evaluate_dictation.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';

void main() {
  const useCase = EvaluateDictationUseCase();

  final exercise = ListeningExercise(
    id: 'listen_beg_1',
    transcript: const HebrewText.fixture(
      vocalized: 'אֲנִי רוֹצֶה קָפֶה עִם חָלָב בְּבַקָּשָׁה?',
      normalized: 'אני רוצה קפה עם חלב בבקשה?',
    ),
    russianTranslation: 'Я хочу кофе с молоком, пожалуйста?',
    difficulty: ListeningDifficulty.beginner,
    focusWords: const <String>['רוֹצֶה', 'קָפֶה'],
    attribution: const ContentAttribution(
      sourceName: 'Nexus Curated Ulpan',
      licenseName: 'CC0 1.0',
    ),
  );

  group('EvaluateDictationUseCase', () {
    test('returns 100% exact match ignoring nikkud and trailing punctuation', () {
      final result = useCase(
        EvaluateDictationParams(
          exercise: exercise,
          userInput: 'אני רוצה קפה עם חלב בבקשה',
        ),
      );

      expect(result.isSuccess, isTrue);
      final comparison = result.getOrNull()!;
      expect(comparison.isExactMatch, isTrue);
      expect(comparison.wordAccuracy, 1.0);
      expect(comparison.missedWords, isEmpty);
      expect(comparison.matchedWords, hasLength(6));
    });

    test('scores partial match and lists missed words accurately', () {
      final result = useCase(
        EvaluateDictationParams(
          exercise: exercise,
          userInput: 'אני רוצה קפה בבקשה',
        ),
      );

      expect(result.isSuccess, isTrue);
      final comparison = result.getOrNull()!;
      expect(comparison.isExactMatch, isFalse);
      expect(comparison.wordAccuracy, closeTo(4 / 6, 0.0001));
      expect(comparison.missedWords, <String>['עם', 'חלב']);
    });

    test('penalizes extra unexpected words in wordAccuracy calculation', () {
      final result = useCase(
        EvaluateDictationParams(
          exercise: exercise,
          userInput: 'אני רוצה קפה עם חלב בבקשה שלום תודה',
        ),
      );

      expect(result.isSuccess, isTrue);
      final comparison = result.getOrNull()!;
      expect(comparison.isExactMatch, isFalse);
      expect(comparison.wordAccuracy, closeTo(6 / 8, 0.0001));
    });

    test('returns ValidationFailure for empty or punctuation-only input', () {
      final emptyRes = useCase(
        EvaluateDictationParams(exercise: exercise, userInput: '  ... ! '),
      );

      expect(emptyRes, isA<Error<DictationComparison, Failure>>());
      expect(emptyRes.failureOrNull(), isA<ValidationFailure>());
    });
  });
}
