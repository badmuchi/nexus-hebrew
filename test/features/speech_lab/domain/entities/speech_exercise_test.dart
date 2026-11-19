import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/speech_lab/domain/entities/speech_exercise.dart';

void main() {
  group('SpeechExercise', () {
    test('instantiates correctly with full props', () {
      const exercise = SpeechExercise(
        id: 'test_1',
        hebrewVocalized: 'שָׁלוֹם עֲלֵיכֶם',
        hebrewNormalized: 'שלום עליכם',
        transcription: 'шало́м алэхэ́м',
        translationRu: 'Мир вам',
        category: SpeechCategory.social,
        phoneticTipRu: 'Чётко произноси звук шва.',
        difficulty: 'A1',
        keyPhonemes: ['ש', 'ע'],
      );

      expect(exercise.id, 'test_1');
      expect(exercise.hebrewVocalized, 'שָׁלוֹם עֲלֵיכֶם');
      expect(exercise.hebrewNormalized, 'שלום עליכם');
      expect(exercise.category, SpeechCategory.social);
      expect(exercise.keyPhonemes, ['ש', 'ע']);
    });

    test('SpeechExercise.custom creates custom exercise with automatic normalization', () {
      final customEx = SpeechExercise.custom(
        rawHebrew: 'בֹּקֶר טוֹב חֲבֵרִים!',
        translationRu: 'Доброе утро, друзья!',
      );

      expect(customEx.id, startsWith('custom_'));
      expect(customEx.hebrewVocalized, 'בֹּקֶר טוֹב חֲבֵרִים!');
      expect(customEx.hebrewNormalized, 'בקר טוב חברים!');
      expect(customEx.category, SpeechCategory.custom);
      expect(customEx.difficulty, 'Custom');
      expect(customEx.translationRu, 'Доброе утро, друзья!');
    });

    test('SpeechCategory defines all 6 categories with appropriate labels and colors', () {
      expect(SpeechCategory.values.length, 6);
      expect(SpeechCategory.cafe.labelRu, 'Кафе и еда');
      expect(SpeechCategory.cityTaxi.labelRu, 'Город и такси');
      expect(SpeechCategory.market.labelRu, 'Шук и покупки');
      expect(SpeechCategory.slang.labelRu, 'Сленг и вайб');
      expect(SpeechCategory.social.labelRu, 'Знакомство и этикет');
      expect(SpeechCategory.custom.labelRu, 'Свой текст');
    });
  });
}
