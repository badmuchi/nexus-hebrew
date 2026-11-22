import 'dart:math' as math;

import '../../../../core/database/app_database.dart';
import '../entities/fsrs_analytics_data.dart';

/// Lightweight representation of a card for FSRS calculations.
final class FsrsCardItem {
  final double stability;
  final double difficulty;
  final int reps;
  final int lapses;
  final DateTime dueAt;
  final DateTime? lastReviewedAt;
  final String fsrsState;

  const FsrsCardItem({
    required this.stability,
    required this.difficulty,
    required this.reps,
    required this.lapses,
    required this.dueAt,
    this.lastReviewedAt,
    required this.fsrsState,
  });

  factory FsrsCardItem.fromRow(SrsCardRow row) {
    return FsrsCardItem(
      stability: row.stability,
      difficulty: row.difficulty,
      reps: row.reps,
      lapses: row.lapses,
      dueAt: row.dueAt,
      lastReviewedAt: row.lastReviewedAt,
      fsrsState: row.fsrsState,
    );
  }
}

/// Lightweight representation of a review log for FSRS calculations.
final class FsrsReviewLogItem {
  final int rating;
  final DateTime reviewedAt;

  const FsrsReviewLogItem({
    required this.rating,
    required this.reviewedAt,
  });

  factory FsrsReviewLogItem.fromRow(SrsReviewLogRow row) {
    return FsrsReviewLogItem(
      rating: row.rating,
      reviewedAt: row.reviewedAt,
    );
  }
}

/// Service computing FSRS retention decay curves, memory stability distribution,
/// and review load forecasts.
final class FsrsAnalyticsCalculator {
  const FsrsAnalyticsCalculator();

  static const List<String> _kRussianWeekdays = [
    'Пн',
    'Вт',
    'Ср',
    'Чт',
    'Пт',
    'Сб',
    'Вс',
  ];

