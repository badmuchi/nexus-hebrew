import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../domain/entities/audio_drill_config.dart';
import '../../domain/entities/srs_card.dart';
import '../cubit/audio_drill_cubit.dart';
import '../cubit/audio_drill_state.dart';
import '../widgets/audio_drill_config_sheet.dart';

/// Fullscreen Hands-Free Audio Drill Screen for FSRS vocabulary practice.
class AudioDrillScreen extends StatelessWidget {
  final List<SrsCard> allCards;
  final AudioPlaybackService? audioService;
  final AudioDrillConfig initialConfig;

  const AudioDrillScreen({
    super.key,
    required this.allCards,
    this.audioService,
    this.initialConfig = const AudioDrillConfig(),
  });

  static Future<void> launch(
    BuildContext context, {
    required List<SrsCard> allCards,
    AudioPlaybackService? audioService,
    AudioDrillConfig initialConfig = const AudioDrillConfig(),
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AudioDrillScreen(
          allCards: allCards,
          audioService: audioService,
          initialConfig: initialConfig,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AudioDrillCubit>(
      create: (_) => AudioDrillCubit(audioService: audioService)
        ..startSession(allCards: allCards, config: initialConfig),
      child: const _AudioDrillView(),
    );
  }
}

class _AudioDrillView extends StatelessWidget {
  const _AudioDrillView();

  void _openSettings(BuildContext context, AudioDrillActive state) async {
    final cubit = context.read<AudioDrillCubit>();
    final newConfig = await AudioDrillConfigSheet.show(
      context,
      initialConfig: state.config,
    );
    if (newConfig != null && context.mounted) {
      cubit.updateConfig(newConfig);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AudioDrillCubit>();

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        cubit.pause();
      },
      child: Scaffold(
        appBar: AppBar(
        title: const Text('FSRS Аудиотренажер 🎧'),
        actions: [
          BlocBuilder<AudioDrillCubit, AudioDrillState>(
            builder: (context, state) {
              if (state is! AudioDrillActive) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.shuffle_rounded),
                tooltip: 'Перемешать плейлист',
                onPressed: context.read<AudioDrillCubit>().shuffle,
              );
            },
          ),
          BlocBuilder<AudioDrillCubit, AudioDrillState>(
            builder: (context, state) {
              if (state is! AudioDrillActive) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Настройки тренировки',
                onPressed: () => _openSettings(context, state),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<AudioDrillCubit, AudioDrillState>(
        listener: (context, state) {
          if (state is AudioDrillError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            AudioDrillInitial() || AudioDrillLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            AudioDrillError(:final message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Назад'),
                      ),
                    ],
                  ),
                ),
              ),
            AudioDrillCompleted(:final totalCardsDrilled, :final xpEarned) =>
              _DrillCompletedView(
                totalCardsDrilled: totalCardsDrilled,
                xpEarned: xpEarned,
              ),
            AudioDrillActive() => _ActiveDrillPlayer(state: state),
          };
        },
      ),
    ),
    );
  }
}

class _ActiveDrillPlayer extends StatelessWidget {
  final AudioDrillActive state;

