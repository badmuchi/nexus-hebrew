import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/stories/domain/services/custom_text_story_parser.dart';

void main() {
  group('CustomTextStoryParser', () {
    test('throws FormatException on empty text', () {
      expect(
        () => CustomTextStoryParser.parse(rawText: '   '),
        throwsFormatException,
      );
    });

    test('parses arbitrary Hebrew text into paragraphs, sentences, and word tokens', () {
      const input = '''
תֵּל אָבִיב הִיא עִיר יָפָה.
יֵשׁ שָׁם יָם וְשֶׁמֶשׁ.

אֲנָשִׁים הוֹלְכִים לַחוֹף.
''';

      final story = CustomTextStoryParser.parse(
        rawText: input,
        titleRussian: 'Тель-Авив сегодня',
        dictionaryLookup: {
          'עיר': 'город',
          'ים': 'море',
        },
      );

      expect(story.titleRussian, equals('Тель-Авив сегодня'));
      expect(story.paragraphs.length, equals(2));

      // Paragraph 1 has 2 sentences
      expect(story.paragraphs[0].sentences.length, equals(2));
      final s1 = story.paragraphs[0].sentences[0];
      expect(s1.hebrewVocalized, equals('תֵּל אָבִיב הִיא עִיר יָפָה.'));
      expect(s1.tokens.length, equals(5));

      // Token for 'עִיר' should have normalized 'עיר' and translation 'город'
      final cityToken = s1.tokens.firstWhere((t) => t.wordNormalized == 'עיר');
      expect(cityToken.russianTranslation, equals('город'));

      // Paragraph 2 has 1 sentence
      expect(story.paragraphs[1].sentences.length, equals(1));
      expect(
        story.paragraphs[1].sentences[0].hebrewVocalized,
        equals('אֲנָשִׁים הוֹלְכִים לַחוֹף.'),
      );
    });
  });
}
