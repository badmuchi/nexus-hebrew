import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../data/datasources/level_quiz_seed_data.dart';
import '../../domain/entities/level_quiz_question.dart';
import '../../domain/entities/level_quiz_result.dart';
import '../widgets/level_certificate_card.dart';

/// Full-screen diagnostic test determining learner's Hebrew CEFR level (A1 -> B1).
class LevelAssessmentScreen extends StatefulWidget {
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const LevelAssessmentScreen({
    super.key,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  @override
  State<LevelAssessmentScreen> createState() => _LevelAssessmentScreenState();
}

class _LevelAssessmentScreenState extends State<LevelAssessmentScreen> {
  final List<LevelQuizQuestion> _questions = List.of(LevelQuizSeedData.diagnosticQuestions);
  final Map<String, int> _userAnswers = {};

  int _currentIndex = 0;
  bool _isPlayingAudio = false;
  LevelQuizResult? _result;

  LevelQuizQuestion get _currentQuestion => _questions[_currentIndex];

  void _onSelectOption(int index) {
    unawaited(HapticFeedback.selectionClick());
    setState(() {
      _userAnswers[_currentQuestion.id] = index;
    });
  }

  void _nextQuestion() {
    unawaited(HapticFeedback.lightImpact());
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _finishAssessment();
    }
  }

  void _prevQuestion() {
    if (_currentIndex > 0) {
      unawaited(HapticFeedback.lightImpact());
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _finishAssessment() {
    unawaited(HapticFeedback.mediumImpact());
    final result = LevelQuizResult.evaluate(
      questions: _questions,
      userAnswers: _userAnswers,
    );
    setState(() {
      _result = result;
    });
  }

  void _restartAssessment() {
    unawaited(HapticFeedback.lightImpact());
    setState(() {
      _userAnswers.clear();
      _currentIndex = 0;
      _result = null;
    });
  }

  Future<void> _playPromptAudio() async {
    final audio = widget.audioService;
    final q = _currentQuestion;
    if (audio == null) return;

    setState(() => _isPlayingAudio = true);
    try {
      await audio.playWithTtsFallback(
        sourcePath: q.audioPath,
        fallbackHebrewText: q.promptHebrew ?? q.options.first,
      );
    } finally {
      if (mounted) {
        setState(() => _isPlayingAudio = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Тест на уровень иврита'),
        actions: [
          if (_result == null)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 16),
              child: Center(
                child: Text(
                  '${_currentIndex + 1} / ${_questions.length}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _result != null
            ? SingleChildScrollView(
                padding: const EdgeInsetsDirectional.all(16),
                child: LevelCertificateCard(
                  result: _result!,
                  onRetake: _restartAssessment,
                  addCardToSrsUseCase: widget.addCardToSrsUseCase,
                ),
              )
            : _buildQuestionBody(theme),
      ),
    );
  }

  Widget _buildQuestionBody(ThemeData theme) {
    final q = _currentQuestion;
    final progress = (_currentIndex + 1) / _questions.length;
    final selectedIndex = _userAnswers[q.id];
    final isAnswered = selectedIndex != null;

    return Column(
      children: [
        // Top Linear Progress Bar
        LinearProgressIndicator(
          value: progress,
          minHeight: 4,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 24),
            children: [
              // Badges: Level & Skill Focus
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: q.skillFocus.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: q.skillFocus.color.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(q.skillFocus.icon, size: 14, color: q.skillFocus.color),
                        const SizedBox(width: 4),
                        Text(
                          q.skillFocus.labelRu,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: q.skillFocus.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${q.level.label} (${q.level.labelRu})',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Question Prompt Card
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.all(18),
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
                      if (q.promptHebrew != null) ...[
                        const SizedBox(height: 14),
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            q.promptHebrew!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                              height: 1.45,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                      if (q.audioPath != null || q.promptHebrew != null) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: _isPlayingAudio ? null : _playPromptAudio,
                            icon: Icon(_isPlayingAudio
                                ? Icons.volume_up_rounded
                                : Icons.volume_down_rounded),
                            label: const Text('Прослушать вопрос'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Options List
              Text(
                'Выберите один верный вариант:',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),

              for (int i = 0; i < q.options.length; i++) ...[
                _OptionTile(
                  optionText: q.options[i],
                  index: i,
                  isSelected: selectedIndex == i,
                  onSelect: () => _onSelectOption(i),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),

        // Bottom Action Bar: Back / Next
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: _currentIndex > 0 ? _prevQuestion : null,
                icon: const Icon(Icons.chevron_left_rounded),
                label: const Text('Назад'),
              ),
              FilledButton.icon(
                onPressed: isAnswered ? _nextQuestion : null,
                icon: Icon(
                  _currentIndex == _questions.length - 1
                      ? Icons.check_circle_rounded
                      : Icons.chevron_right_rounded,
                ),
                label: Text(
                  _currentIndex == _questions.length - 1
                      ? 'Завершить тест'
                      : 'Далее',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String optionText;
  final int index;
  final bool isSelected;
  final VoidCallback onSelect;

  const _OptionTile({
    required this.optionText,
    required this.index,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final borderColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.7);

    final bgColor = isSelected
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
        : theme.colorScheme.surface;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onSelect,
        child: Container(
          padding: const EdgeInsetsDirectional.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, D
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    optionText,
                    textAlign: TextAlign.start,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
