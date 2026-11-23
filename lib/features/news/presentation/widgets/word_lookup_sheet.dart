import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';

/// Modal bottom sheet displaying a tapped word's vocalization, root and translation,
/// with audio pronunciation and 1-tap FSRS card saving.
class WordLookupSheet extends StatelessWidget {
  final String wordHebrewWithNikkud;
  final String wordHebrewNormalized;
  final String translationRu;
  final String? root;
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const WordLookupSheet({
    super.key,
    required this.wordHebrewWithNikkud,
    required this.wordHebrewNormalized,
    required this.translationRu,
    this.root,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  static Future<void> show({
    required BuildContext context,
    required String wordHebrewWithNikkud,
    required String wordHebrewNormalized,
    required String translationRu,
    String? root,
    AudioPlaybackService? audioService,
    AddCardToSrsUseCase? addCardToSrsUseCase,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => WordLookupSheet(
        wordHebrewWithNikkud: wordHebrewWithNikkud,
        wordHebrewNormalized: wordHebrewNormalized,
        translationRu: translationRu,
        root: root,
        audioService: audioService,
        addCardToSrsUseCase: addCardToSrsUseCase,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Top row: Vocalized word & Audio
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      wordHebrewWithNikkud,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
                if (audioService != null)
                  IconButton.filledTonal(
                    icon: const Icon(Icons.volume_up_rounded),
                    tooltip: 'Озвучить слово',
                    onPressed: () => audioService?.playWithTtsFallback(
                      sourcePath: null,
                      fallbackHebrewText: wordHebrewWithNikkud,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Translation in Russian
            Text(
              translationRu,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            // Root / Shoresh chip if present
            if (root != null && root!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🌱 ', style: TextStyle(fontSize: 16)),
                    const Text(
                      'Корень (שֹׁרֶשׁ): ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        root!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF004D40),
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Add to FSRS button
            if (addCardToSrsUseCase != null)
              FilledButton.icon(
                icon: const Icon(Icons.bookmark_add_rounded),
                label: const Text('Сохранить в FSRS карточки'),
                onPressed: () async {
                  final res = await addCardToSrsUseCase!(
                    AddCardToSrsParams(
                      id: 'news_word_${wordHebrewNormalized.hashCode}',
                      hebrewVocalized: wordHebrewWithNikkud,
                      russianTranslation: translationRu,
                      root: root != null ? Shoresh.create(root!).getOrNull() : null,
                      category: LexicalCategory.phrase,
                    ),
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    if (res.isSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Слово добавлено в колоду FSRS!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
