import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/speech/pronunciation_accuracy_evaluator.dart';
import '../../../../core/speech/speech_recognition_service.dart';

class PronunciationPracticeSheet extends StatefulWidget {
  final String phraseVocalized;
  final String? phraseRussian;
  final String? transliteration;
  final AudioPlaybackService? audioService;
  final SpeechRecognitionService? speechService;
  final ValueChanged<int>? onXpEarned;

  const PronunciationPracticeSheet({
    super.key,
    required this.phraseVocalized,
    this.phraseRussian,
    this.transliteration,
    this.audioService,
    this.speechService,
    this.onXpEarned,
  });

  static Future<void> show(
    BuildContext context, {
    required String phraseVocalized,
    String? phraseRussian,
    String? transliteration,
    AudioPlaybackService? audioService,
    SpeechRecognitionService? speechService,
    ValueChanged<int>? onXpEarned,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (_) => PronunciationPracticeSheet(
        phraseVocalized: phraseVocalized,
        phraseRussian: phraseRussian,
        transliteration: transliteration,
        audioService: audioService,
        speechService: speechService ??
            createPlatformSpeechRecognitionService(
              logger: const DeveloperAppLogger(),
            ),
        onXpEarned: onXpEarned,
      ),
    );
  }

  @override
  State<PronunciationPracticeSheet> createState() =>
      _PronunciationPracticeSheetState();
}

