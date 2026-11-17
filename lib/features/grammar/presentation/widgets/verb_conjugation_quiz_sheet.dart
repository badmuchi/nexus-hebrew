import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/utils/hebrew_normalizer.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../../domain/entities/verb_conjugation.dart';
import '../../domain/services/hebrew_conjugation_highlighter.dart';

/// Interactive rapid-fire quiz testing Hebrew verb conjugation paradigms.
class VerbConjugationQuizSheet extends StatefulWidget {
  final List<VerbLexeme> verbs;
  final bool showNikkud;
  final AudioPlaybackService? audioService;
  final ValueChanged<ConjugatedForm>? onSaveToSrs;

  const VerbConjugationQuizSheet({
    super.key,
    required this.verbs,
    required this.showNikkud,
    this.audioService,
    this.onSaveToSrs,
  });

  @override
  State<VerbConjugationQuizSheet> createState() => _VerbConjugationQuizSheetState();
}

class _VerbConjugationQuizSheetState extends State<VerbConjugationQuizSheet> {
  final Random _random = Random();

  int _score = 0;
  int _streak = 0;

  VerbLexeme? _currentVerb;
  ConjugatedForm? _targetForm;
  List<String> _currentOptions = [];
  String? _selectedOption;
  bool _hasAnswered = false;

  @override
  void initState() {
    super.initState();
    _nextQuestion();
  }

  void _nextQuestion() {
    final validVerbs = widget.verbs
        .where((v) => v.conjugations.isNotEmpty)
        .toList(growable: false);

    if (validVerbs.isEmpty) return;

    final verb = validVerbs[_random.nextInt(validVerbs.length)];
    final target = verb.conjugations[_random.nextInt(verb.conjugations.length)];

    final correctDisplay = widget.showNikkud
        ? target.form.vocalized
        : target.form.normalized;

    // Distractor 1: same tense, different person
    final sameTenseOthers = verb
        .formsForTense(target.tense)
        .where((f) => f.person != target.person)
        .map((f) => widget.showNikkud ? f.form.vocalized : f.form.normalized)
        .toList();

    // Distractor 2: different tense, any person
    final otherTenseForms = verb.conjugations
        .where((f) => f.tense != target.tense)
        .map((f) => widget.showNikkud ? f.form.vocalized : f.form.normalized)
        .toList();

    // Distractor 3: from another verb
    final otherVerbsForms = validVerbs
        .where((v) => v.id != verb.id)
        .expand((v) => v.conjugations)
        .map((f) => widget.showNikkud ? f.form.vocalized : f.form.normalized)
        .toList();

    final optionsSet = <String>{correctDisplay};

    if (sameTenseOthers.isNotEmpty) {
      sameTenseOthers.shuffle(_random);
      optionsSet.add(sameTenseOthers.first);
    }
    if (otherTenseForms.isNotEmpty) {
      otherTenseForms.shuffle(_random);
      optionsSet.add(otherTenseForms.first);
    }
    if (otherVerbsForms.isNotEmpty) {
      otherVerbsForms.shuffle(_random);
      for (final candidate in otherVerbsForms) {
        if (optionsSet.length >= 4) break;
        optionsSet.add(candidate);
      }
    }

    // Fallback if needed
    for (final f in verb.conjugations) {
      if (optionsSet.length >= 4) break;
      final display = widget.showNikkud ? f.form.vocalized : f.form.normalized;
      optionsSet.add(display);
    }

    final options = optionsSet.toList()..shuffle(_random);

    setState(() {
      _currentVerb = verb;
      _targetForm = target;
      _currentOptions = options;
      _selectedOption = null;
      _hasAnswered = false;
    });
  }

