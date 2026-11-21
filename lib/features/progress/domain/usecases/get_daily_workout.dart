import 'dart:math';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/settings/app_settings_storage.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../../../grammar/domain/entities/verb_conjugation.dart';
import '../../../grammar/domain/repositories/grammar_repository.dart';
import '../../../listening/domain/entities/listening_exercise.dart';
import '../../../listening/domain/repositories/listening_repository.dart';
import '../../../scenes/data/datasources/israeli_scenes_seed_data.dart';
import '../../../scenes/domain/entities/israeli_life_scene.dart';
import '../../../scenes/domain/repositories/scenes_repository.dart';
import '../../../shoresh/data/datasources/shoresh_seed_data.dart';
import '../../../shoresh/domain/entities/shoresh_entity.dart';
import '../../../shoresh/domain/repositories/shoresh_repository.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/repositories/srs_repository.dart';
import '../entities/daily_workout_plan.dart';

class GetDailyWorkoutUseCase {
  final SrsRepository _srsRepository;
  final GrammarRepository _grammarRepository;
  final ListeningRepository _listeningRepository;
  final ShoreshRepository? _shoreshRepository;
  final ScenesRepository? _scenesRepository;
  final AppSettingsStorage? _settingsStorage;
  final Random _random;

  GetDailyWorkoutUseCase({
    required SrsRepository srsRepository,
    required GrammarRepository grammarRepository,
    required ListeningRepository listeningRepository,
    ShoreshRepository? shoreshRepository,
    ScenesRepository? scenesRepository,
    AppSettingsStorage? settingsStorage,
    Random? random,
  })  : _srsRepository = srsRepository,
        _grammarRepository = grammarRepository,
        _listeningRepository = listeningRepository,
        _shoreshRepository = shoreshRepository,
        _scenesRepository = scenesRepository,
        _settingsStorage = settingsStorage,
        _random = random ?? Random();

  Future<Result<DailyWorkoutPlan, Failure>> call({DateTime? asOf}) async {
    final now = asOf?.toUtc() ?? DateTime.now().toUtc();

    // Check completion today & user CEFR level
    var isCompletedToday = false;
    final lastCompletedDate = await _settingsStorage?.readLastDailyWorkoutDate();
    if (lastCompletedDate != null) {
      final lastUtc = lastCompletedDate.toUtc();
      isCompletedToday = lastUtc.year == now.year &&
          lastUtc.month == now.month &&
          lastUtc.day == now.day;
    }

    final assessedLevel = await _settingsStorage?.readAssessedLevel();
    final isAdvanced = assessedLevel != null &&
        (assessedLevel.startsWith('A2') || assessedLevel.startsWith('B1'));

    // 1. Fetch up to 5 cards (due cards or fallback)
    final cardsResult = await _srsRepository.getDueCards(asOf: now, limit: 5);
    final cards = cardsResult.getOrNull() ?? <SrsCard>[];

    // 2. Fetch grammar verb & form (adaptive binyan based on level)
    DailyGrammarChallenge? grammarChallenge;
    final targetBinyan = isAdvanced
        ? switch (_random.nextInt(4)) {
            0 => Binyan.paal,
            1 => Binyan.piel,
            2 => Binyan.hifil,
            _ => Binyan.hitpael,
          }
        : Binyan.paal;

    final verbsResult = await _grammarRepository.getVerbs(binyan: targetBinyan);
    var verbs = verbsResult.getOrNull() ?? <VerbLexeme>[];
    if (verbs.isEmpty && targetBinyan != Binyan.paal) {
      final fallbackVerbs = await _grammarRepository.getVerbs(binyan: Binyan.paal);
      verbs = fallbackVerbs.getOrNull() ?? <VerbLexeme>[];
    }

    if (verbs.isNotEmpty) {
      final verb = verbs[_random.nextInt(verbs.length)];
      if (verb.conjugations.isNotEmpty) {
        final targetForm =
            verb.conjugations[_random.nextInt(verb.conjugations.length)];
        final otherForms = verb.conjugations
            .where((f) => f.form != targetForm.form)
            .map((f) => f.form.vocalized)
            .toSet()
            .toList();
        otherForms.shuffle(_random);
        final distractors = otherForms.take(3).toList();

        grammarChallenge = DailyGrammarChallenge(
          verb: verb,
          targetForm: targetForm,
          distractors: distractors,
        );
      }
    }

    // 3. Fetch listening exercise
    ListeningExercise? listeningExercise;
    final exercisesResult = await _listeningRepository.getExercises();
    final exercises = exercisesResult.getOrNull() ?? <ListeningExercise>[];

    if (exercises.isNotEmpty) {
      listeningExercise = exercises[_random.nextInt(exercises.length)];
    }

    // 4. Fetch shoresh challenge
    ShoreshQuizQuestion? shoreshChallenge;
    final shoreshQuestions =
        _shoreshRepository?.generateQuizQuestions(count: 10) ??
            ShoreshSeedData.detectiveQuizChallenges;
    if (shoreshQuestions.isNotEmpty) {
      shoreshChallenge =
          shoreshQuestions[_random.nextInt(shoreshQuestions.length)];
    }

    // 5. Fetch scene challenge (adaptive based on CEFR level)
    SceneChallenge? sceneChallenge;
    final allScenes =
        _scenesRepository?.getAllScenes() ?? IsraeliScenesSeedData.scenes;
    final matchedScenes = isAdvanced
        ? allScenes
            .where((s) =>
                s.cefrLevel.contains('A2') || s.cefrLevel.contains('B1'))
            .toList()
        : allScenes.where((s) => s.cefrLevel.contains('A1')).toList();

    final targetScenes = matchedScenes.isNotEmpty ? matchedScenes : allScenes;
    final allSceneChallenges = [
      for (final s in targetScenes) ...s.challenges,
    ];
    if (allSceneChallenges.isNotEmpty) {
      sceneChallenge =
          allSceneChallenges[_random.nextInt(allSceneChallenges.length)];
    }

    final plan = DailyWorkoutPlan(
      date: now,
      cards: cards,
      grammarChallenge: grammarChallenge,
      listeningExercise: listeningExercise,
      shoreshChallenge: shoreshChallenge,
      sceneChallenge: sceneChallenge,
      isCompletedToday: isCompletedToday,
    );

    return Success(plan);
  }
}
