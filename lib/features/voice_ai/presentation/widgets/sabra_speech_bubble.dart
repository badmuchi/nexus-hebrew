import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';

/// Renders Sabra's spoken message with audio TTS playback,
/// RTL layout and 1-tap FSRS card creation.
class SabraSpeechBubble extends StatelessWidget {
  final String hebrewWithNikkud;
  final String hebrewNormalized;
  final String translationRu;
  final String? audioPath;
  final bool showNikkud;
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const SabraSpeechBubble({
    super.key,
    required this.hebrewWithNikkud,
    required this.hebrewNormalized,
    required this.translationRu,
    this.audioPath,
    this.showNikkud = true,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayedHebrew = showNikkud ? hebrewWithNikkud : hebrewNormalized;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.28),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomRight: Radius.circular(18),
          bottomLeft: Radius.circular(4),
        ),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with Sabra badge & audio trigger
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🌵 ', style: TextStyle(fontSize: 18)),
                  Text(
                    'Сабра AI',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (audioService != null)
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded, size: 20),
                      tooltip: 'Озвучить фразу Сабры',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => audioService?.playWithTtsFallback(
                        sourcePath: audioPath,
                        fallbackHebrewText: hebrewWithNikkud,
                      ),
                    ),
                  if (addCardToSrsUseCase != null)
                    IconButton(
                      icon: const Icon(Icons.bookmark_add_outlined, size: 19),
                      tooltip: 'В словарь FSRS',
                      visualDensity: VisualDensity.compact,
                      onPressed: () async {
                        final res = await addCardToSrsUseCase!(
                          AddCardToSrsParams(
                            id: 'sabra_voice_${hebrewNormalized.hashCode}',
                            hebrewVocalized: hebrewWithNikkud,
                            russianTranslation: translationRu,
                            category: LexicalCategory.phrase,
                          ),
                        );
                        if (context.mounted && res.isSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Фраза сохранена в FSRS карточки!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Hebrew Speech with strict RTL
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              displayedHebrew,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                height: 1.45,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Russian Translation
          Text(
            translationRu,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
