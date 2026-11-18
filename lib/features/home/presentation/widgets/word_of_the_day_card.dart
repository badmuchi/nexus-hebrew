import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/result/result.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/word_of_the_day.dart';

/// Interactive card presenting the curated Hebrew Word of the Day.
class WordOfTheDayCard extends StatefulWidget {
  final WordOfTheDay word;
  final bool showNikkud;
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const WordOfTheDayCard({
    super.key,
    required this.word,
    required this.showNikkud,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  @override
  State<WordOfTheDayCard> createState() => _WordOfTheDayCardState();
}

class _WordOfTheDayCardState extends State<WordOfTheDayCard> {
  bool _isSpeaking = false;
  bool _isSaved = false;

  Future<void> _speakWord() async {
    if (widget.audioService == null) return;
    setState(() => _isSpeaking = true);

    await widget.audioService!.playWithTtsFallback(
      sourcePath: null,
      fallbackHebrewText: widget.word.word.vocalized,
    );

    if (mounted) {
      setState(() => _isSpeaking = false);
    }
  }

  Future<void> _speakSentence() async {
    if (widget.audioService == null) return;
    await widget.audioService!.playWithTtsFallback(
      sourcePath: null,
      fallbackHebrewText: widget.word.exampleSentenceHebrew,
    );
  }

  Future<void> _saveToSrs() async {
    if (widget.addCardToSrsUseCase == null) return;

    final params = AddCardToSrsParams(
      id: 'wotd_${widget.word.id}',
      hebrewVocalized: widget.word.word.vocalized,
      russianTranslation: widget.word.russianMeaning,
      root: widget.word.root,
      category: LexicalCategory.noun,
      exampleHebrewVocalized: widget.word.exampleSentenceHebrew,
      exampleRussian: widget.word.exampleSentenceRussian,
    );

    final res = await widget.addCardToSrsUseCase!(params);
    if (!mounted) return;

    switch (res) {
      case Success(:final data):
        setState(() => _isSaved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data
                  ? 'Слово дня добавлено в колоду FSRS! 📌'
                  : 'Это слово уже есть в вашей колоде повторений.',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      case Error(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения: ${failure.message}')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayedWord = widget.showNikkud
        ? widget.word.word.vocalized
        : widget.word.word.normalized;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'СЛОВО ДНЯ',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton.filledTonal(
                      icon: Icon(_isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded),
                      tooltip: 'Прослушать произношение',
                      onPressed: _speakWord,
                    ),
                    const SizedBox(width: 6),
                    IconButton.outlined(
                      icon: Icon(
                        _isSaved ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
                        color: _isSaved ? theme.colorScheme.primary : null,
                      ),
                      tooltip: _isSaved ? 'Сохранено в FSRS' : 'Добавить в FSRS',
                      onPressed: _isSaved ? null : _saveToSrs,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                displayedWord,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                  height: 1.25,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  widget.word.transliteration,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Text('•', style: TextStyle(color: theme.colorScheme.outline)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.word.russianMeaning,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Chip(
                  label: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text('שורש: ${widget.word.root.hyphenated}'),
                  ),
                  avatar: const Icon(Icons.hub_outlined, size: 16),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsetsDirectional.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Пример в контексте:',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      InkWell(
                        onTap: _speakSentence,
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.volume_down_rounded, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      widget.word.exampleSentenceHebrew,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.word.exampleSentenceRussian,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 16,
                  color: theme.colorScheme.tertiary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.word.sabraCulturalNote,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
