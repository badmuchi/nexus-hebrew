import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/omni_search_result.dart';

/// Interactive result card in the Omni-Search list.
class OmniSearchResultTile extends StatefulWidget {
  const OmniSearchResultTile({
    super.key,
    required this.result,
    this.audioService,
    this.addCardToSrsUseCase,
    this.onTap,
  });

  final OmniSearchResult result;
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;
  final VoidCallback? onTap;

  @override
  State<OmniSearchResultTile> createState() => _OmniSearchResultTileState();
}

class _OmniSearchResultTileState extends State<OmniSearchResultTile> {
  bool _isSavedToSrs = false;

  (IconData, Color, String) _getCategoryMeta(OmniResultCategory cat) {
    return switch (cat) {
      OmniResultCategory.dictionary => (
          Icons.menu_book_rounded,
          const Color(0xFF1976D2),
          'Словарь'
        ),
      OmniResultCategory.slang => (
          Icons.chat_bubble_outline_rounded,
          const Color(0xFFD81B60),
          'Сленг'
        ),
      OmniResultCategory.grammar => (
          Icons.hub_rounded,
          const Color(0xFF6A1B9A),
          'Грамматика'
        ),
      OmniResultCategory.alphabet => (
          Icons.spellcheck_rounded,
          const Color(0xFFE65100),
          'Алфавит'
        ),
      OmniResultCategory.preposition => (
          Icons.alt_route_rounded,
          const Color(0xFF00796B),
          'Предлог'
        ),
      OmniResultCategory.shoresh => (
          Icons.biotech_rounded,
          const Color(0xFF00897B),
          'Корень'
        ),
      OmniResultCategory.army => (
          Icons.shield_rounded,
          const Color(0xFF33691E),
          'ЦАХАЛ'
        ),
      OmniResultCategory.news => (
          Icons.newspaper_rounded,
          const Color(0xFF00838F),
          'Новости'
        ),
      OmniResultCategory.chat => (
          Icons.chat_rounded,
          const Color(0xFF00796B),
          'WhatsApp'
        ),
      OmniResultCategory.dialogue => (
          Icons.record_voice_over_rounded,
          const Color(0xFF2E7D32),
          'Диалог'
        ),
    };
  }

  Future<void> _addToSrs() async {
    final useCase = widget.addCardToSrsUseCase;
    if (useCase == null) return;

    final params = AddCardToSrsParams(
      id: 'omni_${widget.result.id}_${DateTime.now().millisecondsSinceEpoch}',
      hebrewVocalized: widget.result.hebrewWithNikkud,
      russianTranslation: widget.result.translationRu,
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
              ? '«${widget.result.hebrewWithoutNikkud}» добавлено в FSRS повторения!'
              : 'Уже находится в колоде FSRS',
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
    final (catIcon, catColor, catLabel) = _getCategoryMeta(widget.result.category);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.black.withOpacity(0.06),
        ),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header row: Category Badge & Actions
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: catColor.withOpacity(isDark ? 0.25 : 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(catIcon, size: 14, color: catColor),
                        const SizedBox(width: 4),
                        Text(
                          catLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: catColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.result.root != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'שורש: ${widget.result.root}',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (widget.audioService != null)
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded, size: 20),
                      tooltip: 'Озвучить (TTS)',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => widget.audioService?.playWithTtsFallback(
                        sourcePath: null,
                        fallbackHebrewText: widget.result.effectiveAudioText,
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
                      tooltip: 'Добавить в FSRS',
                      visualDensity: VisualDensity.compact,
                      onPressed: _addToSrs,
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Hebrew word & Russian translation
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.result.translationRu,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (widget.result.transliteration != null &&
                            widget.result.transliteration!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              widget.result.transliteration!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ),
                        if (widget.result.details != null &&
                            widget.result.details!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              widget.result.details!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Hebrew text block with strict RTL and increased line-height for nikkud
                  Flexible(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        widget.result.hebrewWithNikkud,
                        textAlign: TextAlign.right,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: 'Heebo',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.45,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
