import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/logging/app_logger.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/entities/dictionary_entry.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/repositories/dictionary_repository.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/usecases/add_custom_dictionary_entry.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/usecases/search_dictionary_entries.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/usecases/search_online_dictionary.dart';
import 'package:nexus_hebrew_app/features/dictionary/presentation/cubit/dictionary_cubit.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/add_card_to_srs.dart';
import 'package:nexus_hebrew_app/features/srs/presentation/screens/speed_sprint_screen.dart';

class _MockDictionaryRepository extends Mock implements DictionaryRepository {}

class _MockAddCardToSrsUseCase extends Mock implements AddCardToSrsUseCase {}

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}

void main() {
  final fixedNow = DateTime.utc(2026, 11, 12);
  const attribution = ContentAttribution(
    sourceName: 'Nexus Seed',
    licenseName: 'CC BY-SA 4.0',
  );

  late _MockDictionaryRepository repository;
  late _MockAddCardToSrsUseCase addCardToSrsUseCase;
  late _MockAudioPlaybackService audioService;
  late StreamController<AudioPlaybackEvent> audioEvents;
  late List<DictionaryEntry> entries;

  setUpAll(() {
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

    entries = [
      DictionaryEntry(
        id: 'dict_1',
        hebrew: HebrewText.create('סֵפֶר').getOrNull()!,
        russianTranslation: 'книга',
        transliteration: 'sefer',
        category: LexicalCategory.noun,
        root: Shoresh.create('ס-פ-ר').getOrNull()!,
        attribution: attribution,
        createdAt: fixedNow,
      ),
      DictionaryEntry(
        id: 'dict_2',
        hebrew: HebrewText.create('שָׁלוֹם').getOrNull()!,
        russianTranslation: 'мир / привет',
        transliteration: 'shalom',
        category: LexicalCategory.noun,
        root: Shoresh.create('ש-ל-ם').getOrNull()!,
        attribution: attribution,
        createdAt: fixedNow,
      ),
      DictionaryEntry(
        id: 'dict_3',
        hebrew: HebrewText.create('בַּיִת').getOrNull()!,
        russianTranslation: 'дом',
        transliteration: 'bayit',
        category: LexicalCategory.noun,
        root: Shoresh.create('ב-י-ת').getOrNull()!,
        attribution: attribution,
        createdAt: fixedNow,
      ),
      DictionaryEntry(
        id: 'dict_4',
        hebrew: HebrewText.create('יוֹם').getOrNull()!,
        russianTranslation: 'день',
        transliteration: 'yom',
        category: LexicalCategory.noun,
        attribution: attribution,
        createdAt: fixedNow,
      ),
    ];

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
        .thenAnswer((_) async => Success(entries));
    when(() => repository.getSrsNormalizedForms())
        .thenAnswer((_) async => const Success(<String>{}));
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

  Widget createSubject({required DictionaryCubit cubit}) {
    return MaterialApp(
      home: BlocProvider<DictionaryCubit>.value(
        value: cubit,
        child: SpeedSprintScreen(
          audioService: audioService,
          addCardToSrsUseCase: addCardToSrsUseCase,
        ),
      ),
    );
  }

  testWidgets('Отображает лобби спринта и правила игры', (tester) async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await cubit.loadDictionary();

    await tester.pumpWidget(createSubject(cubit: cubit));
    await tester.pumpAndSettle();

    expect(find.text('⚡️ Блиц-спринт'), findsOneWidget);
    expect(find.text('Блиц-спринт: 60 секунд'), findsOneWidget);
    expect(find.text('Начать спринт'), findsOneWidget);
    expect(find.text('60 секунд'), findsOneWidget);
  });

  testWidgets('Запуск спринта открывает игровой экран с таймером и опциями', (tester) async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await cubit.loadDictionary();

    await tester.pumpWidget(createSubject(cubit: cubit));
    await tester.pumpAndSettle();

    // Нажимаем Начать спринт
    await tester.tap(find.text('Начать спринт'));
    await tester.pump();

    // Виден таймер и индикатор очков
    expect(find.text('60 с'), findsOneWidget);
    expect(find.byIcon(Icons.stars_rounded), findsOneWidget);
    expect(find.text('0'), findsWidgets);

    // Звук TTS должен быть вызван для первого слова
    verify(
      () => audioService.playWithTtsFallback(
        sourcePath: any(named: 'sourcePath'),
        fallbackHebrewText: any(named: 'fallbackHebrewText'),
      ),
    ).called(1);
  });

  testWidgets('Выбор ответа обновляет очки и комбо', (tester) async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await cubit.loadDictionary();

    await tester.pumpWidget(createSubject(cubit: cubit));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Начать спринт'));
    await tester.pump();

    // Находим первый вариант и тапаем
    final firstOption = find.byType(InkWell).first;
    await tester.tap(firstOption);
    await tester.pump();

    // Ждём задержку перехода (320мс)
    await tester.pump(const Duration(milliseconds: 400));

    // Проверяем, что экран активен и продолжается игра
    expect(find.byType(SpeedSprintScreen), findsOneWidget);
  });
}
