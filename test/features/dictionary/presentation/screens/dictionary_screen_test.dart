import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:nexus_hebrew_app/features/dictionary/presentation/screens/dictionary_screen.dart';
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
  late List<DictionaryEntry> storedEntries;

  setUpAll(() {
    registerFallbackValue(
      const AddCardToSrsParams(
        id: 'fallback',
        hebrewVocalized: 'שָׁלוֹם',
        russianTranslation: 'мир',
        attribution: attribution,
      ),
    );
    registerFallbackValue(
      DictionaryEntry(
        id: 'fallback',
        hebrew: HebrewText.create('שָׁלוֹם').getOrNull()!,
        russianTranslation: 'мир',
        attribution: attribution,
        createdAt: fixedNow,
      ),
    );
  });

  setUp(() {
    repository = _MockDictionaryRepository();
    addCardToSrsUseCase = _MockAddCardToSrsUseCase();
    audioService = _MockAudioPlaybackService();
    audioEvents = StreamController<AudioPlaybackEvent>.broadcast();

    storedEntries = <DictionaryEntry>[
      DictionaryEntry(
        id: 'dict_sefer',
        hebrew: HebrewText.create('סֵפֶר').getOrNull()!,
        russianTranslation: 'книга',
        transliteration: 'sefer',
        category: LexicalCategory.noun,
        root: Shoresh.create('ס-פ-ר').getOrNull()!,
        frequencyRank: 15,
        audioUrl: 'assets/audio/dictionary/dict_sefer.mp3',
        attribution: attribution,
        createdAt: fixedNow,
      ),
      DictionaryEntry(
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
      ),
    ];

    when(() => audioService.statusStream).thenAnswer((_) => audioEvents.stream);
    when(() => audioService.stop())
        .thenAnswer((_) async => const Success(null));
    when(() => repository.getAllEntries())
        .thenAnswer((_) async => Success(storedEntries));
    when(() => repository.getSrsNormalizedForms())
        .thenAnswer((_) async => const Success(<String>{}));
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

  Future<void> settle(WidgetTester tester, String step) async {
    try {
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 4),
      );
    } catch (error) {
      fail('pumpAndSettle timed out at step [$step]: $error');
    }
  }

  testWidgets('DictionaryScreen ищет, открывает карточку корня и добавляет своё слово', (
    WidgetTester tester,
  ) async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await cubit.loadDictionary();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<DictionaryCubit>.value(
          value: cubit,
          child: const DictionaryScreen(),
        ),
      ),
    );
    await settle(tester, 'initial pump');

    expect(find.text('Словарь · 2'), findsOneWidget);
    expect(find.text('סֵפֶר'), findsOneWidget);
    expect(find.text('книга'), findsOneWidget);
    expect(find.text('לְסַפֵּר'), findsOneWidget);

    // Скрыть огласовки и снова показать
    await tester.tap(find.byTooltip('Скрыть огласовки'));
    await settle(tester, 'hide nikkud');
    expect(find.text('ספר'), findsOneWidget);
    expect(find.text('לספר'), findsOneWidget);
    await tester.tap(find.byTooltip('Показать огласовки'));
    await settle(tester, 'show nikkud');
    expect(find.text('סֵפֶר'), findsOneWidget);

    // Поиск по-русски
    await tester.enterText(find.byType(TextField), 'рассказывать');
    await settle(tester, 'enter search');
    expect(find.text('לְסַפֵּר'), findsOneWidget);
    expect(find.text('книга'), findsNothing);

    // Очистка поиска
    await tester.tap(find.byTooltip('Очистить'));
    await settle(tester, 'clear search');
    expect(find.text('книга'), findsOneWidget);

    // Открыть подробную карточку слова
    await tester.tap(find.text('книга'));
    await settle(tester, 'open sheet');
    expect(find.textContaining('Корень ס-פ-ר'), findsOneWidget);

    // Фильтр по однокоренным из карточки
    await tester.tap(find.byTooltip('Показать все однокоренные слова'));
    await settle(tester, 'filter by root');
    expect(find.textContaining('Однокоренные'), findsOneWidget);
    await tester.tap(find.text('Сбросить'));
    await settle(tester, 'reset root');

    // Добавление пользовательского слова через диалог
    await tester.tap(find.byTooltip('Добавить своё слово'));
    await settle(tester, 'open dialog');
    expect(find.text('Добавить слово в словарь'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Слово или фраза на иврите *'),
      'מַחְשֵׁב',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Перевод на русский *'),
      'компьютер',
    );
    await tester.tap(find.text('Сохранить'));
    await settle(tester, 'submit dialog');

    expect(find.text('компьютер'), findsOneWidget);
    expect(find.text('Словарь · 3'), findsOneWidget);
  });
}
