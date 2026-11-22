import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/core/database/app_database.dart';
import 'package:nexus_hebrew_app/features/stories/domain/services/weak_words_story_generator.dart';

void main() {
  group('WeakWordsStoryGenerator', () {
    test('extractWeakWords returns fallback default words when cards list is empty', () {
      final weakWords = WeakWordsStoryGenerator.extractWeakWords(const []);

      expect(weakWords, isNotEmpty);
      expect(weakWords.length, greaterThanOrEqualTo(3));
      expect(weakWords.any((w) => w.hebrewNormalized == 'קפה'), isTrue);
    });

    test('extractWeakWords filters and sorts cards by lapses and stability', () {
      final now = DateTime.utc(2026, 11, 22);
      final cards = [
        SrsCardRow(
          id: 'card_1',
          hebrewVocalized: 'שָׁלוֹם',
          hebrewNormalized: 'שלום',
          russianTranslation: 'мир, привет',
          binyan: 'none',
          category: 'general',
          sourceName: 'seed',
          licenseName: 'CC0',
          stability: 45.0,
          difficulty: 2.0,
          lapses: 0,
          reps: 10,
          fsrsState: 'review',
          dueAt: now.add(const Duration(days: 10)),
        ),
        SrsCardRow(
          id: 'card_2',
          hebrewVocalized: 'מַיִם',
          hebrewNormalized: 'מים',
          russianTranslation: 'вода',
          binyan: 'none',
          category: 'general',
          sourceName: 'seed',
          licenseName: 'CC0',
          stability: 1.2,
          difficulty: 6.0,
          lapses: 2,
          reps: 3,
          fsrsState: 'review',
          dueAt: now,
        ),
        SrsCardRow(
          id: 'card_3',
          hebrewVocalized: 'לֶחֶם',
          hebrewNormalized: 'לחם',
          russianTranslation: 'хлеб',
          binyan: 'none',
          category: 'general',
          sourceName: 'seed',
          licenseName: 'CC0',
          stability: 2.5,
          difficulty: 5.0,
          lapses: 1,
          reps: 2,
          fsrsState: 'review',
          dueAt: now,
        ),
      ];

      final weakWords = WeakWordsStoryGenerator.extractWeakWords(cards);

      expect(weakWords, isNotEmpty);
      // 'מים' has 2 lapses, so it should come first
      expect(weakWords.first.hebrewNormalized, 'מים');
      expect(weakWords.any((w) => w.hebrewNormalized == 'לחם'), isTrue);
    });

    test('generateStory creates an FSRS Smart Story with targeted weak word tokens', () {
      const weakWords = [
        WeakWordTarget(
          hebrewVocalized: 'קָפֶה',
          hebrewNormalized: 'קפה',
          russianTranslation: 'кофе',
          stability: 1.2,
          lapses: 2,
        ),
        WeakWordTarget(
          hebrewVocalized: 'בְּבַקָּשָׁה',
          hebrewNormalized: 'בבקשה',
          russianTranslation: 'пожалуйста',
          stability: 1.8,
          lapses: 1,
        ),
        WeakWordTarget(
          hebrewVocalized: 'תּוֹדָה',
          hebrewNormalized: 'תודה',
          russianTranslation: 'спасибо',
          stability: 2.1,
          lapses: 0,
        ),
      ];

      final story = WeakWordsStoryGenerator.generateStory(
        weakWords: weakWords,
        seed: 0, // Deterministic scenario 0 (Cafe)
      );

      expect(story.level, 'FSRS Smart');
      expect(story.id, startsWith('story_weak_'));
      expect(story.titleRussian, contains('FSRS'));
      expect(story.paragraphs, hasLength(2));

      // Check that targeted words are marked with category: 'weak_word_practice'
      final allTokens = story.paragraphs
          .expand((p) => p.sentences)
          .expand((s) => s.tokens)
          .toList();

      final weakWordTokens = allTokens
          .where((t) => t.category == 'weak_word_practice')
          .toList();

      expect(weakWordTokens, isNotEmpty);
      expect(
        weakWordTokens.any((t) => t.wordNormalized == 'קפה'),
        isTrue,
      );
    });

    test('generateStory supports multiple scenarios based on seed', () {
      const weakWords = [
        WeakWordTarget(
          hebrewVocalized: 'קָפֶה',
          hebrewNormalized: 'קפה',
          russianTranslation: 'кофе',
          stability: 1.2,
          lapses: 1,
        ),
      ];

      final cafeStory = WeakWordsStoryGenerator.generateStory(weakWords: weakWords, seed: 0);
      final marketStory = WeakWordsStoryGenerator.generateStory(weakWords: weakWords, seed: 1);
      final beachStory = WeakWordsStoryGenerator.generateStory(weakWords: weakWords, seed: 2);

      expect(cafeStory.titleRussian, contains('Дизенгоф'));
      expect(marketStory.titleRussian, contains('Кармель'));
      expect(beachStory.titleRussian, contains('пляже'));
    });
  });
}
