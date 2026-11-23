import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/army_term.dart';

/// Card rendering an army term, abbreviation, cultural insight, and audio example.
class ArmyTermCard extends StatelessWidget {
  final ArmyTerm term;
  final bool showNikkud;
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const ArmyTermCard({
    super.key,
    required this.term,
    this.showNikkud = true,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayedHebrew =
        showNikkud ? term.hebrewWithNikkud : term.hebrewNormalized;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top row: Category badge & Actions (Audio, FSRS)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF33691E).withValues(alpha: 0.12), // Army olive
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(term.category.iconEmoji, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        term.category.titleRu,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF33691E),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (audioService != null)
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded, size: 20),
                        tooltip: 'Озвучить термин',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => audioService?.playWithTtsFallback(
                          sourcePath: null,
                          fallbackHebrewText: term.hebrewWithNikkud,
                        ),
                      ),
                    if (addCardToSrsUseCase != null)
                      IconButton(
                        icon: const Icon(Icons.bookmark_add_outlined, size: 20),
                        tooltip: 'В словарь FSRS',
                        visualDensity: VisualDensity.compact,
                        onPressed: () async {
                          final res = await addCardToSrsUseCase!(
                            AddCardToSrsParams(
                              id: 'army_${term.id}',
                              hebrewVocalized: term.hebrewWithNikkud,
                              russianTranslation: term.meaningRu,
                              category: LexicalCategory.phrase,
                            ),
                          );
                          if (context.mounted && res.isSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Термин добавлен в FSRS карточки!'),
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
            const SizedBox(height: 8),

            // Hebrew Term (RTL)
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                displayedHebrew,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.45,
                ),
              ),
            ),

            // Abbreviation Expansion if present
            if (term.abbreviationExpansionHebrew != null) ...[
              const SizedBox(height: 2),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  'ראשי תיבות: ${term.abbreviationExpansionHebrew!}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: Colors.brown.shade700,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 4),

            // Russian Transcription
            Text(
              '🗣 ${term.transcriptionRu}',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),

            // Russian Meaning
            Text(
              term.meaningRu,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),

            // Cultural Context Box
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '💡 ${term.culturalContextRu}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Example Sentence
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF33691E).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      showNikkud ? term.exampleHebrewWithNikkud : term.exampleRu,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        height: 1.45,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    term.exampleRu,
                    style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700),
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
