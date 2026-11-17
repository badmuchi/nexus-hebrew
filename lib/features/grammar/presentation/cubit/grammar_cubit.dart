import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/verb_conjugation.dart';
import '../../domain/usecases/check_verb_conjugation.dart';
import '../../domain/usecases/get_verbs_by_binyan.dart';
import '../../domain/usecases/record_grammar_practice.dart';
import 'grammar_state.dart';

typedef GrammarClockUtc = DateTime Function();

/// State manager for the Hebrew Grammar & Binyanim study workspace.
final class GrammarCubit extends Cubit<GrammarState> {
  static const String _tag = 'GrammarCubit';

  GrammarCubit({
    required GetVerbsByBinyanUseCase getVerbsUseCase,
    required CheckVerbConjugationUseCase checkConjugationUseCase,
    required RecordGrammarPracticeUseCase recordPracticeUseCase,
    AddCardToSrsUseCase? addCardToSrsUseCase,
    required AudioPlaybackService audioService,
    required AppLogger logger,
    GrammarClockUtc? clock,
  })  : _getVerbsUseCase = getVerbsUseCase,
        _checkConjugationUseCase = checkConjugationUseCase,
        _recordPracticeUseCase = recordPracticeUseCase,
        _addCardToSrsUseCase = addCardToSrsUseCase,
        _audioService = audioService,
        _logger = logger,
        _clock = clock ?? (() => DateTime.now().toUtc()),
        super(const GrammarInitial()) {
    _audioSubscription = _audioService.statusStream.listen(_handleAudioEvent);
  }

  final GetVerbsByBinyanUseCase _getVerbsUseCase;
  final CheckVerbConjugationUseCase _checkConjugationUseCase;
  final RecordGrammarPracticeUseCase _recordPracticeUseCase;
  final AddCardToSrsUseCase? _addCardToSrsUseCase;
  final AudioPlaybackService _audioService;
  final AppLogger _logger;
  final GrammarClockUtc _clock;

  StreamSubscription<AudioPlaybackEvent>? _audioSubscription;

  /// Loads Hebrew verb paradigms applying optional [binyan] filter and [query].
  Future<void> loadVerbs({Binyan? binyan, String? query}) async {
    final prev = state is GrammarLoaded ? state as GrammarLoaded : null;
    final effectiveBinyan = binyan ?? prev?.selectedBinyan;
    final effectiveQuery = query ?? prev?.searchQuery ?? '';
    final effectiveTense = prev?.selectedTense ?? VerbTense.present;
    final effectiveShowNikkud = prev?.showNikkud ?? true;

    if (prev == null) {
      emit(const GrammarLoading());
    }

    final result = await _getVerbsUseCase(
      GetVerbsByBinyanParams(
        binyan: effectiveBinyan,
        query: effectiveQuery,
      ),
    );
    if (isClosed) return;

    result.fold(
      (failure) => emit(GrammarError(failure)),
      (verbs) {
        final nextSelected = _resolveSelectedVerb(
          verbs: verbs,
          previous: prev?.selectedVerb,
        );
        final nextPrompt = _pickInitialPrompt(nextSelected, effectiveTense);

        emit(
          GrammarLoaded(
            verbs: verbs,
            selectedVerb: nextSelected,
            selectedBinyan: effectiveBinyan,
            searchQuery: effectiveQuery,
            selectedTense: effectiveTense,
            showNikkud: effectiveShowNikkud,
            drillPrompt: nextPrompt,
            lastCheckResult: null,
          ),
        );
      },
    );
  }

  /// Applies or clears the binyan chip filter (`null` resets to all binyanim).
  Future<void> filterByBinyan(Binyan? binyan) async {
    final prev = state is GrammarLoaded ? state as GrammarLoaded : null;
    final query = prev?.searchQuery ?? '';
    final tense = prev?.selectedTense ?? VerbTense.present;
    final showNikkud = prev?.showNikkud ?? true;

    final result = await _getVerbsUseCase(
      GetVerbsByBinyanParams(binyan: binyan, query: query),
    );
    if (isClosed) return;

    result.fold(
      (failure) => emit(GrammarError(failure)),
      (verbs) {
        final nextSelected = _resolveSelectedVerb(
          verbs: verbs,
          previous: prev?.selectedVerb,
        );
        emit(
          GrammarLoaded(
            verbs: verbs,
            selectedVerb: nextSelected,
            selectedBinyan: binyan,
            searchQuery: query,
            selectedTense: tense,
            showNikkud: showNikkud,
            drillPrompt: _pickInitialPrompt(nextSelected, tense),
          ),
        );
      },
    );
  }

