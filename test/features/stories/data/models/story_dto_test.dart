import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/core/network/json_reader.dart';
import 'package:nexus_hebrew_app/features/stories/data/models/story_dto.dart';

void main() {
  group('StoryDto', () {
    const validStoryJson = '''
    {
      "id": "story_test_1",
      "title_hebrew": "בֹּקֶר טוֹב",
      "title_russian": "Доброе утро",
      "level": "A1",
      "reading_time_minutes": 2,
      "cover_emoji": "☀️",
      "summary_russian": "Короткий рассказ о добром утре.",
      "paragraphs": [
        {
          "id": "p1",
          "sentences": [
            {
              "id": "s1",
              "hebrew_vocalized": "שָׁלוֹם וּבֹקֶר טוֹב!",
              "russian_translation": "Привет и доброе утро!",
              "audio_url": null,
              "tokens": [
                {
                  "word_vocalized": "שָׁלוֹם",
                  "word_normalized": "שלום",
                  "russian_translation": "мир, привет",
                  "transliteration": "sha-lom",
                  "root": "ש-ל-ם",
                  "binyan": null,
                  "category": "noun"
                },
                {
                  "word_vocalized": "וּבֹקֶר",
                  "word_normalized": "ובוקר",
                  "russian_translation": "и утро",
                  "transliteration": "u-vo-ker",
                  "root": "ב-ק-ר",
                  "binyan": null,
                  "category": "noun"
                }
              ]
            }
          ]
        }
      ]
    }
    ''';

    test('parses valid JSON and converts to domain Story correctly', () {
      final readerRes = JsonReader.parseObject(validStoryJson);
      expect(readerRes.isSuccess, isTrue);

      final dtoRes = StoryDto.fromReader(readerRes.getOrNull()!);
      expect(dtoRes.isSuccess, isTrue);

      final dto = dtoRes.getOrNull()!;
      expect(dto.id, equals('story_test_1'));
      expect(dto.level, equals('A1'));
      expect(dto.readingTimeMinutes, equals(2));
      expect(dto.coverEmoji, equals('☀️'));
      expect(dto.paragraphs.length, equals(1));
      expect(dto.paragraphs.first.sentences.length, equals(1));

      final domainRes = dto.toDomain();
      expect(domainRes.isSuccess, isTrue);

      final story = domainRes.getOrNull()!;
      expect(story.id, equals('story_test_1'));
      expect(story.titleHebrew.vocalized, equals('בֹּקֶר טוֹב'));
      expect(story.titleRussian, equals('Доброе утро'));
      expect(story.wordCount, equals(2));
      expect(story.paragraphs.first.sentences.first.tokens.first.root?.hyphenated,
          equals('ש-ל-ם'));
    });

    test('returns ParsingFailure if required field is missing', () {
      const invalidJson = '{"id": "story_bad"}';
      final reader = JsonReader.parseObject(invalidJson).getOrNull()!;
      final dtoRes = StoryDto.fromReader(reader);
      expect(dtoRes.isError, isTrue);
    });
  });
}
