import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../data/datasources/minimal_pairs_seed_data.dart';
import '../../domain/entities/minimal_pair.dart';

/// Interactive workspace for Hebrew Audio Minimal Pairs and phonetic distinction.
///
/// Features:
/// - Blind audio playback with TTS (he-IL) and 0.8x/1.0x speed toggle.
/// - Side-by-side choice cards with immediate phonological feedback.
/// - Detailed historical & mnemonic notes explaining root and letter differences.
/// - Side-by-side isolated audio comparison and FSRS saving.
class MinimalPairsView extends StatefulWidget {
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;
  final bool showNikkud;

  const MinimalPairsView({
    super.key,
    this.audioService,
    this.addCardToSrsUseCase,
    this.showNikkud = true,
  });

  @override
  State<MinimalPairsView> createState() => _MinimalPairsViewState();
}

class _MinimalPairsViewState extends State<MinimalPairsView> {
  PhoneticCategory? _selectedCategory;
  int _currentExerciseIndex = 0;
  int _score = 0;
  int _streak = 0;

  double _playbackSpeed = 1.0;
  String? _selectedWordId;
  bool _isAnswered = false;
  bool _isCorrect = false;

  late List<MinimalPairExercise> _filteredExercises;
  late MinimalPairExercise _currentExercise;
  late List<MinimalPairWord> _shuffledChoices;

  @override
  void initState() {
    super.initState();
    _applyFilterAndReset();
  }

  void _applyFilterAndReset({PhoneticCategory? category}) {
    void update() {
      _selectedCategory = category;
      if (_selectedCategory == null) {
        _filteredExercises = List.from(MinimalPairsSeedData.allExercises);
      } else {
        _filteredExercises = MinimalPairsSeedData.allExercises
            .where((e) => e.category == _selectedCategory)
            .toList();
      }
      _currentExerciseIndex = 0;
      _setupCurrentExercise();
    }

    if (mounted) {
      setState(update);
    } else {
      update();
    }
  }

