import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/grammar/data/datasources/sentence_builder_seed_data.dart';
import 'package:nexus_hebrew_app/features/grammar/domain/entities/sentence_builder_exercise.dart';

void main() {
  group('SentenceExercise Entity & Validation', () {
    final token1 = SentenceToken.create(
      id: 't1',
      vocalized: 'אֲנִי',
      translation: 'Я',
      syntacticRole: 'Подлежащее',
    );
    final token2 = SentenceToken.create(
      id: 't2',
      vocalized: 'רוֹאֶה',
      translation: 'вижу',
      syntacticRole: 'Глагол',
    );
    final distractor = SentenceToken.create(
      id: 'd1',
      vocalized: 'אַתָּה',
      translation: 'ты',
      syntacticRole: 'Ловушка',
      isDistractor: true,
    );

    final exercise = SentenceExercise(
      id: 'test_1',
      targetHebrew: 'אֲנִי רוֹאֶה',
      targetHebrewUnpointed: 'אני רואה',
      russianTranslation: 'Я вижу',
      transliteration: 'Ani ro\'eh',
      category: SyntaxCategory.directObjectEt,
      level: 'A1',
      ruleTitle: 'Тестовое правило',
      ruleExplanation: 'Объяснение',
      tokens: [token1, token2],
      distractorTokens: [distractor],
      hint: 'Подсказка',
    );

    test('isCorrect returns true for exact token order', () {
      expect(exercise.isCorrect([token1, token2]), isTrue);
    });

    test('isCorrect returns false for wrong order or distractors', () {
      expect(exercise.isCorrect([token2, token1]), isFalse);
      expect(exercise.isCorrect([token1, distractor]), isFalse);
      expect(exercise.isCorrect([token1]), isFalse);
      expect(exercise.isCorrect([]), isFalse);
    });

    test('allTokensPool contains both target and distractor tokens', () {
      final pool = exercise.allTokensPool;
      expect(pool.length, equals(3));
      expect(pool.contains(token1), isTrue);
      expect(pool.contains(token2), isTrue);
      expect(pool.contains(distractor), isTrue);
    });
  });

  group('SentenceBuilderSeedData sanity checks', () {
    test('contains exercises covering all syntax categories', () {
      final exercises = SentenceBuilderSeedData.allExercises;
      expect(exercises, isNotEmpty);

      for (final exercise in exercises) {
        expect(exercise.id, isNotEmpty);
        expect(exercise.targetHebrew, isNotEmpty);
        expect(exercise.targetHebrewUnpointed, isNotEmpty);
        expect(exercise.russianTranslation, isNotEmpty);
        expect(exercise.tokens, isNotEmpty);
        expect(exercise.ruleTitle, isNotEmpty);
        expect(exercise.ruleExplanation, isNotEmpty);

        // Target tokens assembled match target Hebrew
        final assembled =
            exercise.tokens.map((t) => t.unpointed).join(' ').trim();
        expect(
          assembled,
          equals(exercise.targetHebrewUnpointed.trim()),
          reason: 'Token assembly mismatch for exercise ${exercise.id}',
        );
      }
    });
  });
}
