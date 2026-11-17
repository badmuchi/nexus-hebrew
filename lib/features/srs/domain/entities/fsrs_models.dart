import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';

enum FsrsRating {
  again(1, 'Снова'),
  hard(2, 'Трудно'),
  good(3, 'Хорошо'),
  easy(4, 'Легко');

  final int value;
  final String labelRu;

  const FsrsRating(this.value, this.labelRu);

  static Result<FsrsRating, ValidationFailure> fromValue(int value) {
    for (final rating in FsrsRating.values) {
      if (rating.value == value) {
        return Success(rating);
      }
    }
    return Error(ValidationFailure('Invalid FSRS rating value: $value'));
  }
}

enum FsrsCardState {
  newCard('newCard'),
  learning('learning'),
  review('review'),
  relearning('relearning');

  final String id;

  const FsrsCardState(this.id);

  static Result<FsrsCardState, ParsingFailure> parseStrict(String raw) {
    final normalized = raw.trim();
    for (final state in FsrsCardState.values) {
      if (state.id == normalized) {
        return Success(state);
      }
    }
    return Error(ParsingFailure('Unknown FSRS state: "$raw"'));
  }
}

/// FSRS-4.5 model parameters (17 weights from open-spaced-repetition).
final class FsrsParameters extends Equatable {
  static const List<double> defaultWeights = <double>[
    0.4872,
    1.4003,
    3.7145,
    13.8206,
    5.1618,
    1.2298,
    0.8975,
    0.031,
    1.6474,
    0.1367,
    1.0461,
    2.1072,
    0.0793,
    0.3246,
    1.587,
    0.2272,
    2.8755,
  ];

  final List<double> weights;
  final double requestRetention;
  final int maximumIntervalDays;

  FsrsParameters({
    List<double> weights = defaultWeights,
    this.requestRetention = 0.9,
    this.maximumIntervalDays = 36500,
  }) : weights = List<double>.unmodifiable(weights);

  const FsrsParameters.defaults()
      : weights = defaultWeights,
        requestRetention = 0.9,
        maximumIntervalDays = 36500;

  @override
  List<Object?> get props => [weights, requestRetention, maximumIntervalDays];
}

final class FsrsMemoryState extends Equatable {
  final FsrsCardState state;
  final double stability;
  final double difficulty;
  final int reps;
  final int lapses;
  final DateTime dueAt;
  final DateTime? lastReviewedAt;

  const FsrsMemoryState({
    required this.state,
    required this.stability,
    required this.difficulty,
    required this.reps,
    required this.lapses,
    required this.dueAt,
    this.lastReviewedAt,
  });

  factory FsrsMemoryState.initial({required DateTime now}) {
    return FsrsMemoryState(
      state: FsrsCardState.newCard,
      stability: 0.0,
      difficulty: 0.0,
      reps: 0,
      lapses: 0,
      dueAt: now.toUtc(),
    );
  }

  @override
  List<Object?> get props => [
        state,
        stability,
        difficulty,
        reps,
        lapses,
        dueAt,
        lastReviewedAt,
      ];
}

final class FsrsScheduleOutcome extends Equatable {
  final FsrsMemoryState updatedMemory;
  final int scheduledDays;
  final double retrievability;

  const FsrsScheduleOutcome({
    required this.updatedMemory,
    required this.scheduledDays,
    required this.retrievability,
  });

  @override
  List<Object?> get props => [updatedMemory, scheduledDays, retrievability];
}
