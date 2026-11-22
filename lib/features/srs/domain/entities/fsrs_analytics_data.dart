import 'package:equatable/equatable.dart';

/// Memory stability intervals according to FSRS-4.5.
enum FsrsStabilityTier {
  unlearned('Новые', '0 дн', 0xFF9E9E9E),
  shortTerm('Краткосрочные', '< 3 дн', 0xFFFFA726),
  mediumTerm('Среднесрочные', '3–21 дн', 0xFF42A5F5),
  longTerm('Долгосрочные', '21–90 дн', 0xFF66BB6A),
  permanent('Перманентные', '≥ 90 дн', 0xFF7E57C2);

  final String labelRu;
  final String durationRange;
  final int colorValue;

  const FsrsStabilityTier(this.labelRu, this.durationRange, this.colorValue);
}

/// Difficulty spectrum of Hebrew vocabulary items (D in [1.0, 10.0]).
enum FsrsDifficultyTier {
  easy('Низкая сложность', 'D < 4.0', 0xFF66BB6A),
  medium('Средняя сложность', '4.0 ≤ D < 7.0', 0xFFFFA726),
  hard('Высокая сложность', 'D ≥ 7.0', 0xFFEF5350);

  final String labelRu;
  final String rangeLabel;
  final int colorValue;

  const FsrsDifficultyTier(this.labelRu, this.rangeLabel, this.colorValue);
}

/// Forecast of due reviews for a specific future day.
final class FsrsForecastDay extends Equatable {
  final DateTime date;
  final int dueCount;
  final String dayLabel;
  final bool isToday;

  const FsrsForecastDay({
    required this.date,
    required this.dueCount,
    required this.dayLabel,
    this.isToday = false,
  });

  @override
  List<Object?> get props => [date, dueCount, dayLabel, isToday];
}

/// Aggregated FSRS-4.5 memory analytics across user's Hebrew flashcard deck.
final class FsrsAnalyticsData extends Equatable {
  final int totalCards;
  final int unlearnedCards;
  final Map<FsrsStabilityTier, int> cardsByStabilityTier;
  final Map<FsrsDifficultyTier, int> cardsByDifficultyTier;
  final double averageStabilityDays;
  final double averageDifficulty;
  final double currentRetentionRate; // e.g. 0.912 (91.2%)
  final double historicalSuccessRate; // e.g. 0.88 (88%)
  final int totalLapses;
  final int totalReviews;
  final List<FsrsForecastDay> forecastDays;
  final List<double> retentionCurvePoints; // R values at day 0, 1, 2, ... 30

  const FsrsAnalyticsData({
    required this.totalCards,
    required this.unlearnedCards,
    required this.cardsByStabilityTier,
    required this.cardsByDifficultyTier,
    required this.averageStabilityDays,
    required this.averageDifficulty,
    required this.currentRetentionRate,
    required this.historicalSuccessRate,
    required this.totalLapses,
    required this.totalReviews,
    required this.forecastDays,
    required this.retentionCurvePoints,
  });

  @override
  List<Object?> get props => [
        totalCards,
        unlearnedCards,
        cardsByStabilityTier,
        cardsByDifficultyTier,
        averageStabilityDays,
        averageDifficulty,
        currentRetentionRate,
        historicalSuccessRate,
        totalLapses,
        totalReviews,
        forecastDays,
        retentionCurvePoints,
      ];
}
