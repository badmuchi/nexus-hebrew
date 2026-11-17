import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/utils/hebrew_normalizer.dart';
import '../../domain/entities/listening_exercise.dart';
import '../cubit/listening_state.dart';

class PuzzleWordChip {
  final String id;
  final String vocalized;
  final String normalized;
  final bool isDistractor;

  const PuzzleWordChip({
    required this.id,
    required this.vocalized,
    required this.normalized,
    this.isDistractor = false,
  });
}

class WordPuzzleInputCard extends StatefulWidget {
  const WordPuzzleInputCard({
    super.key,
    required this.exercise,
    required this.showNikkud,
    required this.answerMode,
    required this.comparison,
    this.audioService,
    required this.keyboardController,
    required this.onModeChanged,
    required this.onSubmit,
  });

  final ListeningExercise exercise;
  final bool showNikkud;
  final ListeningAnswerMode answerMode;
  final DictationComparison? comparison;
  final AudioPlaybackService? audioService;
  final TextEditingController keyboardController;
  final ValueChanged<ListeningAnswerMode> onModeChanged;
  final ValueChanged<String> onSubmit;

  @override
  State<WordPuzzleInputCard> createState() => _WordPuzzleInputCardState();
}

class _WordPuzzleInputCardState extends State<WordPuzzleInputCard> {
  static final RegExp _punctRegex = RegExp(r'[,.\?!:;…\(\)\[\]—–\-"]+');
  static final RegExp _spaceRegex = RegExp(r'\s+');

  static const _curatedDistractors = <(String vocalized, String normalized)>[
    ('בְּבַקָּשָׁה', 'בבקשה'),
    ('תּוֹדָה', 'תודה'),
    ('עַכְשָׁו', 'עכשיו'),
    ('מְאֹד', 'מאוד'),
    ('שָׁלוֹם', 'שלום'),
    ('מַיִם', 'מים'),
    ('כֵּן', 'כן'),
    ('לֹא', 'לא'),
    ('הַיּוֹם', 'היום'),
    ('גַּם', 'גם'),
  ];

  final List<PuzzleWordChip> _assembledChips = [];
  final List<PuzzleWordChip> _bankChips = [];

  @override
  void initState() {
    super.initState();
    _initPuzzle();
  }

