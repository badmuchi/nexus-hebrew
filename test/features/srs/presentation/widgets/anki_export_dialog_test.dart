import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/binyan.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/entities/dictionary_entry.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/fsrs_models.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';
import 'package:nexus_hebrew_app/features/srs/presentation/widgets/anki_export_dialog.dart';

void main() {
  final testCards = [
    SrsCard(
      id: 'card-1',
      hebrew: const HebrewText.fixture(
        vocalized: 'שָׁלוֹם',
        normalized: 'שלום',
      ),
      russianTranslation: 'Привет, мир',
      root: const Shoresh.fixture(['ש', 'ל', 'מ']),
      binyan: Binyan.paal,
      audioUrl: 'assets/audio/srs/shalom.mp3',
      memory: FsrsMemoryState.initial(now: DateTime.utc(2026, 1, 1)),
      attribution: const ContentAttribution(
        sourceName: 'Seed',
        licenseName: 'CC-BY',
      ),
    ),
  ];

  final testEntries = [
    DictionaryEntry(
      id: 'dict-1',
      hebrew: const HebrewText.fixture(
        vocalized: 'תּוֹדָה',
        normalized: 'תודה',
      ),
      russianTranslation: 'Спасибо',
      category: LexicalCategory.noun,
      binyan: Binyan.none,
      frequencyRank: 1,
      createdAt: DateTime.utc(2025, 1, 1),
      attribution: const ContentAttribution(
        sourceName: 'Seed',
        licenseName: 'CC-BY',
      ),
    ),
  ];

  Widget createSubject({
    List<SrsCard>? cards,
    List<DictionaryEntry>? entries,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () {
                if (cards != null) {
                  AnkiExportDialog.showSrsExport(context, cards: cards);
                } else if (entries != null) {
                  AnkiExportDialog.showDictionaryExport(context, entries: entries);
                }
              },
              child: const Text('Open Export'),
            ),
          ),
        ),
      ),
    );
  }

  group('AnkiExportDialog', () {
    testWidgets('открывается и отображает статистику карточек и предпросмотр', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createSubject(cards: testCards));
      await tester.tap(find.text('Open Export'));
      await tester.pumpAndSettle();

      expect(find.text('Экспорт FSRS колоды в Anki'), findsOneWidget);
      expect(find.text('Всего карточек к экспорту: 1'), findsOneWidget);
      expect(find.text('Anki TSV'), findsOneWidget);
      expect(find.text('CSV'), findsOneWidget);
      expect(find.text('JSON'), findsOneWidget);
      expect(find.text('Включать огласовки (никуд)'), findsOneWidget);
      expect(find.text('Как импортировать в Anki?'), findsOneWidget);

      // Раскрываем инструкцию
      await tester.tap(find.text('Как импортировать в Anki?'));
      await tester.pumpAndSettle();
      expect(find.textContaining('В приложении Anki'), findsOneWidget);

      // Кнопка копирования
      expect(find.text('Скопировать для Anki'), findsOneWidget);
      await tester.tap(find.text('Скопировать для Anki'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Скопировано!'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('переключает формат между TSV и CSV', (tester) async {
      await tester.pumpWidget(createSubject(entries: testEntries));
      await tester.tap(find.text('Open Export'));
      await tester.pumpAndSettle();

      expect(find.text('Экспорт словаря в Anki'), findsOneWidget);

      // Нажимаем на CSV сегмент
      await tester.tap(find.text('CSV'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Front,Back,Transliteration'), findsOneWidget);

      // Нажимаем на JSON сегмент
      await tester.tap(find.text('JSON'));
      await tester.pumpAndSettle();

      expect(find.textContaining('"hebrew"'), findsOneWidget);
    });
  });
}
