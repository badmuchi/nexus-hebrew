import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/binyan.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/entities/dictionary_entry.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/repositories/dictionary_repository.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/usecases/add_custom_dictionary_entry.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/usecases/search_dictionary_entries.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';

class _InMemoryDictRepo implements DictionaryRepository {
  DictionaryEntry? lastSaved;

  @override
  Future<Result<List<DictionaryEntry>, Failure>> getAllEntries() async =>
      const Success<List<DictionaryEntry>, Failure>(<DictionaryEntry>[]);

  @override
  Future<Result<Set<String>, Failure>> getSrsNormalizedForms() async =>
      const Success<Set<String>, Failure>(<String>{});

  @override
  Future<Result<DictionaryEntry, Failure>> saveCustomEntry(
    DictionaryEntry entry,
  ) async {
    lastSaved = entry;
    return Success<DictionaryEntry, Failure>(entry);
  }

  @override
  Future<Result<List<DictionaryEntry>, Failure>> searchOnlineAndCache({
    required String query,
    int limit = 12,
  }) async =>
      const Success<List<DictionaryEntry>, Failure>(<DictionaryEntry>[]);
}

void main() {
  final fixedNow = DateTime.utc(2026, 11, 12);
  const attribution = ContentAttribution(
    sourceName: 'Kaikki Hebrew',
    licenseName: 'CC BY-SA 4.0',
  );

  DictionaryEntry makeEntry({
    required String id,
    required String hebrewVocalized,
    required String russian,
    String? transliteration,
    LexicalCategory category = LexicalCategory.noun,
    String? root,
    Binyan binyan = Binyan.none,
    String? formsSummary,
    String? exampleHeb,
    String? exampleRu,
    int? frequencyRank,
  }) {
    return DictionaryEntry(
      id: id,
      hebrew: HebrewText.create(hebrewVocalized).getOrNull()!,
      russianTranslation: russian,
      transliteration: transliteration,
      category: category,
      root: root == null ? null : Shoresh.create(root).getOrNull()!,
      binyan: binyan,
      formsSummary: formsSummary,
      exampleHebrew:
          exampleHeb == null ? null : HebrewText.create(exampleHeb).getOrNull()!,
      exampleRussian: exampleRu,
      frequencyRank: frequencyRank,
      attribution: attribution,
      createdAt: fixedNow,
    );
  }

  final entries = <DictionaryEntry>[
    makeEntry(
      id: 'dict_shalom',
      hebrewVocalized: 'שָׁלוֹם',
      russian: 'мир, привет',
      transliteration: 'shalom',
      category: LexicalCategory.noun,
      root: 'ש-ל-ם',
      frequencyRank: 12,
    ),
    makeEntry(
      id: 'dict_likhtov',
      hebrewVocalized: 'לִכְתֹּב',
      russian: 'писать',
      transliteration: 'likhtov',
      category: LexicalCategory.verb,
      root: 'כ-ת-ב',
      binyan: Binyan.paal,
      formsSummary: 'כּוֹתֵב · כָּתַב · יִכְתֹּב',
      frequencyRank: 30,
    ),
    makeEntry(
      id: 'dict_mikhtav',
      hebrewVocalized: 'מִכְתָּב',
      russian: 'письмо',
      transliteration: 'mikhtav',
      category: LexicalCategory.noun,
      root: 'כ-ת-ב',
      frequencyRank: 85,
      exampleHeb: 'קִבַּלְתִּי מִכְתָּב',
      exampleRu: 'Я получил письмо и сразу начал его читать',
    ),
    makeEntry(
      id: 'dict_katav',
      hebrewVocalized: 'כָּתָב',
      russian: 'журналист, репортёр',
      transliteration: 'katav',
      category: LexicalCategory.noun,
      root: 'כ-ת-ב',
      frequencyRank: 140,
    ),
    makeEntry(
      id: 'dict_bayit',
      hebrewVocalized: 'בַּיִת',
      russian: 'дом',
      transliteration: 'bayit',
      category: LexicalCategory.noun,
      frequencyRank: 5,
    ),
  ];

  group('SearchDictionaryEntriesUseCase', () {
    const useCase = SearchDictionaryEntriesUseCase();

    test('пустой фильтр сортирует по frequencyRank и расставляет isInSrs', () {
      final matches = useCase(
        entries: entries,
        filter: const DictionaryFilter(),
        srsNormalizedForms: const <String>{'שלום'},
      );

      expect(matches.map((m) => m.entry.id).toList(), <String>[
        'dict_bayit',
        'dict_shalom',
        'dict_likhtov',
        'dict_mikhtav',
        'dict_katav',
      ]);
      expect(matches[0].isInSrs, isFalse);
      expect(matches[1].isInSrs, isTrue);
    });

    test('поиск на иврите работает с огласовками, без них и с софитами', () {
      final withNikkud = useCase(
        entries: entries,
        filter: const DictionaryFilter(query: 'שָׁלוֹם'),
      );
      expect(withNikkud.first.entry.id, equals('dict_shalom'));

      // Конечная мем как обычная ממ
      final withRegularMem = useCase(
        entries: entries,
        filter: const DictionaryFilter(query: 'שלומ'),
      );
      expect(withRegularMem.map((m) => m.entry.id), contains('dict_shalom'));

      // Поиск по словоформе из formsSummary
      final byForm = useCase(
        entries: entries,
        filter: const DictionaryFilter(query: 'כותב'),
      );
      expect(byForm.map((m) => m.entry.id), contains('dict_likhtov'));
    });

    test('поиск по-русски и по транскрипции ранжирует точные совпадения выше', () {
      final rusMatches = useCase(
        entries: entries,
        filter: const DictionaryFilter(query: 'письмо'),
      );
      expect(rusMatches.first.entry.id, equals('dict_mikhtav'));

      final translitMatches = useCase(
        entries: entries,
        filter: const DictionaryFilter(query: 'shalom'),
      );
      expect(translitMatches.first.entry.id, equals('dict_shalom'));
    });

    test('поиск по корню כ-ת-ב и findRelatedByRoot возвращают всё семейство', () {
      final byRootQuery = useCase(
        entries: entries,
        filter: const DictionaryFilter(query: 'כ-ת-ב'),
      );
      expect(
        byRootQuery.map((m) => m.entry.id).toSet(),
        equals(<String>{'dict_likhtov', 'dict_mikhtav', 'dict_katav'}),
      );

      final rootKtb = Shoresh.create('כ-ת-ב').getOrNull()!;
      final related = useCase.findRelatedByRoot(
        entries: entries,
        root: rootKtb,
        excludeEntryId: 'dict_mikhtav',
      );
      expect(
        related.map((e) => e.id).toList(),
        equals(<String>['dict_likhtov', 'dict_katav']),
      );
    });

    test('комбинация фильтров category, binyan, onlyInSrs, onlyWithRoot и rootFilter', () {
      final filtered = useCase(
        entries: entries,
        filter: DictionaryFilter(
          category: LexicalCategory.verb,
          binyan: Binyan.paal,
          onlyInSrs: true,
          onlyWithRoot: true,
          rootFilter: Shoresh.create('כ-ת-ב').getOrNull()!,
        ),
        srsNormalizedForms: const <String>{'לכתב'},
      );
      expect(filtered.length, equals(1));
      expect(filtered.single.entry.id, equals('dict_likhtov'));
    });
  });

  group('AddCustomDictionaryEntryUseCase', () {
    test('валидирует иврит и русский перевод', () async {
      final repo = _InMemoryDictRepo();
      final useCase = AddCustomDictionaryEntryUseCase(
        repository: repo,
        clock: () => fixedNow,
      );

      final badHebrew = await useCase(
        const AddCustomDictionaryEntryParams(
          hebrewVocalized: 'computer',
          russianTranslation: 'компьютер',
        ),
      );
      expect(badHebrew, isA<Error<DictionaryEntry, Failure>>());

      final emptyRu = await useCase(
        const AddCustomDictionaryEntryParams(
          hebrewVocalized: 'מַחְשֵׁב',
          russianTranslation: '   ',
        ),
      );
      expect(emptyRu, isA<Error<DictionaryEntry, Failure>>());
    });

    test('сохраняет пользовательское слово с корнем, примером и пометкой isUserAdded', () async {
      final repo = _InMemoryDictRepo();
      final useCase = AddCustomDictionaryEntryUseCase(
        repository: repo,
        clock: () => fixedNow,
      );

      final res = await useCase(
        const AddCustomDictionaryEntryParams(
          hebrewVocalized: 'מַחְשֵׁב',
          russianTranslation: 'компьютер',
          transliteration: 'makhshev',
          category: LexicalCategory.noun,
          rawRoot: 'ח-ש-ב',
          exampleHebrewVocalized: 'יֵשׁ לִי מַחְשֵׁב חָדָשׁ.',
          exampleRussian: 'У меня есть новый компьютер.',
        ),
      );

      expect(res, isA<Success<DictionaryEntry, Failure>>());
      final saved = res.getOrNull()!;
      expect(saved.isUserAdded, isTrue);
      expect(saved.hebrew.normalized, equals('מחשב'));
      expect(saved.root?.hyphenated, equals('ח-ש-ב'));
      expect(saved.attribution.sourceName, equals('Личный словарь'));
      expect(repo.lastSaved, equals(saved));
    });
  });
}
