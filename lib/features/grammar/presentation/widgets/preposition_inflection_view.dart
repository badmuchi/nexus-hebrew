import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../data/datasources/hebrew_prepositions_seed_data.dart';
import '../../domain/entities/preposition_inflection.dart';

/// Interactive workspace for Hebrew Preposition Inflexion (נְטִיַּת מִלּוֹת יַחַס)
/// with full paradigm tables, TTS audio, FSRS saving, and an interactive quiz drill.
class PrepositionInflectionView extends StatefulWidget {
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;
  final bool showNikkud;

  const PrepositionInflectionView({
    super.key,
    this.audioService,
    this.addCardToSrsUseCase,
    this.showNikkud = true,
  });

  @override
  State<PrepositionInflectionView> createState() =>
      _PrepositionInflectionViewState();
}

class _PrepositionInflectionViewState extends State<PrepositionInflectionView> {
  String _selectedPrepositionId = 'shel';
  bool _isDrillMode = false;

  // Drill state
  late _PrepositionQuizQuestion _currentQuestion;
  int? _selectedDrillOption;
  bool _isDrillAnswered = false;
  int _drillScore = 0;

  @override
  void initState() {
    super.initState();
    _currentQuestion = _generateDrillQuestion();
  }

  void _speakText(String hebrewText) {
    widget.audioService?.playWithTtsFallback(
      sourcePath: null,
      fallbackHebrewText: hebrewText,
    );
  }

