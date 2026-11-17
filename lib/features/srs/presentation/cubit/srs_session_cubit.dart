import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/entities/fsrs_models.dart';
import '../../domain/services/fsrs_scheduler.dart';
import '../../domain/usecases/check_hebrew_typed_answer.dart';
import '../../domain/usecases/get_due_srs_cards.dart';
import '../../domain/usecases/import_open_tatoeba_cards.dart';
import '../../domain/usecases/review_srs_card.dart';
import 'srs_session_state.dart';

typedef ClockUtc = DateTime Function();

final class SrsSessionCubit extends Cubit<SrsSessionState> {
  static const String _tag = 'SrsSessionCubit';

  final GetDueSrsCardsUseCase _getDueCardsUseCase;
  final ReviewSrsCardUseCase _reviewCardUseCase;
  final CheckHebrewTypedAnswerUseCase _checkTypedAnswerUseCase;
  final ImportOpenTatoebaCardsUseCase _importTatoebaCardsUseCase;
  final FsrsScheduler _scheduler;
  final AudioPlaybackService _audioService;
  final AppLogger _logger;
  final ClockUtc _clock;

  StreamSubscription<AudioPlaybackEvent>? _audioSubscription;

  SrsSessionCubit({
    required GetDueSrsCardsUseCase getDueCardsUseCase,
    required ReviewSrsCardUseCase reviewCardUseCase,
    required CheckHebrewTypedAnswerUseCase checkTypedAnswerUseCase,
    required ImportOpenTatoebaCardsUseCase importTatoebaCardsUseCase,
    required AudioPlaybackService audioService,
    required AppLogger logger,
    FsrsScheduler scheduler = const FsrsScheduler(),
    ClockUtc? clock,
  })  : _getDueCardsUseCase = getDueCardsUseCase,
        _reviewCardUseCase = reviewCardUseCase,
        _checkTypedAnswerUseCase = checkTypedAnswerUseCase,
        _importTatoebaCardsUseCase = importTatoebaCardsUseCase,
        _audioService = audioService,
        _logger = logger,
        _scheduler = scheduler,
        _clock = clock ?? (() => DateTime.now().toUtc()),
        super(const SrsSessionInitial()) {
    _audioSubscription = _audioService.statusStream.listen(_handleAudioEvent);
  }

  Future<void> loadDueCards({int limit = 20}) async {
    final prevMode = state is SrsSessionActive
        ? (state as SrsSessionActive).studyMode
        : SrsStudyMode.flashcard;
    final prevShowNikkud = state is SrsSessionActive
        ? (state as SrsSessionActive).showNikkud
        : true;
    final prevReviewedCount = switch (state) {
      SrsSessionActive(:final reviewedCount) => reviewedCount,
      SrsSessionEmpty(:final reviewedCount) => reviewedCount,
      _ => 0,
    };

    await _audioService.stop();
    if (isClosed) return;

    emit(const SrsSessionLoading());

    final now = _clock();
    final result = await _getDueCardsUseCase.execute(asOf: now, limit: limit);
    if (isClosed) return;

    result.fold(
      (failure) {
        _logger.warning(
          _tag,
          'Failed to load due SRS cards',
          failure: failure,
        );
        emit(SrsSessionError(failure));
      },
      (cards) {
        if (cards.isEmpty) {
          emit(SrsSessionEmpty(reviewedCount: prevReviewedCount));
          return;
        }
        emit(
          SrsSessionActive(
            queue: cards,
            reviewedCount: prevReviewedCount,
            studyMode: prevMode,
            showNikkud: prevShowNikkud,
            intervalPreview: _scheduler.previewIntervals(
              current: cards.first.memory,
              now: now,
            ),
          ),
        );
      },
    );
  }

  void revealAnswer() {
    final current = state;
    if (current is! SrsSessionActive || current.isAnswerRevealed) {
      return;
    }
    emit(current.copyWith(isAnswerRevealed: true));
  }

  void toggleStudyMode() {
    final current = state;
    if (current is! SrsSessionActive || current.isSubmittingReview) {
      return;
    }
    final nextMode = current.studyMode == SrsStudyMode.flashcard
        ? SrsStudyMode.typing
        : SrsStudyMode.flashcard;
    emit(
      current.copyWith(
        studyMode: nextMode,
        isAnswerRevealed: false,
        clearTypingEvaluation: true,
        clearTransientNotice: true,
      ),
    );
  }

  void toggleNikkudVisibility() {
    final current = state;
    if (current is! SrsSessionActive) {
      return;
    }
    emit(current.copyWith(showNikkud: !current.showNikkud));
  }

  void submitTypedAnswer(String rawInput) {
    final current = state;
    if (current is! SrsSessionActive || current.isSubmittingReview) {
      return;
    }

    final evalRes = _checkTypedAnswerUseCase.execute(
      card: current.currentCard,
      rawUserInput: rawInput,
    );

    evalRes.fold(
      (failure) {
        emit(current.copyWith(transientNotice: failure.message));
      },
      (evaluation) {
        emit(
          current.copyWith(
            typingEvaluation: evaluation,
            isAnswerRevealed: true,
            clearTransientNotice: true,
          ),
        );
      },
    );
  }

