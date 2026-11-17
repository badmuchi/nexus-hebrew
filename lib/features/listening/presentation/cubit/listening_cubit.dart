import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/utils/hebrew_normalizer.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/listening_exercise.dart';
import '../../domain/usecases/evaluate_dictation.dart';
import '../../domain/usecases/get_listening_exercises.dart';
import '../../domain/usecases/import_tatoeba_listening.dart';
import '../../domain/usecases/play_listening_exercise.dart';
import '../../domain/usecases/record_listening_attempt.dart';
import 'listening_state.dart';

typedef ListeningClockUtc = DateTime Function();

/// State manager for Hebrew audio comprehension, speed control, and dictation checks.
final class ListeningCubit extends Cubit<ListeningState> {
  static const String _tag = 'ListeningCubit';

  ListeningCubit({
    required GetListeningExercisesUseCase getExercisesUseCase,
    required PlayListeningExerciseUseCase playExerciseUseCase,
    required EvaluateDictationUseCase evaluateDictationUseCase,
    required ImportTatoebaListeningUseCase importTatoebaUseCase,
    required RecordListeningAttemptUseCase recordAttemptUseCase,
    AddCardToSrsUseCase? addCardToSrsUseCase,
    required AudioPlaybackService audioService,
    required AppLogger logger,
    ListeningClockUtc? clock,
  })  : _getExercisesUseCase = getExercisesUseCase,
        _playExerciseUseCase = playExerciseUseCase,
        _evaluateDictationUseCase = evaluateDictationUseCase,
        _importTatoebaUseCase = importTatoebaUseCase,
        _recordAttemptUseCase = recordAttemptUseCase,
        _addCardToSrsUseCase = addCardToSrsUseCase,
        _audioService = audioService,
        _logger = logger,
        _clock = clock ?? (() => DateTime.now().toUtc()),
        super(const ListeningInitial()) {
    _audioSubscription = _audioService.statusStream.listen(_handleAudioEvent);
  }

  final GetListeningExercisesUseCase _getExercisesUseCase;
  final PlayListeningExerciseUseCase _playExerciseUseCase;
  final EvaluateDictationUseCase _evaluateDictationUseCase;
  final ImportTatoebaListeningUseCase _importTatoebaUseCase;
  final RecordListeningAttemptUseCase _recordAttemptUseCase;
  final AddCardToSrsUseCase? _addCardToSrsUseCase;
  final AudioPlaybackService _audioService;
  final AppLogger _logger;
  final ListeningClockUtc _clock;

  StreamSubscription<AudioPlaybackEvent>? _audioSubscription;

  /// Loads listening exercises optionally filtered by [difficulty].
  Future<void> loadExercises({ListeningDifficulty? difficulty}) async {
    final prev = state is ListeningLoaded ? state as ListeningLoaded : null;
    final effectiveDifficulty = difficulty ?? prev?.selectedDifficulty;
    final speed = prev?.playbackSpeed ?? _audioService.currentSpeed;
    final showNikkud = prev?.showNikkud ?? true;

    if (prev == null) {
      emit(const ListeningLoading());
    }

    final res = await _getExercisesUseCase(
      GetListeningExercisesParams(difficulty: effectiveDifficulty),
    );
    if (isClosed) return;

    res.fold(
      (Failure failure) => emit(ListeningError(failure)),
      (List<ListeningExercise> exercises) {
        emit(
          ListeningLoaded(
            exercises: exercises,
            currentIndex: 0,
            selectedDifficulty: effectiveDifficulty,
            playbackSpeed: speed,
            showNikkud: showNikkud,
          ),
        );
      },
    );
  }

  /// Filters exercises by [difficulty] (`null` resets to all tiers).
  Future<void> filterByDifficulty(ListeningDifficulty? difficulty) async {
    final prev = state is ListeningLoaded ? state as ListeningLoaded : null;
    final speed = prev?.playbackSpeed ?? _audioService.currentSpeed;
    final showNikkud = prev?.showNikkud ?? true;

    await _audioService.stop();
    if (isClosed) return;

    final res = await _getExercisesUseCase(
      GetListeningExercisesParams(difficulty: difficulty),
    );
    if (isClosed) return;

    res.fold(
      (Failure failure) => emit(ListeningError(failure)),
      (List<ListeningExercise> exercises) {
        emit(
          ListeningLoaded(
            exercises: exercises,
            currentIndex: 0,
            selectedDifficulty: difficulty,
            playbackSpeed: speed,
            showNikkud: showNikkud,
          ),
        );
      },
    );
  }

  /// Updates audio playback speed (`0.75` or `1.0`).
  Future<void> setPlaybackSpeed(double speed) async {
    final current = state;
    if (current is! ListeningLoaded) return;

    final speedRes = await _audioService.setPlaybackSpeed(speed);
    if (isClosed) return;

    speedRes.fold(
      (Failure failure) =>
          emit(current.copyWith(transientNotice: failure.message)),
      (_) => emit(current.copyWith(playbackSpeed: speed)),
    );
  }

