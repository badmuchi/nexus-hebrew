import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/israeli_life_scene.dart';

class SceneWordCard extends StatefulWidget {
  const SceneWordCard({
    super.key,
    required this.word,
    this.showNikkud = true,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  final SceneWord word;
  final bool showNikkud;
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  @override
  State<SceneWordCard> createState() => _SceneWordCardState();
}

class _SceneWordCardState extends State<SceneWordCard> {
  bool _isSavedToSrs = false;

  Future<void> _addToSrs() async {
    final useCase = widget.addCardToSrsUseCase;
    if (useCase == null) return;

    final params = AddCardToSrsParams(
      id: 'scene_word_${widget.word.id}_${DateTime.now().millisecondsSinceEpoch}',
      hebrewVocalized: widget.word.hebrewVocalized,
      russianTranslation: widget.word.russianMeaning,
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
              ? '«${widget.word.hebrewNormalized}» добавлено в FSRS повторения!'
              : 'Уже в колоде FSRS',
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

    final hebrewText = widget.showNikkud
        ? widget.word.hebrewVocalized
        : widget.word.hebrewNormalized;

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
            // Top Row: Root & Action Buttons
            Row(
              children: [
                if (widget.word.root != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'שורש: ${widget.word.root}',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
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
                      sourcePath: widget.word.audioPath,
                      fallbackHebrewText: widget.word.hebrewVocalized,
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
                    tooltip: 'Сохранить в FSRS',
                    visualDensity: VisualDensity.compact,
                    onPressed: _addToSrs,
                  ),
              ],
            ),
            const SizedBox(height: 6),

            // Middle Row: Meaning, Transliteration, and Hebrew Word
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.word.russianMeaning,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.word.transliteration,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    hebrewText,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontFamily: 'Heebo',
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      height: 1.45,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),

            // Bottom Context Note
            if (widget.word.contextNote != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.word.contextNote!,
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