  const _ActiveDrillPlayer({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = state.currentCard;
    final cubit = context.read<AudioDrillCubit>();

    if (card == null) {
      return const Center(child: Text('Нет доступных карточек'));
    }

    final isHebrewPrompt =
        state.config.direction == AudioDrillDirection.hebrewToRussian;
    final isThinking = state.phase == AudioDrillPhase.thinking;
    final isAnswerRevealed = state.phase == AudioDrillPhase.answer ||
        state.phase == AudioDrillPhase.example ||
        state.phase == AudioDrillPhase.transition;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          children: [
            // Top Status Bar: Filter & Direction Chips + Progress
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.config.filter.icon,
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        state.config.filter.labelRu,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '${state.currentIndex + 1} из ${state.playlist.length}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Linear Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (state.currentIndex + 1) / state.playlist.length,
                minHeight: 4,
              ),
            ),
            const Spacer(),

            // Card Container
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Phase indicator badge
                    _PhaseBadge(
                      phase: state.phase,
                      isHebrewPrompt: isHebrewPrompt,
                    ),
                    const SizedBox(height: 20),

                    // Primary Word
                    if (isHebrewPrompt) ...[
                      // Hebrew Prompt
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          card.hebrew.vocalized,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 34,
                            height: 1.5, // Niqqud diacritic safety
                            color: theme.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (card.root != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Корень: ${card.root!.hyphenated}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ] else ...[
                      // Russian Prompt
                      Text(
                        card.russianTranslation,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 26,
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Countdown / Thinking Progress Indicator
                    SizedBox(
                      height: 72,
                      width: 72,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: isThinking
                                ? (1.0 - state.thinkingProgress)
                                : (isAnswerRevealed ? 1.0 : 0.0),
                            strokeWidth: 5,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isThinking
                                  ? Colors.amber.shade700
                                  : theme.colorScheme.primary,
                            ),
                          ),
                          if (isThinking)
                            Text(
                              '${state.thinkingSecondsLeft.toStringAsFixed(1)}с',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade800,
                              ),
                            )
                          else if (isAnswerRevealed)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                              size: 32,
                            )
                          else
                            Icon(
                              Icons.volume_up_rounded,
                              color: theme.colorScheme.primary,
                              size: 28,
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Response Side (Revealed in Answer phase)
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: isAnswerRevealed ? 1.0 : 0.0,
                      child: Column(
                        children: [
                          if (isHebrewPrompt)
                            Text(
                              card.russianTranslation,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary,
                              ),
                              textAlign: TextAlign.center,
                            )
                          else
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: Text(
                                card.hebrew.vocalized,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.primary,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          if (card.exampleHebrew != null) ...[
                            const SizedBox(height: 12),
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: Text(
                                card.exampleHebrew!.vocalized,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  height: 1.45,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Controls Dock
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Speed button
                  TextButton(
                    onPressed: () {
                      final nextSpeed = switch (state.playbackSpeed) {
                        0.75 => 1.0,
                        1.0 => 1.25,
                        _ => 0.75,
                      };
                      cubit.setPlaybackSpeed(nextSpeed);
                    },
                    child: Text(
                      '${state.playbackSpeed}x',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  // Previous button
                  IconButton(
                    iconSize: 32,
                    icon: const Icon(Icons.skip_previous_rounded),
                    tooltip: 'Предыдущее слово',
                    onPressed: cubit.previous,
                  ),

                  // Play / Pause main button
                  IconButton.filled(
                    iconSize: 42,
                    icon: Icon(
                      state.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    tooltip: state.isPlaying ? 'Пауза' : 'Воспроизведение',
                    onPressed: cubit.togglePlayPause,
                  ),

                  // Next button
                  IconButton(
                    iconSize: 32,
                    icon: const Icon(Icons.skip_next_rounded),
                    tooltip: 'Следующее слово',
                    onPressed: cubit.next,
                  ),

                  // Direction switch
                  IconButton(
                    icon: const Icon(Icons.swap_horiz_rounded),
                    tooltip: 'Сменить направление перевода',
                    onPressed: () {
                      final nextDir = state.config.direction ==
                              AudioDrillDirection.hebrewToRussian
                          ? AudioDrillDirection.russianToHebrew
                          : AudioDrillDirection.hebrewToRussian;
                      cubit.updateConfig(state.config.copyWith(direction: nextDir));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhaseBadge extends StatelessWidget {
  final AudioDrillPhase phase;
  final bool isHebrewPrompt;

  const _PhaseBadge({
    required this.phase,
    required this.isHebrewPrompt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (label, icon, color) = switch (phase) {
      AudioDrillPhase.prompt => isHebrewPrompt
          ? ('Слушай иврит 🎧', Icons.hearing_rounded, theme.colorScheme.primary)
          : ('Вспомни иврит 💭', Icons.psychology_rounded, Colors.purple),
      AudioDrillPhase.thinking => (
          'Назови ответ вслух! 🗣️',
          Icons.record_voice_over_rounded,
          Colors.amber.shade800,
        ),
      AudioDrillPhase.answer => (
          'Проверь себя ✨',
          Icons.done_rounded,
          Colors.green,
        ),
      AudioDrillPhase.example => (
          'Пример в контексте 📖',
          Icons.menu_book_rounded,
          Colors.teal,
        ),
      AudioDrillPhase.transition => (
          'Следующее слово ➔',
          Icons.arrow_forward_rounded,
          theme.colorScheme.outline,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrillCompletedView extends StatelessWidget {
  final int totalCardsDrilled;
  final int xpEarned;

  const _DrillCompletedView({
    required this.totalCardsDrilled,
    required this.xpEarned,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Text('🎉', style: TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 20),
            Text(
              'Тренировка завершена!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Отличная работа на слух! Слова закрепились в долговременной памяти.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatTile(
                  title: '$totalCardsDrilled',
                  subtitle: 'слов прослушано',
                  icon: '🎧',
                ),
                const SizedBox(width: 16),
                _StatTile(
                  title: '+$xpEarned XP',
                  subtitle: 'в Лигу Сабр',
                  icon: '⚡️',
                ),
              ],
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Готово'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;

  const _StatTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
