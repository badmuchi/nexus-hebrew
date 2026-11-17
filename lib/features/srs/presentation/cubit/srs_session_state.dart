import 'package:equatable/equatable.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/fsrs_models.dart';
import '../../domain/entities/srs_card.dart';

enum SrsStudyMode {
  flashcard,
  typing,
}

sealed class SrsSessionState extends Equatable {
  const SrsSessionState();

  @override
  List<Object?> get props => const [];
}

final class SrsSessionInitial extends SrsSessionState {
  const SrsSessionInitial();
}

final class SrsSessionLoading extends SrsSessionState {
  const SrsSessionLoading();
}

final class SrsSessionEmpty extends SrsSessionState {
  final int reviewedCount;
  final bool isImporting;
  final String? transientNotice;

  const SrsSessionEmpty({
    this.reviewedCount = 0,
    this.isImporting = false,
    this.transientNotice,
  });

  SrsSessionEmpty copyWith({
    int? reviewedCount,
    bool? isImporting,
    String? transientNotice,
    bool clearTransientNotice = false,
  }) {
    return SrsSessionEmpty(
      reviewedCount: reviewedCount ?? this.reviewedCount,
      isImporting: isImporting ?? this.isImporting,
      transientNotice: clearTransientNotice
          ? null
          : (transientNotice ?? this.transientNotice),
    );
  }

  @override
  List<Object?> get props => [reviewedCount, isImporting, transientNotice];
}

final class SrsSessionActive extends SrsSessionState {
  final List<SrsCard> queue;
  final int reviewedCount;
  final SrsStudyMode studyMode;
  final bool isAnswerRevealed;
  final bool showNikkud;
  final TypingAnswerEvaluation? typingEvaluation;
  final Map<FsrsRating, int> intervalPreview;
  final AudioPlaybackStatus audioStatus;
  final bool isSubmittingReview;
  final bool isImporting;
  final String? transientNotice;

  SrsSessionActive({
    required List<SrsCard> queue,
    this.reviewedCount = 0,
    this.studyMode = SrsStudyMode.flashcard,
    this.isAnswerRevealed = false,
    this.showNikkud = true,
    this.typingEvaluation,
    Map<FsrsRating, int> intervalPreview = const {},
    this.audioStatus = AudioPlaybackStatus.idle,
    this.isSubmittingReview = false,
    this.isImporting = false,
    this.transientNotice,
  })  : assert(queue.isNotEmpty),
        queue = List<SrsCard>.unmodifiable(queue),
        intervalPreview = Map<FsrsRating, int>.unmodifiable(intervalPreview);

  SrsCard get currentCard => queue.first;
  int get remainingCount => queue.length;

  SrsSessionActive copyWith({
    List<SrsCard>? queue,
    int? reviewedCount,
    SrsStudyMode? studyMode,
    bool? isAnswerRevealed,
    bool? showNikkud,
    TypingAnswerEvaluation? typingEvaluation,
    bool clearTypingEvaluation = false,
    Map<FsrsRating, int>? intervalPreview,
    AudioPlaybackStatus? audioStatus,
    bool? isSubmittingReview,
    bool? isImporting,
    String? transientNotice,
    bool clearTransientNotice = false,
  }) {
    return SrsSessionActive(
      queue: queue ?? this.queue,
      reviewedCount: reviewedCount ?? this.reviewedCount,
      studyMode: studyMode ?? this.studyMode,
      isAnswerRevealed: isAnswerRevealed ?? this.isAnswerRevealed,
      showNikkud: showNikkud ?? this.showNikkud,
      typingEvaluation: clearTypingEvaluation
          ? null
          : (typingEvaluation ?? this.typingEvaluation),
      intervalPreview: intervalPreview ?? this.intervalPreview,
      audioStatus: audioStatus ?? this.audioStatus,
      isSubmittingReview: isSubmittingReview ?? this.isSubmittingReview,
      isImporting: isImporting ?? this.isImporting,
      transientNotice: clearTransientNotice
          ? null
          : (transientNotice ?? this.transientNotice),
    );
  }

  @override
  List<Object?> get props => [
        queue,
        reviewedCount,
        studyMode,
        isAnswerRevealed,
        showNikkud,
        typingEvaluation,
        intervalPreview,
        audioStatus,
        isSubmittingReview,
        isImporting,
        transientNotice,
      ];
}

final class SrsSessionError extends SrsSessionState {
  final Failure failure;

  const SrsSessionError(this.failure);

  @override
  List<Object?> get props => [failure];
}