  /// Computes comprehensive FSRS memory statistics as of [asOf].
  static FsrsAnalyticsData compute({
    required List<FsrsCardItem> cards,
    required List<FsrsReviewLogItem> logs,
    required DateTime asOf,
  }) {
    if (cards.isEmpty) {
      return _emptyAnalytics(asOf);
    }

    final stabilityMap = <FsrsStabilityTier, int>{
      FsrsStabilityTier.unlearned: 0,
      FsrsStabilityTier.shortTerm: 0,
      FsrsStabilityTier.mediumTerm: 0,
      FsrsStabilityTier.longTerm: 0,
      FsrsStabilityTier.permanent: 0,
    };

    final difficultyMap = <FsrsDifficultyTier, int>{
      FsrsDifficultyTier.easy: 0,
      FsrsDifficultyTier.medium: 0,
      FsrsDifficultyTier.hard: 0,
    };

    var unlearnedCount = 0;
    var totalLapses = 0;
    var learnedStabilitySum = 0.0;
    var learnedDifficultySum = 0.0;
    var learnedCount = 0;
    var retentionSum = 0.0;
    var retentionCount = 0;

    for (final card in cards) {
      totalLapses += card.lapses;

      final isUnlearned = card.stability <= 0.0 || card.fsrsState == 'newCard';
      if (isUnlearned) {
        unlearnedCount++;
        stabilityMap[FsrsStabilityTier.unlearned] =
            (stabilityMap[FsrsStabilityTier.unlearned] ?? 0) + 1;
      } else {
        learnedCount++;
        learnedStabilitySum += card.stability;
        learnedDifficultySum += card.difficulty;

        // Stability Tier classification
        if (card.stability < 3.0) {
          stabilityMap[FsrsStabilityTier.shortTerm] =
              (stabilityMap[FsrsStabilityTier.shortTerm] ?? 0) + 1;
        } else if (card.stability < 21.0) {
          stabilityMap[FsrsStabilityTier.mediumTerm] =
              (stabilityMap[FsrsStabilityTier.mediumTerm] ?? 0) + 1;
        } else if (card.stability < 90.0) {
          stabilityMap[FsrsStabilityTier.longTerm] =
              (stabilityMap[FsrsStabilityTier.longTerm] ?? 0) + 1;
        } else {
          stabilityMap[FsrsStabilityTier.permanent] =
              (stabilityMap[FsrsStabilityTier.permanent] ?? 0) + 1;
        }

        // Difficulty Tier classification
        if (card.difficulty < 4.0) {
          difficultyMap[FsrsDifficultyTier.easy] =
              (difficultyMap[FsrsDifficultyTier.easy] ?? 0) + 1;
        } else if (card.difficulty < 7.0) {
          difficultyMap[FsrsDifficultyTier.medium] =
              (difficultyMap[FsrsDifficultyTier.medium] ?? 0) + 1;
        } else {
          difficultyMap[FsrsDifficultyTier.hard] =
              (difficultyMap[FsrsDifficultyTier.hard] ?? 0) + 1;
        }

        // Current Retrievability: R(t) = 0.9^(t / S)
        if (card.lastReviewedAt != null) {
          final elapsedDays = math.max(
            0.0,
            asOf.difference(card.lastReviewedAt!).inHours / 24.0,
          );
          final cardR = math.pow(0.9, elapsedDays / card.stability).toDouble();
          retentionSum += cardR.clamp(0.0, 1.0);
          retentionCount++;
        }
      }
    }

    final averageStability =
        learnedCount > 0 ? learnedStabilitySum / learnedCount : 0.0;
    final averageDifficulty =
        learnedCount > 0 ? learnedDifficultySum / learnedCount : 0.0;
    final currentRetentionRate =
        retentionCount > 0 ? retentionSum / retentionCount : 0.90;

    // Historical review success rate (Ratings 3 Good and 4 Easy are considered successes)
    var successReviews = 0;
    for (final log in logs) {
      if (log.rating >= 3) {
        successReviews++;
      }
    }
    final historicalSuccessRate =
        logs.isNotEmpty ? successReviews / logs.length : 0.90;

    // 14-Day Forecast of due cards
    final forecastDays = <FsrsForecastDay>[];
    final asOfDate = DateTime(asOf.year, asOf.month, asOf.day);

    for (var i = 0; i < 14; i++) {
      final targetDate = asOfDate.add(Duration(days: i));
      final nextDay = targetDate.add(const Duration(days: 1));

      var dayDueCount = 0;
      for (final card in cards) {
        if (card.fsrsState == 'newCard') continue;

        if (i == 0) {
          // Today: all cards due on or before today
          if (card.dueAt.isBefore(nextDay)) {
            dayDueCount++;
          }
        } else {
          // Future days: cards due strictly on targetDate
          if (!card.dueAt.isBefore(targetDate) && card.dueAt.isBefore(nextDay)) {
            dayDueCount++;
          }
        }
      }

      final dayLabel = i == 0
          ? 'Сегодня'
          : i == 1
              ? 'Завтра'
              : _kRussianWeekdays[targetDate.weekday - 1];

      forecastDays.add(
        FsrsForecastDay(
          date: targetDate,
          dueCount: dayDueCount,
          dayLabel: dayLabel,
          isToday: i == 0,
        ),
      );
    }

    // Retrievability Decay Curve Points for day 0 to 30
    final curveStability = averageStability > 0 ? averageStability : 7.0;
    final retentionCurvePoints = List<double>.generate(31, (day) {
      final r = math.pow(0.9, day / curveStability).toDouble();
      return r.clamp(0.0, 1.0);
    });

    return FsrsAnalyticsData(
      totalCards: cards.length,
      unlearnedCards: unlearnedCount,
      cardsByStabilityTier: stabilityMap,
      cardsByDifficultyTier: difficultyMap,
      averageStabilityDays: averageStability,
      averageDifficulty: averageDifficulty,
      currentRetentionRate: currentRetentionRate,
      historicalSuccessRate: historicalSuccessRate,
      totalLapses: totalLapses,
      totalReviews: logs.length,
      forecastDays: forecastDays,
      retentionCurvePoints: retentionCurvePoints,
    );
  }

  static FsrsAnalyticsData _emptyAnalytics(DateTime asOf) {
    final asOfDate = DateTime(asOf.year, asOf.month, asOf.day);
    return FsrsAnalyticsData(
      totalCards: 0,
      unlearnedCards: 0,
      cardsByStabilityTier: const {
        FsrsStabilityTier.unlearned: 0,
        FsrsStabilityTier.shortTerm: 0,
        FsrsStabilityTier.mediumTerm: 0,
        FsrsStabilityTier.longTerm: 0,
        FsrsStabilityTier.permanent: 0,
      },
      cardsByDifficultyTier: const {
        FsrsDifficultyTier.easy: 0,
        FsrsDifficultyTier.medium: 0,
        FsrsDifficultyTier.hard: 0,
      },
      averageStabilityDays: 0.0,
      averageDifficulty: 0.0,
      currentRetentionRate: 0.9,
      historicalSuccessRate: 1.0,
      totalLapses: 0,
      totalReviews: 0,
      forecastDays: List.generate(
        14,
        (i) => FsrsForecastDay(
          date: asOfDate.add(Duration(days: i)),
          dueCount: 0,
          dayLabel: i == 0
              ? 'Сегодня'
              : i == 1
                  ? 'Завтра'
                  : _kRussianWeekdays[asOfDate.add(Duration(days: i)).weekday - 1],
          isToday: i == 0,
        ),
      ),
      retentionCurvePoints: List.generate(31, (_) => 1.0),
    );
  }
}
