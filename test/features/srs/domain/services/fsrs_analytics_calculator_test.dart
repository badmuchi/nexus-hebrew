import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/fsrs_analytics_data.dart';
import 'package:nexus_hebrew_app/features/srs/domain/services/fsrs_analytics_calculator.dart';

void main() {
  final now = DateTime(2026, 11, 22, 12, 0);

  group('FsrsAnalyticsCalculator', () {
    test('returns empty analytics when cards list is empty', () {
      final res = FsrsAnalyticsCalculator.compute(
        cards: const [],
        logs: const [],
        asOf: now,
      );

      expect(res.totalCards, equals(0));
      expect(res.unlearnedCards, equals(0));
      expect(res.averageStabilityDays, equals(0.0));
      expect(res.currentRetentionRate, equals(0.9));
      expect(res.forecastDays.length, equals(14));
      expect(res.retentionCurvePoints.length, equals(31));
    });

    test('correctly calculates stability tiers and averages', () {
      final cards = [
        FsrsCardItem(
          stability: 0.0,
          difficulty: 0.0,
          reps: 0,
          lapses: 0,
          dueAt: now,
          fsrsState: 'newCard',
        ),
        FsrsCardItem(
          stability: 1.5,
          difficulty: 2.5,
          reps: 1,
          lapses: 0,
          dueAt: now,
          lastReviewedAt: now.subtract(const Duration(hours: 12)),
          fsrsState: 'learning',
        ),
        FsrsCardItem(
          stability: 10.0,
          difficulty: 5.0,
          reps: 3,
          lapses: 1,
          dueAt: now.add(const Duration(days: 3)),
          lastReviewedAt: now.subtract(const Duration(days: 2)),
          fsrsState: 'review',
        ),
        FsrsCardItem(
          stability: 50.0,
          difficulty: 7.5,
          reps: 6,
          lapses: 0,
          dueAt: now.add(const Duration(days: 20)),
          lastReviewedAt: now.subtract(const Duration(days: 5)),
          fsrsState: 'review',
        ),
        FsrsCardItem(
          stability: 120.0,
          difficulty: 8.5,
          reps: 10,
          lapses: 2,
          dueAt: now.add(const Duration(days: 60)),
          lastReviewedAt: now.subtract(const Duration(days: 10)),
          fsrsState: 'review',
        ),
      ];

      final logs = [
        FsrsReviewLogItem(rating: 3, reviewedAt: now.subtract(const Duration(days: 2))),
        FsrsReviewLogItem(rating: 4, reviewedAt: now.subtract(const Duration(days: 1))),
        FsrsReviewLogItem(rating: 1, reviewedAt: now.subtract(const Duration(hours: 12))),
      ];

      final res = FsrsAnalyticsCalculator.compute(
        cards: cards,
        logs: logs,
        asOf: now,
      );

      expect(res.totalCards, equals(5));
      expect(res.unlearnedCards, equals(1));
      expect(res.cardsByStabilityTier[FsrsStabilityTier.unlearned], equals(1));
      expect(res.cardsByStabilityTier[FsrsStabilityTier.shortTerm], equals(1));
      expect(res.cardsByStabilityTier[FsrsStabilityTier.mediumTerm], equals(1));
      expect(res.cardsByStabilityTier[FsrsStabilityTier.longTerm], equals(1));
      expect(res.cardsByStabilityTier[FsrsStabilityTier.permanent], equals(1));

      // Difficulty tiers for 4 learned cards: 1 easy (2.5), 1 medium (5.0), 2 hard (7.5, 8.5)
      expect(res.cardsByDifficultyTier[FsrsDifficultyTier.easy], equals(1));
      expect(res.cardsByDifficultyTier[FsrsDifficultyTier.medium], equals(1));
      expect(res.cardsByDifficultyTier[FsrsDifficultyTier.hard], equals(2));

      // Average stability of learned cards: (1.5 + 10 + 50 + 120) / 4 = 181.5 / 4 = 45.375
      expect(res.averageStabilityDays, closeTo(45.375, 0.001));

      // Lapses: 0 + 0 + 1 + 0 + 2 = 3
      expect(res.totalLapses, equals(3));

      // Historical success rate: 2 out of 3 logs are >= 3 (Good/Easy) -> 2/3 ~ 0.666
      expect(res.historicalSuccessRate, closeTo(2 / 3, 0.01));

      // Current retention rate should be between 0.85 and 1.0
      expect(res.currentRetentionRate, inInclusiveRange(0.85, 1.0));

      // Forecast: Today (cards due now or in the past) has 1 card
      expect(res.forecastDays.first.dueCount, greaterThanOrEqualTo(1));
    });
  });
}
