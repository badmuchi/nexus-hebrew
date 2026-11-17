import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../../../srs/domain/entities/fsrs_models.dart';
import '../../domain/entities/daily_workout_plan.dart';
import '../../domain/usecases/complete_daily_workout.dart';

enum WorkoutStep { cards, grammar, listening, completed }

/// 5-minute mixed daily training screen combining FSRS, grammar, and listening.
class DailyWorkoutScreen extends StatefulWidget {
  final DailyWorkoutPlan plan;
  final AudioPlaybackService? audioService;
  final CompleteDailyWorkoutUseCase completeUseCase;
  final VoidCallback? onCompleted;

  const DailyWorkoutScreen({
    super.key,
    required this.plan,
    required this.completeUseCase,
    this.audioService,
    this.onCompleted,
  });

  @override
  State<DailyWorkoutScreen> createState() => _DailyWorkoutScreenState();
}

class _DailyWorkoutScreenState extends State<DailyWorkoutScreen> {
  WorkoutStep _currentStep = WorkoutStep.cards;
  int _cardIndex = 0;
  bool _cardFlipped = false;

  // Grammar state
  String? _selectedGrammarOption;

  // Listening state
  bool _listeningRevealed = false;
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    if (widget.plan.cards.isEmpty) {
      if (widget.plan.grammarChallenge != null) {
        _currentStep = WorkoutStep.grammar;
      } else if (widget.plan.listeningExercise != null) {
        _currentStep = WorkoutStep.listening;
      } else {
        _currentStep = WorkoutStep.completed;
      }
    }
  }

  Future<void> _playHebrew(String vocalized, {String? audioUrl}) async {
    if (_isPlayingAudio) return;
    setState(() {
      _isPlayingAudio = true;
    });
    try {
      await widget.audioService?.playWithTtsFallback(
        sourcePath: audioUrl,
        fallbackHebrewText: vocalized,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPlayingAudio = false;
        });
      }
    }
  }

  void _onRateCard(FsrsRating rating) {
    setState(() {
      _cardFlipped = false;
      if (_cardIndex + 1 < widget.plan.cards.length) {
        _cardIndex += 1;
      } else {
        // Move to step 2 or 3
        if (widget.plan.grammarChallenge != null) {
          _currentStep = WorkoutStep.grammar;
        } else if (widget.plan.listeningExercise != null) {
          _currentStep = WorkoutStep.listening;
        } else {
          _finishWorkout();
        }
      }
    });
  }

  void _onSelectGrammarOption(String option) {
    if (_selectedGrammarOption != null) return;
    setState(() {
      _selectedGrammarOption = option;
    });

    _playHebrew(option);

    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() {
        if (widget.plan.listeningExercise != null) {
          _currentStep = WorkoutStep.listening;
        } else {
          _finishWorkout();
        }
      });
    });
  }

  Future<void> _finishWorkout() async {
    await widget.completeUseCase(completedAt: DateTime.now().toUtc());
    widget.onCompleted?.call();
    if (mounted) {
      setState(() {
        _currentStep = WorkoutStep.completed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Тренировка дня 🎯'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: switch (_currentStep) {
          WorkoutStep.cards => _buildCardsStep(theme),
          WorkoutStep.grammar => _buildGrammarStep(theme),
          WorkoutStep.listening => _buildListeningStep(theme),
          WorkoutStep.completed => _buildCompletedStep(theme),
        },
      ),
    );
  }

  Widget _buildStepHeader({
    required ThemeData theme,
    required String stepTitle,
    required int stepNumber,
    required double progress,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ШАГ $stepNumber ИЗ 3: $stepTitle',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+50 XP',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsStep(ThemeData theme) {
    final card = widget.plan.cards[_cardIndex];
    final totalCards = widget.plan.cards.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepHeader(
          theme: theme,
          stepTitle: 'FSRS-ЭКСПРЕСС ($_cardIndex/$totalCards)',
          stepNumber: 1,
          progress: (_cardIndex + 1) / (totalCards + 2),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                setState(() {
                  _cardFlipped = !_cardFlipped;
                });
              },
              child: Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (card.binyan != Binyan.none)
                        Chip(
                          label: Text(
                            '${card.binyan.hebrewLabel} · ${card.binyan.transliteration}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        card.hebrew.vocalized,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      IconButton.filledTonal(
                        icon: Icon(
                          _isPlayingAudio
                              ? Icons.volume_up_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        onPressed: () => _playHebrew(
                          card.hebrew.vocalized,
                          audioUrl: card.audioUrl,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_cardFlipped) ...[
                        const Divider(),
                        const SizedBox(height: 12),
                        Text(
                          card.russianTranslation,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (card.root != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Корень: ${card.root!.hyphenated}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ] else ...[
                        Text(
                          'Нажми на карточку, чтобы перевернуть',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: _cardFlipped
              ? Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _onRateCard(FsrsRating.again),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        child: const Text('Снова'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _onRateCard(FsrsRating.hard),
                        child: const Text('Трудно'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _onRateCard(FsrsRating.good),
                        child: const Text('Хорошо'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: () => _onRateCard(FsrsRating.easy),
                        child: const Text('Легко'),
                      ),
                    ),
                  ],
                )
              : FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      _cardFlipped = true;
                    });
                  },
                  icon: const Icon(Icons.flip_rounded),
                  label: const Text('Показать перевод'),
                ),
        ),
      ],
    );
  }

  Widget _buildGrammarStep(ThemeData theme) {
    final challenge = widget.plan.grammarChallenge;
    if (challenge == null) {
      return const SizedBox.shrink();
    }

    final verb = challenge.verb;
    final form = challenge.targetForm;
    final allOptions = <String>[
      form.form.vocalized,
      ...challenge.distractors,
    ]..shuffle();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepHeader(
          theme: theme,
          stepTitle: 'ГРАММАТИЧЕСКИЙ БЛИЦ',
          stepNumber: 2,
          progress: 0.66,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 0,
                  color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              verb.infinitive?.vocalized ?? verb.lemma.vocalized,
                              textDirection: TextDirection.rtl,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                height: 1.4,
                              ),
                            ),
                            Chip(
                              label: Text(
                                '${verb.binyan.hebrewLabel} (${verb.binyan.transliteration})',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Значение: ${verb.russianMeaning}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Корень: ${verb.root.hyphenated}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Выбери правильную форму:',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.help_outline_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${form.tense.russianLabel} время · ${form.person.russianLabel} (${form.person.hebrewPronoun})',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...allOptions.map((option) {
                  final isSelected = _selectedGrammarOption == option;
                  final isCorrectOption =
                      option.trim() == form.form.vocalized.trim();

                  Color? btnColor;
                  if (_selectedGrammarOption != null) {
                    if (isCorrectOption) {
                      btnColor = Colors.green.shade600;
                    } else if (isSelected) {
                      btnColor = theme.colorScheme.error;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor: btnColor?.withValues(alpha: 0.15),
                        side: BorderSide(
                          color: btnColor ?? theme.colorScheme.outlineVariant,
                          width: btnColor != null ? 2.0 : 1.0,
                        ),
                      ),
                      onPressed: _selectedGrammarOption == null
                          ? () => _onSelectGrammarOption(option)
                          : null,
                      child: Row(
                        children: [
                          if (_selectedGrammarOption != null && isCorrectOption)
                            const Icon(Icons.check_circle_rounded,
                                color: Colors.green)
                          else if (isSelected && !isCorrectOption)
                            Icon(Icons.cancel_rounded,
                                color: theme.colorScheme.error)
                          else
                            const SizedBox(width: 24),
                          Expanded(
                            child: Text(
                              option,
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListeningStep(ThemeData theme) {
    final exercise = widget.plan.listeningExercise;
    if (exercise == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepHeader(
          theme: theme,
          stepTitle: 'АУДИО-ЧЕЛЛЕНДЖ',
          stepNumber: 3,
          progress: 0.95,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        iconSize: 36,
                        icon: Icon(
                          _isPlayingAudio
                              ? Icons.volume_up_rounded
                              : Icons.play_arrow_rounded,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        onPressed: () => _playHebrew(
                          exercise.transcript.vocalized,
                          audioUrl: exercise.audioUrl,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Прослушай фразу на иврите',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Нажми кнопку воспроизведения выше',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (_listeningRevealed) ...[
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        exercise.transcript.vocalized,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        exercise.russianTranslation,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ] else ...[
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _listeningRevealed = true;
                          });
                        },
                        icon: const Icon(Icons.visibility_rounded),
                        label: const Text('Проверить понимание'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: FilledButton.icon(
            onPressed: _finishWorkout,
            icon: const Icon(Icons.check_circle_rounded),
            label: const Text('Завершить тренировку дня'),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedStep(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.tertiary,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 54,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Тренировка дня завершена! 🎉',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+50 XP НАЧИСЛЕНО 🏅',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ты отлично потренировал карточки, спряжение глаголов и восприятие на слух. Твоя ударная серия продолжается!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.done_all_rounded),
              label: const Text('Отлично, к прогрессу!'),
            ),
          ],
        ),
      ),
    );
  }
}
