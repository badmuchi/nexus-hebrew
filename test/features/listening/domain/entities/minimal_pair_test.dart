import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/listening/data/datasources/minimal_pairs_seed_data.dart';
import 'package:nexus_hebrew_app/features/listening/domain/entities/minimal_pair.dart';

void main() {
  group('MinimalPair Domain & Entity Tests', () {
    final target = MinimalPairWord.create(
      id: 'w_1',
      vocalized: 'עֵט',
      transliteration: 'Эт',
      translation: 'Ручка',
      mnemonicNote: 'Заметка 1',
      exampleSentenceHebrew: 'דוגמה 1',
      exampleSentenceRussian: 'Пример 1',
    );

    final contrast = MinimalPairWord.create(
      id: 'w_2',
      vocalized: 'עֵת',
      transliteration: 'Эт',
      translation: 'Время',
      mnemonicNote: 'Заметка 2',
      exampleSentenceHebrew: 'דוגמה 2',
      exampleSentenceRussian: 'Пример 2',
    );

    final exercise = MinimalPairExercise(
      id: 'ex_1',
      category: PhoneticCategory.tavVsTet,
      contrastTitle: 'עֵט vs עֵת',
      pedagogicalExplanation: 'Тестовое объяснение',
      targetWord: target,
      contrastWord: contrast,
    );

    test('isCorrectChoice accurately checks target word ID', () {
      expect(exercise.isCorrectChoice('w_1'), isTrue);
      expect(exercise.isCorrectChoice('w_2'), isFalse);
      expect(exercise.isCorrectChoice('unknown'), isFalse);
    });

    test('auto-normalizes unpointed word correctly', () {
      expect(target.unpointed, equals('עט'));
      expect(contrast.unpointed, equals('עת'));
    });
  });

  group('MinimalPairsSeedData Tests', () {
    test('contains comprehensive minimal pairs across phonetic categories', () {
      final exercises = MinimalPairsSeedData.allExercises;
      expect(exercises.length, greaterThanOrEqualTo(10));

      final categoriesCovered = exercises.map((e) => e.category).toSet();
      expect(
        categoriesCovered.contains(PhoneticCategory.tavVsTet),
        isTrue,
      );
      expect(
        categoriesCovered.contains(PhoneticCategory.kafVsQof),
        isTrue,
      );
      expect(
        categoriesCovered.contains(PhoneticCategory.alefVsAyin),
        isTrue,
      );
      expect(
        categoriesCovered.contains(PhoneticCategory.genderSound),
        isTrue,
      );
      expect(
        categoriesCovered.contains(PhoneticCategory.stressAccent),
        isTrue,
      );

      for (final ex in exercises) {
        expect(ex.id, isNotEmpty);
        expect(ex.contrastTitle, isNotEmpty);
        expect(ex.pedagogicalExplanation, isNotEmpty);
        expect(ex.targetWord.vocalized, isNotEmpty);
        expect(ex.contrastWord.vocalized, isNotEmpty);
        expect(ex.targetWord.translation, isNotEmpty);
        expect(ex.contrastWord.translation, isNotEmpty);
        expect(ex.targetWord.mnemonicNote, isNotEmpty);
      }
    });
  });
}