  /// Plays or stops the currently active listening exercise.
  Future<void> togglePlayCurrent() async {
    final current = state;
    if (current is! ListeningLoaded) return;
    final exercise = current.currentExercise;
    if (exercise == null) return;

    if (current.audioStatus == AudioPlaybackStatus.playing) {
      await _audioService.stop();
      return;
    }

    emit(current.copyWith(audioStatus: AudioPlaybackStatus.loading));

    final playRes = await _playExerciseUseCase(
      PlayListeningExerciseParams(
        exercise: exercise,
        speed: current.playbackSpeed,
      ),
    );
    if (isClosed) return;

    playRes.fold(
      (Failure failure) {
        final latest = state;
        if (latest is ListeningLoaded) {
          emit(
            latest.copyWith(
              audioStatus: AudioPlaybackStatus.error,
              transientNotice: failure.message,
            ),
          );
        }
      },
      (_) {},
    );
  }

  /// Moves to the next exercise in the current list, wrapping around.
  Future<void> nextExercise() async {
    final current = state;
    if (current is! ListeningLoaded || current.exercises.isEmpty) return;

    await _audioService.stop();
    if (isClosed) return;

    final nextIndex = (current.currentIndex + 1) % current.exercises.length;
    emit(
      current.copyWith(
        currentIndex: nextIndex,
        audioStatus: AudioPlaybackStatus.idle,
        showFocusWordsHint: false,
        showTranscript: false,
        clearLastComparison: true,
        clearTransientNotice: true,
      ),
    );
  }

  /// Moves to the previous exercise in the current list, wrapping around.
  Future<void> previousExercise() async {
    final current = state;
    if (current is! ListeningLoaded || current.exercises.isEmpty) return;

    await _audioService.stop();
    if (isClosed) return;

    final length = current.exercises.length;
    final prevIndex = (current.currentIndex - 1 + length) % length;
    emit(
      current.copyWith(
        currentIndex: prevIndex,
        audioStatus: AudioPlaybackStatus.idle,
        showFocusWordsHint: false,
        showTranscript: false,
        clearLastComparison: true,
        clearTransientNotice: true,
      ),
    );
  }

  /// Toggles progressive stage 1 hint: key vocabulary chips.
  void toggleFocusWordsHint() {
    final current = state;
    if (current is! ListeningLoaded) return;
    emit(current.copyWith(showFocusWordsHint: !current.showFocusWordsHint));
  }

  /// Toggles progressive stage 2 hint: full Hebrew transcript & translation.
  void toggleTranscriptReveal() {
    final current = state;
    if (current is! ListeningLoaded) return;
    emit(current.copyWith(showTranscript: !current.showTranscript));
  }

  /// Toggles nikkud visibility when transcript/focus words are revealed.
  void toggleNikkud() {
    final current = state;
    if (current is! ListeningLoaded) return;
    emit(current.copyWith(showNikkud: !current.showNikkud));
  }

  /// Switches between Word Puzzle mode and manual Keyboard mode.
  void setAnswerMode(ListeningAnswerMode mode) {
    final current = state;
    if (current is! ListeningLoaded) return;
    emit(current.copyWith(answerMode: mode));
  }

  /// Evaluates typed Hebrew dictation and saves attempt stats locally.
  Future<void> submitDictation(String userInput) async {
    final current = state;
    if (current is! ListeningLoaded) return;
    final exercise = current.currentExercise;
    if (exercise == null) return;

    final evalRes = _evaluateDictationUseCase(
      EvaluateDictationParams(exercise: exercise, userInput: userInput),
    );

    await evalRes.fold<Future<void>>(
      (Failure failure) async {
        emit(current.copyWith(transientNotice: failure.message));
      },
      (DictationComparison comparison) async {
        emit(
          current.copyWith(
            lastComparison: comparison,
            clearTransientNotice: true,
          ),
        );

        final recordRes = await _recordAttemptUseCase(
          RecordListeningAttemptParams(
            exerciseId: exercise.id,
            wordAccuracy: comparison.wordAccuracy,
            isExactMatch: comparison.isExactMatch,
            attemptedAt: _clock(),
          ),
        );
        recordRes.fold(
          (Failure failure) => _logger.warning(
            _tag,
            'Non-fatal error logging listening attempt: ${failure.message}',
          ),
          (_) {},
        );
      },
    );
  }

