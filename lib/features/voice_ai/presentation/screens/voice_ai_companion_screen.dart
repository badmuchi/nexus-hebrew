import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/speech/pronunciation_accuracy_evaluator.dart';
import '../../../../core/speech/speech_recognition_service.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../data/datasources/voice_ai_seed_data.dart';
import '../../domain/entities/voice_scenario.dart';
import '../widgets/sabra_speech_bubble.dart';
import '../widgets/voice_answer_suggestion_card.dart';

/// Full interactive Voice AI companion screen where learners converse
/// with Sabra in real Israeli Hebrew scenarios.
class VoiceAiCompanionScreen extends StatefulWidget {
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;
  final SpeechRecognitionService? speechService;
  final ValueChanged<int>? onXpEarned;

  const VoiceAiCompanionScreen({
    super.key,
    this.audioService,
    this.addCardToSrsUseCase,
    this.speechService,
    this.onXpEarned,
  });

  @override
  State<VoiceAiCompanionScreen> createState() => _VoiceAiCompanionScreenState();
}

class _VoiceAiCompanionScreenState extends State<VoiceAiCompanionScreen> {
  static const _evaluator = PronunciationAccuracyEvaluator();

  late final SpeechRecognitionService _speechService;
  StreamSubscription<String>? _speechSub;

  final List<VoiceScenario> _scenarios = VoiceAiSeedData.scenarios;
  int _selectedScenarioIndex = 0;
  int _currentTurnIndex = 0;

  bool _showNikkud = true;
  bool _isListening = false;
  String _recognizedSpeech = '';
  PronunciationEvaluationResult? _lastEvaluation;
  SuggestedVoiceAnswer? _selectedAnswer;
  bool _scenarioFinished = false;

  VoiceScenario get _currentScenario => _scenarios[_selectedScenarioIndex];
  VoiceTurn get _currentTurn => _currentScenario.turns[_currentTurnIndex];

  @override
  void initState() {
    super.initState();
    _speechService = widget.speechService ??
        createPlatformSpeechRecognitionService(
          logger: const DeveloperAppLogger(),
        );

    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final res = await _speechService.initialize(language: 'he-IL');
    if (res.isSuccess) {
      _speechSub = _speechService.textStream.listen((text) {
        if (mounted && text.isNotEmpty) {
          setState(() => _recognizedSpeech = text);
          _evaluateSpeech(text);
        }
      });
    }
  }

  @override
  void dispose() {
    _speechSub?.cancel();
    _speechService.dispose();
    super.dispose();
  }

  void _onSelectScenario(int index) {
    if (_isListening) {
      unawaited(_stopListening());
    }
    setState(() {
      _selectedScenarioIndex = index;
      _currentTurnIndex = 0;
      _recognizedSpeech = '';
      _lastEvaluation = null;
      _selectedAnswer = null;
      _scenarioFinished = false;
    });
  }

  Future<void> _toggleListening() async {
    unawaited(HapticFeedback.mediumImpact());
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    setState(() {
      _isListening = true;
      _recognizedSpeech = '';
    });
    await _speechService.startListening();
  }

  Future<void> _stopListening() async {
    await _speechService.stopListening();
    if (mounted) {
      setState(() => _isListening = false);
    }
  }

  void _onAnswerSelected(SuggestedVoiceAnswer answer) {
    unawaited(HapticFeedback.selectionClick());
    setState(() {
      _selectedAnswer = answer;
      _recognizedSpeech = answer.hebrewNormalized;
    });

    _evaluateSpeech(answer.hebrewNormalized, targetOverride: answer);
  }

  void _evaluateSpeech(String spoken, {SuggestedVoiceAnswer? targetOverride}) {
    final targetAnswer = targetOverride ??
        _selectedAnswer ??
        _currentTurn.suggestedAnswers[_currentTurn.bestAnswerIndex];

    final result = _evaluator.evaluate(
      targetVocalized: targetAnswer.hebrewWithNikkud,
      spokenRaw: spoken,
    );

    setState(() => _lastEvaluation = result);

    if (result.grade != PronunciationGrade.retry) {
      widget.onXpEarned?.call(result.xpEarned);
    }
  }