  @override
  void didUpdateWidget(covariant WordPuzzleInputCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.exercise.id != oldWidget.exercise.id) {
      _initPuzzle();
    }
  }

  void _initPuzzle() {
    _assembledChips.clear();
    _bankChips.clear();

    final vocalizedTokens = widget.exercise.transcript.vocalized
        .replaceAll(_punctRegex, ' ')
        .trim()
        .split(_spaceRegex)
        .where((t) => t.isNotEmpty)
        .toList();

    final normalizedTokens = widget.exercise.transcript.normalized
        .replaceAll(_punctRegex, ' ')
        .trim()
        .split(_spaceRegex)
        .where((t) => t.isNotEmpty)
        .toList();

    final chips = <PuzzleWordChip>[];
    final normalizedSet = <String>{};

    for (var i = 0; i < vocalizedTokens.length; i++) {
      final voc = vocalizedTokens[i];
      final norm = i < normalizedTokens.length
          ? normalizedTokens[i]
          : HebrewNormalizer.stripNikkud(voc);
      normalizedSet.add(norm);
      chips.add(
        PuzzleWordChip(
          id: 'word_${widget.exercise.id}_$i',
          vocalized: voc,
          normalized: norm,
        ),
      );
    }

    // Add 1–2 clever distractors
    var distractorCount = 0;
    for (final d in _curatedDistractors) {
      if (!normalizedSet.contains(d.$2)) {
        chips.add(
          PuzzleWordChip(
            id: 'distractor_${widget.exercise.id}_$distractorCount',
            vocalized: d.$1,
            normalized: d.$2,
            isDistractor: true,
          ),
        );
        distractorCount++;
        if (distractorCount >= 2) break;
      }
    }

    // Deterministic shuffle by exercise id
    final random = math.Random(widget.exercise.id.hashCode & 0x7FFFFFFF);
    chips.shuffle(random);

    _bankChips.addAll(chips);
  }

  void _selectWord(PuzzleWordChip chip) {
    setState(() {
      _bankChips.remove(chip);
      _assembledChips.add(chip);
    });
    // Pronounce the selected word for audio feedback
    widget.audioService?.playWithTtsFallback(
      sourcePath: null,
      fallbackHebrewText: chip.vocalized,
    );
  }

  void _deselectWord(PuzzleWordChip chip) {
    setState(() {
      _assembledChips.remove(chip);
      _bankChips.add(chip);
    });
  }

  void _resetPuzzle() {
    setState(() {
      _initPuzzle();
    });
  }

  void _submitPuzzle() {
    final text = _assembledChips
        .map((c) => widget.showNikkud ? c.vocalized : c.normalized)
        .join(' ');
    widget.onSubmit(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPuzzle = widget.answerMode == ListeningAnswerMode.puzzle;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mode Header Switcher
            Row(
              children: [
                Expanded(
                  child: Text(
                    isPuzzle ? 'Собери фразу из блоков:' : 'Запиши услышанное:',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SegmentedButton<ListeningAnswerMode>(
                  segments: const [
                    ButtonSegment<ListeningAnswerMode>(
                      value: ListeningAnswerMode.puzzle,
                      icon: Icon(Icons.extension_outlined, size: 16),
                      label: Text('Блоки'),
                    ),
                    ButtonSegment<ListeningAnswerMode>(
                      value: ListeningAnswerMode.keyboard,
                      icon: Icon(Icons.keyboard_outlined, size: 16),
                      label: Text('Клавиатура'),
                    ),
                  ],
                  selected: {widget.answerMode},
                  onSelectionChanged: (newSelection) {
                    widget.onModeChanged(newSelection.first);
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (isPuzzle) ...[
              // Assembled Sentence Area
              Container(
                constraints: const BoxConstraints(minHeight: 64),
                padding: const EdgeInsetsDirectional.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _assembledChips.isEmpty
                        ? theme.colorScheme.outlineVariant
                        : theme.colorScheme.primary.withValues(alpha: 0.5),
                    width: _assembledChips.isEmpty ? 1 : 1.5,
                  ),
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: _assembledChips.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.symmetric(
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.touch_app_outlined,
                                  size: 18,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Нажимай на слова внизу, чтобы собрать ответ',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final chip in _assembledChips)
                              ActionChip(
                                elevation: 1,
                                backgroundColor:
                                    theme.colorScheme.primaryContainer,
                                label: Text(
                                  widget.showNikkud
                                      ? chip.vocalized
                                      : chip.normalized,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                avatar: const Icon(Icons.close_rounded,
                                    size: 16),
                                onPressed: () => _deselectWord(chip),
                              ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Available Bank Chips
              Text(
                'Слова для выбора:',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(minHeight: 52),
                padding: const EdgeInsetsDirectional.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: _bankChips.isEmpty
                      ? Center(
                          child: Text(
                            'Все слова использованы',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final chip in _bankChips)
                              ActionChip(
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHigh,
                                label: Text(
                                  widget.showNikkud
                                      ? chip.vocalized
                                      : chip.normalized,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onPressed: () => _selectWord(chip),
                              ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 14),

              // Actions Row
              Row(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Сбросить'),
                    onPressed: _assembledChips.isEmpty ? null : _resetPuzzle,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: const Text('Проверить ответ'),
                      onPressed:
                          _assembledChips.isEmpty ? null : _submitPuzzle,
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Keyboard manual input
              Directionality(
                textDirection: TextDirection.rtl,
                child: TextField(
                  controller: widget.keyboardController,
                  maxLines: 2,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  decoration: const InputDecoration(
                    hintText: 'Напиши фразу на иврите...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () =>
                    widget.onSubmit(widget.keyboardController.text),
                child: const Text('Проверить диктант'),
              ),
            ],

            // Comparison result
            if (widget.comparison != null) ...[
              const SizedBox(height: 14),
              _DictationResultBox(result: widget.comparison!),
            ],
          ],
        ),
      ),
    );
  }
}

class _DictationResultBox extends StatelessWidget {
  const _DictationResultBox({required this.result});

  final DictationComparison result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (result.wordAccuracy * 100).round();

    return Container(
      padding: const EdgeInsetsDirectional.all(14),
      decoration: BoxDecoration(
        color: result.isExactMatch
            ? Colors.green.withValues(alpha: 0.12)
            : theme.colorScheme.tertiaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: result.isExactMatch
              ? Colors.green.withValues(alpha: 0.4)
              : theme.colorScheme.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                result.isExactMatch
                    ? Icons.check_circle_rounded
                    : Icons.info_outline_rounded,
                color: result.isExactMatch
                    ? Colors.green.shade800
                    : theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.isExactMatch
                      ? 'Великолепно! Точность 100%'
                      : 'Точность: $percent%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: result.isExactMatch
                        ? Colors.green.shade800
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          if (!result.isExactMatch) ...[
            const SizedBox(height: 8),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                'Эталон: ${result.normalizedExpected}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (result.missedWords.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Пропущенные слова: ${result.missedWords.join(", ")}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
