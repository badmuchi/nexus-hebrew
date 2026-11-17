import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/binyan.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/entities/dictionary_entry.dart';
import 'package:nexus_hebrew_app/features/dictionary/presentation/widgets/shoresh_explorer_view.dart';
import 'package:nexus_hebrew_app/features/grammar/domain/entities/verb_conjugation.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/add_card_to_srs.dart';

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}

class _MockAddCardToSrsUseCase extends Mock implements AddCardToSrsUseCase {}

void main() {
  final fixedNow = DateTime.utc(2026, 11, 12);
  const attribution = ContentAttribution(
    sourceName: 'Nexus Seed',
    licenseName: 'CC BY-SA 4.0',
  );

  late _MockAudioPlaybackService audioService;
  late _MockAddCardToSrsUseCase addCardToSrsUseCase;
  late StreamController<AudioPlaybackEvent> audioEvents;
  late List<DictionaryEntry> entries;
  late List<VerbLexeme> verbs;

  setUpAll(() {
    registerFallbackValue(
      const AddCardToSrsParams(
        id: 'fallback',
        hebrewVocalized: 'סֵפֶר',
        russianTranslation: 'книга',
        attribution: attribution,
      ),
    );
  });

  setUp(() {
    audioService = _MockAudioPlaybackService();
    addCardToSrsUseCase = _MockAddCardToSrsUseCase();
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
    when(() => addCardToSrsUseCase(any()))
        .thenAnswer((_) async => const Success(true));

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
        hebrew: HebrewText.create('מִסְפָּר').getOrNull()!,
        russianTranslation: 'номер, число',
        transliteration: 'mispar',
        category: LexicalCategory.noun,
        root: Shoresh.create('ס-פ-ר').getOrNull()!,
        attribution: attribution,
        createdAt: fixedNow,
      ),
      DictionaryEntry(
        id: 'dict_3',
        hebrew: HebrewText.create('מִכְתָּב').getOrNull()!,
        russianTranslation: 'письмо',
        transliteration: 'mikhtav',
        category: LexicalCategory.noun,
        root: Shoresh.create('כ-ת-ב').getOrNull()!,
        attribution: attribution,
        createdAt: fixedNow,
      ),
    ];

    verbs = [
      VerbLexeme(
        id: 'verb_1',
        lemma: HebrewText.create('כָּתַב').getOrNull()!,
        infinitive: HebrewText.create('לִכְתֹּב').getOrNull()!,
        root: Shoresh.create('כ-ת-ב').getOrNull()!,
        binyan: Binyan.paal,
        russianMeaning: 'писать',
        grammarNotesRu: 'Пааль',
        attribution: attribution,
        conjugations: const [],
      ),
      VerbLexeme(
        id: 'verb_2',
        lemma: HebrewText.create('סִפֵּר').getOrNull()!,
        infinitive: HebrewText.create('לְסַפֵּר').getOrNull()!,
        root: Shoresh.create('ס-פ-ר').getOrNull()!,
        binyan: Binyan.piel,
        russianMeaning: 'рассказывать',
        grammarNotesRu: 'Пиэль',
        attribution: attribution,
        conjugations: const [],
      ),
    ];
  });

  tearDown(() async {
    await audioEvents.close();
  });

  Widget createSubject() {
    return MaterialApp(
      home: Scaffold(
        body: ShoreshExplorerView(
          allEntries: entries,
          verbParadigms: verbs,
          srsNormalizedForms: const {},
          audioService: audioService,
          addCardToSrsUseCase: addCardToSrsUseCase,
        ),
      ),
    );
  }

  testWidgets('Отображает заголовок Коренного компаса и карточки корней', (tester) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    expect(find.text('Коренной компас · מַצְפֵּן שָׁרָשִׁים'), findsOneWidget);
    expect(find.text('ס-פ-ר'), findsOneWidget);
    expect(find.text('כ-ת-ב'), findsOneWidget);
    expect(find.text('3 сл.'), findsOneWidget); // ס-פ-ר has 2 dict + 1 verb
    expect(find.text('2 сл.'), findsOneWidget); // כ-ת-ב has 1 dict + 1 verb
  });

  testWidgets('Поиск по корню фильтрует отображаемые семьи', (tester) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'כתב');
    await tester.pumpAndSettle();

    expect(find.text('כ-ת-ב'), findsOneWidget);
    expect(find.text('ס-פ-ר'), findsNothing);
  });

  testWidgets('Тап по карточке корня открывает интерактивный ShoreshFamilySheet', (tester) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    // Нажимаем на карточку корня ס-פ-ר
    await tester.tap(find.text('ס-פ-ר'));
    await tester.pumpAndSettle();

    // Открылся ShoreshFamilySheet с заголовком и секциями
    expect(find.text('Семья корня'), findsOneWidget);
    expect(find.text('Слова в словаре (2)'), findsOneWidget);
    expect(find.text('Глаголы (1)'), findsOneWidget);
  });
}
