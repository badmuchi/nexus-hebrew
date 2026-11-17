import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/learning_progress_summary.dart';
import '../../domain/usecases/get_learning_progress.dart';
import '../../domain/usecases/search_hebrew_library.dart';
import 'progress_state.dart';

typedef ProgressClockUtc = DateTime Function();

/// State manager for learner progress analytics and global shoresh/Hebrew search.
final class ProgressCubit extends Cubit<ProgressState> {
  ProgressCubit({
    required GetLearningProgressUseCase getProgressUseCase,
    required SearchHebrewLibraryUseCase searchLibraryUseCase,
    AddCardToSrsUseCase? addCardToSrsUseCase,
    required AudioPlaybackService audioService,
    ProgressClockUtc? clock,
  })  : _getProgressUseCase = getProgressUseCase,
        _searchLibraryUseCase = searchLibraryUseCase,
        _addCardToSrsUseCase = addCardToSrsUseCase,
        _audioService = audioService,
        _clock = clock ?? (() => DateTime.now().toUtc()),
        super(const ProgressInitial()) {
    _audioSubscription = _audioService.statusStream.listen(_handleAudioEvent);
  }

  final GetLearningProgressUseCase _getProgressUseCase;
  final SearchHebrewLibraryUseCase _searchLibraryUseCase;
  final AddCardToSrsUseCase? _addCardToSrsUseCase;
  final AudioPlaybackService _audioService;
  final ProgressClockUtc _clock;

  StreamSubscription<AudioPlaybackEvent>? _audioSubscription;

  /// Loads or refreshes aggregated progress metrics across all local modules.
  Future<void> loadProgress() async {
    final prev = state is ProgressLoaded ? state as ProgressLoaded : null;
    if (prev == null) {
      emit(const ProgressLoading());
    }

    final result = await _getProgressUseCase(
      GetLearningProgressParams(asOf: _clock()),
    );
    if (isClosed) return;

    result.fold(
      (Failure failure) => emit(ProgressError(failure)),
      (LearningProgressSummary summary) {
        if (prev != null) {
          emit(prev.copyWith(summary: summary));
        } else {
          emit(ProgressLoaded(summary: summary));
        }
      },
    );
  }

  /// Searches across FSRS, grammar, dialogue, and listening items.
  Future<void> search(String query) async {
    final current = state;
    if (current is! ProgressLoaded) return;

    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      emit(
        current.copyWith(
          searchQuery: '',
          searchResults: const <GlobalHebrewSearchResult>[],
          isSearching: false,
          clearTransientNotice: true,
        ),
      );
      return;
    }

    emit(
      current.copyWith(
        searchQuery: query,
        isSearching: true,
        clearTransientNotice: true,
      ),
    );

    final result = await _searchLibraryUseCase(
      SearchHebrewLibraryParams(query: trimmed),
    );
    if (isClosed) return;

    final latest = state;
    if (latest is! ProgressLoaded) return;

    result.fold(
      (Failure failure) => emit(
        latest.copyWith(
          isSearching: false,
          transientNotice: failure.message,
        ),
      ),
      (List<GlobalHebrewSearchResult> hits) => emit(
        latest.copyWith(
          searchResults: hits,
          isSearching: false,
        ),
      ),
    );
  }

  /// Pronounces a search result using its audio URL or he-IL TTS fallback.
  Future<void> speakHit(GlobalHebrewSearchResult hit) async {
    final current = state;
    if (current is! ProgressLoaded) return;

    final samePlaying = current.activeSpokenHebrew == hit.hebrew.vocalized &&
        current.audioStatus == AudioPlaybackStatus.playing;
    if (samePlaying) {
      await _audioService.stop();
      return;
    }

    emit(
      current.copyWith(
        activeSpokenHebrew: hit.hebrew.vocalized,
        activeAudioUrl: hit.audioUrl,
        clearActiveAudioUrl: hit.audioUrl == null,
        audioStatus: AudioPlaybackStatus.loading,
      ),
    );

    final res = await _audioService.playWithTtsFallback(
      sourcePath: hit.audioUrl,
      fallbackHebrewText: hit.hebrew.vocalized,
    );
    if (isClosed) return;

    res.fold(
      (Failure failure) {
        final latest = state;
        if (latest is ProgressLoaded) {
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

  /// Adds a search hit directly to the user's FSRS flashcard deck in one tap.
  Future<void> saveHitToSrs(GlobalHebrewSearchResult hit) async {
    final current = state;
    final useCase = _addCardToSrsUseCase;
    if (current is! ProgressLoaded || useCase == null) return;

    final category = hit.kind == SearchSourceKind.grammar
        ? LexicalCategory.verb
        : LexicalCategory.phrase;

    final res = await useCase(
      AddCardToSrsParams(
        id: 'custom_search_${hit.kind.name}_${hit.id}',
        hebrewVocalized: hit.hebrew.vocalized,
        russianTranslation: hit.russianMeaning,
        root: hit.root,
        binyan: hit.binyan,
        category: category,
        audioUrl: hit.audioUrl,
        exampleRussian: hit.contextNote,
      ),
    );
    if (isClosed) return;

    switch (res) {
      case Error(:final failure):
        final latest = state;
        if (latest is ProgressLoaded) {
          emit(latest.copyWith(transientNotice: failure.message));
        }
      case Success(data: final added):
        final summaryRes = await _getProgressUseCase(
          GetLearningProgressParams(asOf: _clock()),
        );
        if (isClosed) return;

        final latest = state;
        if (latest is! ProgressLoaded) return;

        final updatedSummary = summaryRes.getOrNull() ?? latest.summary;
        emit(
          latest.copyWith(
            summary: updatedSummary,
            transientNotice: added
                ? 'Добавлено в колоду FSRS!'
                : 'Уже есть в твоей колоде FSRS',
          ),
        );
    }
  }

  /// Clears consumed SnackBar notices.
  void clearTransientNotice() {
    final current = state;
    if (current is! ProgressLoaded || current.transientNotice == null) return;
    emit(current.copyWith(clearTransientNotice: true));
  }

  void _handleAudioEvent(AudioPlaybackEvent event) {
    if (isClosed) return;
    final current = state;
    if (current is! ProgressLoaded) return;
    final spoken = current.activeSpokenHebrew;
    if (spoken == null) return;

    final expectedTts = 'tts://he-IL/$spoken';
    final matches =
        event.sourcePath == current.activeAudioUrl ||
            event.sourcePath == expectedTts;
    if (!matches) return;

    emit(current.copyWith(audioStatus: event.status));
  }

  @override
  Future<void> close() async {
    await _audioSubscription?.cancel();
    return super.close();
  }
}
