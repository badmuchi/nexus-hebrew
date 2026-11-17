import 'package:equatable/equatable.dart';

import '../../../grammar/domain/entities/verb_conjugation.dart';
import '../../../listening/domain/entities/listening_exercise.dart';
import '../../../srs/domain/entities/srs_card.dart';

/// Grammar challenge included in a daily workout session.
final class DailyGrammarChallenge extends Equatable {
  const DailyGrammarChallenge({
    required this.verb,
    required this.targetForm,
    required this.distractors,
  });

  final VerbLexeme verb;
  final ConjugatedForm targetForm;
  final List<String> distractors;

  @override
  List<Object?> get props => [verb, targetForm, distractors];
}

/// A focused 5-minute mixed daily training plan.
final class DailyWorkoutPlan extends Equatable {
  const DailyWorkoutPlan({
    required this.date,
    required this.cards,
    this.grammarChallenge,
    this.listeningExercise,
    required this.isCompletedToday,
    this.bonusXp = 50,
  });

  final DateTime date;
  final List<SrsCard> cards;
  final DailyGrammarChallenge? grammarChallenge;
  final ListeningExercise? listeningExercise;
  final bool isCompletedToday;
  final int bonusXp;

  int get totalSteps =>
      (cards.isNotEmpty ? 1 : 0) +
      (grammarChallenge != null ? 1 : 0) +
      (listeningExercise != null ? 1 : 0);

  bool get isEmpty =>
      cards.isEmpty && grammarChallenge == null && listeningExercise == null;

  @override
  List<Object?> get props => [
        date,
        cards,
        grammarChallenge,
        listeningExercise,
        isCompletedToday,
        bonusXp,
      ];
}
