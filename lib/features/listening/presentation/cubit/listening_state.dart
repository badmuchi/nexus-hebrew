import 'package:equatable/equatable.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/listening_exercise.dart';

enum ListeningAnswerMode {
  puzzle,
  keyboard,
}

/// Base sealed UI state for the Listening & Dictation feature.
sealed class ListeningState extends Equatable {
  const ListeningState();

  @override
  List<Object?> get props => [];
}

/// Initial state before listening exercises are loaded.
final class ListeningInitial extends ListeningState {
  const ListeningInitial();
}

/// Loading state while seeding or loading listening exercises.
final class ListeningLoading extends ListeningState {
  const ListeningLoading();
}

/// Unrecoverable load error state.
final class ListeningError extends ListeningState {
  const ListeningError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// Active listening & dictation study workspace.
final class ListeningLoaded extends ListeningState {
  ListeningLoaded({
    required List<ListeningExercise> exercises,
    this.currentIndex = 0,
    this.selectedDifficulty,
    this.playbackSpeed = 1.0,
    this.audioStatus = AudioPlaybackStatus.idle,
    this.showFocusWordsHint = false,
    this.showTranscript = false,
    this.showNikkud = true,
    this.answerMode = ListeningAnswerMode.puzzle,
    this.lastComparison,
    this.isImporting = false,
    this.transientNotice,
  }) : exercises = List<ListeningExercise>.unmodifiable(exercises);

  final List<ListeningExercise> exercises;
  final int currentIndex;
  final ListeningDifficulty? selectedDifficulty;
  final double playbackSpeed;
  final AudioPlaybackStatus audioStatus;
  final bool showFocusWordsHint;
  final bool showTranscript;
  final bool showNikkud;
  final ListeningAnswerMode answerMode;
  final DictationComparison? lastComparison;
  final bool isImporting;
  final String? transientNotice;

  /// Currently selected exercise or null if the filtered list is empty.
  ListeningExercise? get currentExercise {
    if (exercises.isEmpty ||
        currentIndex < 0 ||
        currentIndex >= exercises.length) {
      return null;
    }
    return exercises[currentIndex];
  }

  /// Creates an updated immutable copy of [ListeningLoaded].
  ListeningLoaded copyWith({
    List<ListeningExercise>? exercises,
    int? currentIndex,
    ListeningDifficulty? selectedDifficulty,
    bool clearSelectedDifficulty = false,
    double? playbackSpeed,
    AudioPlaybackStatus? audioStatus,
    bool? showFocusWordsHint,
    bool? showTranscript,
    bool? showNikkud,
    ListeningAnswerMode? answerMode,
    DictationComparison? lastComparison,
    bool clearLastComparison = false,
    bool? isImporting,
    String? transientNotice,
    bool clearTransientNotice = false,
  }) {
    return ListeningLoaded(
      exercises: exercises ?? this.exercises,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedDifficulty: clearSelectedDifficulty
          ? null
          : (selectedDifficulty ?? this.selectedDifficulty),
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      audioStatus: audioStatus ?? this.audioStatus,
      showFocusWordsHint: showFocusWordsHint ?? this.showFocusWordsHint,
      showTranscript: showTranscript ?? this.showTranscript,
      showNikkud: showNikkud ?? this.showNikkud,
      answerMode: answerMode ?? this.answerMode,
      lastComparison: clearLastComparison
          ? null
          : (lastComparison ?? this.lastComparison),
      isImporting: isImporting ?? this.isImporting,
      transientNotice: clearTransientNotice
          ? null
          : (transientNotice ?? this.transientNotice),
    );
  }

  @override
  List<Object?> get props => [
        exercises,
        currentIndex,
        selectedDifficulty,
        playbackSpeed,
        audioStatus,
        showFocusWordsHint,
        showTranscript,
        showNikkud,
        answerMode,
        lastComparison,
        isImporting,
        transientNotice,
      ];
}