  /// Imports open-licensed sentences from Tatoeba and refreshes the exercise list.
  Future<void> importFromTatoeba(String query) async {
    final current = state;
    if (current is! ListeningLoaded || current.isImporting) return;

    emit(current.copyWith(isImporting: true, clearTransientNotice: true));

    final importRes = await _importTatoebaUseCase(
      ImportTatoebaListeningParams(query: query, limit: 8),
    );
    if (isClosed) return;

    await importRes.fold<Future<void>>(
      (Failure failure) async {
        final latest = state;
        if (latest is ListeningLoaded) {
          emit(
            latest.copyWith(
              isImporting: false,
              transientNotice: failure.message,
            ),
          );
        }
      },
      (List<ListeningExercise> imported) async {
        if (imported.isEmpty) {
          final latest = state;
          if (latest is ListeningLoaded) {
            emit(
              latest.copyWith(
                isImporting: false,
                transientNotice:
                    'По этому запросу в Tatoeba не найдено открытых фраз',
              ),
            );
          }
          return;
        }

        final latest = state;
        final difficulty =
            latest is ListeningLoaded ? latest.selectedDifficulty : null;
        final refreshRes = await _getExercisesUseCase(
          GetListeningExercisesParams(difficulty: difficulty),
        );
        if (isClosed) return;

        refreshRes.fold(
          (Failure failure) => emit(ListeningError(failure)),
          (List<ListeningExercise> allExercises) {
            final base = state is ListeningLoaded
                ? state as ListeningLoaded
                : current;
            emit(
              base.copyWith(
                exercises: allExercises,
                isImporting: false,
                transientNotice:
                    'Импортировано из Tatoeba: ${imported.length} фраз',
              ),
            );
          },
        );
      },
    );
  }

  /// Saves the full listening sentence directly into FSRS in one tap.
  Future<void> saveExerciseToSrs(ListeningExercise exercise) async {
    final current = state;
    final useCase = _addCardToSrsUseCase;
    if (current is! ListeningLoaded || useCase == null) return;

    final res = await useCase(
      AddCardToSrsParams(
        id: 'custom_listen_${exercise.id}',
        hebrewVocalized: exercise.transcript.vocalized,
        russianTranslation: exercise.russianTranslation,
        category: LexicalCategory.phrase,
        audioUrl: exercise.audioUrl,
        attribution: exercise.attribution,
      ),
    );
    if (isClosed) return;

    final latest = state;
    if (latest is! ListeningLoaded) return;
    res.fold(
      (Failure failure) =>
          emit(latest.copyWith(transientNotice: failure.message)),
      (bool added) => emit(
        latest.copyWith(
          transientNotice: added
              ? 'Фраза добавлена в колоду FSRS!'
              : 'Эта фраза уже есть в колоде FSRS',
        ),
      ),
    );
  }

  /// Saves an individual focus word from [exercise] into FSRS with sentence context.
  Future<void> saveFocusWordToSrs(
    ListeningExercise exercise,
    String focusWord,
  ) async {
    final current = state;
    final useCase = _addCardToSrsUseCase;
    if (current is! ListeningLoaded || useCase == null) return;

    final normalizedSlug = HebrewNormalizer.normalizeForComparison(focusWord)
        .replaceAll(' ', '_');
    final res = await useCase(
      AddCardToSrsParams(
        id: 'custom_focus_${exercise.id}_$normalizedSlug',
        hebrewVocalized: focusWord,
        russianTranslation: 'Ключевое слово · ${exercise.russianTranslation}',
        category: LexicalCategory.phrase,
        exampleHebrewVocalized: exercise.transcript.vocalized,
        exampleRussian: exercise.russianTranslation,
        attribution: exercise.attribution,
      ),
    );
    if (isClosed) return;

    final latest = state;
    if (latest is! ListeningLoaded) return;
    res.fold(
      (Failure failure) =>
          emit(latest.copyWith(transientNotice: failure.message)),
      (bool added) => emit(
        latest.copyWith(
          transientNotice: added
              ? 'Слово «${HebrewNormalizer.stripNikkud(focusWord)}» добавлено в FSRS!'
              : 'Это слово уже есть в колоде FSRS',
        ),
      ),
    );
  }

  /// Clears transient SnackBar notification after consumption.
  void clearTransientNotice() {
    final current = state;
    if (current is! ListeningLoaded || current.transientNotice == null) return;
    emit(current.copyWith(clearTransientNotice: true));
  }

  void _handleAudioEvent(AudioPlaybackEvent event) {
    if (isClosed) return;
    final current = state;
    if (current is! ListeningLoaded) return;
    final exercise = current.currentExercise;
    if (exercise == null) return;

    final expectedTtsKey = 'tts://he-IL/${exercise.transcript.vocalized}';
    final matchesExercise =
        event.sourcePath == exercise.audioUrl ||
            event.sourcePath == expectedTtsKey;
    if (!matchesExercise) return;

    emit(current.copyWith(audioStatus: event.status));
  }

  @override
  Future<void> close() async {
    await _audioSubscription?.cancel();
    return super.close();
  }
}
