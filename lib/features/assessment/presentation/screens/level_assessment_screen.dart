import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/settings/app_settings_storage.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../data/datasources/level_quiz_seed_data.dart';
import '../../domain/entities/level_quiz_question.dart';
import '../../domain/entities/level_quiz_result.dart';
import '../widgets/level_certificate_card.dart';

/// Full-screen diagnostic test determining learner's Hebrew CEFR level (A1 -> B1).
class LevelAssessmentScreen extends StatefulWidget {
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;
  final AppSettingsStorage? settingsStorage;
  final ValueChanged<LevelQuizResult>? onLevelUpdated;

  const LevelAssessmentScreen({
    super.key,
    this.audioService,
    this.addCardToSrsUseCase,
    this.settingsStorage,
    this.onLevelUpdated,
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
    unawaited(widget.settingsStorage?.writeAssessedLevel(result.determinedLevel));
    unawaited(widget.settingsStorage?.writeLastAssessmentDate(result.completedAt));
    widget.onLevelUpdated?.call(result);
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

  Future<void> _playOptionAudio(String optionText) async {
    final audio = widget.audioService;
    if (audio == null) return;

    // Extract Hebrew portion if present, otherwise speak full option
    final match = RegExp(r'^([\u0590-\u05FF\s\-\.\,\?!]+)').firstMatch(optionText.trim());
    final hebrewToSpeak = match != null ? match.group(1)!.trim() : optionText.trim();
    if (hebrewToSpeak.isEmpty) return;

    await audio.playWithTtsFallback(
      sourcePath: null,
      fallbackHebrewText: hebrewToSpeak,
    );
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
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
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
                  onPlayAudio: widget.audioService != null
                      ? () => _playOptionAudio(q.options[i])
                      : null,
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
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
          child: Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
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
  final VoidCallback? onPlayAudio;

  const _OptionTile({
    required this.optionText,
    required this.index,
    required this.isSelected,
    required this.onSelect,
    this.onPlayAudio,
  });

  Widget _buildOptionContent(ThemeData theme) {
    final trimmed = optionText.trim();
    // Pattern: "Hebrew (Russian)" e.g. "לוֹמֵד (ломэд)"
    final match = RegExp(r'^([\u0590-\u05FF\s\-\.\,\?!]+)\s*(\([^\)]+\))$').firstMatch(trimmed);
    if (match != null) {
      final hebrewPart = match.group(1)!.trim();
      final transPart = match.group(2)!.trim();
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: [
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              hebrewPart,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 18,
                height: 1.45,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            transPart,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.85)
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    final hasHebrew = RegExp(r'[\u0590-\u05FF]').hasMatch(trimmed);
    if (hasHebrew) {
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            trimmed,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 18,
              height: 1.45,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      );
    }

    return Text(
      trimmed,
      style: theme.textTheme.bodyLarge?.copyWith(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final borderColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.7);

    final bgColor = isSelected
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
        : theme.colorScheme.surface;

    final hasHebrew = RegExp(r'[\u0590-\u05FF]').hasMatch(optionText);

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
                    String.fromCharCode(65 + index), // A, B, C, D
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildOptionContent(theme),
              ),
              if (onPlayAudio != null && hasHebrew) ...[
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, size: 20),
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  tooltip: 'Прослушать вариант',
                  onPressed: onPlayAudio,
                ),
              ],
              if (isSelected)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 4),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 22,
                    color: theme.colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
