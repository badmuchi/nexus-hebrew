import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/core/settings/app_settings_storage.dart';
import 'package:nexus_hebrew_app/features/gamification/domain/entities/sabra_quest.dart';
import 'package:nexus_hebrew_app/features/gamification/domain/services/sabra_quest_service.dart';

class _FakeSettingsStorage implements AppSettingsStorage {
  String? sabraJson;
  int streak = 0;

  @override
  Future<String?> readSabraQuestsJson() async => sabraJson;
  @override
  Future<void> writeSabraQuestsJson(String json) async => sabraJson = json;
  @override
  Future<int> readSabraStreakDays() async => streak;
  @override
  Future<void> writeSabraStreakDays(int days) async => streak = days;
  @override
  Future<String?> readDailyGoalJson() async => null;
  @override
  Future<void> writeDailyGoalJson(String json) async {}

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
  Future<void> writeThemeMode(ThemeMode mode) async {}
}

void main() {
  group('SabraQuestService', () {
    final testDate = DateTime(2026, 11, 22);

    test('generateDefaultQuests создает 3 квеста для указанной даты', () {
      final state = SabraQuestService.generateDefaultQuests(
        date: testDate,
        streakDays: 4,
      );

      expect(state.dateKey, equals('2026-11-22'));
      expect(state.streakDays, equals(4));
      expect(state.streakStage, equals(SabraStreakStage.youngCactus));
      expect(state.quests.length, equals(3));
      expect(state.allQuestsCompleted, isFalse);
      expect(state.canClaimChest, isFalse);
    });

    test('updateProgress корректно обновляет счетчик квеста', () {
      var state = SabraQuestService.generateDefaultQuests(
        date: testDate,
        streakDays: 7,
      );

      // Инкремент разговорного квеста
      state = SabraQuestService.updateProgress(
        current: state,
        type: SabraQuestType.conversational,
        increment: 1,
      );

      final convQuest = state.quests.firstWhere((q) => q.type == SabraQuestType.conversational);
      expect(convQuest.currentCount, equals(1));
      expect(convQuest.isCompleted, isTrue);
      expect(convQuest.canClaim, isTrue);

      // Инкремент FSRS квеста
      state = SabraQuestService.updateProgress(
        current: state,
        type: SabraQuestType.ironMemory,
        absoluteCount: 10,
      );
      final srsQuest = state.quests.firstWhere((q) => q.type == SabraQuestType.ironMemory);
      expect(srsQuest.currentCount, equals(10));
      expect(srsQuest.isCompleted, isTrue);
    });

    test('claimQuest начисляет XP и помечает квест как забранный только один раз', () {
      var state = SabraQuestService.generateDefaultQuests(
        date: testDate,
        streakDays: 1,
      );

      state = SabraQuestService.updateProgress(
        current: state,
        type: SabraQuestType.conversational,
        increment: 1,
      );

      final qId = state.quests.firstWhere((q) => q.type == SabraQuestType.conversational).id;

      // Первое забирание
      final (updatedState1, earnedXp1) = SabraQuestService.claimQuest(
        current: state,
        questId: qId,
      );
      expect(earnedXp1, equals(50));
      expect(updatedState1.quests.first.isClaimed, isTrue);

      // Повторное забирание дает 0 XP
      final (_, earnedXp2) = SabraQuestService.claimQuest(
        current: updatedState1,
        questId: qId,
      );
      expect(earnedXp2, equals(0));
    });

    test('claimChest доступен только при завершении всех 3 квестов', () {
      var state = SabraQuestService.generateDefaultQuests(
        date: testDate,
        streakDays: 5,
      );

      // Попытка открыть сундук до завершения квестов
      final (stateFail, xpFail) = SabraQuestService.claimChest(current: state);
      expect(xpFail, equals(0));
      expect(stateFail.isChestClaimed, isFalse);

      // Завершаем все 3 квеста
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

      expect(state.allQuestsCompleted, isTrue);
      expect(state.canClaimChest, isTrue);

      // Забираем сундук
      final (stateSuccess, xpSuccess) = SabraQuestService.claimChest(current: state);
      expect(xpSuccess, equals(100));
      expect(stateSuccess.isChestClaimed, isTrue);
      expect(stateSuccess.canClaimChest, isFalse);
    });

    test('SabraStreakStage корректно вычисляет стадии роста кактуса', () {
      expect(SabraStreakStage.fromDays(0), equals(SabraStreakStage.sprout));
      expect(SabraStreakStage.fromDays(2), equals(SabraStreakStage.sprout));
      expect(SabraStreakStage.fromDays(3), equals(SabraStreakStage.youngCactus));
      expect(SabraStreakStage.fromDays(6), equals(SabraStreakStage.youngCactus));
      expect(SabraStreakStage.fromDays(7), equals(SabraStreakStage.flowering));
      expect(SabraStreakStage.fromDays(13), equals(SabraStreakStage.flowering));
      expect(SabraStreakStage.fromDays(14), equals(SabraStreakStage.fruitSabra));
      expect(SabraStreakStage.fromDays(100), equals(SabraStreakStage.fruitSabra));
    });

    test('loadOrCreateToday сохраняет и загружает данные из storage', () async {
      final fakeStorage = _FakeSettingsStorage();
      final service = SabraQuestService(storage: fakeStorage);

      final state1 = await service.loadOrCreateToday(now: testDate, currentStreak: 3);
      expect(state1.dateKey, equals('2026-11-22'));
      expect(state1.streakDays, equals(3));
      expect(fakeStorage.sabraJson, isNotNull);

      // Обновляем состояние и сохраняем
      final updated = SabraQuestService.updateProgress(
        current: state1,
        type: SabraQuestType.conversational,
        increment: 1,
      );
      await service.saveState(updated);

      // Загружаем снова
      final state2 = await service.loadOrCreateToday(now: testDate, currentStreak: 3);
      expect(state2.quests.first.currentCount, equals(1));
    });
  });
}
