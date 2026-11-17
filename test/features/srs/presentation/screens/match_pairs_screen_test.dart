import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/fsrs_models.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';
import 'package:nexus_hebrew_app/features/srs/domain/services/match_pairs_engine.dart';
import 'package:nexus_hebrew_app/features/srs/presentation/screens/match_pairs_screen.dart';

void main() {
  final testCards = [
    SrsCard(
      id: 'card_1',
      hebrew: const HebrewText.fixture(vocalized: 'שָׁלוֹם', normalized: 'שלום'),
      russianTranslation: 'Привет',
      memory: FsrsMemoryState.initial(now: DateTime.utc(2026, 1, 1)),
      attribution: const ContentAttribution(sourceName: 'Seed', licenseName: 'CC-BY'),
    ),
    SrsCard(
      id: 'card_2',
      hebrew: const HebrewText.fixture(vocalized: 'תּוֹדָה', normalized: 'תודה'),
      russianTranslation: 'Спасибо',
      memory: FsrsMemoryState.initial(now: DateTime.utc(2026, 1, 1)),
      attribution: const ContentAttribution(sourceName: 'Seed', licenseName: 'CC-BY'),
    ),
  ];

  group('MatchPairsEngine', () {
    final engine = MatchPairsEngine();

    test('генерирует плитки (пары) для карточек', () {
      final tiles = engine.generateTiles(testCards, pairCount: 2);
      expect(tiles.length, equals(4));

      final hebrewTiles = tiles.where((t) => t.isHebrew).toList();
      final russianTiles = tiles.where((t) => !t.isHebrew).toList();

      expect(hebrewTiles.length, equals(2));
      expect(russianTiles.length, equals(2));
    });

    test('считает XP корректно при полной победе', () {
      final xp = engine.calculateEarnedXp(
        matchedCount: 6,
        totalPairs: 6,
        remainingSeconds: 30,
        mistakes: 0,
      );
      expect(xp, greaterThanOrEqualTo(35));
    });
  });

  group('MatchPairsScreen', () {
    testWidgets('отображает таймер, счетчик и плитки', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MatchPairsScreen(cards: testCards),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Быстрые пары 🃏'), findsOneWidget);
      expect(find.text('60с'), findsOneWidget);
      expect(find.text('0 очков'), findsOneWidget);

      expect(find.text('שָׁלוֹם'), findsOneWidget);
      expect(find.text('Привет'), findsOneWidget);
      expect(find.text('תּוֹדָה'), findsOneWidget);
      expect(find.text('Спасибо'), findsOneWidget);

      // Тапаем пару שָׁלוֹם и Привет
      await tester.tap(find.text('שָׁלוֹם'));
      await tester.pump();

      await tester.tap(find.text('Привет'));
      await tester.pump();

      // Очки увеличились
      expect(find.text('150 очков'), findsOneWidget);
      expect(find.text('x2 🔥'), findsOneWidget);
    });
  });
}