  /// Filters loaded verbs by normalized Hebrew root/lemma or Russian translation.
  Future<void> search(String query) async {
    final prev = state is GrammarLoaded ? state as GrammarLoaded : null;
    await loadVerbs(
      binyan: prev?.selectedBinyan,
      query: query,
    );
  }

  /// Switches the active verb lexeme and resets drill feedback.
  void selectVerb(VerbLexeme verb) {
    final current = state;
    if (current is! GrammarLoaded) return;

    emit(
      current.copyWith(
        selectedVerb: verb,
        drillPrompt: _pickInitialPrompt(verb, current.selectedTense),
        clearLastCheckResult: true,
        clearTransientNotice: true,
      ),
    );
  }

  /// Switches the displayed paradigm tense and updates the active drill target.
  void selectTense(VerbTense tense) {
    final current = state;
    if (current is! GrammarLoaded) return;

    emit(
      current.copyWith(
        selectedTense: tense,
        drillPrompt: _pickInitialPrompt(current.selectedVerb, tense),
        clearLastCheckResult: true,
      ),
    );
  }

  /// Toggles nikkud visibility across Hebrew verb forms.
  void toggleNikkud() {
    final current = state;
    if (current is! GrammarLoaded) return;

    emit(current.copyWith(showNikkud: !current.showNikkud));
  }

  /// Advances to the next conjugated form within the selected verb and tense.
  void nextDrillPrompt() {
    final current = state;
    if (current is! GrammarLoaded) return;
    final verb = current.selectedVerb;
    if (verb == null) return;

    final tenseForms = verb.formsForTense(current.selectedTense);
    final pool = tenseForms.isNotEmpty ? tenseForms : verb.conjugations;
    if (pool.isEmpty) return;

    final currentIndex = current.drillPrompt == null
        ? -1
        : pool.indexOf(current.drillPrompt!);
    final nextIndex = (currentIndex + 1) % pool.length;

    emit(
      current.copyWith(
        drillPrompt: pool[nextIndex],
        clearLastCheckResult: true,
        clearTransientNotice: true,
      ),
    );
  }

  /// Checks [userInput] against the active drill form and logs the practice attempt.
  Future<void> checkDrillAnswer(String userInput) async {
    final current = state;
    if (current is! GrammarLoaded) return;
    final verb = current.selectedVerb;
    final prompt = current.drillPrompt;
    if (verb == null || prompt == null) return;

    final checkRes = _checkConjugationUseCase(
      CheckVerbConjugationParams(
        verb: verb,
        tense: prompt.tense,
        person: prompt.person,
        userInput: userInput,
      ),
    );

    await checkRes.fold(
      (failure) async {
        emit(current.copyWith(transientNotice: failure.message));
      },
      (result) async {
        emit(
          current.copyWith(
            lastCheckResult: result,
            clearTransientNotice: true,
          ),
        );

        final logRes = await _recordPracticeUseCase(
          RecordGrammarPracticeParams(
            verbId: verb.id,
            tense: prompt.tense,
            person: prompt.person,
            isCorrect: result.isCorrect,
            practicedAt: _clock(),
          ),
        );
        logRes.fold(
          (Failure failure) => _logger.warning(
            _tag,
            'Non-fatal error logging grammar drill outcome: ${failure.message}',
          ),
          (_) {},
        );
      },
    );
  }

