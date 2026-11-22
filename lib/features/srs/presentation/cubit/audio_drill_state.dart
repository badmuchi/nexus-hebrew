import 'package:equatable/equatable.dart';

import '../../domain/entities/audio_drill_config.dart';
import '../../domain/entities/srs_card.dart';

sealed class AudioDrillState extends Equatable {
  const AudioDrillState();

  @override
  List<Object?> get props => [];
}

final class AudioDrillInitial extends AudioDrillState {
  const AudioDrillInitial();
}

final class AudioDrillLoading extends AudioDrillState {
  const AudioDrillLoading();
}

final class AudioDrillActive extends AudioDrillState {
  final List<SrsCard> playlist;
  final int currentIndex;
  final AudioDrillPhase phase;
  final double thinkingSecondsLeft;
  final double thinkingProgress; // 0.0 to 1.0
  final bool isPlaying;
  final AudioDrillConfig config;
  final double playbackSpeed;
  final int completedCardsCount;
  final int xpEarned;

  const AudioDrillActive({
    required this.playlist,
    required this.currentIndex,
    required this.phase,
    required this.thinkingSecondsLeft,
    required this.thinkingProgress,
    required this.isPlaying,
    required this.config,
    required this.playbackSpeed,
    required this.completedCardsCount,
    required this.xpEarned,
  });

  SrsCard? get currentCard =>
      (currentIndex >= 0 && currentIndex < playlist.length)
          ? playlist[currentIndex]
          : null;

  AudioDrillActive copyWith({
    List<SrsCard>? playlist,
    int? currentIndex,
    AudioDrillPhase? phase,
    double? thinkingSecondsLeft,
    double? thinkingProgress,
    bool? isPlaying,
    AudioDrillConfig? config,
    double? playbackSpeed,
    int? completedCardsCount,
    int? xpEarned,
  }) {
    return AudioDrillActive(
      playlist: playlist ?? this.playlist,
      currentIndex: currentIndex ?? this.currentIndex,
      phase: phase ?? this.phase,
      thinkingSecondsLeft: thinkingSecondsLeft ?? this.thinkingSecondsLeft,
      thinkingProgress: thinkingProgress ?? this.thinkingProgress,
      isPlaying: isPlaying ?? this.isPlaying,
      config: config ?? this.config,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      completedCardsCount: completedCardsCount ?? this.completedCardsCount,
      xpEarned: xpEarned ?? this.xpEarned,
    );
  }

  @override
  List<Object?> get props => [
        playlist,
        currentIndex,
        phase,
        thinkingSecondsLeft,
        thinkingProgress,
        isPlaying,
        config,
        playbackSpeed,
        completedCardsCount,
        xpEarned,
      ];
}

final class AudioDrillCompleted extends AudioDrillState {
  final int totalCardsDrilled;
  final int xpEarned;

  const AudioDrillCompleted({
    required this.totalCardsDrilled,
    required this.xpEarned,
  });

  @override
  List<Object?> get props => [totalCardsDrilled, xpEarned];
}

final class AudioDrillError extends AudioDrillState {
  final String message;

  const AudioDrillError(this.message);

  @override
  List<Object?> get props => [message];
}
