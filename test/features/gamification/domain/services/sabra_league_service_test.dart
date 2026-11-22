import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/gamification/domain/entities/sabra_league.dart';
import 'package:nexus_hebrew_app/features/gamification/domain/services/sabra_league_service.dart';
import 'package:nexus_hebrew_app/features/progress/domain/entities/learning_progress_summary.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/fsrs_analytics_data.dart';

void main() {
  group('SabraLeagueService', () {
    test('resolveTier returns correct tier based on weekly XP boundaries', () {
      expect(SabraLeagueService.resolveTier(0), equals(SabraLeagueTier.sabra));
      expect(SabraLeagueService.resolveTier(299), equals(SabraLeagueTier.sabra));
      expect(SabraLeagueService.resolveTier(300), equals(SabraLeagueTier.jaffaOrange));
      expect(SabraLeagueService.resolveTier(799), equals(SabraLeagueTier.jaffaOrange));
      expect(SabraLeagueService.resolveTier(800), equals(SabraLeagueTier.galileeOlive));
      expect(SabraLeagueService.resolveTier(1600), equals(SabraLeagueTier.carmelGrape));
      expect(SabraLeagueService.resolveTier(3500), equals(SabraLeagueTier.jerusalemDate));
    });

    test('computeLeagueStatus generates leaderboard with user and competitors', () {
      final now = DateTime(2026, 11, 22);
      final status = SabraLeagueService.computeLeagueStatus(
        weeklyXp: 450,
        asOf: now,
      );

      expect(status.tier, equals(SabraLeagueTier.jaffaOrange));
      expect(status.weeklyXp, equals(450));
      expect(status.leaderboard.length, greaterThanOrEqualTo(10));

      // Leaderboard must be sorted descending by XP
      for (var i = 0; i < status.leaderboard.length - 1; i++) {
        expect(
          status.leaderboard[i].weeklyXp,
          greaterThanOrEqualTo(status.leaderboard[i + 1].weeklyXp),
        );
      }

      // Current user must be present in leaderboard
      final userEntry = status.leaderboard.firstWhere((c) => c.isCurrentUser);
      expect(userEntry.rank, equals(status.userRank));
      expect(userEntry.weeklyXp, equals(450));
    });

    test('evaluateMemoryBadges accurately computes unlocked state', () {
      const sampleAnalytics = FsrsAnalyticsData(
        totalCards: 35,
        unlearnedCards: 2,
        cardsByStabilityTier: {
          FsrsStabilityTier.unlearned: 2,
          FsrsStabilityTier.shortTerm: 5,
          FsrsStabilityTier.mediumTerm: 15,
          FsrsStabilityTier.longTerm: 7,
          FsrsStabilityTier.permanent: 6, // 6 >= 5 -> permanent vault unlocked!
        },
        cardsByDifficultyTier: {
          FsrsDifficultyTier.easy: 10,
          FsrsDifficultyTier.medium: 20,
          FsrsDifficultyTier.hard: 5,
        },
        averageStabilityDays: 32.0,
        averageDifficulty: 4.8,
        currentRetentionRate: 0.93, // >= 0.89 and 35 >= 10 -> iron memory unlocked!
        historicalSuccessRate: 0.91,
        totalLapses: 2,
        totalReviews: 60, // >= 50 -> review master unlocked!
        forecastDays: [],
        retentionCurvePoints: [],
      );

      final summary = LearningProgressSummary(
        totalSrsCards: 35,
        dueSrsCards: 2,
        newCards: 2,
        learningCards: 5,
        reviewCards: 28,
        relearningCards: 0,
        totalSrsReviews: 60,
        currentStreakDays: 8, // >= 7 -> streak unlocked!
        activeTodayCount: 12,
        grammarAttempts: 10,
        grammarCorrect: 9,
        binyanStats: const [],
        listeningAttempts: 5,
        listeningExactMatches: 4,
        averageListeningAccuracy: 0.9,
        fsrsAnalytics: sampleAnalytics,
      );

      final badges = SabraLeagueService.evaluateMemoryBadges(summary: summary);
      expect(badges.length, equals(5));

      final ironMemory = badges.firstWhere((b) => b.id == 'iron_memory');
      expect(ironMemory.isUnlocked, isTrue);

      final permanentVault = badges.firstWhere((b) => b.id == 'permanent_vault');
      expect(permanentVault.isUnlocked, isTrue);

      final streakBadge = badges.firstWhere((b) => b.id == 'srs_streak');
      expect(streakBadge.isUnlocked, isTrue);

      final reviewMaster = badges.firstWhere((b) => b.id == 'review_master');
      expect(reviewMaster.isUnlocked, isTrue);

      final sabraLexicon = badges.firstWhere((b) => b.id == 'sabra_lexicon');
      expect(sabraLexicon.isUnlocked, isTrue); // 35 >= 30
    });
  });
}
