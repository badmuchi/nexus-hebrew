import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../data/datasources/hebrew_numbers_seed_data.dart';
import '../../domain/entities/cashier_challenge.dart';
import '../../domain/entities/hebrew_number.dart';
import '../widgets/israeli_coins_counter.dart';

/// Full-screen interactive learning arena for Hebrew numbers, supermarket cashier
/// dialogues, Israeli shekel calculation, and inverted gender agreements.
class NumbersCashierScreen extends StatefulWidget {
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;
  final ValueChanged<int>? onXpEarned;

  const NumbersCashierScreen({
    super.key,
    this.audioService,
    this.addCardToSrsUseCase,
    this.onXpEarned,
  });

  @override
  State<NumbersCashierScreen> createState() => _NumbersCashierScreenState();
}

class _NumbersCashierScreenState extends State<NumbersCashierScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Game state
  CashierChallengeMode _selectedMode = CashierChallengeMode.marketCheckout;
  int _questionIndex = 0;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;
  int _score = 0;
  bool _isPlayingAudio = false;

  List<CashierChallengeQuestion> get _filteredQuestions => HebrewNumbersSeedData.challenges
      .where((q) => q.mode == _selectedMode)
      .toList();

  CashierChallengeQuestion get _currentQuestion {
    final list = _filteredQuestions;
    if (list.isEmpty) return HebrewNumbersSeedData.challenges.first;
    return list[_questionIndex % list.length];
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onSelectMode(CashierChallengeMode mode) {
    unawaited(HapticFeedback.selectionClick());
    setState(() {
      _selectedMode = mode;
      _questionIndex = 0;
      _selectedAnswerIndex = null;
      _isAnswered = false;
    });
  }

  Future<void> _playCurrentAudio() async {
    final audio = widget.audioService;
    if (audio == null) return;
    setState(() => _isPlayingAudio = true);
    try {
      final q = _currentQuestion;
      await audio.playWithTtsFallback(
        sourcePath: q.audioPath,
        fallbackHebrewText: q.promptHebrewWithNikkud,
      );
    } finally {
      if (mounted) {
        setState(() => _isPlayingAudio = false);
      }
    }
  }

  void _onAnswer(int index) {
    if (_isAnswered) return;
    unawaited(HapticFeedback.lightImpact());

    final isCorrect = index == _currentQuestion.correctAnswerIndex;
    if (isCorrect) {
      unawaited(HapticFeedback.mediumImpact());
      _score += 15;
      widget.onXpEarned?.call(15);
    }

    setState(() {
      _selectedAnswerIndex = index;
      _isAnswered = true;
    });
  }

  void _onCoinsTraySubmitted(int amount) {
    if (_isAnswered) return;
    final target = _currentQuestion.targetAmountShekels;
    if (target == null) return;

    final isCorrect = amount == target;
    if (isCorrect) {
      unawaited(HapticFeedback.heavyImpact());
      _score += 25;
      widget.onXpEarned?.call(25);
    } else {
      unawaited(HapticFeedback.selectionClick());
    }

    setState(() {
      _selectedAnswerIndex = isCorrect ? _currentQuestion.correctAnswerIndex : -1;
      _isAnswered = true;
    });
  }

  void _nextQuestion() {
    unawaited(HapticFeedback.lightImpact());
    setState(() {
      _questionIndex++;
      _selectedAnswerIndex = null;
      _isAnswered = false;
    });
  }

  Future<void> _addEntryToSrs(HebrewNumberEntry entry) async {
    final useCase = widget.addCardToSrsUseCase;
    if (useCase == null) return;

    final params = AddCardToSrsParams(
      id: 'num_${entry.numberValue}_${entry.gender.name}_${entry.hebrewWithoutNikkud.hashCode.abs()}',
      hebrewVocalized: entry.hebrewWithNikkud,
      russianTranslation: '${entry.translationRu} (${entry.transcriptionRu})',
      category: LexicalCategory.phrase,
      exampleHebrewVocalized: entry.hebrewWithNikkud,
      exampleRussian: entry.ruleExplanationRu ?? entry.translationRu,
    );

    final res = await useCase(params);

    if (mounted) {
      final message = res.isSuccess
          ? '✓ "${entry.hebrewWithNikkud}" добавлено в FSRS!'
          : 'Уже есть в колоде или ошибка';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Касса и Шекели (קֻפָּה)'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.point_of_sale_rounded), text: 'Тренажер кассы'),
            Tab(icon: Icon(Icons.menu_book_rounded), text: 'Атлас чисел'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGameTab(theme),
          _buildReferenceTab(theme),
        ],
      ),
    );
  }

  Widget _buildGameTab(ThemeData theme) {
    final q = _currentQuestion;
    final questions = _filteredQuestions;
    final progress = questions.isEmpty ? 0.0 : ((_questionIndex % questions.length) + 1) / questions.length;

    return ListView(
      padding: const EdgeInsetsDirectional.all(16),
      children: [
        // Mode Selector Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final mode in CashierChallengeMode.values) ...[
                ChoiceChip(
                  label: Text('${mode.icon} ${mode.titleRu}'),
                  selected: _selectedMode == mode,
                  onSelected: (_) => _onSelectMode(mode),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Linear Progress & Score Bar
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
              ),
              child: Text(
                '⭐ $_score XP',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFF57F17)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Prompt Card
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  q.promptRu,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    q.promptHebrewWithNikkud,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  q.transcriptionRu,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: _isPlayingAudio ? null : _playCurrentAudio,
                    icon: Icon(_isPlayingAudio ? Icons.volume_up_rounded : Icons.volume_down_rounded),
                    label: const Text('Послушать кассира'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Interactive Coins Counter Tray for Market Checkout Mode
        if (_selectedMode == CashierChallengeMode.marketCheckout && q.targetAmountShekels != null) ...[
          IsraeliCoinsCounter(
            targetAmount: q.targetAmountShekels,
            onAmountSubmitted: _onCoinsTraySubmitted,
          ),
          const SizedBox(height: 16),
        ],

        // Options List
        Text(
          'Выберите ответ:',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),

        for (int i = 0; i < q.options.length; i++) ...[
          _buildOptionTile(theme, q, i),
          const SizedBox(height: 8),
        ],

        // Explanation & Next Button
        if (_isAnswered) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsetsDirectional.all(14),
            decoration: BoxDecoration(
              color: (_selectedAnswerIndex == q.correctAnswerIndex)
                  ? const Color(0xFF2E7D32).withValues(alpha: 0.12)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (_selectedAnswerIndex == q.correctAnswerIndex)
                    ? const Color(0xFF2E7D32).withValues(alpha: 0.3)
                    : Colors.red.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      _selectedAnswerIndex == q.correctAnswerIndex
                          ? Icons.check_circle_rounded
                          : Icons.info_outline_rounded,
                      color: _selectedAnswerIndex == q.correctAnswerIndex
                          ? const Color(0xFF2E7D32)
                          : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedAnswerIndex == q.correctAnswerIndex ? 'Верно! Отличная реакция!' : 'Объяснение правила:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _selectedAnswerIndex == q.correctAnswerIndex
                              ? const Color(0xFF2E7D32)
                              : Colors.red.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(q.explanationRu, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _nextQuestion,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Следующий вопрос ➔'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOptionTile(ThemeData theme, CashierChallengeQuestion q, int index) {
    final isSelected = _selectedAnswerIndex == index;
    final isCorrect = index == q.correctAnswerIndex;

    Color borderColor = theme.colorScheme.outlineVariant.withValues(alpha: 0.5);
    Color bgColor = theme.colorScheme.surface;

    if (_isAnswered) {
      if (isCorrect) {
        borderColor = const Color(0xFF2E7D32);
        bgColor = const Color(0xFF2E7D32).withValues(alpha: 0.12);
      } else if (isSelected) {
        borderColor = Colors.red;
        bgColor = Colors.red.withValues(alpha: 0.1);
      }
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: _isAnswered ? null : () => _onAnswer(index),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsetsDirectional.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: isSelected || (_isAnswered && isCorrect) ? 2 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                ),
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    q.options[index],
                    textAlign: TextAlign.start,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
              if (_isAnswered && isCorrect)
                const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 20)
              else if (_isAnswered && isSelected)
                const Icon(Icons.cancel_rounded, color: Colors.red, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReferenceTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsetsDirectional.all(16),
      children: [
        // Golden Rule Callout
        Container(
          padding: const EdgeInsetsDirectional.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFB300).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFB300).withValues(alpha: 0.4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💡', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Золотое правило числительных 1-10:',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFE65100),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Окончание ־ָה (камац-хей) у чисел 3-10 означает МУЖСКОЙ род (שְׁלוֹשָׁה שְׁקָלִים)!\n'
                      'Форма без окончания — ЖЕНСКИЙ род (שָׁלוֹשׁ עוּגוֹת — три торта).',
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'Числа и цены в шекелях:',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        for (final entry in HebrewNumbersSeedData.referenceNumbers) ...[
          _buildReferenceEntryTile(theme, entry),
          const SizedBox(height: 8),
        ],

        const SizedBox(height: 16),
        Text(
          'Полезные фразы на кассе:',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        for (final phrase in HebrewNumbersSeedData.cashierPhrases) ...[
          _buildReferenceEntryTile(theme, phrase),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildReferenceEntryTile(ThemeData theme, HebrewNumberEntry entry) {
    return Container(
      padding: const EdgeInsetsDirectional.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              entry.numberValue > 0 ? '${entry.numberValue}' : '🗣️',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    entry.hebrewWithNikkud,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                      height: 1.45,
                    ),
                  ),
                ),
                Text(
                  '${entry.transcriptionRu} • ${entry.translationRu}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (entry.ruleExplanationRu != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      entry.ruleExplanationRu!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Озвучить',
            icon: const Icon(Icons.volume_up_rounded, size: 20),
            onPressed: () {
              widget.audioService?.playWithTtsFallback(
                sourcePath: entry.audioPath,
                fallbackHebrewText: entry.hebrewWithNikkud,
              );
            },
          ),
          IconButton(
            tooltip: 'В FSRS',
            icon: const Icon(Icons.bookmark_add_outlined, size: 20),
            onPressed: () => _addEntryToSrs(entry),
          ),
        ],
      ),
    );
  }
}
