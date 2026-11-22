import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/gamification/presentation/widgets/sabra_leaderboard_sheet.dart';
import 'package:nexus_hebrew_app/features/gamification/presentation/widgets/sabra_league_card.dart';

void main() {
  group('SabraLeagueCard Widget Tests', () {
    testWidgets('renders current league name, Hebrew title, and opens leaderboard',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SabraLeagueCard(weeklyXp: 450),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify league information
      expect(find.text('Яффская апельсиновая лига'), findsOneWidget);
      expect(find.text('לִיגַת תַּפּוּז יָפוֹ'), findsOneWidget);
      expect(find.textContaining('450 XP на этой неделе'), findsOneWidget);

      // Tap on 'Турнирная таблица' to open leaderboard bottom sheet
      await tester.tap(find.text('Турнирная таблица'));
      await tester.pumpAndSettle();

      expect(find.byType(SabraLeaderboardSheet), findsOneWidget);
      expect(find.text('Вы'), findsOneWidget);
      expect(find.text('(אַתָּה (Ты))'), findsOneWidget);
    });
  });
}