  void _setupCurrentExercise() {
    if (_filteredExercises.isEmpty) return;
    _currentExercise = _filteredExercises[_currentExerciseIndex];
    _selectedWordId = null;
    _isAnswered = false;
    _isCorrect = false;

    // Shuffle the two choices so target isn't always on the same side
    final choices = [
      _currentExercise.targetWord,
      _currentExercise.contrastWord,
    ];
    choices.shuffle(Random());
    _shuffledChoices = choices;

    // Automatically speak the target word on exercise start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakCurrentTarget();
    });
  }

  void _speakCurrentTarget() {
    _speakText(
      _currentExercise.targetWord.vocalized,
      speed: _playbackSpeed,
    );
  }

  void _speakText(String hebrewText, {double speed = 1.0}) {
    widget.audioService?.setPlaybackSpeed(speed);
    widget.audioService?.playWithTtsFallback(
      sourcePath: null,
      fallbackHebrewText: hebrewText,
    );
  }

  void _onSelectChoice(String wordId) {
    if (_isAnswered) return;

    final isCorrect = _currentExercise.isCorrectChoice(wordId);
    setState(() {
      _selectedWordId = wordId;
      _isAnswered = true;
      _isCorrect = isCorrect;
      if (isCorrect) {
        _score += 25;
        _streak += 1;
      } else {
        _streak = 0;
      }
    });
  }

  void _nextExercise() {
    setState(() {
      _currentExerciseIndex =
          (_currentExerciseIndex + 1) % _filteredExercises.length;
      _setupCurrentExercise();
    });
  }

  Future<void> _saveWordToSrs(
    BuildContext context,
    MinimalPairWord word,
  ) async {
    final useCase = widget.addCardToSrsUseCase;
    if (useCase == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    try {
      final result = await useCase.call(
        AddCardToSrsParams(
          id: 'mp_${word.id}',
          hebrewVocalized: word.vocalized,
          russianTranslation: word.translation,
          exampleHebrewVocalized: word.exampleSentenceHebrew,
          exampleRussian: word.exampleSentenceRussian,
          attribution: const ContentAttribution(
            sourceName: 'Nexus Hebrew Minimal Pairs',
            licenseName: 'CC0 1.0',
          ),
        ),
      );

      result.fold(
        (failure) => messenger.showSnackBar(
          SnackBar(content: Text('Ошибка: ${failure.message}')),
        ),
        (_) => messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Слово «${word.vocalized}» (${word.translation}) добавлено в FSRS!',
              style: TextStyle(color: theme.colorScheme.onSecondary),
            ),
            backgroundColor: theme.colorScheme.secondary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Не удалось сохранить карточку'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_filteredExercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.volume_off_outlined, size: 48),
            const SizedBox(height: 16),
            const Text('В этой категории пока нет упражнений'),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () => _applyFilterAndReset(),
              child: const Text('Показать все категории'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 32),
      children: [
        _buildCategoryChips(theme),
        const SizedBox(height: 12),
        _buildHeaderCard(theme),
        const SizedBox(height: 16),
        _buildAudioHeroCard(theme),
        const SizedBox(height: 16),
        _buildChoicesSection(theme),
        if (_isAnswered) ...[
          const SizedBox(height: 16),
          _buildFeedbackDeepDiveCard(theme),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('next_minimal_pair_button'),
            onPressed: _nextExercise,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Следующая пара'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsetsDirectional.symmetric(vertical: 14),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryChips(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Все звуки'),
            selected: _selectedCategory == null,
            onSelected: (_) => _applyFilterAndReset(category: null),
          ),
          const SizedBox(width: 8),
          ...PhoneticCategory.values.map((cat) {
            final isSelected = _selectedCategory == cat;
            return Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                label: Text(cat.title),
                selected: isSelected,
                onSelected: (_) => _applyFilterAndReset(category: cat),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsetsDirectional.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _currentExercise.category.title,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Пара ${_currentExerciseIndex + 1} из ${_filteredExercises.length}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (_streak > 1) ...[
            Container(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '🔥 $_streak',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            'Очки: $_score',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioHeroCard(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(20),
        child: Column(
          children: [
            Text(
              'Слушайте произношение слова:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              key: const Key('play_audio_hero_button'),
              onPressed: _speakCurrentTarget,
              icon: const Icon(Icons.volume_up_rounded, size: 28),
              label: const Text(
                'Прослушать снова',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Скорость: '),
                SegmentedButton<double>(
                  segments: const [
                    ButtonSegment<double>(
                      value: 1.0,
                      label: Text('1.0x'),
                    ),
                    ButtonSegment<double>(
                      value: 0.8,
                      label: Text('0.8x (Медленно)'),
                    ),
                  ],
                  selected: {_playbackSpeed},
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      _playbackSpeed = newSelection.first;
                    });
                    _speakCurrentTarget();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoicesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Какое слово прозвучало?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 500;
            if (isWide) {
              return Row(
                children: _shuffledChoices.map((word) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 6,
                      ),
                      child: _buildChoiceCard(theme, word),
                    ),
                  );
                }).toList(),
              );
            } else {
              return Column(
                children: _shuffledChoices.map((word) {
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 10),
                    child: _buildChoiceCard(theme, word),
                  );
                }).toList(),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildChoiceCard(ThemeData theme, MinimalPairWord word) {
    final isTarget = word.id == _currentExercise.targetWord.id;
    final isSelected = word.id == _selectedWordId;

    Color cardBg;
    Color borderColor;
    Widget? trailingIcon;

    if (!_isAnswered) {
      cardBg = theme.colorScheme.surface;
      borderColor = theme.colorScheme.outlineVariant;
    } else {
      if (isTarget) {
        cardBg = Colors.green.withValues(alpha: 0.15);
        borderColor = Colors.green.shade400;
        trailingIcon = const Icon(Icons.check_circle, color: Colors.green);
      } else if (isSelected) {
        cardBg = Colors.red.withValues(alpha: 0.15);
        borderColor = Colors.red.shade400;
        trailingIcon = const Icon(Icons.cancel, color: Colors.red);
      } else {
        cardBg = theme.colorScheme.surface.withValues(alpha: 0.5);
        borderColor = theme.colorScheme.outlineVariant.withValues(alpha: 0.3);
      }
    }

    return Card(
      key: Key('choice_card_${word.id}'),
      elevation: _isAnswered ? 0 : 2,
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: borderColor,
          width: isTarget && _isAnswered ? 2 : 1.5,
        ),
      ),
      child: InkWell(
        onTap: _isAnswered ? null : () => _onSelectChoice(word.id),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (word.shoresh != null)
                    Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Шореш: ${word.shoresh}',
                        style: theme.textTheme.labelSmall,
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  if (trailingIcon != null) trailingIcon,
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.showNikkud ? word.vocalized : word.unpointed,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: 'Noto Sans Hebrew',
                  fontSize: 28,
                  height: 1.35,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '[${word.transliteration}]',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                word.translation,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackDeepDiveCard(ThemeData theme) {
    return Card(
      elevation: 0,
      color: _isCorrect
          ? Colors.green.withValues(alpha: 0.1)
          : Colors.red.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: _isCorrect ? Colors.green.shade300 : Colors.red.shade300,
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  _isCorrect ? Icons.check_circle_outline : Icons.info_outline,
                  color: _isCorrect ? Colors.green.shade800 : Colors.red.shade800,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isCorrect
                        ? 'Точно! Вы безошибочно распознали слово'
                        : 'Внимание: в беглой речи эти звуки звучат одинаково',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _isCorrect
                          ? Colors.green.shade900
                          : Colors.red.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _currentExercise.pedagogicalExplanation,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
            const Divider(height: 24),
            Text(
              'Сравнение слов лицом к лицу:',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildWordComparisonRow(theme, _currentExercise.targetWord),
            const SizedBox(height: 8),
            _buildWordComparisonRow(theme, _currentExercise.contrastWord),
          ],
        ),
      ),
    );
  }

  Widget _buildWordComparisonRow(ThemeData theme, MinimalPairWord word) {
    return Container(
      padding: const EdgeInsetsDirectional.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.volume_up_rounded, size: 20),
                tooltip: 'Слушать ${word.vocalized}',
                onPressed: () => _speakText(word.vocalized),
              ),
              const SizedBox(width: 4),
              Text(
                word.vocalized,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: 'Noto Sans Hebrew',
                  fontSize: 18,
                  height: 1.35,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '— ${word.translation}',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_add_outlined, size: 20),
                tooltip: 'В FSRS',
                onPressed: () => _saveWordToSrs(context, word),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 44,
              end: 8,
              bottom: 4,
            ),
            child: Text(
              '💡 ${word.mnemonicNote}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
