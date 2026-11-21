import 'package:equatable/equatable.dart';

import '../../../grammar/domain/entities/verb_conjugation.dart';
import '../../../listening/domain/entities/listening_exercise.dart';
import '../../../scenes/domain/entities/israeli_life_scene.dart';
import '../../../shoresh/domain/entities/shoresh_entity.dart';
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

/// A focused 5-minute mixed daily training plan combining SRS flashcards,
/// grammar conjugation drills, listening comprehension, root extraction,
/// and real-life Israeli situational dialogue challenges.
final class DailyWorkoutPlan extends Equatable {
  const DailyWorkoutPlan({
    required this.date,
    required this.cards,
    this.grammarChallenge,
    this.listeningExercise,
    this.shoreshChallenge,
    this.sceneChallenge,
    required this.isCompletedToday,
    this.bonusXp = 50,
  });

  final DateTime date;
  final List<SrsCard> cards;
  final DailyGrammarChallenge? grammarChallenge;
  final ListeningExercise? listeningExercise;
  final ShoreshQuizQuestion? shoreshChallenge;
  final SceneChallenge? sceneChallenge;
  final bool isCompletedToday;
  final int bonusXp;

  int get totalSteps =>
      (cards.isNotEmpty ? 1 : 0) +
      (grammarChallenge != null ? 1 : 0) +
      (listeningExercise != null ? 1 : 0) +
      (shoreshChallenge != null ? 1 : 0) +
      (sceneChallenge != null ? 1 : 0);

  bool get isEmpty =>
      cards.isEmpty &&
      grammarChallenge == null &&
      listeningExercise == null &&
      shoreshChallenge == null &&
      sceneChallenge == null;

  @override
  List<Object?> get props => [
        date,
        cards,
        grammarChallenge,
        listeningExercise,
        shoreshChallenge,
        sceneChallenge,
        isCompletedToday,
        bonusXp,
      ];
}
