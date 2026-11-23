import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/leagues/domain/services/sabra_league_service.dart';
import 'package:nexus_hebrew_app/features/leagues/presentation/screens/sabra_leagues_screen.dart';

void main() {
  group('SabraLeaguesScreen', () {
    late InMemorySabraLeagueStorage storage;
    late SabraLeagueService service;

    setUp(() {
      storage = InMemorySabraLeagueStorage();
      service = SabraLeagueService(storage: storage);
    });

    testWidgets('renders header, leaderboard members, and rules sheet', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: SabraLeaguesScreen(service: service),
        ),
      );

      await tester.pumpAndSettle();

      // Check header titles
      expect(find.text('Лиги Сабры'), findsOneWidget);
      expect(find.text('לִיגַת אֲרָד'), findsOneWidget);
      expect(find.text('Бронзовая лига'), findsOneWidget);

      // Check leaderboard competitors
      expect(find.text('נוֹעָה כֹּהֵן'), findsOneWidget);
      expect(find.text('אַתָּה (סַבְּרָה)'), findsOneWidget);

      // Open rules bottom sheet
      final infoButton = find.byTooltip('Правила лиги').first;
      await tester.tap(infoButton);
      await tester.pumpAndSettle();

      expect(find.text('חֻקֵּי לִיגַת הַסַּבְּרָה'), findsOneWidget);
      expect(find.text('Правила еженедельных соревнований'), findsOneWidget);

      // Close rules bottom sheet
      await tester.tap(find.text('Понятно (הֵבַנְתִּי)'));
      await tester.pumpAndSettle();

      // Tap +15 XP Action Chip
      final cardsChip = find.text('+15 XP Карточки');
      expect(cardsChip, findsOneWidget);
      await tester.tap(cardsChip);
      await tester.pumpAndSettle();

      // Verify SnackBar was shown
      expect(find.textContaining('за повторение карточек'), findsOneWidget);
    });
  });
}
