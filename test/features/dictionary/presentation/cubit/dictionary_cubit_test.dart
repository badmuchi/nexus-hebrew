import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/logging/app_logger.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/binyan.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/entities/dictionary_entry.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/repositories/dictionary_repository.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/usecases/add_custom_dictionary_entry.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/usecases/search_dictionary_entries.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/usecases/search_online_dictionary.dart';
import 'package:nexus_hebrew_app/features/dictionary/presentation/cubit/dictionary_cubit.dart';
import 'package:nexus_hebrew_app/features/dictionary/presentation/cubit/dictionary_state.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/add_card_to_srs.dart';

class _MockDictionaryRepository extends Mock implements DictionaryRepository {}

class _MockAddCardToSrsUseCase extends Mock implements AddCardToSrsUseCase {}

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}

void main() {
  final fixedNow = DateTime.utc(2026, 11, 12);
  const attribution = ContentAttribution(
    sourceName: 'Kaikki Hebrew',
    licenseName: 'CC BY-SA 4.0',
  );

  late _MockDictionaryRepository repository;
  late _MockAddCardToSrsUseCase addCardToSrsUseCase;
  late _MockAudioPlaybackService audioService;
  late StreamController<AudioPlaybackEvent> audioEvents;

  final entry1 = DictionaryEntry(
    id: 'dict_sefer',
    hebrew: HebrewText.create('סֵפֶר').getOrNull()!,
    russianTranslation: 'книга',
    transliteration: 'sefer',
    category: LexicalCategory.noun,
    root: Shoresh.create('ס-פ-ר').getOrNull()!,
    frequencyRank: 15,
    audioUrl: 'assets/audio/srs/srs_sefer.mp3',
    attribution: attribution,
    createdAt: fixedNow,
  );

  final entry2 = DictionaryEntry(
    id: 'dict_lesaper',
    hebrew: HebrewText.create('לְסַפֵּר').getOrNull()!,
    russianTranslation: 'рассказывать',
    transliteration: 'lesaper',
    category: LexicalCategory.verb,
    root: Shoresh.create('ס-פ-ר').getOrNull()!,
    binyan: Binyan.piel,
    frequencyRank: 45,
    attribution: attribution,
    createdAt: fixedNow,
  );

  final onlineEntry = DictionaryEntry(
    id: 'tatoeba_dict_555',
    hebrew: HebrewText.create('קָפֶה בְּבַקָּשָׁה').getOrNull()!,
    russianTranslation: 'Кофе, пожалуйста',
    category: LexicalCategory.phrase,
    attribution: const ContentAttribution(
      sourceName: 'Tatoeba.org',
      licenseName: 'CC BY 2.0 FR',
    ),
    createdAt: fixedNow,
  );

  setUpAll(() {
    registerFallbackValue(entry1);
    registerFallbackValue(
      const AddCardToSrsParams(
        id: 'fallback',
        hebrewVocalized: 'שָׁלוֹם',
        russianTranslation: 'мир',
        attribution: attribution,
      ),
    );
  });

  setUp(() {
    repository = _MockDictionaryRepository();
    addCardToSrsUseCase = _MockAddCardToSrsUseCase();
    audioService = _MockAudioPlaybackService();
    audioEvents = StreamController<AudioPlaybackEvent>.broadcast();

    when(() => audioService.statusStream).thenAnswer((_) => audioEvents.stream);
    when(() => audioService.stop())
        .thenAnswer((_) async => const Success(null));
    when(
      () => audioService.playWithTtsFallback(
        sourcePath: any(named: 'sourcePath'),
        fallbackHebrewText: any(named: 'fallbackHebrewText'),
      ),
    ).thenAnswer((_) async => const Success(null));
    when(() => repository.getAllEntries())
        .thenAnswer((_) async => Success(<DictionaryEntry>[entry1, entry2]));
    when(() => repository.getSrsNormalizedForms())
        .thenAnswer((_) async => const Success(<String>{'ספר'}));
    when(() => repository.saveCustomEntry(any())).thenAnswer(
      (Invocation inv) async =>
          Success(inv.positionalArguments.first as DictionaryEntry),
    );
    when(() => addCardToSrsUseCase(any()))
        .thenAnswer((_) async => const Success(true));
  });

  tearDown(() async {
    await audioEvents.close();
  });

  DictionaryCubit buildCubit() {
    return DictionaryCubit(
      repository: repository,
      searchUseCase: const SearchDictionaryEntriesUseCase(),
      addCustomEntryUseCase: AddCustomDictionaryEntryUseCase(
        repository: repository,
        clock: () => fixedNow,
      ),
      searchOnlineUseCase: SearchOnlineDictionaryUseCase(repository),
      addCardToSrsUseCase: addCardToSrsUseCase,
      audioService: audioService,
      logger: const DeveloperAppLogger(),
    );
  }

  group('DictionaryCubit', () {
    test('loadDictionary загружает записи, фильтрует и находит однокоренные слова', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await cubit.loadDictionary();

      expect(cubit.state, isA<DictionaryLoaded>());
      final loaded = cubit.state as DictionaryLoaded;
      expect(loaded.allEntries.length, equals(2));
      expect(loaded.visibleMatches.first.isInSrs, isTrue);

      final related = cubit.findRelatedWords(entry1);
      expect(related.map((e) => e.id).toList(), equals(<String>['dict_lesaper']));

      cubit.updateQuery('рассказ');
      expect((cubit.state as DictionaryLoaded).visibleMatches.single.entry.id,
          equals('dict_lesaper'));
    });

    test('saveToSrs обновляет srsNormalizedForms и выставляет notice', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await cubit.loadDictionary();
      await cubit.saveToSrs(entry2);

      final state = cubit.state as DictionaryLoaded;
      expect(state.srsNormalizedForms, containsAll(<String>['ספר', 'לספר']));
      expect(state.transientNotice, equals('Добавлено в колоду FSRS!'));
    });

    test('addCustomWord сохраняет новое слово и сразу добавляет его в FSRS', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      await cubit.loadDictionary();
      final ok = await cubit.addCustomWord(
        hebrewVocalized: 'מַחְשֵׁב',
        russianTranslation: 'компьютер',
        rawRoot: 'ח-ש-ב',
        alsoAddToSrs: true,
      );

      expect(ok, isTrue);
      final state = cubit.state as DictionaryLoaded;
      expect(state.allEntries.length, equals(3));
      expect(state.srsNormalizedForms, contains('מחשב'));
      expect(
        state.transientNotice,
        equals('Слово сохранено в словарь и добавлено в FSRS!'),
      );
    });

    test('searchOnline объединяет новые фразы Tatoeba без дубликатов', () async {
      when(
        () => repository.searchOnlineAndCache(
          query: 'кофе',
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => Success(<DictionaryEntry>[onlineEntry]));

      final cubit = buildCubit();
      addTearDown(cubit.close);

      await cubit.loadDictionary();
      cubit.updateQuery('кофе');
      await cubit.searchOnline();

      final state = cubit.state as DictionaryLoaded;
      expect(state.isSearchingOnline, isFalse);
      expect(state.lastOnlineQuery, equals('кофе'));
      expect(state.lastOnlineResultsCount, equals(1));
      expect(state.allEntries.map((e) => e.id), contains('tatoeba_dict_555'));
      expect(state.visibleMatches.single.entry.id, equals('tatoeba_dict_555'));
    });
  });
}
