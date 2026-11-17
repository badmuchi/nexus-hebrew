import 'dart:math' as math;

import '../entities/fsrs_models.dart';

/// Pure Dart implementation of the FSRS-4.5 (Free Spaced Repetition Scheduler) DSR model.
final class FsrsScheduler {
  static const Duration _againDelay = Duration(minutes: 10);
  static const Duration _learningHardDelay = Duration(hours: 12);

  final FsrsParameters parameters;

  const FsrsScheduler({
    this.parameters = const FsrsParameters.defaults(),
  });

  double retrievability({
    required double elapsedDays,
    required double stability,
  }) {
    if (stability <= 0.0) {
      return 0.0;
    }
    final safeElapsed = math.max(0.0, elapsedDays);
    return math.pow(1.0 + safeElapsed / (9.0 * stability), -1.0).toDouble();
  }

  int nextIntervalDays(double stability) {
    final rawInterval =
        9.0 * stability * (1.0 / parameters.requestRetention - 1.0);
    return rawInterval.round().clamp(1, parameters.maximumIntervalDays);
  }

  FsrsScheduleOutcome schedule({
    required FsrsMemoryState current,
    required FsrsRating rating,
    required DateTime now,
  }) {
    final reviewTime = now.toUtc();
    if (current.state == FsrsCardState.newCard || current.reps == 0) {
      return _scheduleInitialReview(
        current: current,
        rating: rating,
        now: reviewTime,
      );
    }

    final previousReview = current.lastReviewedAt ?? reviewTime;
    final elapsedDays = math.max(
      0.0,
      reviewTime.difference(previousReview).inMinutes / 1440.0,
    );
    final currentRetrievability = retrievability(
      elapsedDays: elapsedDays,
      stability: current.stability,
    );
    final updatedDifficulty = _nextDifficulty(current.difficulty, rating);

    if (rating == FsrsRating.again) {
      final forgetStability = _nextForgetStability(
        difficulty: current.difficulty,
        stability: current.stability,
        retrievability: currentRetrievability,
      );
      final clampedStability = math.min(current.stability, forgetStability);
      return FsrsScheduleOutcome(
        scheduledDays: 0,
        retrievability: currentRetrievability,
        updatedMemory: FsrsMemoryState(
          state: FsrsCardState.relearning,
          stability: math.max(0.1, clampedStability),
          difficulty: updatedDifficulty,
          reps: current.reps + 1,
          lapses: current.lapses + 1,
          dueAt: reviewTime.add(_againDelay),
          lastReviewedAt: reviewTime,
        ),
      );
    }

    // Same-day graduation from learning/relearning when elapsedDays ~ 0 keeps stability valid.
    final nextStability = current.state == FsrsCardState.learning ||
            current.state == FsrsCardState.relearning
        ? math.max(current.stability, _initialStability(rating))
        : _nextRecallStability(
            difficulty: current.difficulty,
            stability: current.stability,
            retrievability: currentRetrievability,
            rating: rating,
          );

    final intervalDays = nextIntervalDays(nextStability);
    return FsrsScheduleOutcome(
      scheduledDays: intervalDays,
      retrievability: currentRetrievability,
      updatedMemory: FsrsMemoryState(
        state: FsrsCardState.review,
        stability: nextStability,
        difficulty: updatedDifficulty,
        reps: current.reps + 1,
        lapses: current.lapses,
        dueAt: reviewTime.add(Duration(days: intervalDays)),
        lastReviewedAt: reviewTime,
      ),
    );
  }

  Map<FsrsRating, int> previewIntervals({
    required FsrsMemoryState current,
    required DateTime now,
  }) {
    final map = <FsrsRating, int>{};
    for (final rating in FsrsRating.values) {
      final outcome = schedule(current: current, rating: rating, now: now);
      map[rating] = outcome.scheduledDays;
    }
    return Map<FsrsRating, int>.unmodifiable(map);
  }

  FsrsScheduleOutcome _scheduleInitialReview({
    required FsrsMemoryState current,
    required FsrsRating rating,
    required DateTime now,
  }) {
    final s0 = _initialStability(rating);
    final d0 = _initialDifficulty(rating);

    switch (rating) {
      case FsrsRating.again:
        return FsrsScheduleOutcome(
          scheduledDays: 0,
          retrievability: 0.0,
          updatedMemory: FsrsMemoryState(
            state: FsrsCardState.learning,
            stability: s0,
            difficulty: d0,
            reps: current.reps + 1,
            lapses: current.lapses,
            dueAt: now.add(_againDelay),
            lastReviewedAt: now,
          ),
        );
      case FsrsRating.hard:
        return FsrsScheduleOutcome(
          scheduledDays: 0,
          retrievability: 0.0,
          updatedMemory: FsrsMemoryState(
            state: FsrsCardState.learning,
            stability: s0,
            difficulty: d0,
            reps: current.reps + 1,
            lapses: current.lapses,
            dueAt: now.add(_learningHardDelay),
            lastReviewedAt: now,
          ),
        );
      case FsrsRating.good:
      case FsrsRating.easy:
        final intervalDays = nextIntervalDays(s0);
        return FsrsScheduleOutcome(
          scheduledDays: intervalDays,
          retrievability: 0.0,
          updatedMemory: FsrsMemoryState(
            state: FsrsCardState.review,
            stability: s0,
            difficulty: d0,
            reps: current.reps + 1,
            lapses: current.lapses,
            dueAt: now.add(Duration(days: intervalDays)),
            lastReviewedAt: now,
          ),
        );
    }
  }

  double _initialStability(FsrsRating rating) {
    return math.max(0.1, parameters.weights[rating.value - 1]);
  }

  double _initialDifficulty(FsrsRating rating) {
    final w = parameters.weights;
    final raw = w[4] - math.exp(w[5] * (rating.value - 1)) + 1.0;
    return raw.clamp(1.0, 10.0);
  }

  double _nextDifficulty(double currentDifficulty, FsrsRating rating) {
    final w = parameters.weights;
    final raw = currentDifficulty - w[6] * (rating.value - 3);
    final meanReverted =
        w[7] * _initialDifficulty(FsrsRating.easy) + (1.0 - w[7]) * raw;
    return meanReverted.clamp(1.0, 10.0);
  }

  double _nextRecallStability({
    required double difficulty,
    required double stability,
    required double retrievability,
    required FsrsRating rating,
  }) {
    final w = parameters.weights;
    final hardPenalty = rating == FsrsRating.hard ? w[15] : 1.0;
    final easyBonus = rating == FsrsRating.easy ? w[16] : 1.0;

    final nextS = stability *
        (1.0 +
            math.exp(w[8]) *
                (11.0 - difficulty) *
                math.pow(stability, -w[9]) *
                (math.exp((1.0 - retrievability) * w[10]) - 1.0) *
                hardPenalty *
                easyBonus);

    return math.max(0.1, nextS);
  }

  double _nextForgetStability({
    required double difficulty,
    required double stability,
    required double retrievability,
  }) {
    final w = parameters.weights;
    final nextS = w[11] *
        math.pow(difficulty, -w[12]) *
        (math.pow(stability + 1.0, w[13]) - 1.0) *
        math.exp((1.0 - retrievability) * w[14]);
    return math.max(0.1, nextS);
  }
}