  /// Speaks a vocalized Hebrew verb form via TTS fallback audio service.
  Future<void> speakHebrew(String vocalizedHebrew) async {
    final current = state;
    if (current is! GrammarLoaded) return;
    final trimmed = vocalizedHebrew.trim();
    if (trimmed.isEmpty) return;

    final isSameAndPlaying = current.activeSpokenHebrew == trimmed &&
        current.audioStatus == AudioPlaybackStatus.playing;
    if (isSameAndPlaying) {
      await _audioService.stop();
      return;
    }

    emit(
      current.copyWith(
        activeSpokenHebrew: trimmed,
        audioStatus: AudioPlaybackStatus.loading,
      ),
    );

    final playRes = await _audioService.playWithTtsFallback(
      sourcePath: null,
      fallbackHebrewText: trimmed,
    );
    if (isClosed) return;

    playRes.fold(
      (failure) {
        final latest = state;
        if (latest is GrammarLoaded) {
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

  /// Saves a verb lexeme (with shoresh and binyan) into FSRS in one tap.
  Future<void> saveVerbToSrs(VerbLexeme verb) async {
    final current = state;
    final useCase = _addCardToSrsUseCase;
    if (current is! GrammarLoaded || useCase == null) return;

    final targetHebrew = verb.infinitive?.vocalized ?? verb.lemma.vocalized;
    final res = await useCase(
      AddCardToSrsParams(
        id: 'custom_verb_${verb.id}',
        hebrewVocalized: targetHebrew,
        russianTranslation: verb.russianMeaning,
        root: verb.root,
        binyan: verb.binyan,
        category: LexicalCategory.verb,
        exampleHebrewVocalized: verb.conjugations.isNotEmpty
            ? verb.conjugations.first.form.vocalized
            : null,
        exampleRussian: verb.grammarNotesRu,
        attribution: verb.attribution,
      ),
    );
    if (isClosed) return;

    final latest = state;
    if (latest is! GrammarLoaded) return;
    res.fold(
      (Failure failure) =>
          emit(latest.copyWith(transientNotice: failure.message)),
      (bool added) => emit(
        latest.copyWith(
          transientNotice: added
              ? 'Глагол добавлен в колоду FSRS!'
              : 'Этот глагол уже есть в колоде FSRS',
        ),
      ),
    );
  }

  /// Saves a specific conjugated verb form as an FSRS flashcard in one tap.
  Future<void> saveConjugatedFormToSrs(
    VerbLexeme verb,
    ConjugatedForm form,
  ) async {
    final current = state;
    final useCase = _addCardToSrsUseCase;
    if (current is! GrammarLoaded || useCase == null) return;

    final res = await useCase(
      AddCardToSrsParams(
        id: 'custom_form_${verb.id}_${form.tense.id}_${form.person.id}',
        hebrewVocalized: form.form.vocalized,
        russianTranslation:
            '${verb.russianMeaning} (${form.tense.russianLabel}, ${form.person.russianLabel})',
        root: verb.root,
        binyan: verb.binyan,
        category: LexicalCategory.verb,
        exampleHebrewVocalized:
            verb.infinitive?.vocalized ?? verb.lemma.vocalized,
        exampleRussian: '${verb.russianMeaning} (${form.transliteration})',
        attribution: verb.attribution,
      ),
    );
    if (isClosed) return;

    final latest = state;
    if (latest is! GrammarLoaded) return;
    res.fold(
      (Failure failure) =>
          emit(latest.copyWith(transientNotice: failure.message)),
      (bool added) => emit(
        latest.copyWith(
          transientNotice: added
              ? 'Форма «${form.form.normalized}» добавлена в FSRS!'
              : 'Эта форма уже есть в колоде FSRS',
        ),
      ),
    );
  }

  /// Clears any shown SnackBar notice after it is consumed by the UI.
  void clearTransientNotice() {
    final current = state;
    if (current is! GrammarLoaded || current.transientNotice == null) return;
    emit(current.copyWith(clearTransientNotice: true));
  }

  void _handleAudioEvent(AudioPlaybackEvent event) {
    if (isClosed) return;
    final current = state;
    if (current is! GrammarLoaded) return;
    final activeHebrew = current.activeSpokenHebrew;
    if (activeHebrew == null) return;

    final expectedKey = 'tts://he-IL/$activeHebrew';
    if (event.sourcePath != expectedKey) return;

    emit(current.copyWith(audioStatus: event.status));
  }

  VerbLexeme? _resolveSelectedVerb({
    required List<VerbLexeme> verbs,
    required VerbLexeme? previous,
  }) {
    if (verbs.isEmpty) return null;
    if (previous != null) {
      for (final item in verbs) {
        if (item.id == previous.id) return item;
      }
    }
    return verbs.first;
  }

  ConjugatedForm? _pickInitialPrompt(VerbLexeme? verb, VerbTense tense) {
    if (verb == null || verb.conjugations.isEmpty) return null;
    final matching = verb.formsForTense(tense);
    return matching.isNotEmpty ? matching.first : verb.conjugations.first;
  }

  @override
  Future<void> close() async {
    await _audioSubscription?.cancel();
    return super.close();
  }
}
