import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/entities/dictionary_entry.dart';
import 'package:nexus_hebrew_app/features/morphology/presentation/widgets/sentence_xray_sheet.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/add_card_to_srs.dart';

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}
class _MockAddCardToSrsUseCase extends Mock implements AddCardToSrsUseCase {}

void main() {
  late _MockAudioPlaybackService audioMock;
  late _MockAddCardToSrsUseCase addSrsMock;

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
  ];

  setUpAll(() {
    registerFallbackValue(
      const AddCardToSrsParams(
        id: 'test',
        hebrewVocalized: 'בַּיִת',
        russianTranslation: 'дом',
      ),
    );
  });

  setUp(() {
    audioMock = _MockAudioPlaybackService();
    addSrsMock = _MockAddCardToSrsUseCase();

    when(
      () => audioMock.playWithTtsFallback(
        sourcePath: any(named: 'sourcePath'),
        fallbackHebrewText: any(named: 'fallbackHebrewText'),
      ),
    ).thenAnswer((_) async => const Success(null));

    when(() => addSrsMock.call(any())).thenAnswer((_) async => const Success(true));
  });

  Widget createSubject() {
    return MaterialApp(
      home: Scaffold(
        body: SentenceXRaySheet(
          sentenceHebrew: 'שָׁלוֹם וּבְבֵיתֵנוּ',
          sentenceRussian: 'Мир и в нашем доме',
          allDictionaryEntries: dictEntries,
          audioService: audioMock,
          addCardToSrsUseCase: addSrsMock,
        ),
      ),
    );
  }

  group('SentenceXRaySheet', () {
    testWidgets('рендерит заголовок, предложение, чипы слов и разбор', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('Рентген фразы'), findsOneWidget);
      expect(find.text('Анатомический разбор слов и приставок иврита'), findsOneWidget);
      expect(find.text('Мир и в нашем доме'), findsOneWidget);

      // Чипы слов
      expect(find.text('שָׁלוֹם'), findsWidgets);
      expect(find.text('וּבְבֵיתֵנוּ'), findsWidgets);

      // По умолчанию выбрано первое слово "שלום"
      expect(find.text('мир, привет'), findsWidgets);
    });

    testWidgets('переключение на слово с приставками отображает приставки и суффикс', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Нажимаем на второе слово "וּבְבֵיתֵנוּ"
      await tester.tap(find.text('וּבְבֵיתֵנוּ').first);
      await tester.pumpAndSettle();

      // Должны появиться приставки и суффикс
      expect(find.text('Приставки (אותיות השימוש):'), findsOneWidget);
      expect(find.text('Союз «и / а»'), findsOneWidget);
      expect(find.text('Предлог «в / внутри / с помощью»'), findsOneWidget);
      expect(find.text('Суффикс «наш / мы»'), findsOneWidget);
      expect(find.text('Корень: ב-י-ת'), findsOneWidget);
    });

    testWidgets('кнопка Добавить основу в FSRS карточки вызывает юзкейс', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('וּבְבֵיתֵנוּ').first);
      await tester.pumpAndSettle();

      final addBtn = find.text('Добавить основу в FSRS карточки');
      expect(addBtn, findsOneWidget);

      await tester.ensureVisible(addBtn);
      await tester.pumpAndSettle();

      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      verify(() => addSrsMock.call(any())).called(1);
      expect(find.textContaining('добавлено в карточки FSRS!'), findsOneWidget);
    });
  });
}
