import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/israeli_life_scene.dart';

class ScenePhraseTile extends StatefulWidget {
  const ScenePhraseTile({
    super.key,
    required this.phrase,
    this.showNikkud = true,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  final ScenePhrase phrase;
  final bool showNikkud;
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  @override
  State<ScenePhraseTile> createState() => _ScenePhraseTileState();
}

class _ScenePhraseTileState extends State<ScenePhraseTile> {
  bool _isSavedToSrs = false;

  Future<void> _addToSrs() async {
    final useCase = widget.addCardToSrsUseCase;
    if (useCase == null) return;

    final params = AddCardToSrsParams(
      id: 'scene_phrase_${widget.phrase.id}_${DateTime.now().millisecondsSinceEpoch}',
      hebrewVocalized: widget.phrase.hebrewVocalized,
      russianTranslation: widget.phrase.russianTranslation,
      category: LexicalCategory.phrase,
    );

    final res = await useCase(params);
    if (!mounted) return;

    setState(() => _isSavedToSrs = true);

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          (res.getOrNull() == true)
              ? 'Фраза добавлена в FSRS повторения!'
              : 'Фраза уже в колоде FSRS',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isIncoming = widget.phrase.role.isIncoming;

    final roleColor = isIncoming ? Colors.amber.shade800 : theme.colorScheme.primary;
    final roleBg = isIncoming
        ? Colors.amber.withOpacity(isDark ? 0.2 : 0.12)
        : theme.colorScheme.primary.withOpacity(isDark ? 0.2 : 0.1);

    final hebrewText = widget.showNikkud
        ? widget.phrase.hebrewVocalized
        : widget.phrase.hebrewNormalized;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.black.withOpacity(0.08),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top: Role badge & actions
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: roleBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: roleColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    widget.phrase.role.labelRu,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: roleColor,
                    ),
                  ),
                ),
                const Spacer(),
                if (widget.audioService != null)
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded, size: 20),
                    tooltip: 'Озвучить (TTS)',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => widget.audioService?.playWithTtsFallback(
                      sourcePath: widget.phrase.audioPath,
                      fallbackHebrewText: widget.phrase.hebrewVocalized,
                    ),
                  ),
                if (widget.addCardToSrsUseCase != null)
                  IconButton(
                    icon: Icon(
                      _isSavedToSrs
                          ? Icons.bookmark_added_rounded
                          : Icons.bookmark_add_outlined,
                      size: 20,
                      color: _isSavedToSrs ? theme.colorScheme.primary : null,
                    ),
                    tooltip: 'В FSRS',
                    visualDensity: VisualDensity.compact,
                    onPressed: _addToSrs,
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Hebrew Phrase (RTL)
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                hebrewText,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'Heebo',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  height: 1.45,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Transliteration
            Text(
              widget.phrase.transliteration,
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 6),

            // Russian Translation
            Text(
              widget.phrase.russianTranslation,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),

            // Cultural Tip
            if (widget.phrase.culturalTip != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡 ', style: TextStyle(fontSize: 12)),
                    Expanded(
                      child: Text(
                        widget.phrase.culturalTip!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
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
