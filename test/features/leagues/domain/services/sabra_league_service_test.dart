import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/leagues/domain/entities/sabra_league.dart';
import 'package:nexus_hebrew_app/features/leagues/domain/services/sabra_league_service.dart';

void main() {
  group('SabraLeagueService', () {
    late InMemorySabraLeagueStorage storage;
    late SabraLeagueService service;

    setUp(() {
      storage = InMemorySabraLeagueStorage();
      service = SabraLeagueService(storage: storage);
    });

    test('loadLeagueState creates initial Bronze league with cohort and persists', () async {
      final state = await service.loadLeagueState(now: DateTime(2026, 11, 23));

      expect(state.tier, SabraLeagueTier.bronze);
      expect(state.userWeeklyXp, 45);
      expect(state.leaderboard, isNotEmpty);
      expect(state.leaderboard.any((m) => m.isCurrentUser), isTrue);

      final raw = await storage.readLeagueJson();
      expect(raw, contains('bronze'));
    });

    test('recordXp increments points, recalculates leaderboard ranking, and updates cache', () async {
      final initial = await service.loadLeagueState(now: DateTime(2026, 11, 23));
      final initialRank = initial.userRank;

      // Add a large amount of XP to reach #1
      final updated = await service.recordXp(500, now: DateTime(2026, 11, 23));

      expect(updated.userWeeklyXp, initial.userWeeklyXp + 500);
      expect(updated.userRank, 1);
      expect(updated.isPromotionZone, isTrue);

      final currentUser = updated.leaderboard.firstWhere((m) => m.isCurrentUser);
      expect(currentUser.rank, 1);
      expect(currentUser.rankChange, initialRank - 1);
    });

    test('advanceToNextTier transitions from Bronze to Silver tier', () async {
      await service.loadLeagueState(now: DateTime(2026, 11, 23));
      final promoted = await service.advanceToNextTier(now: DateTime(2026, 11, 23));

      expect(promoted.tier, SabraLeagueTier.silver);
      expect(promoted.leaderboard, isNotEmpty);
    });

    test('daysRemainingInWeek accurately calculates days until Shabbat', () {
      // Dart DateTime: 2026-11-22 is Sunday (weekday 7) -> 6 days remaining in Israel week
      final sunday = DateTime(2026, 11, 22);
      expect(SabraLeagueService.daysRemainingInWeek(sunday), 6);

      // 2026-11-28 is Saturday (weekday 6) -> 0 days remaining
      final saturday = DateTime(2026, 11, 28);
      expect(SabraLeagueService.daysRemainingInWeek(saturday), 0);
    });
  });
}
