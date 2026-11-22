import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/gamification/domain/entities/sabra_quest.dart';
import 'package:nexus_hebrew_app/features/gamification/domain/services/sabra_quest_service.dart';
import 'package:nexus_hebrew_app/features/gamification/presentation/widgets/sabra_daily_quests_card.dart';

void main() {
  group('SabraDailyQuestsCard', () {
    testWidgets('отображает заголовок, стадии кактуса и список из 3 квестов', (tester) async {
      final state = SabraQuestService.generateDefaultQuests(
        date: DateTime(2026, 11, 22),
        streakDays: 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SabraDailyQuestsCard(
                initialState: state,
                streakDays: 5,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Квесты Сабры'), findsOneWidget);
      expect(find.text('מְשִׂימוֹת צַבָּר'), findsOneWidget);
      expect(find.text('5 дн.'), findsOneWidget);
      expect(find.text('Сабра в диалоге'), findsOneWidget);
      expect(find.text('Железная память'), findsOneWidget);
      expect(find.text('Охотник за корнями'), findsOneWidget);
      expect(find.text('Сундук Сабры'), findsOneWidget);
      expect(find.text('Выполнено 0/3 квестов дня'), findsOneWidget);
    });

    testWidgets('позволяет забрать награду за выполненный квест', (tester) async {
      int claimedXp = 0;
      var state = SabraQuestService.generateDefaultQuests(
        date: DateTime(2026, 11, 22),
        streakDays: 2,
      );
      state = SabraQuestService.updateProgress(
        current: state,
        type: SabraQuestType.conversational,
        increment: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SabraDailyQuestsCard(
                initialState: state,
                streakDays: 2,
                onXpClaimed: (xp) => claimedXp += xp,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Кнопка "Забрать +50 XP"
      final claimBtn = find.text('+50 XP');
      expect(claimBtn, findsOneWidget);

      await tester.tap(claimBtn);
      await tester.pumpAndSettle();

      expect(claimedXp, equals(50));
      expect(find.text('Забрано'), findsOneWidget);
    });

    testWidgets('разблокирует сундук при выполнении всех 3 квестов и начисляет +100 XP', (tester) async {
      int claimedXp = 0;
      var state = SabraQuestService.generateDefaultQuests(
        date: DateTime(2026, 11, 22),
        streakDays: 14,
      );
      state = SabraQuestService.updateProgress(
        current: state,
        type: SabraQuestType.conversational,
        increment: 1,
      );
      state = SabraQuestService.updateProgress(
        current: state,
        type: SabraQuestType.ironMemory,
        absoluteCount: 10,
      );
      state = SabraQuestService.updateProgress(
        current: state,
        type: SabraQuestType.shoreshHunter,
        increment: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SabraDailyQuestsCard(
                initialState: state,
                streakDays: 14,
                onXpClaimed: (xp) => claimedXp += xp,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final openChestBtn = find.text('Открыть! 🎁');
      expect(openChestBtn, findsOneWidget);

      await tester.tap(openChestBtn);
      await tester.pumpAndSettle();

      expect(claimedXp, equals(100));
      expect(find.text('Бонус дня забран! Отличная работа!'), findsOneWidget);
    });
  });
}
