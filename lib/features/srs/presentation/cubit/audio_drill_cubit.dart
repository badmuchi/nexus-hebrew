import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../domain/entities/audio_drill_config.dart';
import '../../domain/entities/fsrs_models.dart';
import '../../domain/entities/srs_card.dart';
import 'audio_drill_state.dart';

/// Cubit managing the hands-free audio drill loop for FSRS flashcards.
final class AudioDrillCubit extends Cubit<AudioDrillState> {
  final AudioPlaybackService? _audioService;
  int _runToken = 0;
  bool _isDisposed = false;

  AudioDrillCubit({
    AudioPlaybackService? audioService,
  })  : _audioService = audioService,
        super(const AudioDrillInitial());

  AudioPlaybackService? get audioService => _audioService;

  @override
  Future<void> close() async {
    _isDisposed = true;
    _runToken++;
    unawaited(_audioService?.stop());
    return super.close();
  }

  /// Initializes the playlist from given cards and starts the drill loop.
  void startSession({
    required List<SrsCard> allCards,
    AudioDrillConfig config = const AudioDrillConfig(),
  }) {
    if (allCards.isEmpty) {
      emit(const AudioDrillError('В колоде нет карточек для тренировки'));
      return;
    }

    final filtered = _filterCards(allCards, config.filter);
    final playlist = filtered.isNotEmpty ? filtered : allCards.take(20).toList();

    final activeState = AudioDrillActive(
      playlist: playlist,
      currentIndex: 0,
      phase: AudioDrillPhase.prompt,
      thinkingSecondsLeft: config.pauseSeconds,
      thinkingProgress: 0.0,
      isPlaying: true,
      config: config,
      playbackSpeed: _audioService?.currentSpeed ?? 1.0,
      completedCardsCount: 0,
      xpEarned: 0,
    );

    emit(activeState);
    _runCycle(++_runToken);
  }

  List<SrsCard> _filterCards(List<SrsCard> cards, AudioDrillFilter filter) {
    switch (filter) {
      case AudioDrillFilter.weakWordsOnly:
        final weak = cards.where((c) {
          final isWeakStability = c.memory.stability < 3.0;
          final hasLapses = c.memory.lapses > 0;
          final isRelearning = c.memory.state == FsrsCardState.relearning ||
              c.memory.state == FsrsCardState.learning;
          return isWeakStability || hasLapses || isRelearning;
        }).toList();

        // Sort by lowest stability and most lapses
        weak.sort((a, b) {
          final lapseComp = b.memory.lapses.compareTo(a.memory.lapses);
          if (lapseComp != 0) return lapseComp;
          return a.memory.stability.compareTo(b.memory.stability);
        });
        return weak;

      case AudioDrillFilter.dueTodayOnly:
        final now = DateTime.now().toUtc();
        return cards.where((c) => c.memory.dueAt.isBefore(now)).toList();

      case AudioDrillFilter.allDeck:
        return List<SrsCard>.from(cards);
    }
  }

