import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/entities/dictionary_entry.dart';
import 'package:nexus_hebrew_app/features/morphology/domain/entities/morphology_models.dart';
import 'package:nexus_hebrew_app/features/morphology/domain/services/hebrew_morphology_engine.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';

void main() {
  const engine = HebrewMorphologyEngine();

  final dictEntries = [
    DictionaryEntry(
      id: 'dict-1',
      hebrew: const HebrewText.fixture(vocalized: 'בַּיִת', normalized: 'בית'),
      russianTranslation: 'дом',
      root: const Shoresh.fixture(['ב', 'י', 'ת']),
      attribution: const ContentAttribution(sourceName: 'Seed', licenseName: 'CC-BY'),
      createdAt: DateTime.utc(2026, 1, 1),
    ),
    DictionaryEntry(
      id: 'dict-2',
      hebrew: const HebrewText.fixture(vocalized: 'שָׁלוֹם', normalized: 'שלום'),
      russianTranslation: 'мир, привет',
      root: const Shoresh.fixture(['ש', 'ל', 'ם']),
      attribution: const ContentAttribution(sourceName: 'Seed', licenseName: 'CC-BY'),
      createdAt: DateTime.utc(2026, 1, 1),
    ),
    DictionaryEntry(
      id: 'dict-3',
      hebrew: const HebrewText.fixture(vocalized: 'סֵפֶר', normalized: 'ספר'),
      russianTranslation: 'книга',
      root: const Shoresh.fixture(['ס', 'פ', 'ר']),
      attribution: const ContentAttribution(sourceName: 'Seed', licenseName: 'CC-BY'),
      createdAt: DateTime.utc(2026, 1, 1),
    ),
  ];

  group('HebrewMorphologyEngine', () {
    test('прямое совпадение со словарным словом без префиксов', () {
      final res = engine.analyzeWord(
        rawToken: 'שָׁלוֹם',
        dictionaryEntries: dictEntries,
      );

      expect(res.lemmaNormalized, 'שלום');
      expect(res.translation, 'мир, привет');
      expect(res.hasPrefixes, isFalse);
      expect(res.hasSuffix, isFalse);
      expect(res.hasRoot, isTrue);
      expect(res.root?.hyphenated, 'ש-ל-ם');
    });

    test('разбирает составные префиксы (союз ו + предлог ב)', () {
      final res = engine.analyzeWord(
        rawToken: 'ובבית',
        dictionaryEntries: dictEntries,
      );

      expect(res.hasPrefixes, isTrue);
      expect(res.prefixes.length, 2);
      expect(res.prefixes[0].normalized, 'ו');
      expect(res.prefixes[0].type, MorphemeType.conjunction);
      expect(res.prefixes[1].normalized, 'ב');
      expect(res.prefixes[1].type, MorphemeType.preposition);

      expect(res.lemmaNormalized, 'בית');
      expect(res.translation, 'дом');
      expect(res.root?.hyphenated, 'ב-י-ת');
    });

    test('разбирает префикс и притяжательный суффикс (ובביתנו)', () {
      final res = engine.analyzeWord(
        rawToken: 'ובביתנו',
        dictionaryEntries: dictEntries,
      );

      expect(res.hasPrefixes, isTrue);
      expect(res.prefixes.any((p) => p.normalized == 'ו'), isTrue);
      expect(res.prefixes.any((p) => p.normalized == 'ב'), isTrue);

      expect(res.hasSuffix, isTrue);
      expect(res.suffix?.normalized, 'נו');
      expect(res.suffix?.type, MorphemeType.pronominalSuffix);

      expect(res.lemmaNormalized, 'בית');
      expect(res.translation, 'дом');
      expect(res.explanation, contains('בַּיִת (дом)'));
    });

    test('разбирает полное предложение на слова', () {
      final res = engine.analyzeSentence(
        sentence: 'שָׁלוֹם וּבְבֵיתֵנוּ סֵפֶר!',
        russianTranslation: 'Мир, и в нашем доме книга!',
        dictionaryEntries: dictEntries,
      );

      expect(res.words.length, 3);
      expect(res.words[0].lemmaNormalized, 'שלום');
      expect(res.words[1].lemmaNormalized, 'בית');
      expect(res.words[2].lemmaNormalized, 'ספר');
    });
  });
}
