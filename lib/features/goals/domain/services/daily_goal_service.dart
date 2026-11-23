import 'dart:convert';

import '../../../../core/settings/app_settings_storage.dart';
import '../entities/daily_goal.dart';

/// Service managing daily learning goal progress, ring state, and habit streaks.
final class DailyGoalService {
  final AppSettingsStorage? _storage;

  const DailyGoalService({AppSettingsStorage? storage}) : _storage = storage;

  /// Formats date to deterministic YYYY-MM-DD key.
  static String dateToKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Calculates streak continuation between last active date and current date.
  static int calculateNextStreak({
    required DateTime currentDate,
    required DateTime lastActiveDate,
    required int currentStreak,
    required bool wasLastGoalCompleted,
  }) {
    final curZero = DateTime(currentDate.year, currentDate.month, currentDate.day);
    final lastZero = DateTime(lastActiveDate.year, lastActiveDate.month, lastActiveDate.day);
    final diffDays = curZero.difference(lastZero).inDays;

    if (diffDays == 0) {
      // Same day, streak remains
      return currentStreak;
    } else if (diffDays == 1) {
      // Consecutive day!
      return wasLastGoalCompleted ? currentStreak + 1 : currentStreak;
    } else {
      // Missed more than 1 day
      return 1;
    }
  }

  /// Loads today's daily goal progress from storage or initializes a fresh one.
  Future<DailyGoalProgress> loadGoalProgress({DateTime? now}) async {
    final currentMoment = now ?? DateTime.now();
    final todayKey = dateToKey(currentMoment);

    if (_storage == null) {
      return DailyGoalProgress(
        dateKey: todayKey,
        lastUpdated: currentMoment,
      );
    }

    try {
      final raw = await _storage.readDailyGoalJson();
      if (raw != null && raw.trim().isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final storedProgress = DailyGoalProgress.fromJson(decoded);

        if (storedProgress.dateKey == todayKey) {
          return storedProgress;
        }

        // New day: compute streak
        final newStreak = calculateNextStreak(
          currentDate: currentMoment,
          lastActiveDate: storedProgress.lastUpdated,
          currentStreak: storedProgress.streakDays,
          wasLastGoalCompleted: storedProgress.isAllGoalsMet || storedProgress.closedRingsCount >= 1,
        );

        final freshToday = DailyGoalProgress(
          dateKey: todayKey,
          intensity: storedProgress.intensity,
          cardsReviewed: 0,
          practiceMinutes: 0,
          questsCompleted: 0,
          streakDays: newStreak,
          lastUpdated: currentMoment,
        );

        await _storage.writeDailyGoalJson(jsonEncode(freshToday.toJson()));
        return freshToday;
      }
    } catch (_) {
      // Fallback on decode failure
    }

    final initial = DailyGoalProgress(
      dateKey: todayKey,
      intensity: DailyGoalIntensity.regular,
      cardsReviewed: 0,
      practiceMinutes: 0,
      questsCompleted: 0,
      streakDays: 1,
      lastUpdated: currentMoment,
    );

    await _storage.writeDailyGoalJson(jsonEncode(initial.toJson()));
    return initial;
  }

  /// Records activity increments (cards, minutes, quests) and persists to storage.
  Future<DailyGoalProgress> recordActivity({
    int cardsDelta = 0,
    int minutesDelta = 0,
    int questsDelta = 0,
    DateTime? now,
  }) async {
    final current = await loadGoalProgress(now: now);
    final moment = now ?? DateTime.now();

    final updated = current.copyWith(
      cardsReviewed: (current.cardsReviewed + cardsDelta).clamp(0, 9999),
      practiceMinutes: (current.practiceMinutes + minutesDelta).clamp(0, 9999),
      questsCompleted: (current.questsCompleted + questsDelta).clamp(0, 9999),
      lastUpdated: moment,
    );

    if (_storage != null) {
      await _storage.writeDailyGoalJson(jsonEncode(updated.toJson()));
    }

    return updated;
  }

  /// Changes the goal intensity level (e.g. casual -> regular -> serious -> ulpanHero).
  Future<DailyGoalProgress> updateIntensity(
    DailyGoalIntensity intensity, {
    DateTime? now,
  }) async {
    final current = await loadGoalProgress(now: now);
    final updated = current.copyWith(
      intensity: intensity,
      lastUpdated: now ?? DateTime.now(),
    );

    if (_storage != null) {
      await _storage.writeDailyGoalJson(jsonEncode(updated.toJson()));
    }

    return updated;
  }
}
