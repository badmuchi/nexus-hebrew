import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../data/datasources/sentence_builder_seed_data.dart';
import '../../domain/entities/sentence_builder_exercise.dart';

/// Interactive sentence building and syntax training workspace.
///
/// Features:
/// - RTL word bank and construction canvas with tap-to-assemble and tap-to-remove.
/// - Rule category filters and syntax breakdown explanations.
/// - Native Hebrew TTS playback and FSRS spaced repetition saving.
/// - Visual hint system and score tracking.
class SentenceBuilderView extends StatefulWidget {
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;
  final bool showNikkud;

  const SentenceBuilderView({
    super.key,
    this.audioService,
    this.addCardToSrsUseCase,
    this.showNikkud = true,
  });

  @override
  State<SentenceBuilderView> createState() => _SentenceBuilderViewState();
}

class _SentenceBuilderViewState extends State<SentenceBuilderView> {
  SyntaxCategory? _selectedCategory;
  int _currentExerciseIndex = 0;
  int _score = 0;
  int _streak = 0;

  bool _isAnswerChecked = false;
  bool _isAnswerCorrect = false;
  bool _showHint = false;

  late List<SentenceExercise> _filteredExercises;
  late SentenceExercise _currentExercise;
  late List<SentenceToken> _availableTokens;
  final List<SentenceToken> _assembledTokens = [];

  @override
  void initState() {
    super.initState();
    _applyFilterAndReset();
  }

