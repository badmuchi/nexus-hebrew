import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/utils/hebrew_normalizer.dart';
import '../../domain/entities/listening_exercise.dart';

/// Audio player card with 0.75x/1.0x speed toggle and progressive comprehension hints.
class ListeningPlayerCard extends StatelessWidget {
  const ListeningPlayerCard({
    super.key,
    required this.exercise,
    required this.playbackSpeed,
    required this.audioStatus,
    required this.showFocusWordsHint,
    required this.showTranscript,
    required this.showNikkud,
    required this.onTogglePlay,
    required this.onSpeedChanged,
    required this.onToggleFocusWords,
    required this.onToggleTranscript,
    this.onSaveExerciseToSrs,
    this.onSaveFocusWordToSrs,
  });

  final ListeningExercise exercise;
  final double playbackSpeed;
  final AudioPlaybackStatus audioStatus;
  final bool showFocusWordsHint;
  final bool showTranscript;
  final bool showNikkud;
  final VoidCallback onTogglePlay;
  final ValueChanged<double> onSpeedChanged;
  final VoidCallback onToggleFocusWords;
  final VoidCallback onToggleTranscript;
  final VoidCallback? onSaveExerciseToSrs;
  final ValueChanged<String>? onSaveFocusWordToSrs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlaying = audioStatus == AudioPlaybackStatus.playing;
    final isLoading = audioStatus == AudioPlaybackStatus.loading;
    final audioUrl = exercise.audioUrl;
    final hasRemoteAudio = audioUrl != null &&
        (audioUrl.startsWith('http://') || audioUrl.startsWith('https://'));
    final hasLocalAssetAudio = audioUrl != null && !hasRemoteAudio;

    return Card(
      elevation: 0,
      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Chip(
                  avatar: const Icon(Icons.equalizer, size: 16),
                  label: Text(exercise.difficulty.russianLabel),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      avatar: Icon(
                        hasRemoteAudio
                            ? Icons.record_voice_over_outlined
                            : hasLocalAssetAudio
                                ? Icons.graphic_eq_rounded
                                : Icons.spatial_audio_off_outlined,
                        size: 16,
                      ),
                      label: Text(
                        hasRemoteAudio
                            ? 'Аудио носителя'
                            : hasLocalAssetAudio
                                ? 'Офлайн-озвучка he-IL'
                                : 'Озвучка he-IL TTS',
                      ),
                    ),
                    if (onSaveExerciseToSrs != null) ...[
                      const SizedBox(width: 4),
                      IconButton.outlined(
                        onPressed: onSaveExerciseToSrs,
                        tooltip: 'Фразу в FSRS',
                        icon: const Icon(Icons.bookmark_add_outlined, size: 20),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isLoading ? null : onTogglePlay,
                    icon: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                    label: Text(
                      isPlaying
                          ? 'Остановить'
                          : isLoading
                              ? 'Загрузка...'
                              : 'Слушать фразу',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SegmentedButton<double>(
                  segments: const <ButtonSegment<double>>[
                    ButtonSegment<double>(
                      value: 0.75,
                      label: Text('0.75x'),
                    ),
                    ButtonSegment<double>(
                      value: 1.0,
                      label: Text('1.0x'),
                    ),
                  ],
                  selected: <double>{playbackSpeed <= 0.85 ? 0.75 : 1.0},
                  onSelectionChanged: (Set<double> selected) {
                    if (selected.isNotEmpty) {
                      onSpeedChanged(selected.first);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onToggleFocusWords,
                  icon: Icon(
                    showFocusWordsHint
                        ? Icons.visibility_off_outlined
                        : Icons.key_outlined,
                    size: 18,
                  ),
                  label: Text(
                    showFocusWordsHint
                        ? 'Скрыть подсказку'
                        : 'Опорные слова (${exercise.focusWords.length})',
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onToggleTranscript,
                  icon: Icon(
                    showTranscript
                        ? Icons.subtitles_off_outlined
                        : Icons.subtitles_outlined,
                    size: 18,
                  ),
                  label: Text(
                    showTranscript ? 'Скрыть текст' : 'Показать текст и перевод',
                  ),
                ),
              ],
            ),
            if (showFocusWordsHint && exercise.focusWords.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Опорные слова:',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: exercise.focusWords
                    .map(
                      (String word) => ActionChip(
                        avatar: onSaveFocusWordToSrs != null
                            ? const Icon(Icons.bookmark_add_outlined, size: 16)
                            : null,
                        tooltip: onSaveFocusWordToSrs != null
                            ? 'Добавить слово в FSRS'
                            : null,
                        onPressed: onSaveFocusWordToSrs != null
                            ? () => onSaveFocusWordToSrs!(word)
                            : null,
                        label: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            showNikkud
                                ? word
                                : HebrewNormalizer.stripNikkud(word),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
            if (showTranscript) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsetsDirectional.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        showNikkud
                            ? exercise.transcript.vocalized
                            : exercise.transcript.normalized,
                        textAlign: TextAlign.right,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      exercise.russianTranslation,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