  void _handleOptionSelected(String option) {
    if (_hasAnswered || _targetForm == null) return;

    final correctDisplay = widget.showNikkud
        ? _targetForm!.form.vocalized
        : _targetForm!.form.normalized;

    final isCorrect = HebrewNormalizer.stripNikkud(option) ==
        HebrewNormalizer.stripNikkud(correctDisplay);

    setState(() {
      _selectedOption = option;
      _hasAnswered = true;
      if (isCorrect) {
        _score += 10;
        _streak++;
      } else {
        _streak = 0;
      }
    });

    if (isCorrect && widget.audioService != null) {
      widget.audioService!.playWithTtsFallback(
        sourcePath: null,
        fallbackHebrewText: _targetForm!.form.vocalized,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verb = _currentVerb;
    final target = _targetForm;

    if (verb == null || target == null) {
      return const SizedBox(
        height: 250,
        child: Center(
          child: Text('Нет доступных глаголов для квиза.'),
        ),
      );
    }

    final correctDisplay = widget.showNikkud
        ? target.form.vocalized
        : target.form.normalized;
    final isSelectedCorrect = _selectedOption != null &&
        HebrewNormalizer.stripNikkud(_selectedOption!) ==
            HebrewNormalizer.stripNikkud(correctDisplay);

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'XP: $_score',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_streak > 1)
                    Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '🔥 $_streak подряд',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(16),
              child: Column(
                children: [
                  Text(
                    '${verb.russianMeaning} (${verb.binyan.transliteration})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      verb.infinitive?.vocalized ?? verb.lemma.vocalized,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _QuizBadge(
                        label: 'Время',
                        value: target.tense.russianLabel,
                        hebrewValue: target.tense.hebrewLabel,
                      ),
                      _QuizBadge(
                        label: 'Лицо / Местоимение',
                        value: target.person.russianLabel,
                        hebrewValue: target.person.hebrewPronoun,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Выберите правильную форму:',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.3,
            children: _currentOptions.map((option) {
              final isCurrent = option == _selectedOption;
              final isThisCorrect = HebrewNormalizer.stripNikkud(option) ==
                  HebrewNormalizer.stripNikkud(correctDisplay);

              final Color? cardColor;
              final BorderSide borderSide;

              if (!_hasAnswered) {
                cardColor = theme.colorScheme.surface;
                borderSide = BorderSide(color: theme.colorScheme.outlineVariant);
              } else if (isThisCorrect) {
                cardColor = Colors.green.withValues(alpha: 0.15);
                borderSide = const BorderSide(color: Colors.green, width: 2);
              } else if (isCurrent) {
                cardColor = Colors.red.withValues(alpha: 0.15);
                borderSide = const BorderSide(color: Colors.red, width: 2);
              } else {
                cardColor = theme.colorScheme.surface;
                borderSide = BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                );
              }

              return OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: cardColor,
                  side: borderSide,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
                ),
                onPressed: _hasAnswered ? null : () => _handleOptionSelected(option),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    option,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _hasAnswered && isThisCorrect
                          ? Colors.green.shade800
                          : null,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_hasAnswered) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsetsDirectional.all(12),
              decoration: BoxDecoration(
                color: isSelectedCorrect
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelectedCorrect ? Colors.green : Colors.red,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        isSelectedCorrect
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: isSelectedCorrect ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isSelectedCorrect
                              ? 'Верно! +10 XP 🎉'
                              : 'Ошибка! Правильный ответ:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelectedCorrect
                                ? Colors.green.shade900
                                : Colors.red.shade900,
                          ),
                        ),
                      ),
                      if (widget.onSaveToSrs != null)
                        IconButton(
                          tooltip: 'Добавить в интервальное повторение FSRS',
                          icon: const Icon(Icons.bookmark_add_outlined),
                          onPressed: () {
                            widget.onSaveToSrs!(target);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Форма сохранена в карточки FSRS!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                  if (!isSelectedCorrect) ...[
                    const SizedBox(height: 6),
                    _MorphologyRow(
                      vocalizedForm: correctDisplay,
                      root: verb.root,
                      transliteration: target.transliteration,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Следующий вопрос'),
              onPressed: _nextQuestion,
            ),
          ],
        ],
      ),
    );
  }
}

class _QuizBadge extends StatelessWidget {
  const _QuizBadge({
    required this.label,
    required this.value,
    required this.hebrewValue,
  });

  final String label;
  final String value;
  final String hebrewValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            hebrewValue,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _MorphologyRow extends StatelessWidget {
  const _MorphologyRow({
    required this.vocalizedForm,
    required this.root,
    required this.transliteration,
  });

  final String vocalizedForm;
  final Shoresh root;
  final String transliteration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const highlighter = HebrewConjugationHighlighter();
    final segments = highlighter.highlight(
      vocalizedForm: vocalizedForm,
      root: root,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          transliteration,
          style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
        ),
        Directionality(
          textDirection: TextDirection.rtl,
          child: Text.rich(
            TextSpan(
              children: segments.map((s) {
                final color = switch (s.role) {
                  MorphologicalRole.root => Colors.green.shade800,
                  MorphologicalRole.prefix => Colors.blue.shade800,
                  MorphologicalRole.suffix => Colors.deepOrange.shade800,
                  MorphologicalRole.infix => Colors.purple.shade800,
                  MorphologicalRole.base => theme.colorScheme.onSurface,
                };
                return TextSpan(
                  text: s.text,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: color,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