  Future<void> _saveFormToSrs(
    BuildContext context,
    PrepositionEntity prep,
    PrepositionForm form,
  ) async {
    final useCase = widget.addCardToSrsUseCase;
    if (useCase == null) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final result = await useCase(
      AddCardToSrsParams(
        id: 'prep_${prep.id}_${form.person.name}',
        hebrewVocalized: form.hebrewVocalized,
        russianTranslation:
            '${form.russianTranslation} (предлог ${prep.baseHebrew})',
        exampleHebrewVocalized: form.exampleSentenceHebrew,
        exampleRussian: form.exampleSentenceRussian,
        attribution: const ContentAttribution(
          sourceName: 'Nexus Hebrew Prepositions',
          licenseName: 'CC0 1.0',
        ),
      ),
    );

    result.fold(
      (failure) => scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Ошибка: ${failure.message}')),
      ),
      (_) => scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            'Форма «${form.hebrewVocalized}» (${form.russianTranslation}) добавлена в FSRS!',
          ),
        ),
      ),
    );
  }

  _PrepositionQuizQuestion _generateDrillQuestion() {
    const prepositions = HebrewPrepositionsSeedData.prepositions;
    final random = Random();
    final prep = prepositions[random.nextInt(prepositions.length)];
    final form = prep.forms[random.nextInt(prep.forms.length)];

    final correct = form.hebrewVocalized;
    final otherForms = prep.forms
        .where((f) => f.hebrewVocalized != correct)
        .map((f) => f.hebrewVocalized)
        .toList();
    otherForms.shuffle(random);
    final options = [correct, ...otherForms.take(3)]..shuffle(random);

    return _PrepositionQuizQuestion(
      preposition: prep,
      targetForm: form,
      promptText:
          'Как сказать «${form.russianTranslation}» (предлог ${prep.baseHebrew})?',
      options: options,
      correctIndex: options.indexOf(correct),
      explanation:
          '«${form.hebrewVocalized}» [${form.transliteration}] — форма для ${form.person.labelRu}. Пример: ${form.exampleSentenceHebrew} (${form.exampleSentenceRussian}).',
    );
  }

  void _answerDrill(int index) {
    if (_isDrillAnswered) return;
    setState(() {
      _selectedDrillOption = index;
      _isDrillAnswered = true;
      if (index == _currentQuestion.correctIndex) {
        _drillScore++;
      }
    });
  }

  void _nextDrillQuestion() {
    setState(() {
      _currentQuestion = _generateDrillQuestion();
      _selectedDrillOption = null;
      _isDrillAnswered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedPrep = HebrewPrepositionsSeedData.prepositions.firstWhere(
      (p) => p.id == _selectedPrepositionId,
      orElse: () => HebrewPrepositionsSeedData.prepositions.first,
    );

    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 32),
      children: [
        // Mode switch row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Склонение предлогов (נְטִיָּה)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            FilterChip(
              avatar: Icon(
                _isDrillMode ? Icons.table_chart_rounded : Icons.quiz_rounded,
                size: 16,
              ),
              label: Text(_isDrillMode ? 'Таблица' : 'Тренажер'),
              selected: _isDrillMode,
              onSelected: (val) => setState(() => _isDrillMode = val),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (_isDrillMode)
          _buildDrillModeView(theme, colorScheme)
        else ...[
          // Horizontal selector of prepositions
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: HebrewPrepositionsSeedData.prepositions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final prep = HebrewPrepositionsSeedData.prepositions[index];
                final isSelected = prep.id == _selectedPrepositionId;
                return ChoiceChip(
                  label: Text(
                    '${prep.baseHebrew} (${prep.transliteration})',
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      height: 1.3,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) {
                      setState(() => _selectedPrepositionId = prep.id);
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Preposition Info Hero Card
          Card(
            elevation: 0,
            color: colorScheme.primaryContainer.withValues(alpha: 0.35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          selectedPrep.baseHebrew,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedPrep.baseRussian,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              selectedPrep.pattern.title,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    selectedPrep.grammaticalRule,
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (selectedPrep.usageNote != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsetsDirectional.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              selectedPrep.usageNote!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
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
          ),
          const SizedBox(height: 16),

          Text(
            'Парадигма склонения (${selectedPrep.forms.length} форм)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          // Paradigm Cards Grid
          ...selectedPrep.forms.map((form) {
            final hebrewText = widget.showNikkud
                ? form.hebrewVocalized
                : form.hebrewNormalized;

            return Card(
              elevation: 0,
              margin: const EdgeInsetsDirectional.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer.withValues(
                                alpha: 0.6,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              form.person.labelRu,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                hebrewText,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                  height: 1.35,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '[${form.transliteration}]',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.outline,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '· ${form.russianTranslation}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Пример: ${form.exampleSentenceHebrew} (${form.exampleSentenceRussian})',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded),
                      tooltip: 'Слушать',
                      onPressed: () => _speakText(form.hebrewVocalized),
                    ),
                    if (widget.addCardToSrsUseCase != null)
                      IconButton(
                        icon: const Icon(Icons.bookmark_add_outlined),
                        tooltip: 'В FSRS',
                        onPressed: () => unawaited(
                          _saveFormToSrs(context, selectedPrep, form),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildDrillModeView(ThemeData theme, ColorScheme colorScheme) {
    final question = _currentQuestion;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology_rounded, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Тренажер склонений',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Счёт: $_drillScore',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              question.promptText,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // 4 Option buttons
            ...List.generate(question.options.length, (index) {
              final option = question.options[index];
              final isSelected = _selectedDrillOption == index;
              final isCorrect = index == question.correctIndex;

              Color? bgColor;
              BorderSide borderSide = BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.7),
              );

              if (_isDrillAnswered) {
                if (isCorrect) {
                  bgColor = colorScheme.primaryContainer;
                  borderSide = BorderSide(color: colorScheme.primary, width: 2);
                } else if (isSelected) {
                  bgColor = colorScheme.errorContainer;
                  borderSide = BorderSide(color: colorScheme.error, width: 2);
                }
              }

              return Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 10),
                child: InkWell(
                  key: Key('drill_option_$index'),
                  onTap: () => _answerDrill(index),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsetsDirectional.all(14),
                    decoration: BoxDecoration(
                      color: bgColor ?? colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.fromBorderSide(borderSide),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          option,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            height: 1.35,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        if (_isDrillAnswered && isCorrect)
                          Icon(
                            Icons.check_circle_rounded,
                            color: colorScheme.primary,
                          ),
                        if (_isDrillAnswered && isSelected && !isCorrect)
                          Icon(Icons.cancel_rounded, color: colorScheme.error),
                      ],
                    ),
                  ),
                ),
              );
            }),

            if (_isDrillAnswered) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsetsDirectional.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  question.explanation,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _nextDrillQuestion,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Следующий вопрос'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PrepositionQuizQuestion {
  final PrepositionEntity preposition;
  final PrepositionForm targetForm;
  final String promptText;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const _PrepositionQuizQuestion({
    required this.preposition,
    required this.targetForm,
    required this.promptText,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}
