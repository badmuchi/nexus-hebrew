import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/goals/domain/entities/daily_goal.dart';

void main() {
  group('DailyGoalIntensity', () {
    test('Intensity levels have appropriate learning targets', () {
      expect(DailyGoalIntensity.casual.targetMinutes, 5);
      expect(DailyGoalIntensity.casual.targetCards, 10);
      expect(DailyGoalIntensity.casual.targetQuests, 1);
      expect(DailyGoalIntensity.casual.titleHebrewWithNikkud, 'קַל');

      expect(DailyGoalIntensity.regular.targetMinutes, 15);
      expect(DailyGoalIntensity.regular.targetCards, 20);
      expect(DailyGoalIntensity.regular.targetQuests, 2);
      expect(DailyGoalIntensity.regular.titleHebrewWithNikkud, 'רָגִיל');

      expect(DailyGoalIntensity.serious.targetMinutes, 30);
      expect(DailyGoalIntensity.serious.targetCards, 35);
      expect(DailyGoalIntensity.serious.targetQuests, 3);
      expect(DailyGoalIntensity.serious.titleHebrewWithNikkud, 'רְצִינִי');

      expect(DailyGoalIntensity.ulpanHero.targetMinutes, 45);
      expect(DailyGoalIntensity.ulpanHero.targetCards, 50);
      expect(DailyGoalIntensity.ulpanHero.targetQuests, 3);
      expect(DailyGoalIntensity.ulpanHero.titleHebrewWithNikkud, 'גִּבּוֹר אֻלְפָּן');
    });

    test('fromId returns correct enum or falls back to regular', () {
      expect(DailyGoalIntensity.fromId('casual'), DailyGoalIntensity.casual);
      expect(DailyGoalIntensity.fromId('ulpanHero'), DailyGoalIntensity.ulpanHero);
      expect(DailyGoalIntensity.fromId('unknown'), DailyGoalIntensity.regular);
      expect(DailyGoalIntensity.fromId(null), DailyGoalIntensity.regular);
    });
  });

  group('DailyGoalProgress', () {
    test('Calculates individual ring progress and closed states accurately', () {
      final now = DateTime(2026, 11, 23, 12, 0);
      final initial = DailyGoalProgress(
        dateKey: '2026-11-23',
        intensity: DailyGoalIntensity.regular, // target: 20 cards, 15 min, 2 quests
        cardsReviewed: 10,
        practiceMinutes: 15,
        questsCompleted: 0,
        lastUpdated: now,
      );

      expect(initial.cardsProgress, 0.5);
      expect(initial.isCardsRingClosed, isFalse);

      expect(initial.minutesProgress, 1.0);
      expect(initial.isMinutesRingClosed, isTrue);

      expect(initial.questsProgress, 0.0);
      expect(initial.isQuestsRingClosed, isFalse);

      expect(initial.closedRingsCount, 1);
      expect(initial.overallPercent, 50); // (0.5 + 1.0 + 0) / 3 = 50%
      expect(initial.isAllGoalsMet, isFalse);
    });

    test('isAllGoalsMet returns true when all 3 rings reach or exceed target', () {
      final full = DailyGoalProgress(
        dateKey: '2026-11-23',
        intensity: DailyGoalIntensity.regular,
        cardsReviewed: 25, // >= 20
        practiceMinutes: 20, // >= 15
        questsCompleted: 2, // >= 2
        streakDays: 5,
        lastUpdated: DateTime(2026, 11, 23, 18, 0),
      );

      expect(full.isCardsRingClosed, isTrue);
      expect(full.isMinutesRingClosed, isTrue);
      expect(full.isQuestsRingClosed, isTrue);
      expect(full.closedRingsCount, 3);
      expect(full.overallPercent, 100);
      expect(full.isAllGoalsMet, isTrue);
    });

    test('Serializes to and from JSON map correctly', () {
      final now = DateTime.utc(2026, 11, 23, 12, 0);
      final original = DailyGoalProgress(
        dateKey: '2026-11-23',
        intensity: DailyGoalIntensity.serious,
        cardsReviewed: 18,
        practiceMinutes: 25,
        questsCompleted: 1,
        streakDays: 7,
        lastUpdated: now,
      );

      final json = original.toJson();
      final restored = DailyGoalProgress.fromJson(json);

      expect(restored.dateKey, original.dateKey);
      expect(restored.intensity, original.intensity);
      expect(restored.cardsReviewed, original.cardsReviewed);
      expect(restored.practiceMinutes, original.practiceMinutes);
      expect(restored.questsCompleted, original.questsCompleted);
      expect(restored.streakDays, original.streakDays);
      expect(restored.lastUpdated.toIso8601String(), original.lastUpdated.toIso8601String());
    });
  });
}
