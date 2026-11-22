import 'dart:convert';

import '../../../../core/settings/app_settings_storage.dart';
import '../entities/sabra_quest.dart';

/// Service managing daily Sabra quests lifecycle, progress increments,
/// reward claiming, and local storage synchronization.
final class SabraQuestService {
  final AppSettingsStorage? _storage;

  const SabraQuestService({AppSettingsStorage? storage}) : _storage = storage;

  /// Formats date to deterministic YYYY-MM-DD key.
  static String dateToKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Generates the initial 3 Sabra quests for a given day and streak.
  static SabraDailyQuestsState generateDefaultQuests({
    required DateTime date,
    required int streakDays,
  }) {
    final key = dateToKey(date);
    return SabraDailyQuestsState(
      dateKey: key,
      streakDays: streakDays,
      chestRewardXp: 100,
      isChestClaimed: false,
      quests: [
        SabraQuest(
          id: '${key}_${SabraQuestType.conversational.id}',
          type: SabraQuestType.conversational,
          targetCount: SabraQuestType.conversational.defaultTarget,
          xpReward: SabraQuestType.conversational.defaultXp,
        ),
        SabraQuest(
          id: '${key}_${SabraQuestType.ironMemory.id}',
          type: SabraQuestType.ironMemory,
          targetCount: SabraQuestType.ironMemory.defaultTarget,
          xpReward: SabraQuestType.ironMemory.defaultXp,
        ),
        SabraQuest(
          id: '${key}_${SabraQuestType.shoreshHunter.id}',
          type: SabraQuestType.shoreshHunter,
          targetCount: SabraQuestType.shoreshHunter.defaultTarget,
          xpReward: SabraQuestType.shoreshHunter.defaultXp,
        ),
      ],
    );
  }

  /// Updates quest progress by type (either adding [increment] or setting [absoluteCount]).
  static SabraDailyQuestsState updateProgress({
    required SabraDailyQuestsState current,
    required SabraQuestType type,
    int increment = 1,
    int? absoluteCount,
  }) {
    final updatedQuests = current.quests.map((q) {
      if (q.type != type) return q;
      final newCount = absoluteCount ?? (q.currentCount + increment);
      return q.copyWith(currentCount: newCount.clamp(0, 9999));
    }).toList();

    return current.copyWith(quests: updatedQuests);
  }

  /// Claims reward for a single completed quest. Returns updated state and earned XP.
  static (SabraDailyQuestsState, int xpEarned) claimQuest({
    required SabraDailyQuestsState current,
    required String questId,
  }) {
    int earned = 0;
    final updatedQuests = current.quests.map((q) {
      if (q.id == questId && q.isCompleted && !q.isClaimed) {
        earned = q.xpReward;
        return q.copyWith(isClaimed: true);
      }
      return q;
    }).toList();

    return (current.copyWith(quests: updatedQuests), earned);
  }

  /// Claims the daily Sabra bonus chest when all 3 quests are complete.
  static (SabraDailyQuestsState, int xpEarned) claimChest({
    required SabraDailyQuestsState current,
  }) {
    if (!current.canClaimChest) {
      return (current, 0);
    }
    final updated = current.copyWith(isChestClaimed: true);
    return (updated, current.chestRewardXp);
  }

  /// Loads today's state from storage or creates a fresh state for today.
  Future<SabraDailyQuestsState> loadOrCreateToday({
    DateTime? now,
    int currentStreak = 0,
  }) async {
    final date = now ?? DateTime.now();
    final todayKey = dateToKey(date);

    if (_storage != null) {
      final raw = await _storage.readSabraQuestsJson();
      if (raw != null && raw.trim().isNotEmpty) {
        try {
          final decoded = jsonDecode(raw) as Map<String, dynamic>;
          final parsed = SabraDailyQuestsState.fromJson(decoded);
          if (parsed.dateKey == todayKey) {
            // Keep streak updated
            return parsed.copyWith(streakDays: currentStreak);
          }
        } on Object {
          // If corrupted, fallback to fresh
        }
      }
    }

    final fresh = generateDefaultQuests(date: date, streakDays: currentStreak);
    if (_storage != null) {
      await saveState(fresh);
    }
    return fresh;
  }

  /// Persists the quest state to storage.
  Future<void> saveState(SabraDailyQuestsState state) async {
    if (_storage == null) return;
    final encoded = jsonEncode(state.toJson());
    await _storage.writeSabraQuestsJson(encoded);
  }
}
