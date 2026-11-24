import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/entities/dictionary_entry.dart';
import 'package:nexus_hebrew_app/features/search/domain/entities/omni_search_result.dart';
import 'package:nexus_hebrew_app/features/search/domain/services/omni_search_engine.dart';
import 'package:nexus_hebrew_app/features/slang/domain/entities/slang_expression.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';

void main() {
  group('OmniSearchEngine', () {
    test('withStaticDefaults loads letters, nikkud, and prepositions', () {
      final engine = OmniSearchEngine.withStaticDefaults();
      expect(engine.count, greaterThan(30));

      final alefResults = engine.search('אָלֶף');
      expect(alefResults, isNotEmpty);
      expect(alefResults.first.hebrewWithNikkud, contains('אָלֶף'));
      expect(alefResults.first.category, OmniResultCategory.alphabet);

      final shelResults = engine.search('שלי');
      expect(shelResults, isNotEmpty);
      expect(shelResults.first.hebrewWithoutNikkud, 'שלי');
      expect(shelResults.first.category, OmniResultCategory.preposition);
    });

    test('search matches with and without nikkud seamlessly', () {
      final engine = OmniSearchEngine.withStaticDefaults();

      // Search by plain Hebrew letters without nikkud
      final withoutNikkud = engine.search('אלף');
      expect(withoutNikkud, isNotEmpty);
      expect(withoutNikkud.any((r) => r.hebrewWithNikkud.contains('אָלֶף')), isTrue);

      // Search by Russian word
      final byRussian = engine.search('Папа');
      expect(byRussian, isNotEmpty);
    });

    test('category filter limits results to target domain', () {
      final engine = OmniSearchEngine.withStaticDefaults();

      final prepOnly = engine.search('שֶׁל', categoryFilter: OmniResultCategory.preposition);
      expect(prepOnly, isNotEmpty);
      expect(prepOnly.every((r) => r.category == OmniResultCategory.preposition), isTrue);

      final noAlphabet = engine.search('שֶׁל', categoryFilter: OmniResultCategory.alphabet);
      expect(noAlphabet.where((r) => r.category == OmniResultCategory.preposition), isEmpty);
    });

    test('addDictionaryEntries and addSlangExpressions indexes correctly', () {
      final engine = OmniSearchEngine();

      final hebrewWord = HebrewText.create('שָׁלוֹם').getOrNull()!;
      final entry = DictionaryEntry(
        id: '1',
        hebrew: hebrewWord,
        russianTranslation: 'Мир, привет, до свидания',
        attribution: const ContentAttribution(sourceName: 'User', licenseName: 'CC-BY'),
        createdAt: DateTime.now(),
        transliteration: 'Shalom',
      );
      engine.addDictionaryEntries([entry]);

      final slangHebrew = HebrewText.create('סַבָּבָּה').getOrNull()!;
      final slang = SlangExpression(
        id: '2',
        hebrew: slangHebrew,
        transliteration: 'Sababa',
        translationRu: 'Круто, отлично, договорились',
        literalTranslationRu: 'Круто',
        culturalNoteRu: 'Самое популярное слово',
        category: SlangCategory.street,
        exampleHebrew: 'הַכֹּל סַבָּבָּה',
        exampleTranslationRu: 'Всё круто',
      );
      engine.addSlangExpressions([slang]);

      // Search dictionary
      final dictRes = engine.search('мир');
      expect(dictRes, hasLength(1));
      expect(dictRes.first.category, OmniResultCategory.dictionary);
      expect(dictRes.first.hebrewWithNikkud, 'שָׁלוֹם');

      // Search slang
      final slangRes = engine.search('sababa');
      expect(slangRes, hasLength(1));
      expect(slangRes.first.category, OmniResultCategory.slang);
      expect(slangRes.first.hebrewWithoutNikkud, 'סבבה');
    });

    test('withStaticDefaults loads army, chat slang, news, and voice scenarios', () {
      final engine = OmniSearchEngine.withStaticDefaults();

      // Army slang test
      final pakalRes = engine.search('пакаль');
      expect(pakalRes, isNotEmpty);
      expect(pakalRes.any((r) => r.category == OmniResultCategory.army), isTrue);

      // WhatsApp slang test
      final amlakRes = engine.search('אמלק');
      expect(amlakRes, isNotEmpty);
      expect(amlakRes.any((r) => r.category == OmniResultCategory.chat), isTrue);

      // Easy news test
      final newsRes = engine.search('Негев');
      expect(newsRes, isNotEmpty);
      expect(newsRes.any((r) => r.category == OmniResultCategory.news), isTrue);

      // Voice scenario test
      final voiceRes = engine.search('Дизенгоф');
      expect(voiceRes, isNotEmpty);
      expect(voiceRes.any((r) => r.category == OmniResultCategory.dialogue), isTrue);
    });

    test('empty query returns empty list', () {
      final engine = OmniSearchEngine.withStaticDefaults();
      expect(engine.search(''), isEmpty);
      expect(engine.search('   '), isEmpty);
    });
  });
}