  void _applyFilterAndReset({SyntaxCategory? category}) {
    void update() {
      _selectedCategory = category;
      if (_selectedCategory == null) {
        _filteredExercises = List.from(SentenceBuilderSeedData.allExercises);
      } else {
        _filteredExercises = SentenceBuilderSeedData.allExercises
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
    _isAnswerChecked = false;
    _isAnswerCorrect = false;
    _showHint = false;
    _assembledTokens.clear();

    // Prepare pool of tokens (targets + distractors) shuffled
    final pool = List<SentenceToken>.from(_currentExercise.allTokensPool);
    pool.shuffle(Random());
    _availableTokens = pool;
  }

  void _onSelectToken(SentenceToken token) {
    if (_isAnswerChecked && _isAnswerCorrect) return;
    setState(() {
      _availableTokens.remove(token);
      _assembledTokens.add(token);
      if (_isAnswerChecked) {
        _isAnswerChecked = false;
      }
    });
  }

  void _onRemoveToken(SentenceToken token) {
    if (_isAnswerChecked && _isAnswerCorrect) return;
    setState(() {
      _assembledTokens.remove(token);
      _availableTokens.add(token);
      if (_isAnswerChecked) {
        _isAnswerChecked = false;
      }
    });
  }

  void _onClearAssembled() {
    if (_isAnswerChecked && _isAnswerCorrect) return;
    setState(() {
      _availableTokens.addAll(_assembledTokens);
      _assembledTokens.clear();
      _isAnswerChecked = false;
    });
  }

  void _checkAnswer() {
    if (_assembledTokens.isEmpty) return;

    final isCorrect = _currentExercise.isCorrect(_assembledTokens);
    setState(() {
      _isAnswerChecked = true;
      _isAnswerCorrect = isCorrect;
      if (isCorrect) {
        _score += 20;
        _streak += 1;
        _speakHebrew(_currentExercise.targetHebrew);
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

  void _speakHebrew(String text) {
    widget.audioService?.playWithTtsFallback(
      sourcePath: null,
      fallbackHebrewText: text,
    );
  }

  Future<void> _saveToSrs(BuildContext context) async {
    final useCase = widget.addCardToSrsUseCase;
    if (useCase == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    try {
      final result = await useCase.call(
        AddCardToSrsParams(
          id: 'sb_${_currentExercise.id}',
          hebrewVocalized: widget.showNikkud
              ? _currentExercise.targetHebrew
              : _currentExercise.targetHebrewUnpointed,
          russianTranslation: _currentExercise.russianTranslation,
          exampleHebrewVocalized: _currentExercise.targetHebrew,
          exampleRussian:
              '[${_currentExercise.transliteration}] ${_currentExercise.ruleTitle}',
          attribution: const ContentAttribution(
            sourceName: 'Nexus Hebrew Syntax Builder',
            licenseName: 'CC0 1.0',
          ),
        ),
      );

      result.fold(
        (failure) => messenger.showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${failure.message}'),
            behavior: SnackBarBehavior.floating,
          ),
        ),
        (_) => messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Фраза сохранена в карточки FSRS для повторения!',
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
            const Icon(Icons.inbox_outlined, size: 48),
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
        const SizedBox(height: 14),
        _buildPromptCard(theme),
        const SizedBox(height: 16),
        _buildConstructionCanvas(theme),
        const SizedBox(height: 16),
        _buildWordBank(theme),
        const SizedBox(height: 16),
        _buildActionButtons(theme),
        if (_isAnswerChecked) ...[
          const SizedBox(height: 16),
          _buildFeedbackCard(theme),
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
            label: const Text('Все правила'),
            selected: _selectedCategory == null,
            onSelected: (_) => _applyFilterAndReset(category: null),
          ),
          const SizedBox(width: 8),
          ...SyntaxCategory.values.map((cat) {
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
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _currentExercise.level,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Фраза ${_currentExerciseIndex + 1} из ${_filteredExercises.length}',
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

  Widget _buildPromptCard(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
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
                  Icons.translate_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Переведите на иврит:',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Подсказка',
                  icon: Icon(
                    _showHint
                        ? Icons.lightbulb_rounded
                        : Icons.lightbulb_outline_rounded,
                    color: _showHint ? Colors.amber.shade700 : null,
                  ),
                  onPressed: () {
                    setState(() {
                      _showHint = !_showHint;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _currentExercise.russianTranslation,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_showHint) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsetsDirectional.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.tips_and_updates_outlined,
                      size: 18,
                      color: Colors.amber.shade800,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _currentExercise.hint,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.amber.shade900,
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
    );
  }

  Widget _buildConstructionCanvas(ThemeData theme) {
    final borderColor = !_isAnswerChecked
        ? theme.colorScheme.primary.withValues(alpha: 0.4)
        : _isAnswerCorrect
            ? Colors.green.shade400
            : Colors.red.shade400;

    final bgColor = !_isAnswerChecked
        ? theme.colorScheme.surfaceContainerHigh
        : _isAnswerCorrect
            ? Colors.green.withValues(alpha: 0.08)
            : Colors.red.withValues(alpha: 0.08);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ваша фраза (нажмите на слово, чтобы убрать):',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (_assembledTokens.isNotEmpty && (!_isAnswerChecked || !_isAnswerCorrect))
              TextButton.icon(
                onPressed: _onClearAssembled,
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('Сброс'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          constraints: const BoxConstraints(minHeight: 90),
          padding: const EdgeInsetsDirectional.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
          ),
          alignment: Alignment.center,
          child: _assembledTokens.isEmpty
              ? Text(
                  'Нажмите на карточки слов ниже в правильном порядке',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                    fontStyle: FontStyle.italic,
                  ),
                )
              : Directionality(
                  textDirection: TextDirection.rtl,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: _assembledTokens.map((token) {
                      return _buildAssembledWordChip(theme, token);
                    }).toList(),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildAssembledWordChip(ThemeData theme, SentenceToken token) {
    final chipColor = !_isAnswerChecked
        ? theme.colorScheme.secondaryContainer
        : _isAnswerCorrect
            ? Colors.green.withValues(alpha: 0.2)
            : Colors.red.withValues(alpha: 0.15);

    final textColor = !_isAnswerChecked
        ? theme.colorScheme.onSecondaryContainer
        : _isAnswerCorrect
            ? Colors.green.shade900
            : Colors.red.shade900;

    return InkWell(
      onTap: () => _onRemoveToken(token),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: chipColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: textColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.showNikkud ? token.vocalized : token.unpointed,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'Noto Sans Hebrew',
                fontSize: 20,
                height: 1.35,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              token.translation,
              textDirection: TextDirection.ltr,
              style: TextStyle(
                fontSize: 11,
                color: textColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordBank(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Банк слов:',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Directionality(
          textDirection: TextDirection.rtl,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableTokens.map((token) {
              return _buildBankWordChip(theme, token);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBankWordChip(ThemeData theme, SentenceToken token) {
    return ActionChip(
      key: Key('bank_token_${token.id}'),
      onPressed: () => _onSelectToken(token),
      elevation: 1,
      backgroundColor: theme.colorScheme.surface,
      side: BorderSide(
        color: theme.colorScheme.outlineVariant,
      ),
      label: Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.showNikkud ? token.vocalized : token.unpointed,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'Noto Sans Hebrew',
                fontSize: 18,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              token.translation,
              textDirection: TextDirection.ltr,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    if (_isAnswerChecked && _isAnswerCorrect) {
      return FilledButton.icon(
        key: const Key('next_exercise_button'),
        onPressed: _nextExercise,
        icon: const Icon(Icons.arrow_forward_rounded),
        label: const Text('Следующая фраза'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 14),
        ),
      );
    }

    return FilledButton.icon(
      key: const Key('check_answer_button'),
      onPressed: _assembledTokens.isEmpty ? null : _checkAnswer,
      icon: const Icon(Icons.check_circle_outline_rounded),
      label: const Text('Проверить'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsetsDirectional.symmetric(vertical: 14),
      ),
    );
  }

  Widget _buildFeedbackCard(ThemeData theme) {
    if (_isAnswerCorrect) {
      return Card(
        elevation: 0,
        color: Colors.green.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.green.shade300),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Отлично! Правильно!',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.green.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded),
                    tooltip: 'Слушать фразу',
                    onPressed: () => _speakHebrew(_currentExercise.targetHebrew),
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark_add_outlined),
                    tooltip: 'В карточки FSRS',
                    onPressed: () => _saveToSrs(context),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _currentExercise.targetHebrew,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: 'Noto Sans Hebrew',
                  fontSize: 22,
                  height: 1.4,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '[${_currentExercise.transliteration}]',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Divider(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentExercise.ruleTitle,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentExercise.ruleExplanation,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return Card(
        elevation: 0,
        color: Colors.red.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.red.shade300),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Пока не совсем так',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.red.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Проверьте порядок слов, наличие артикля הַ или предлога אֶת. Нажмите на неверные слова в верхнем блоке, чтобы вернуть их в банк, или воспользуйтесь подсказкой (иконка лампочки).',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
            ],
          ),
        ),
      );
    }
  }
}
