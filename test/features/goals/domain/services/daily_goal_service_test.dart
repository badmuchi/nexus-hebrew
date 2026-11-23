import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/core/settings/app_settings_storage.dart';
import 'package:nexus_hebrew_app/features/goals/domain/entities/daily_goal.dart';
import 'package:nexus_hebrew_app/features/goals/domain/services/daily_goal_service.dart';

class _FakeSettingsStorage implements AppSettingsStorage {
  String? dailyGoalJson;

  @override
  Future<String?> readDailyGoalJson() async => dailyGoalJson;

  @override
  Future<void> writeDailyGoalJson(String json) async => dailyGoalJson = json;

  @override
  Future<String?> readAssessedLevel() async => null;
  @override
  Future<DateTime?> readLastAssessmentDate() async => null;
  @override
  Future<DateTime?> readLastAudioPreloadDate() async => null;
  @override
  Future<DateTime?> readLastDailyWorkoutDate() async => null;
  @override
  Future<int> readOfflineCachedAudioCount() async => 0;
  @override
  Future<double> readPlaybackSpeed() async => 1.0;
  @override
  Future<String?> readSabraQuestsJson() async => null;
  @override
  Future<int> readSabraStreakDays() async => 0;
  @override
  Future<ThemeMode> readThemeMode() async => ThemeMode.system;
  @override
  Future<void> writeAssessedLevel(String level) async {}
  @override
  Future<void> writeLastAssessmentDate(DateTime date) async {}
  @override
  Future<void> writeLastAudioPreloadDate(DateTime date) async {}
  @override
  Future<void> writeLastDailyWorkoutDate(DateTime date) async {}
  @override
  Future<void> writeOfflineCachedAudioCount(int count) async {}
  @override
  Future<void> writePlaybackSpeed(double speed) async {}
  @override
  Future<void> writeSabraQuestsJson(String json) async {}
  @override
  Future<void> writeSabraStreakDays(int days) async {}
  @override
  Future<void> writeThemeMode(ThemeMode mode) async {}
}

void main() {
  group('DailyGoalService', () {
    test('dateToKey formats dates predictably', () {
      final date = DateTime(2026, 5, 4);
      expect(DailyGoalService.dateToKey(date), '2026-05-04');
    });

    test('calculateNextStreak handles same day, consecutive day, and missed days', () {
      final base = DateTime(2026, 11, 20);

      // Same day
      final sameDayStreak = DailyGoalService.calculateNextStreak(
        currentDate: base,
        lastActiveDate: base,
        currentStreak: 3,
        wasLastGoalCompleted: true,
      );
      expect(sameDayStreak, 3);

      // Next consecutive day with completed goal
      final nextDayStreak = DailyGoalService.calculateNextStreak(
        currentDate: DateTime(2026, 11, 21),
        lastActiveDate: base,
        currentStreak: 3,
        wasLastGoalCompleted: true,
      );
      expect(nextDayStreak, 4);

      // Missed 3 days
      final missedStreak = DailyGoalService.calculateNextStreak(
        currentDate: DateTime(2026, 11, 24),
        lastActiveDate: base,
        currentStreak: 5,
        wasLastGoalCompleted: true,
      );
      expect(missedStreak, 1);
    });

    test('loadGoalProgress initializes new day and increments activity', () async {
      final fakeStorage = _FakeSettingsStorage();
      final service = DailyGoalService(storage: fakeStorage);
      final today = DateTime(2026, 11, 23, 10, 0);

      // Initial load
      final initial = await service.loadGoalProgress(now: today);
      expect(initial.dateKey, '2026-11-23');
      expect(initial.intensity, DailyGoalIntensity.regular);
      expect(initial.cardsReviewed, 0);
      expect(initial.practiceMinutes, 0);
      expect(initial.questsCompleted, 0);

      // Record activity: +10 cards, +15 minutes, +1 quest
      final updated = await service.recordActivity(
        cardsDelta: 10,
        minutesDelta: 15,
        questsDelta: 1,
        now: today,
      );
      expect(updated.cardsReviewed, 10);
      expect(updated.practiceMinutes, 15);
      expect(updated.questsCompleted, 1);

      // Update intensity to serious
      final seriousGoal = await service.updateIntensity(DailyGoalIntensity.serious, now: today);
      expect(seriousGoal.intensity, DailyGoalIntensity.serious);
      expect(seriousGoal.targetMinutes, 30);
      expect(seriousGoal.targetCards, 35);
    });
  });
}
