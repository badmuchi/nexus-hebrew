import 'package:flutter/material.dart';

import '../../domain/entities/shoresh_entity.dart';

/// Interactive tile displaying a derived Hebrew word, its morphological pattern/binyan,
/// transliteration, Russian meaning, and contextual sentence.
class ShoreshDerivativeTile extends StatelessWidget {
  const ShoreshDerivativeTile({
    super.key,
    required this.derivative,
    required this.showNikkud,
    this.onAddToSrs,
    this.onPlayAudio,
  });

  final ShoreshDerivative derivative;
  final bool showNikkud;
  final VoidCallback? onAddToSrs;
  final VoidCallback? onPlayAudio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hebrewText =
        showNikkud ? derivative.hebrewVocalized : derivative.hebrewNormalized;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hebrewText,
                        textDirection: TextDirection.rtl,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        derivative.transliteration,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${derivative.partOfSpeech.emoji} ${derivative.partOfSpeech.labelRu}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onTertiaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              derivative.russianMeaning,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.architecture_rounded,
                  size: 14,
                  color: colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  derivative.patternOrBinyan,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    derivative.exampleSentenceHebrew,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    derivative.exampleSentenceRussian,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (onAddToSrs != null || onPlayAudio != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onPlayAudio != null)
                    IconButton.outlined(
                      icon: const Icon(Icons.volume_up_rounded, size: 20),
                      onPressed: onPlayAudio,
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Прослушать',
                    ),
                  if (onAddToSrs != null) ...[
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.add_to_photos_rounded, size: 18),
                      label: const Text('В карточки SRS'),
                      onPressed: onAddToSrs,
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