  void togglePlayPause() {
    final s = state;
    if (s is! AudioDrillActive) return;

    if (s.isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void play() {
    final s = state;
    if (s is! AudioDrillActive || s.isPlaying) return;

    emit(s.copyWith(isPlaying: true));
    _runCycle(++_runToken);
  }

  void pause() {
    final s = state;
    if (s is! AudioDrillActive || !s.isPlaying) return;

    _runToken++;
    unawaited(_audioService?.stop());
    emit(s.copyWith(isPlaying: false));
  }

  void next() {
    final s = state;
    if (s is! AudioDrillActive) return;

    _runToken++;
    unawaited(_audioService?.stop());

    final nextIndex = (s.currentIndex + 1 < s.playlist.length)
        ? s.currentIndex + 1
        : (s.config.isLooping ? 0 : s.currentIndex);

    emit(s.copyWith(
      currentIndex: nextIndex,
      phase: AudioDrillPhase.prompt,
      thinkingSecondsLeft: s.config.pauseSeconds,
      thinkingProgress: 0.0,
    ));

    if (s.isPlaying) {
      _runCycle(_runToken);
    }
  }

  void previous() {
    final s = state;
    if (s is! AudioDrillActive) return;

    _runToken++;
    unawaited(_audioService?.stop());

    final prevIndex = (s.currentIndex > 0)
        ? s.currentIndex - 1
        : s.playlist.length - 1;

    emit(s.copyWith(
      currentIndex: prevIndex,
      phase: AudioDrillPhase.prompt,
      thinkingSecondsLeft: s.config.pauseSeconds,
      thinkingProgress: 0.0,
    ));

    if (s.isPlaying) {
      _runCycle(_runToken);
    }
  }

  void shuffle() {
    final s = state;
    if (s is! AudioDrillActive) return;

    _runToken++;
    unawaited(_audioService?.stop());

    final shuffled = List<SrsCard>.from(s.playlist)..shuffle();
    emit(s.copyWith(
      playlist: shuffled,
      currentIndex: 0,
      phase: AudioDrillPhase.prompt,
      thinkingSecondsLeft: s.config.pauseSeconds,
      thinkingProgress: 0.0,
    ));

    if (s.isPlaying) {
      _runCycle(_runToken);
    }
  }

  void updateConfig(AudioDrillConfig newConfig) {
    final s = state;
    if (s is! AudioDrillActive) return;

    emit(s.copyWith(config: newConfig));
  }

  Future<void> setPlaybackSpeed(double speed) async {
    final s = state;
    if (s is! AudioDrillActive) return;

    await _audioService?.setPlaybackSpeed(speed);
    emit(s.copyWith(playbackSpeed: speed));
  }

  Future<void> _runCycle(int token) async {
    while (!_isDisposed && token == _runToken) {
      final s = state;
      if (s is! AudioDrillActive || !s.isPlaying) break;

      final card = s.currentCard;
      if (card == null) break;

      // ─── 1. PROMPT PHASE ──────────────────────────
      emit(s.copyWith(
        phase: AudioDrillPhase.prompt,
        thinkingProgress: 0.0,
        thinkingSecondsLeft: s.config.pauseSeconds,
      ));

      if (s.config.direction == AudioDrillDirection.hebrewToRussian) {
        if (_audioService != null) {
          await _audioService.playWithTtsFallback(
            sourcePath: card.audioUrl,
            fallbackHebrewText: card.hebrew.vocalized,
          );
        } else {
          await Future<void>.delayed(const Duration(milliseconds: 900));
        }
      } else {
        // Russian to Hebrew: wait brief moment for Russian prompt display
        await Future<void>.delayed(const Duration(milliseconds: 1000));
      }

      if (_isDisposed || token != _runToken) break;

      // ─── 2. THINKING PHASE (COUNTDOWN) ───────────
      final pauseSec = s.config.pauseSeconds;
      final totalTicks = (pauseSec * 10).round().clamp(10, 100);
      for (int i = 0; i <= totalTicks; i++) {
        if (_isDisposed || token != _runToken) break;
        final curr = state;
        if (curr is! AudioDrillActive || !curr.isPlaying) break;

        final elapsedRatio = i / totalTicks;
        final timeLeft = (pauseSec * (1.0 - elapsedRatio)).clamp(0.0, pauseSec);

        emit(curr.copyWith(
          phase: AudioDrillPhase.thinking,
          thinkingProgress: elapsedRatio,
          thinkingSecondsLeft: timeLeft,
        ));

        await Future<void>.delayed(const Duration(milliseconds: 100));
      }

      if (_isDisposed || token != _runToken) break;

      // ─── 3. ANSWER PHASE ─────────────────────────
      final sAnswer = state;
      if (sAnswer is! AudioDrillActive || !sAnswer.isPlaying) break;

      emit(sAnswer.copyWith(
        phase: AudioDrillPhase.answer,
        thinkingProgress: 1.0,
        thinkingSecondsLeft: 0.0,
      ));

      if (s.config.direction == AudioDrillDirection.hebrewToRussian) {
        // Translation displayed on screen; short pause to register
        await Future<void>.delayed(const Duration(milliseconds: 1500));
      } else {
        // Play Hebrew pronunciation of the answer
        if (_audioService != null) {
          await _audioService.playWithTtsFallback(
            sourcePath: card.audioUrl,
            fallbackHebrewText: card.hebrew.vocalized,
          );
        } else {
          await Future<void>.delayed(const Duration(milliseconds: 1200));
        }
        await Future<void>.delayed(const Duration(milliseconds: 800));
      }

      if (_isDisposed || token != _runToken) break;

      // ─── 4. EXAMPLE PHASE (OPTIONAL) ─────────────
      if (s.config.includeExamples && card.exampleHebrew != null) {
        final sEx = state;
        if (sEx is AudioDrillActive && sEx.isPlaying) {
          emit(sEx.copyWith(phase: AudioDrillPhase.example));

          if (_audioService != null) {
            await _audioService.playWithTtsFallback(
              sourcePath: null,
              fallbackHebrewText: card.exampleHebrew!.vocalized,
            );
          }
          await Future<void>.delayed(const Duration(milliseconds: 1400));
        }
      }

      if (_isDisposed || token != _runToken) break;

      // ─── 5. TRANSITION & ADVANCE ─────────────────
      final sAdv = state;
      if (sAdv is! AudioDrillActive || !sAdv.isPlaying) break;

      emit(sAdv.copyWith(
        phase: AudioDrillPhase.transition,
        completedCardsCount: sAdv.completedCardsCount + 1,
        xpEarned: sAdv.xpEarned + 2,
      ));

      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (_isDisposed || token != _runToken) break;

      // Check if reached end of playlist
      if (sAdv.currentIndex + 1 >= sAdv.playlist.length) {
        if (sAdv.config.isLooping) {
          emit(sAdv.copyWith(
            currentIndex: 0,
            phase: AudioDrillPhase.prompt,
          ));
        } else {
          emit(AudioDrillCompleted(
            totalCardsDrilled: sAdv.completedCardsCount + 1,
            xpEarned: sAdv.xpEarned + 2,
          ));
          break;
        }
      } else {
        emit(sAdv.copyWith(
          currentIndex: sAdv.currentIndex + 1,
          phase: AudioDrillPhase.prompt,
        ));
      }
    }
  }
}
