import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../../../dictionary/domain/entities/dictionary_entry.dart';
import '../../../dictionary/presentation/cubit/dictionary_cubit.dart';
import '../../../dictionary/presentation/cubit/dictionary_state.dart';
import '../../domain/entities/srs_card.dart';
import '../../domain/usecases/add_card_to_srs.dart';

class SprintQuestion {
  final String id;
  final String hebrewVocalized;
  final String hebrewNormalized;
  final String correctTranslation;
  final List<String> options;
  final int correctIndex;
  final String? audioUrl;
  final String? root;
  final String category;

  const SprintQuestion({
    required this.id,
    required this.hebrewVocalized,
    required this.hebrewNormalized,
    required this.correctTranslation,
    required this.options,
    required this.correctIndex,
    this.audioUrl,
    this.root,
    required this.category,
  });
}

class SpeedSprintScreen extends StatefulWidget {
  const SpeedSprintScreen({
    super.key,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  @override
  State<SpeedSprintScreen> createState() => _SpeedSprintScreenState();
}

class _SpeedSprintScreenState extends State<SpeedSprintScreen> {
  static const int _gameDurationSeconds = 60;

  bool _isGameActive = false;
  bool _isGameOver = false;
  int _secondsRemaining = _gameDurationSeconds;
  Timer? _timer;

  List<SprintQuestion> _questions = [];
  int _currentQuestionIndex = 0;

  int _score = 0;
  int _streak = 0;
  int _maxStreak = 0;
  int _correctCount = 0;
  int _wrongCount = 0;

  int? _selectedOptionIndex;
  bool _isAnswerEvaluating = false;

  final List<SprintQuestion> _missedQuestions = [];
  final Set<String> _addedToSrsWords = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prepareQuestions();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _prepareQuestions() {
    final dictState = context.read<DictionaryCubit>().state;
    final entries = dictState is DictionaryLoaded
        ? dictState.allEntries
        : const <DictionaryEntry>[];

    if (entries.isEmpty) return;

    final shuffledEntries = List<DictionaryEntry>.from(entries)..shuffle();
    final random = math.Random();
    final questions = <SprintQuestion>[];

    for (var i = 0; i < shuffledEntries.length; i++) {
      final target = shuffledEntries[i];
      final correctTranslation = target.russianTranslation;

      // Pick 3 random distractors with distinct translations
      final distractors = <String>{};
      var attempts = 0;
      while (distractors.length < 3 && attempts < 50) {
        attempts++;
        final candidate = entries[random.nextInt(entries.length)];
        if (candidate.id != target.id &&
            candidate.russianTranslation != correctTranslation) {
          distractors.add(candidate.russianTranslation);
        }
      }

      final options = [correctTranslation, ...distractors]..shuffle(random);
      final correctIndex = options.indexOf(correctTranslation);

      questions.add(
        SprintQuestion(
          id: target.id,
          hebrewVocalized: target.hebrew.vocalized,
          hebrewNormalized: target.hebrew.normalized,
          correctTranslation: correctTranslation,
          options: options,
          correctIndex: correctIndex,
          audioUrl: target.audioUrl,
          root: target.root?.hyphenated,
          category: target.category.id,
        ),
      );
    }

    setState(() {
      _questions = questions;
    });
  }

  void _startGame() {
    if (_questions.isEmpty) return;

    setState(() {
      _isGameActive = true;
      _isGameOver = false;
      _secondsRemaining = _gameDurationSeconds;
      _currentQuestionIndex = 0;
      _score = 0;
      _streak = 0;
      _maxStreak = 0;
      _correctCount = 0;
      _wrongCount = 0;
      _selectedOptionIndex = null;
      _isAnswerEvaluating = false;
      _missedQuestions.clear();
      _addedToSrsWords.clear();
    });

    _playCurrentWordAudio();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsRemaining > 1) {
          _secondsRemaining--;
        } else {
          _secondsRemaining = 0;
          _endGame();
        }
      });
    });
  }

  void _endGame() {
    _timer?.cancel();
    setState(() {
      _isGameActive = false;
      _isGameOver = true;
    });
  }

  void _playCurrentWordAudio() {
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) return;
    final audio = widget.audioService;
    if (audio == null) return;
    final q = _questions[_currentQuestionIndex];
    unawaited(
      audio.playWithTtsFallback(
        sourcePath: q.audioUrl,
        fallbackHebrewText: q.hebrewVocalized,
      ),
    );
  }

  void _handleOptionSelected(int index) {
    if (!_isGameActive || _isAnswerEvaluating) return;

    final q = _questions[_currentQuestionIndex];
    final isCorrect = index == q.correctIndex;

    setState(() {
      _selectedOptionIndex = index;
      _isAnswerEvaluating = true;

      if (isCorrect) {
        _correctCount++;
        _streak++;
        if (_streak > _maxStreak) {
          _maxStreak = _streak;
        }

        // Scoring: 100 base + streak multiplier
        var multiplier = 1.0;
        if (_streak >= 10) {
          multiplier = 3.0;
        } else if (_streak >= 5) {
          multiplier = 2.0;
        } else if (_streak >= 3) {
          multiplier = 1.5;
        }
        _score += (100 * multiplier).round();
      } else {
        _wrongCount++;
        _streak = 0;
        _missedQuestions.add(q);
      }
    });

    // Advance to next question after short delay
    Future<void>.delayed(const Duration(milliseconds: 320), () {
      if (!mounted || !_isGameActive) return;

      if (_currentQuestionIndex + 1 < _questions.length) {
        setState(() {
          _currentQuestionIndex++;
          _selectedOptionIndex = null;
          _isAnswerEvaluating = false;
        });
        _playCurrentWordAudio();
      } else {
        _endGame();
      }
    });
  }

  Future<void> _addMissedWordToSrs(SprintQuestion q) async {
    final useCase = widget.addCardToSrsUseCase;
    if (useCase == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('FSRS недоступен в текущей сессии'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final res = await useCase(
      AddCardToSrsParams(
        id: 'srs_sprint_${q.id}_${DateTime.now().millisecondsSinceEpoch}',
        hebrewVocalized: q.hebrewVocalized,
        russianTranslation: q.correctTranslation,
        binyan: Binyan.none,
        category: LexicalCategory.parseStrict(q.category).getOrNull() ??
            LexicalCategory.noun,
        audioUrl: q.audioUrl,
        attribution: const ContentAttribution(
          sourceName: 'Nexus Speed Sprint',
          licenseName: 'CC BY-SA 4.0',
        ),
      ),
    );

    if (res.isSuccess && mounted) {
      setState(() {
        _addedToSrsWords.add(q.hebrewNormalized);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('«${q.hebrewVocalized}» добавлено в FSRS!'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('⚡️ Блиц-спринт'),
        actions: [
          if (_isGameActive)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _secondsRemaining <= 10
                        ? theme.colorScheme.errorContainer
                        : theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: _secondsRemaining <= 10
                            ? theme.colorScheme.onErrorContainer
                            : theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_secondsRemaining с',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: _secondsRemaining <= 10
                              ? theme.colorScheme.onErrorContainer
                              : theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _isGameOver
            ? _buildGameOverView(theme)
            : (_isGameActive
                ? _buildActiveGameView(theme)
                : _buildLobbyView(theme)),
      ),
    );
  }

  Widget _buildLobbyView(ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Text(
                '⚡️',
                style: theme.textTheme.displayMedium,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Блиц-спринт: 60 секунд',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Проверь скорость реакции и словарный запас иврита!\nВыбирай правильный перевод, держи комбо и набирай максимум очков.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                Chip(
                  avatar: Icon(Icons.timer_rounded, size: 16),
                  label: Text('60 секунд'),
                ),
                Chip(
                  avatar: Icon(Icons.local_fire_department_rounded,
                      size: 16),
                  label: Text('Комбо x3'),
                ),
                Chip(
                  avatar: Icon(Icons.volume_up_rounded, size: 16),
                  label: Text('Озвучка слов'),
                ),
              ],
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: 240,
              height: 52,
              child: FilledButton.icon(
                icon: const Icon(Icons.play_arrow_rounded, size: 24),
                label: const Text(
                  'Начать спринт',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                onPressed: _questions.isEmpty ? null : _startGame,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveGameView(ThemeData theme) {
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) {
      return const SizedBox.shrink();
    }

    final q = _questions[_currentQuestionIndex];
    final progress = 1.0 - (_secondsRemaining / _gameDurationSeconds);

    return Column(
      children: [
        // Timer progress bar
        LinearProgressIndicator(
          value: progress,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(
            _secondsRemaining <= 10
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
          ),
          minHeight: 6,
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Score
              Row(
                children: [
                  Icon(Icons.stars_rounded,
                      color: Colors.amber.shade700, size: 22),
                  const SizedBox(width: 6),
                  Text(
                    '$_score',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              // Streak
              if (_streak >= 3)
                Container(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade400),
                  ),
                  child: Row(
                    children: [
                      const Text('🔥'),
                      const SizedBox(width: 4),
                      Text(
                        'Серия: $_streak',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const Spacer(),

        // Hebrew Word Card
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
          child: Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 24,
                vertical: 28,
              ),
              child: Column(
                children: [
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      q.hebrewVocalized,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.volume_up_rounded),
                    tooltip: 'Озвучить слово',
                    onPressed: _playCurrentWordAudio,
                  ),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),

        // Options 2x2 Grid / Column
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 24),
          child: Column(
            children: [
              for (var i = 0; i < q.options.length; i++) ...[
                _buildOptionButton(theme, q, i),
                if (i < q.options.length - 1) const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton(ThemeData theme, SprintQuestion q, int index) {
    Color? backgroundColor;
    Color? textColor;
    BorderSide borderSide = BorderSide(color: theme.colorScheme.outlineVariant);

    if (_isAnswerEvaluating) {
      if (index == q.correctIndex) {
        backgroundColor = Colors.green.shade600;
        textColor = Colors.white;
        borderSide = BorderSide(color: Colors.green.shade800);
      } else if (index == _selectedOptionIndex) {
        backgroundColor = theme.colorScheme.error;
        textColor = theme.colorScheme.onError;
        borderSide = BorderSide(color: theme.colorScheme.error);
      }
    }

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor ?? theme.colorScheme.onSurface,
          side: borderSide,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: _isAnswerEvaluating ? null : () => _handleOptionSelected(index),
        child: Text(
          q.options[index],
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildGameOverView(ThemeData theme) {
    final total = _correctCount + _wrongCount;
    final accuracy = total > 0 ? ((_correctCount / total) * 100).round() : 0;

    String praiseEmoji = '⚡️';
    String praiseText = 'Хорошая разминка!';
    if (_score >= 2000) {
      praiseEmoji = '🏆';
      praiseText = 'Легендарный спринт!';
    } else if (_score >= 1000) {
      praiseEmoji = '🔥';
      praiseText = 'Отличная скорость!';
    }

    return ListView(
      padding: const EdgeInsetsDirectional.all(24),
      children: [
        Center(
          child: Column(
            children: [
              Text(praiseEmoji, style: const TextStyle(fontSize: 54)),
              const SizedBox(height: 8),
              Text(
                praiseText,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              // Score Banner
              Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '$_score',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'очков за 60 секунд',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Stats Row
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                icon: Icons.check_circle_rounded,
                iconColor: Colors.green,
                label: 'Правильно',
                value: '$_correctCount',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                theme,
                icon: Icons.percent_rounded,
                iconColor: theme.colorScheme.primary,
                label: 'Точность',
                value: '$accuracy%',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                theme,
                icon: Icons.local_fire_department_rounded,
                iconColor: Colors.orange,
                label: 'Макс. серия',
                value: '$_maxStreak',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Missed words section with 1-tap FSRS
        if (_missedQuestions.isNotEmpty) ...[
          Text(
            'Слова для повторения (${_missedQuestions.length}):',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          for (final q in _missedQuestions) ...[
            Card(
              elevation: 0,
              margin: const EdgeInsetsDirectional.only(bottom: 8),
              color: theme.colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: ListTile(
                dense: true,
                title: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      q.hebrewVocalized,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                subtitle: Text(q.correctTranslation),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.volume_down_rounded),
                      tooltip: 'Озвучить',
                      onPressed: () => widget.audioService?.playWithTtsFallback(
                        sourcePath: q.audioUrl,
                        fallbackHebrewText: q.hebrewVocalized,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _addedToSrsWords.contains(q.hebrewNormalized)
                            ? Icons.bookmark_added_rounded
                            : Icons.bookmark_add_outlined,
                        color: _addedToSrsWords.contains(q.hebrewNormalized)
                            ? theme.colorScheme.primary
                            : null,
                      ),
                      tooltip: 'В FSRS',
                      onPressed: _addedToSrsWords.contains(q.hebrewNormalized)
                          ? null
                          : () => _addMissedWordToSrs(q),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Завершить'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Сыграть ещё раз'),
                onPressed: _startGame,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