  void _advanceTurn() {
    unawaited(HapticFeedback.lightImpact());
    if (_currentTurnIndex + 1 < _currentScenario.turns.length) {
      setState(() {
        _currentTurnIndex++;
        _recognizedSpeech = '';
        _lastEvaluation = null;
        _selectedAnswer = null;
      });
    } else {
      setState(() => _scenarioFinished = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('🌵 ', style: TextStyle(fontSize: 22)),
            Text(
              'Сабра AI',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _showNikkud ? 'Скрыть огласовки' : 'Показать огласовки',
            icon: Icon(
              _showNikkud ? Icons.visibility_rounded : Icons.visibility_off_rounded,
            ),
            onPressed: () => setState(() => _showNikkud = !_showNikkud),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              // Scenario Selector Row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_scenarios.length, (idx) {
                      final sc = _scenarios[idx];
                      final isSelected = idx == _selectedScenarioIndex;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          avatar: Text(sc.iconEmoji),
                          label: Text(sc.titleRu),
                          selected: isSelected,
                          onSelected: (_) => _onSelectScenario(idx),
                        ),
                      );
                    }),
                  ),
                ),
              ),

              // Main Dialogue & Interactive Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    // Scenario Location & Description
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(_currentScenario.iconEmoji, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _currentScenario.locationRu,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _currentScenario.descriptionRu,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_currentTurnIndex + 1}/${_currentScenario.turns.length}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Sabra's Spoken Bubble
                    SabraSpeechBubble(
                      hebrewWithNikkud: _currentTurn.sabraSpeechHebrewWithNikkud,
                      hebrewNormalized: _currentTurn.sabraSpeechNormalized,
                      translationRu: _currentTurn.sabraSpeechRu,
                      showNikkud: _showNikkud,
                      audioService: widget.audioService,
                      addCardToSrsUseCase: widget.addCardToSrsUseCase,
                    ),
                    const SizedBox(height: 12),

                    // Cultural & Grammar Hint Box
                    _buildCulturalHintCard(theme),
                    const SizedBox(height: 16),

                    if (!_scenarioFinished) ...[
                      // Suggested Answer Options
                      Text(
                        'Ваш ответ Сабре (нажмите или произнесите вслух):',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      for (final ans in _currentTurn.suggestedAnswers) ...[
                        VoiceAnswerSuggestionCard(
                          answer: ans,
                          isSelected: _selectedAnswer?.id == ans.id,
                          showNikkud: _showNikkud,
                          audioService: widget.audioService,
                          onSelect: () => _onAnswerSelected(ans),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],

                    // Evaluation Result Feedback
                    if (_lastEvaluation != null) ...[
                      const SizedBox(height: 12),
                      _buildEvaluationFeedbackCard(theme, _lastEvaluation!),
                    ],

                    // Scenario Finished Banner
                    if (_scenarioFinished) ...[
                      const SizedBox(height: 16),
                      _buildCelebrationCard(theme),
                    ],
                  ],
                ),
              ),

              // Bottom Voice Action Bar
              if (!_scenarioFinished) _buildBottomVoiceBar(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCulturalHintCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡 ', style: TextStyle(fontSize: 16)),
              Text(
                'Культурный код и грамматика',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                  color: Colors.amber.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _currentTurn.culturalTipRu,
            style: const TextStyle(fontSize: 12, height: 1.35, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            '📖 ${_currentTurn.grammarHintRu}',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Colors.brown.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationFeedbackCard(
    ThemeData theme,
    PronunciationEvaluationResult result,
  ) {
    final isGood = result.grade != PronunciationGrade.retry;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isGood ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isGood ? Colors.green.shade300 : Colors.red.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  result.hebrewFeedback,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.45,
                    color: isGood ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isGood ? Colors.green.shade700 : Colors.red.shade700,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(result.accuracyScore * 100).round()}% Точность',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            result.russianFeedback,
            style: TextStyle(
              fontSize: 12.5,
              color: isGood ? Colors.green.shade900 : Colors.red.shade900,
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: isGood ? Colors.green.shade700 : theme.colorScheme.primary,
            ),
            onPressed: _advanceTurn,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: Text(
              _currentTurnIndex + 1 < _currentScenario.turns.length
                  ? 'Продолжить диалог ➔'
                  : 'Завершить ситуацию 🎉',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCelebrationCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Column(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 6),
          const Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              'כָּל הַכָּבוֹד! שִׂיחָה הֻשְׁלְמָה בְּהַצְלָחָה!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                height: 1.45,
                color: Color(0xFF1B5E20),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Отличная работа! Ты уверенно провел диалог на иврите как настоящий сабра.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF2E7D32)),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => _onSelectScenario((_selectedScenarioIndex + 1) % _scenarios.length),
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Следующая ситуация'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomVoiceBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _isListening
                  ? 'Слушаю вас... Говорите на иврите'
                  : (_recognizedSpeech.isNotEmpty
                      ? 'Распознано: $_recognizedSpeech'
                      : 'Нажмите микрофон для ответа голосом'),
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: _isListening ? Colors.red : theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.small(
            backgroundColor: _isListening ? Colors.red : theme.colorScheme.primary,
            foregroundColor: Colors.white,
            onPressed: _toggleListening,
            child: Icon(_isListening ? Icons.mic_off_rounded : Icons.mic_rounded),
          ),
        ],
      ),
    );
  }
}