class _PronunciationPracticeSheetState
    extends State<PronunciationPracticeSheet> {
  static const _evaluator = PronunciationAccuracyEvaluator();

  late final SpeechRecognitionService _speechService;
  StreamSubscription<String>? _textSub;

  String _spokenText = '';
  bool _isRecording = false;
  bool _isPlayingSample = false;
  bool _hasClaimedXp = false;
  PronunciationEvaluationResult? _evaluation;

  final TextEditingController _manualInputController =
      TextEditingController();

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
    await _speechService.initialize(language: 'he-IL');
    _textSub = _speechService.textStream.listen((text) {
      if (mounted) {
        setState(() {
          _spokenText = text;
          _manualInputController.text = text;
        });
      }
    });
  }

  @override
  void dispose() {
    unawaited(_textSub?.cancel());
    unawaited(_speechService.stopListening());
    _manualInputController.dispose();
    super.dispose();
  }

  Future<void> _playSample() async {
    if (widget.audioService == null) return;
    setState(() => _isPlayingSample = true);
    await widget.audioService!.playWithTtsFallback(
      sourcePath: null,
      fallbackHebrewText: widget.phraseVocalized,
    );
    if (mounted) setState(() => _isPlayingSample = false);
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _speechService.stopListening();
      setState(() => _isRecording = false);
      _evaluateSpeech();
    } else {
      setState(() {
        _spokenText = '';
        _evaluation = null;
        _isRecording = true;
      });
      final res = await _speechService.startListening();
      if (res.isError && mounted) {
        setState(() => _isRecording = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Не удалось активировать микрофон браузера. Вы можете ввести фразу вручную.',
            ),
          ),
        );
      }
    }
  }

  void _evaluateSpeech() {
    final text = _spokenText.trim();
    if (text.isEmpty) return;

    final eval = _evaluator.evaluate(
      targetVocalized: widget.phraseVocalized,
      spokenRaw: text,
    );

    setState(() {
      _evaluation = eval;
    });

    if (!_hasClaimedXp && eval.xpEarned > 0) {
      _hasClaimedXp = true;
      widget.onXpEarned?.call(eval.xpEarned);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.mic_rounded,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Тренажёр произношения',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Послушайте эталон и повторите в микрофон',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Target Phrase Card
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHigh,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Эталонная фраза:',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        FilledButton.tonalIcon(
                          onPressed: _isPlayingSample ? null : _playSample,
                          icon: Icon(
                            _isPlayingSample
                                ? Icons.volume_up_rounded
                                : Icons.play_arrow_rounded,
                            size: 18,
                          ),
                          label: Text(
                            _isPlayingSample ? 'Звучит...' : 'Образец',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        widget.phraseVocalized,
                        textAlign: TextAlign.start,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.6,
                        ),
                      ),
                    ),
                    if (widget.transliteration != null &&
                        widget.transliteration!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        widget.transliteration!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                    if (widget.phraseRussian != null &&
                        widget.phraseRussian!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      Text(
                        widget.phraseRussian!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Microphone Interactive Action
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _toggleRecording,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _isRecording ? 86 : 76,
                      height: _isRecording ? 86 : 76,
                      decoration: BoxDecoration(
                        color: _isRecording
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.primary)
                                .withValues(alpha: 0.35),
                            blurRadius: _isRecording ? 18 : 10,
                            spreadRadius: _isRecording ? 4 : 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRecording
                            ? Icons.stop_rounded
                            : Icons.mic_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isRecording
                        ? 'Слушаю вас... Говорите на иврите!'
                        : (_spokenText.isEmpty
                            ? 'Нажмите на микрофон и произнесите фразу'
                            : 'Нажмите для повторной записи'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          _isRecording ? FontWeight.bold : FontWeight.w500,
                      color: _isRecording
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Live recognized transcript display
            if (_spokenText.isNotEmpty) ...[
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.record_voice_over_rounded,
                            size: 18,
                            color: Colors.teal,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Распознанная речь:',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          _spokenText,
                          style: theme.textTheme.titleMedium?.copyWith(
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Evaluation Result Section
            if (_evaluation != null) ...[
              _buildEvaluationCard(_evaluation!, theme),
            ] else if (!_speechService.isSupported) ...[
              // Fallback manual input if browser doesn't have Web Speech
              _buildManualInputFallback(theme),
            ],
          ],
        );
      },
    );
  }

  Widget _buildEvaluationCard(
    PronunciationEvaluationResult eval,
    ThemeData theme,
  ) {
    Color scoreColor;
    if (eval.grade == PronunciationGrade.perfect) {
      scoreColor = const Color(0xFF2E7D32); // Deep emerald
    } else if (eval.grade == PronunciationGrade.good) {
      scoreColor = const Color(0xFF00796B); // Deep teal
    } else {
      scoreColor = const Color(0xFFE65100); // Deep amber
    }

    return Card(
      elevation: 0,
      color: scoreColor.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scoreColor.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Score and Hebrew cheer
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: scoreColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${eval.accuracyPercentage}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eval.hebrewFeedback,
                        textDirection: TextDirection.rtl,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                      Text(
                        eval.russianFeedback,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),

            Text(
              'Пословный разбор:',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Word-by-word chips
            Directionality(
              textDirection: TextDirection.rtl,
              child: Wrap(
                spacing: 6,
                runSpacing: 8,
                children: [
                  for (final word in eval.wordMatches)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: word.isMatched
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: word.isMatched
                              ? const Color(0xFF81C784)
                              : const Color(0xFFE57373),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            word.isMatched
                                ? Icons.check_circle_rounded
                                : Icons.help_outline_rounded,
                            size: 14,
                            color: word.isMatched
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFC62828),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            word.targetWord,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: word.isMatched
                                  ? const Color(0xFF1B5E20)
                                  : const Color(0xFFB71C1C),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualInputFallback(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ввод текста для проверки:',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _manualInputController,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                hintText: 'Введите или надиктуйте фразу...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (val) {
                setState(() => _spokenText = val);
                _evaluateSpeech();
              },
            ),
            const SizedBox(height: 10),
            FilledButton.tonal(
              onPressed: () {
                setState(() => _spokenText = _manualInputController.text);
                _evaluateSpeech();
              },
              child: const Text('Проверить совпадение'),
            ),
          ],
        ),
      ),
    );
  }
}
