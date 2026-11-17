import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/hebrew_letter.dart';
import 'cursive_practice_canvas.dart';

/// Modal bottom sheet displaying comprehensive details for a single Hebrew letter,
/// including pronunciation, dagesh rules, gematria, example words, and cursive tracing.
class LetterDetailSheet extends StatelessWidget {
  final HebrewLetter letter;
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const LetterDetailSheet({
    super.key,
    required this.letter,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  void _speakText(BuildContext context, String text) {
    audioService?.playWithTtsFallback(
      sourcePath: null,
      fallbackHebrewText: text,
    );
  }

  void _openPracticeCanvas(BuildContext context) {
    Navigator.of(context).pop();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => CursivePracticeCanvas(
        letter: letter,
        audioService: audioService,
      ),
    );
  }

  Future<void> _addToSrs(BuildContext context) async {
    if (addCardToSrsUseCase == null) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final result = await addCardToSrsUseCase!(
      AddCardToSrsParams(
        id: 'srs_letter_${letter.id}_${DateTime.now().millisecondsSinceEpoch}',
        hebrewVocalized: letter.exampleWordHebrew,
        russianTranslation:
            '${letter.exampleWordRussian} (Буква: ${letter.nameRussian})',
        exampleHebrewVocalized: letter.exampleWordHebrew,
        exampleRussian:
            '${letter.exampleWordRussian} [${letter.exampleWordTranscription}]',
        attribution: const ContentAttribution(
          sourceName: 'Nexus Hebrew Alphabet',
          licenseName: 'CC0 1.0',
        ),
      ),
    );

    result.fold(
      (failure) => scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Ошибка добавления: ${failure.message}')),
      ),
      (_) => scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            'Буква ${letter.nameRussian} с примером «${letter.exampleWordHebrew}» добавлена в FSRS!',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 28),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        letter.printed,
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                          height: 1.35,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      if (letter.hasFinalForm) ...[
                        const SizedBox(width: 10),
                        Text(
                          '/ ${letter.finalFormPrinted!}',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.primary,
                            height: 1.35,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            letter.nameHebrew,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.35,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.volume_up_rounded),
                            tooltip: 'Слушать',
                            onPressed: () => _speakText(context, letter.nameHebrew),
                          ),
                        ],
                      ),
                      Text(
                        '${letter.nameRussian} · [${letter.transliteration}]',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Гематрия: ${letter.gematria}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (letter.isBegedKefet)
                            Container(
                              padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.tertiaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Бегед-Кефет (с дагешем)',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onTertiaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (letter.isGuttural)
                            Container(
                              padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Гортанная буква',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const _SectionTitle(title: 'Фонетика и звучание'),
            const SizedBox(height: 6),
            Text(
              letter.soundDescription,
              style: theme.textTheme.bodyMedium,
            ),
            if (letter.dageshExplanation != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsetsDirectional.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.tips_and_updates_rounded,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        letter.dageshExplanation!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            const _SectionTitle(title: 'Рукописный стиль (Ктав Яд)'),
            const SizedBox(height: 6),
            Text(
              letter.cursiveDescription,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            const _SectionTitle(title: 'Пример слова'),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.all(14),
                child: Row(
                  children: [
                    IconButton.filledTonal(
                      icon: const Icon(Icons.volume_up_rounded),
                      tooltip: 'Слушать пример',
                      onPressed: () =>
                          _speakText(context, letter.exampleWordHebrew),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            letter.exampleWordHebrew,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.35,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${letter.exampleWordRussian} · [${letter.exampleWordTranscription}]',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (addCardToSrsUseCase != null)
                      IconButton(
                        tooltip: 'В FSRS',
                        icon: const Icon(Icons.bookmark_add_outlined),
                        onPressed: () => unawaited(_addToSrs(context)),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _openPracticeCanvas(context),
                    icon: const Icon(Icons.draw_rounded),
                    label: const Text('Тренировать прописи'),
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }
}
