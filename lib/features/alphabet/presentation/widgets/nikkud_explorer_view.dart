import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../data/datasources/hebrew_alphabet_seed_data.dart';
import '../../domain/entities/nikkud_mark.dart';

/// Interactive explorer for Hebrew vowel diacritics (Nikkud / Огласовки).
class NikkudExplorerView extends StatefulWidget {
  final AudioPlaybackService? audioService;

  const NikkudExplorerView({
    super.key,
    this.audioService,
  });

  @override
  State<NikkudExplorerView> createState() => _NikkudExplorerViewState();
}

class _NikkudExplorerViewState extends State<NikkudExplorerView> {
  NikkudVowelGroup? _selectedGroup;

  void _speakText(String text) {
    widget.audioService?.playWithTtsFallback(
      sourcePath: null,
      fallbackHebrewText: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final filteredMarks = _selectedGroup == null
        ? HebrewAlphabetSeedData.nikkudMarks
        : HebrewAlphabetSeedData.nikkudMarks
            .where((m) => m.group == _selectedGroup)
            .toList(growable: false);

    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 32),
      children: [
        Card(
          elevation: 0,
          color: colorScheme.primaryContainer.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_stories_rounded,
                      color: colorScheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Что такое никуд (נִקּוּד)?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'В иврите алфавит состоит только из согласных букв. '
                  'Огласовки (никуд) — это система точек и черточек под, над и внутри букв, '
                  'обозначающих гласные звуки. В повседневной жизни (книги, интернет, пресса) '
                  'текст пишется без огласовок (ктив мале), а огласовки используются в словарях, '
                  'детских книгах, поэзии и религиозных текстах.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ChoiceChip(
                  label: const Text('Все огласовки (14)'),
                  selected: _selectedGroup == null,
                  onSelected: (_) => setState(() => _selectedGroup = null),
                ),
              ),
              ...NikkudVowelGroup.values.map(
                (group) => Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ChoiceChip(
                    label: Text(group.title),
                    selected: _selectedGroup == group,
                    onSelected: (_) => setState(() => _selectedGroup = group),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...filteredMarks.map(
          (mark) => _NikkudCard(
            mark: mark,
            onPlayLetter: () => _speakText(mark.exampleWithLetter),
            onPlayWord: () => _speakText(mark.exampleWordHebrew),
          ),
        ),
      ],
    );
  }
}

class _NikkudCard extends StatelessWidget {
  final NikkudMark mark;
  final VoidCallback onPlayLetter;
  final VoidCallback onPlayWord;

  const _NikkudCard({
    required this.mark,
    required this.onPlayLetter,
    required this.onPlayWord,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsetsDirectional.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    mark.exampleWithLetter,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                      height: 1.4,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            mark.nameHebrew,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.35,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '· ${mark.nameRussian}',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          mark.sound,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Слушать слог',
                  icon: const Icon(Icons.volume_up_rounded),
                  onPressed: onPlayLetter,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              mark.description,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    'Пример:',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    mark.exampleWordHebrew,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                      height: 1.35,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '· ${mark.exampleWordRussian} [${mark.exampleWordTranscription}]',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded, size: 20),
                    tooltip: 'Слушать слово',
                    onPressed: onPlayWord,
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
