import 'package:equatable/equatable.dart';

import '../../../conversation/domain/entities/binyan.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../../../srs/domain/entities/fsrs_analytics_data.dart';

/// Accuracy breakdown for one Hebrew binyan in grammar drills.
final class BinyanAccuracyStat extends Equatable {
  const BinyanAccuracyStat({
    required this.binyan,
    required this.totalAttempts,
    required this.correctAttempts,
  });

  final Binyan binyan;
  final int totalAttempts;
  final int correctAttempts;

  /// Ratio of correct conjugation attempts in `[0.0, 1.0]`.
  double get accuracyRate =>
      totalAttempts == 0 ? 0.0 : correctAttempts / totalAttempts;

  @override
  List<Object?> get props => [binyan, totalAttempts, correctAttempts];
}

/// Aggregated learner progress across FSRS flashcards, grammar binyanim, and listening.
final class LearningProgressSummary extends Equatable {
  LearningProgressSummary({
    required this.totalSrsCards,
    required this.dueSrsCards,
    required this.newCards,
    required this.learningCards,
    required this.reviewCards,
    required this.relearningCards,
    required this.totalSrsReviews,
    required this.currentStreakDays,
    required this.activeTodayCount,
    required this.grammarAttempts,
    required this.grammarCorrect,
    required List<BinyanAccuracyStat> binyanStats,
    required this.listeningAttempts,
    required this.listeningExactMatches,
    required this.averageListeningAccuracy,
    this.activityByDate = const <String, int>{},
    this.masteredShoreshCount = 0,
    this.totalShoreshCount = 35,
    this.completedScenesCount = 0,
    this.totalScenesCount = 6,
    this.fsrsAnalytics,
  }) : binyanStats = List<BinyanAccuracyStat>.unmodifiable(binyanStats);

  final int totalSrsCards;
  final int dueSrsCards;
  final int newCards;
  final int learningCards;
  final int reviewCards;
  final int relearningCards;
  final int totalSrsReviews;
  final int currentStreakDays;
  final int activeTodayCount;
  final int grammarAttempts;
  final int grammarCorrect;
  final List<BinyanAccuracyStat> binyanStats;
  final int listeningAttempts;
  final int listeningExactMatches;
  final double averageListeningAccuracy;
  final Map<String, int> activityByDate;
  final int masteredShoreshCount;
  final int totalShoreshCount;
  final int completedScenesCount;
  final int totalScenesCount;
  final FsrsAnalyticsData? fsrsAnalytics;

  /// Overall grammar drill accuracy in `[0.0, 1.0]`.
  double get grammarAccuracy =>
      grammarAttempts == 0 ? 0.0 : grammarCorrect / grammarAttempts;

  @override
  List<Object?> get props => [
        totalSrsCards,
        dueSrsCards,
        newCards,
        learningCards,
        reviewCards,
        relearningCards,
        totalSrsReviews,
        currentStreakDays,
        activeTodayCount,
        grammarAttempts,
        grammarCorrect,
        binyanStats,
        listeningAttempts,
        listeningExactMatches,
        averageListeningAccuracy,
        activityByDate,
        masteredShoreshCount,
        totalShoreshCount,
        completedScenesCount,
        totalScenesCount,
        fsrsAnalytics,
      ];
}

/// Feature source tag for a unified Hebrew/shoresh search result.
enum SearchSourceKind {
  srs(labelRu: 'FSRS Карточка'),
  grammar(labelRu: 'Глагол / Биньян'),
  dialogue(labelRu: 'Диалог'),
  listening(labelRu: 'Аудирование');

  const SearchSourceKind({required this.labelRu});

  final String labelRu;
}

/// Unified hit returned by searching across flashcards, grammar verbs, dialogues, and listening.
final class GlobalHebrewSearchResult extends Equatable {
  const GlobalHebrewSearchResult({
    required this.id,
    required this.kind,
    required this.hebrew,
    required this.russianMeaning,
    this.root,
    this.binyan = Binyan.none,
    this.audioUrl,
    this.contextNote,
  });

  final String id;
  final SearchSourceKind kind;
  final HebrewText hebrew;
  final String russianMeaning;
  final Shoresh? root;
  final Binyan binyan;
  final String? audioUrl;
  final String? contextNote;

  @override
  List<Object?> get props => [
        id,
        kind,
        hebrew,
        russianMeaning,
        root,
        binyan,
        audioUrl,
        contextNote,
      ];
}

/// Pure Domain calculator for consecutive study day streaks and today's activity count.
final class StreakCalculator {
  StreakCalculator._();

  /// Computes consecutive UTC days with >= 1 study action ending on `today`
  /// (or `yesterday` if today's session hasn't occurred yet).
  static int calculateCurrentStreakDays({
    required Iterable<DateTime> activityTimestamps,
    required DateTime nowUtc,
  }) {
    final activeDays = <DateTime>{};
    for (final stamp in activityTimestamps) {
      final utc = stamp.toUtc();
      activeDays.add(DateTime.utc(utc.year, utc.month, utc.day));
    }
    if (activeDays.isEmpty) return 0;

    final today = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);
    final yesterday = today.subtract(const Duration(days: 1));

    DateTime? startDay;
    if (activeDays.contains(today)) {
      startDay = today;
    } else if (activeDays.contains(yesterday)) {
      startDay = yesterday;
    }
    if (startDay == null) return 0;

    var cursor = startDay;
    var streak = 0;
    while (activeDays.contains(cursor)) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Counts total logged study actions occurring on `nowUtc`'s UTC date.
  static int countActivitiesToday({
    required Iterable<DateTime> activityTimestamps,
    required DateTime nowUtc,
  }) {
    final today = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);
    var count = 0;
    for (final stamp in activityTimestamps) {
      final utc = stamp.toUtc();
      final day = DateTime.utc(utc.year, utc.month, utc.day);
      if (day == today) {
        count += 1;
      }
    }
    return count;
  }
}