  Future<void> rateCard(FsrsRating rating) async {
    final current = state;
    if (current is! SrsSessionActive || current.isSubmittingReview) {
      return;
    }

    emit(
      current.copyWith(
        isSubmittingReview: true,
        clearTransientNotice: true,
      ),
    );

    await _audioService.stop();
    if (isClosed) return;

    final now = _clock();
    final typedEval = current.typingEvaluation;
    final result = await _reviewCardUseCase.execute(
      card: current.currentCard,
      rating: rating,
      reviewedAt: now,
      wasTypedCheck: typedEval != null,
      wasTypedExact: typedEval?.isMatch ?? false,
    );
    if (isClosed) return;

    result.fold(
      (failure) {
        _logger.warning(
          _tag,
          'Failed to save card review for "${current.currentCard.id}"',
          failure: failure,
        );
        emit(
          current.copyWith(
            isSubmittingReview: false,
            transientNotice: failure.message,
          ),
        );
      },
      (_) {
        final nextReviewed = current.reviewedCount + 1;
        final remaining = current.queue.sublist(1);
        if (remaining.isEmpty) {
          emit(SrsSessionEmpty(reviewedCount: nextReviewed));
          return;
        }
        emit(
          SrsSessionActive(
            queue: remaining,
            reviewedCount: nextReviewed,
            studyMode: current.studyMode,
            showNikkud: current.showNikkud,
            intervalPreview: _scheduler.previewIntervals(
              current: remaining.first.memory,
              now: now,
            ),
          ),
        );
      },
    );
  }

  Future<void> playCurrentCardAudio() async {
    final current = state;
    if (current is! SrsSessionActive) {
      return;
    }

    if (current.audioStatus == AudioPlaybackStatus.playing ||
        current.audioStatus == AudioPlaybackStatus.loading) {
      await _audioService.stop();
      return;
    }

    final result = await _audioService.playWithTtsFallback(
      sourcePath: current.currentCard.audioUrl,
      fallbackHebrewText: current.currentCard.hebrew.vocalized,
    );
    if (isClosed) return;

    result.fold(
      (failure) {
        final latest = state;
        if (latest is SrsSessionActive) {
          emit(latest.copyWith(transientNotice: failure.message));
        }
      },
      (_) {},
    );
  }

  Future<void> importFromTatoeba(String rawQuery, {int limit = 10}) async {
    final active = state is SrsSessionActive ? state as SrsSessionActive : null;
    final empty = state is SrsSessionEmpty ? state as SrsSessionEmpty : null;

    if (active != null) {
      emit(active.copyWith(isImporting: true, clearTransientNotice: true));
    } else if (empty != null) {
      emit(empty.copyWith(isImporting: true, clearTransientNotice: true));
    }

    final importRes = await _importTatoebaCardsUseCase.execute(
      rawQuery: rawQuery,
      limit: limit,
    );
    if (isClosed) return;

    await importRes.fold(
      (failure) async {
        final latest = state;
        if (latest is SrsSessionActive) {
          emit(
            latest.copyWith(
              isImporting: false,
              transientNotice: failure.message,
            ),
          );
        } else if (latest is SrsSessionEmpty) {
          emit(
            latest.copyWith(
              isImporting: false,
              transientNotice: failure.message,
            ),
          );
        }
      },
      (importedCards) async {
        if (importedCards.isEmpty) {
          final latest = state;
          const notice = 'По этому запросу в Tatoeba не найдено пар иврит–русский';
          if (latest is SrsSessionActive) {
            emit(latest.copyWith(isImporting: false, transientNotice: notice));
          } else if (latest is SrsSessionEmpty) {
            emit(latest.copyWith(isImporting: false, transientNotice: notice));
          }
          return;
        }

        final now = _clock();
        final dueRes = await _getDueCardsUseCase.execute(asOf: now, limit: 25);
        if (isClosed) return;

        dueRes.fold(
          (failure) => emit(SrsSessionError(failure)),
          (cards) {
            if (cards.isEmpty) {
              emit(
                SrsSessionEmpty(
                  reviewedCount: empty?.reviewedCount ?? active?.reviewedCount ?? 0,
                  transientNotice:
                      'Загружено из Tatoeba: ${importedCards.length}',
                ),
              );
              return;
            }
            emit(
              SrsSessionActive(
                queue: cards,
                reviewedCount: active?.reviewedCount ?? empty?.reviewedCount ?? 0,
                studyMode: active?.studyMode ?? SrsStudyMode.flashcard,
                showNikkud: active?.showNikkud ?? true,
                intervalPreview: _scheduler.previewIntervals(
                  current: cards.first.memory,
                  now: now,
                ),
                transientNotice:
                    'Добавлено из Tatoeba: ${importedCards.length} карт.',
              ),
            );
          },
        );
      },
    );
  }

  void clearTransientNotice() {
    switch (state) {
      case SrsSessionActive(:final transientNotice) when transientNotice != null:
        emit(
          (state as SrsSessionActive).copyWith(clearTransientNotice: true),
        );
      case SrsSessionEmpty(:final transientNotice) when transientNotice != null:
        emit(
          (state as SrsSessionEmpty).copyWith(clearTransientNotice: true),
        );
      default:
        break;
    }
  }

  void _handleAudioEvent(AudioPlaybackEvent event) {
    if (isClosed) return;
    final current = state;
    if (current is! SrsSessionActive) return;
    final expectedTtsKey = 'tts://he-IL/${current.currentCard.hebrew.vocalized}';
    final matchesCardAudio = event.sourcePath == current.currentCard.audioUrl ||
        event.sourcePath == expectedTtsKey;
    if (!matchesCardAudio) return;
    emit(current.copyWith(audioStatus: event.status));
  }

  @override
  Future<void> close() async {
    await _audioSubscription?.cancel();
    await _audioService.stop();
    return super.close();
  }
}
