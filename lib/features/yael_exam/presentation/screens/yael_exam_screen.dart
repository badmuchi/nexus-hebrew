import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../data/datasources/yael_exam_seed_data.dart';
import '../../domain/entities/yael_exam_result.dart';
import '../../domain/entities/yael_question.dart';
import '../widgets/yael_score_certificate.dart';

/// Full-screen standardized YAEL & Ulpan Alef academic examination simulator.
class YaelExamScreen extends StatefulWidget {
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const YaelExamScreen({
    super.key,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  @override
  State<YaelExamScreen> createState() => _YaelExamScreenState();
}

class _YaelExamScreenState extends State<YaelExamScreen> {
  final List<YaelQuestion> _questions = List.of(YaelExamSeedData.examQuestions);
  final Map<String, int> _userAnswers = {};

  int _currentIndex = 0;
  bool _isPassageExpanded = true;
  bool _isReviewMode = false;
  YaelExamResult? _result;

  // 20-minute countdown timer
  Timer? _countdownTimer;
  int _secondsRemaining = 20 * 60;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        _finishExam();
      }
    });
  }

  String get _formattedTime {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  YaelQuestion get _currentQuestion => _questions[_currentIndex];

  void _onSelectOption(int index) {
    if (_isReviewMode) return;
    unawaited(HapticFeedback.selectionClick());
    setState(() {
      _userAnswers[_currentQuestion.id] = index;
    });
  }

  void _nextQuestion() {
    unawaited(HapticFeedback.lightImpact());
    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _finishExam();
    }
  }

  void _prevQuestion() {
    if (_currentIndex > 0) {
      unawaited(HapticFeedback.lightImpact());
      setState(() => _currentIndex--);
    }
  }

  void _finishExam() {
    _countdownTimer?.cancel();
    unawaited(HapticFeedback.mediumImpact());
    final result = YaelExamResult.evaluate(
      questions: _questions,
      userAnswers: _userAnswers,
    );
    setState(() {
      _result = result;
    });
  }

  void _retakeExam() {
    unawaited(HapticFeedback.lightImpact());
    setState(() {
      _userAnswers.clear();
      _currentIndex = 0;
      _result = null;
      _isReviewMode = false;
      _secondsRemaining = 20 * 60;
    });
    _startTimer();
  }

  void _startReviewMode() {
    setState(() {
      _isReviewMode = true;
      _currentIndex = 0;
    });
  }

  Future<void> _playHebrewAudio(String text) async {
    final audio = widget.audioService;
    if (audio == null) return;
    await audio.playWithTtsFallback(
      sourcePath: null,
      fallbackHebrewText: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Экзамен Яэль и Ульпан Алеф'),
        actions: [
          if (_result == null)
            Center(
              child: Container(
                margin: const EdgeInsetsDirectional.only(end: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _secondsRemaining < 180
                      ? Colors.red.shade100
                      : theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: _secondsRemaining < 180 ? Colors.red : theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formattedTime,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: _secondsRemaining < 180 ? Colors.red : theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _result != null && !_isReviewMode
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: YaelScoreCertificate(
                      result: _result!,
                      onRetake: _retakeExam,
                      onReviewMistakes: _startReviewMode,
                      addCardToSrsUseCase: widget.addCardToSrsUseCase,
                    ),
                  ),
                ),
              )
            : _buildQuestionInterface(theme),
      ),
    );
  }

  Widget _buildQuestionInterface(ThemeData theme) {
    final q = _currentQuestion;
    final selectedIndex = _userAnswers[q.id];
    final isAnswered = selectedIndex != null;
    final progress = (_currentIndex + 1) / _questions.length;

    return Column(
      children: [
        // Progress Bar
        LinearProgressIndicator(
          value: progress,
          minHeight: 4,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        ),

        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 24),
                children: [
                  // Section Badge & Question Counter
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${q.section.iconEmoji} ${q.section.titleRu}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Вопрос ${_currentIndex + 1} из ${_questions.length}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Reading Passage Box (if Reading Comprehension)
                  if (q.readingPassageHebrewWithNikkud != null) ...[
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: Colors.amber.shade50.withValues(alpha: 0.5),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text('📜 ', style: TextStyle(fontSize: 18)),
                                    Text(
                                      q.readingPassageTitleRu ?? 'Текст для чтения',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  icon: Icon(
                                    _isPassageExpanded
                                        ? Icons.expand_less_rounded
                                        : Icons.expand_more_rounded,
                                  ),
                                  onPressed: () =>
                                      setState(() => _isPassageExpanded = !_isPassageExpanded),
                                ),
                              ],
                            ),
                            if (_isPassageExpanded) ...[
                              const Divider(height: 16),
                              Directionality(
                                textDirection: TextDirection.rtl,
                                child: Text(
                                  q.readingPassageHebrewWithNikkud!,
                                  style: const TextStyle(
                                    fontSize: 16.5,
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  icon: const Icon(Icons.volume_up_rounded, size: 18),
                                  label: const Text('Прослушать отрывок'),
                                  onPressed: () =>
                                      _playHebrewAudio(q.readingPassageHebrewWithNikkud!),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Question Prompt Card
                  Card(
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            q.promptRussian,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text(
                              q.promptHebrewWithNikkud,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                height: 1.45,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: const Icon(Icons.volume_up_rounded, size: 20),
                              tooltip: 'Озвучить вопрос',
                              onPressed: () => _playHebrewAudio(q.promptHebrewWithNikkud),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Options Header
                  Text(
                    'Выберите наиболее точный вариант:',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Options List
                  for (int i = 0; i < q.options.length; i++) ...[
                    _YaelOptionTile(
                      optionText: q.options[i],
                      index: i,
                      isSelected: selectedIndex == i,
                      isReviewMode: _isReviewMode,
                      isCorrectOption: q.isCorrect(i),
                      onSelect: () => _onSelectOption(i),
                      onPlayAudio: widget.audioService != null
                          ? () => _playHebrewAudio(q.options[i])
                          : null,
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Review Explanation Card (in review mode)
                  if (_isReviewMode) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.lightbulb_outline_rounded,
                                  color: Colors.indigo, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Правило: ${q.keyGrammarRuleRu}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.indigo,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            q.explanationRu,
                            style: const TextStyle(fontSize: 12.5, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // Bottom Action Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
          child: Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _currentIndex > 0 ? _prevQuestion : null,
                    icon: const Icon(Icons.chevron_left_rounded),
                    label: const Text('Назад'),
                  ),
                  if (_isReviewMode)
                    FilledButton.tonalIcon(
                      onPressed: () => setState(() => _isReviewMode = false),
                      icon: const Icon(Icons.workspace_premium_rounded),
                      label: const Text('К сертификату'),
                    )
                  else
                    FilledButton.icon(
                      onPressed: isAnswered ? _nextQuestion : null,
                      icon: Icon(
                        _currentIndex == _questions.length - 1
                            ? Icons.check_circle_rounded
                            : Icons.chevron_right_rounded,
                      ),
                      label: Text(
                        _currentIndex == _questions.length - 1
                            ? 'Завершить экзамен'
                            : 'Далее',
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _YaelOptionTile extends StatelessWidget {
  final String optionText;
  final int index;
  final bool isSelected;
  final bool isReviewMode;
  final bool isCorrectOption;
  final VoidCallback onSelect;
  final VoidCallback? onPlayAudio;

  const _YaelOptionTile({
    required this.optionText,
    required this.index,
    required this.isSelected,
    required this.isReviewMode,
    required this.isCorrectOption,
    required this.onSelect,
    this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color borderColor = theme.colorScheme.outlineVariant.withValues(alpha: 0.7);
    Color bgColor = theme.colorScheme.surface;

    if (isReviewMode) {
      if (isCorrectOption) {
        borderColor = Colors.green;
        bgColor = Colors.green.shade50;
      } else if (isSelected && !isCorrectOption) {
        borderColor = Colors.red;
        bgColor = Colors.red.shade50;
      }
    } else if (isSelected) {
      borderColor = theme.colorScheme.primary;
      bgColor = theme.colorScheme.primaryContainer.withValues(alpha: 0.4);
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isReviewMode ? null : onSelect,
        child: Container(
          padding: const EdgeInsetsDirectional.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          ),
          child: Row(
            children: [
              // Badge A, B, C, D
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Option Hebrew and Russian text
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    optionText,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      height: 1.45,
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),

              if (onPlayAudio != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.volume_up_rounded, size: 20),
                  tooltip: 'Озвучить вариант',
                  onPressed: onPlayAudio,
                ),

              if (isReviewMode && isCorrectOption)
                const Icon(Icons.check_circle_rounded, color: Colors.green, size: 22)
              else if (isReviewMode && isSelected && !isCorrectOption)
                const Icon(Icons.cancel_rounded, color: Colors.red, size: 22)
              else if (isSelected)
                Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
