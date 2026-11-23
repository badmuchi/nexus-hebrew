import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../domain/entities/voice_scenario.dart';

/// Interactive card presenting a suggested Hebrew response to Sabra.
class VoiceAnswerSuggestionCard extends StatelessWidget {
  final SuggestedVoiceAnswer answer;
  final bool isSelected;
  final bool showNikkud;
  final AudioPlaybackService? audioService;
  final VoidCallback onSelect;

  const VoiceAnswerSuggestionCard({
    super.key,
    required this.answer,
    required this.isSelected,
    this.showNikkud = true,
    this.audioService,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayedHebrew =
        showNikkud ? answer.hebrewWithNikkud : answer.hebrewNormalized;

    return Material(
      color: isSelected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
          : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onSelect,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top row: audio button & selection indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isSelected ? '✓ Выбранный ответ' : 'Вариант ответа',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (audioService != null)
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded, size: 18),
                      tooltip: 'Послушать произношение',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => audioService?.playWithTtsFallback(
                        sourcePath: null,
                        fallbackHebrewText: answer.hebrewWithNikkud,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),

              // Hebrew text in strict RTL
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  displayedHebrew,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.45,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // Russian transcription
              Text(
                '🗣 ${answer.transcriptionRu}',
                style: TextStyle(
                  fontSize: 12.5,
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),

              // Russian translation
              Text(
                answer.translationRu,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
