import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/goals/domain/entities/daily_goal.dart';
import 'package:nexus_hebrew_app/features/goals/presentation/widgets/daily_goal_rings_card.dart';
import 'package:nexus_hebrew_app/features/goals/presentation/widgets/goal_settings_sheet.dart';

void main() {
  testWidgets('renders DailyGoalRingsCard with Hebrew title, rings and target counters', (tester) async {
    final progress = DailyGoalProgress(
      dateKey: '2026-11-23',
      intensity: DailyGoalIntensity.regular,
      cardsReviewed: 10,
      practiceMinutes: 15,
      questsCompleted: 1,
      streakDays: 4,
      lastUpdated: DateTime(2026, 11, 23, 14, 0),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DailyGoalRingsCard(progress: progress),
        ),
      ),
    );

    // Title with RTL Hebrew
    expect(find.text('יַעַד יוֹמִי וְהֶרְגֵּלִים'), findsOneWidget);
    expect(find.text('Оптимальный'), findsOneWidget);
    expect(find.textContaining('Стрик: 4 дн.'), findsOneWidget);

    // Ring target texts
    expect(find.text('Карточки FSRS'), findsOneWidget);
    expect(find.text('Минуты практики'), findsOneWidget);
    expect(find.text('Квесты Сабры'), findsOneWidget);

    expect(find.text('10 / 20 шт.'), findsOneWidget);
    expect(find.text('15 / 15 мин'), findsOneWidget);
    expect(find.text('1 / 2 кв.'), findsOneWidget);

    // Check completed count & overall percent
    expect(find.text('1/3'), findsOneWidget); // only minutes closed
    expect(find.textContaining('67%'), findsOneWidget); // (0.5 + 1.0 + 0.5) / 3 = 66.6% -> 67%

    // Incomplete goal: no celebration banner yet
    expect(find.textContaining('כָּל הַכָּבוֹד! הַיַּעַד הַיּוֹמִי הֻשְׁלַם!'), findsNothing);
  });

  testWidgets('displays celebration banner when all 3 daily rings are closed', (tester) async {
    final fullProgress = DailyGoalProgress(
      dateKey: '2026-11-23',
      intensity: DailyGoalIntensity.regular,
      cardsReviewed: 20,
      practiceMinutes: 15,
      questsCompleted: 2,
      streakDays: 12,
      lastUpdated: DateTime(2026, 11, 23, 20, 0),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DailyGoalRingsCard(progress: fullProgress),
        ),
      ),
    );

    expect(find.text('3/3'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.textContaining('כָּל הַכָּבוֹד! הַיַּעַד הַיּוֹמִי הֻשְׁלַם!'), findsOneWidget);
    expect(find.textContaining('Все 3 кольца активности закрыты. Стрик непрерывен!'), findsOneWidget);
  });

  testWidgets('tapping settings button opens GoalSettingsSheet and updates intensity', (tester) async {
    DailyGoalIntensity? selected;
    final progress = DailyGoalProgress(
      dateKey: '2026-11-23',
      intensity: DailyGoalIntensity.regular,
      cardsReviewed: 5,
      practiceMinutes: 5,
      questsCompleted: 0,
      streakDays: 2,
      lastUpdated: DateTime(2026, 11, 23, 10, 0),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DailyGoalRingsCard(
            progress: progress,
            onIntensityChanged: (val) => selected = val,
          ),
        ),
      ),
    );

    final settingsButton = find.byTooltip('Настроить цель');
    expect(settingsButton, findsOneWidget);
    await tester.tap(settingsButton);
    await tester.pumpAndSettle();

    // GoalSettingsSheet is now visible
    expect(find.byType(GoalSettingsSheet), findsOneWidget);
    expect(find.text('Настройка дневной цели'), findsOneWidget);

    // Tap 'Интенсивный' (serious)
    final seriousTile = find.text('Интенсивный');
    expect(seriousTile, findsOneWidget);
    await tester.tap(seriousTile);
    await tester.pumpAndSettle();

    expect(selected, DailyGoalIntensity.serious);
  });
}
