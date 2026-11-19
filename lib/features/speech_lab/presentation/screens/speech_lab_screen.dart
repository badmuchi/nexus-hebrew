import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/speech/pronunciation_accuracy_evaluator.dart';
import '../../../../core/speech/speech_recognition_service.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../data/datasources/speech_lab_seed_data.dart';
import '../../domain/entities/speech_exercise.dart';
import '../widgets/pronunciation_result_card.dart';
import '../widgets/speech_waveform_indicator.dart';

/// Interactive Speech & Pronunciation Studio for training Hebrew acoustics,
/// guttural phonemes (ח, ע), conversational speed, and AI accuracy evaluation.
class SpeechLabScreen extends StatefulWidget {
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;
  final SpeechRecognitionService? speechService;
  final ValueChanged<int>? onXpEarned;

  const SpeechLabScreen({
    super.key,
    this.audioService,
    this.addCardToSrsUseCase,
    this.speechService,
    this.onXpEarned,
  });

  @override
  State<SpeechLabScreen> createState() => _SpeechLabScreenState();
}

class _SpeechLabScreenState extends State<SpeechLabScreen> {
  static const _evaluator = PronunciationAccuracyEvaluator();

  late final SpeechRecognitionService _speechService;
  StreamSubscription<String>? _textSub;

  final List<SpeechExercise> _allExercises = List.of(SpeechLabSeedData.exercises);
  SpeechCategory? _selectedCategory;
  int _currentIndex = 0;

  bool _showNikkud = true;
  bool _isPlayingAudio = false;
  bool _isRecording = false;

  String _spokenText = '';
  PronunciationEvaluationResult? _evaluationResult;
  final Set<String> _savedToSrsIds = {};

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
        });
      }
    });
  }

  @override
  void dispose() {
    unawaited(_textSub?.cancel());
    unawaited(_speechService.stopListening());
    super.dispose();
  }

  List<SpeechExercise> get _filteredExercises {
    if (_selectedCategory == null) return _allExercises;
    return _allExercises.where((e) => e.category == _selectedCategory).toList();
  }

  SpeechExercise get _currentExercise {
    final list = _filteredExercises;
    if (_currentIndex >= list.length) {
      _currentIndex = 0;
    }
    return list.isNotEmpty ? list[_currentIndex] : _allExercises.first;
  }

  void _onCategoryChanged(SpeechCategory? category) {
    setState(() {
      _selectedCategory = category;
      _currentIndex = 0;
      _evaluationResult = null;
      _spokenText = '';
    });
  }

  void _nextExercise() {
    final list = _filteredExercises;
    if (list.isEmpty) return;
    unawaited(HapticFeedback.lightImpact());
    setState(() {
      _currentIndex = (_currentIndex + 1) % list.length;
      _evaluationResult = null;
      _spokenText = '';
    });
  }

  void _prevExercise() {
    final list = _filteredExercises;
    if (list.isEmpty) return;
    unawaited(HapticFeedback.lightImpact());
    setState(() {
      _currentIndex = (_currentIndex - 1 + list.length) % list.length;
      _evaluationResult = null;
      _spokenText = '';
    });
  }

  Future<void> _playAudio({double speed = 1.0}) async {
    if (widget.audioService == null) return;
    final exercise = _currentExercise;

    setState(() {
      _isPlayingAudio = true;
    });

    try {
      await widget.audioService!.setPlaybackSpeed(speed);
      await widget.audioService!.playWithTtsFallback(
        sourcePath: exercise.audioPath,
        fallbackHebrewText: exercise.hebrewVocalized,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPlayingAudio = false;
        });
      }
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _speechService.stopListening();
      setState(() => _isRecording = false);
      _evaluateSpeech();
    } else {
      unawaited(HapticFeedback.mediumImpact());
      setState(() {
        _spokenText = '';
        _evaluationResult = null;
        _isRecording = true;
      });

      final res = await _speechService.startListening();
      if (res.isError && mounted) {
        setState(() => _isRecording = false);
        _showManualInputDialog();
      }
    }
  }

  void _evaluateSpeech() {
    final rawInput = _spokenText.trim();
    if (rawInput.isEmpty) return;

    final eval = _evaluator.evaluate(
      targetVocalized: _currentExercise.hebrewVocalized,
      spokenRaw: rawInput,
    );

    setState(() {
      _evaluationResult = eval;
    });

    if (eval.xpEarned > 0) {
      widget.onXpEarned?.call(eval.xpEarned);
    }
  }

  void _showManualInputDialog() {
    final controller = TextEditingController(text: _spokenText);
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Ввод фразы для оценки'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Микрофон недоступен на этом устройстве. Введите или проверьте произнесённый текст:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              textDirection: TextDirection.rtl,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'הזן טקסט בעברית...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Quick helper: test exact answer in 1 tap
              controller.text = _currentExercise.hebrewNormalized;
            },
            child: const Text('Вставить эталон'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              setState(() {
                _spokenText = controller.text;
              });
              _evaluateSpeech();
            },
            child: const Text('Оценить'),
          ),
        ],
      ),
    );
  }

  void _showAddCustomExerciseDialog() {
    final hebrewController = TextEditingController();
    final translationController = TextEditingController();
    final tipController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Добавить свою фразу'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: hebrewController,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  labelText: 'Фраза на иврите (можно с огласовками)',
                  hintText: 'לְמָשָׁל: בֹּקֶר טוֹב לְכֻלָּם',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: translationController,
                decoration: const InputDecoration(
                  labelText: 'Русский перевод',
                  hintText: 'Например: Доброе утро всем',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tipController,
                decoration: const InputDecoration(
                  labelText: 'Фонетическая подсказка (опционально)',
                  hintText: 'Например: обрати внимание на букву бейт',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              final rawHebrew = hebrewController.text.trim();
              if (rawHebrew.isEmpty) return;

              final customEx = SpeechExercise.custom(
                rawHebrew: rawHebrew,
                translationRu: translationController.text.trim(),
                phoneticTipRu: tipController.text.trim().isNotEmpty
                    ? tipController.text.trim()
                    : null,
              );

              setState(() {
                _allExercises.insert(0, customEx);
                _selectedCategory = SpeechCategory.custom;
                _currentIndex = 0;
                _evaluationResult = null;
                _spokenText = '';
              });

              Navigator.of(dialogCtx).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Своя фраза добавлена в лабораторию речи!'),
                ),
              );
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCurrentExerciseToSrs() async {
    final useCase = widget.addCardToSrsUseCase;
    if (useCase == null) return;
    final exercise = _currentExercise;

    final params = AddCardToSrsParams(
      id: 'speech_${exercise.id}_${DateTime.now().millisecondsSinceEpoch}',
      hebrewVocalized: exercise.hebrewVocalized,
      russianTranslation: exercise.translationRu,
      category: LexicalCategory.phrase,
      audioUrl: exercise.audioPath,
    );

    final res = await useCase(params);
    if (!mounted) return;

    if (res.isSuccess) {
      setState(() {
        _savedToSrsIds.add(exercise.id);
      });
      unawaited(HapticFeedback.lightImpact());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Фраза добавлена в FSRS карточки: ${exercise.hebrewNormalized}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.failureOrNull()?.message ?? 'Не удалось добавить в FSRS'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exercise = _currentExercise;
    final filtered = _filteredExercises;
    final isSaved = _savedToSrsIds.contains(exercise.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Лаборатория речи'),
        actions: [
          IconButton(
            tooltip: _showNikkud ? 'Скрыть огласовки' : 'Показать огласовки',
            icon: Icon(
              _showNikkud ? Icons.visibility_rounded : Icons.visibility_off_rounded,
            ),
            onPressed: () {
              setState(() => _showNikkud = !_showNikkud);
            },
          ),
          IconButton(
            tooltip: 'Добавить свою фразу',
            icon: const Icon(Icons.add_comment_rounded),
            onPressed: _showAddCustomExerciseDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 32),
        children: [
          // Category selector chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Все фразы'),
                  selected: _selectedCategory == null,
                  onSelected: (_) => _onCategoryChanged(null),
                ),
                const SizedBox(width: 8),
                for (final cat in SpeechCategory.values) ...[
                  FilterChip(
                    avatar: Icon(cat.icon, size: 16),
                    label: Text(cat.labelRu),
                    selected: _selectedCategory == cat,
                    onSelected: (_) => _onCategoryChanged(cat),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Navigation bar: Previous / Next & Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton.filledTonal(
                icon: const Icon(Icons.chevron_left_rounded),
                tooltip: 'Предыдущая фраза',
                onPressed: filtered.length > 1 ? _prevExercise : null,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_currentIndex + 1} из ${filtered.length}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton.filledTonal(
                icon: const Icon(Icons.chevron_right_rounded),
                tooltip: 'Следующая фраза',
                onPressed: filtered.length > 1 ? _nextExercise : null,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Main Exercise Hero Card
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: BorderSide(
                color: exercise.category.badgeColor.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Badges: Category & Difficulty
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: exercise.category.badgeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: exercise.category.badgeColor.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              exercise.category.icon,
                              size: 14,
                              color: exercise.category.badgeColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              exercise.category.labelRu,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: exercise.category.badgeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          exercise.difficulty,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Big Hebrew Vocalized Text
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      _showNikkud
                          ? exercise.hebrewVocalized
                          : exercise.hebrewNormalized,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 26,
                        height: 1.45,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Russian Phonetic Transcription
                  if (exercise.transcription.isNotEmpty) ...[
                    Text(
                      '[ ${exercise.transcription} ]',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],

                  // Russian Translation
                  Text(
                    exercise.translationRu,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),

                  // Key phonemes tags
                  if (exercise.keyPhonemes.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 6,
                      runSpacing: 4,
                      children: exercise.keyPhonemes.map((ph) {
                        return Chip(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          label: Text(
                            'Звук $ph',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(growable: false),
                    ),
                  ],

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 10),

                  // Phonetic Tip Callout
                  Container(
                    padding: const EdgeInsetsDirectional.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 20,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            exercise.phoneticTipRu,
                            style: theme.textTheme.bodySmall?.copyWith(
                              height: 1.35,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Acoustic Audio Section
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(16),
              child: Column(
                children: [
                  Text(
                    'Эталонное звучание:',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SpeechWaveformIndicator(
                    isActive: _isPlayingAudio || _isRecording,
                    color: _isRecording ? Colors.redAccent : theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: _isPlayingAudio ? null : () => _playAudio(speed: 1.0),
                        icon: const Icon(Icons.volume_up_rounded),
                        label: const Text('1.0x Нормально'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _isPlayingAudio ? null : () => _playAudio(speed: 0.75),
                        icon: const Icon(Icons.slow_motion_video_rounded),
                        label: const Text('0.75x Медленно'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Microphone / Speech Recording Section
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _toggleRecording,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording
                          ? Colors.red
                          : theme.colorScheme.primaryContainer,
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording
                                  ? Colors.red
                                  : theme.colorScheme.primary)
                              .withValues(alpha: 0.35),
                          blurRadius: _isRecording ? 18 : 8,
                          spreadRadius: _isRecording ? 4 : 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                      size: 38,
                      color: _isRecording
                          ? Colors.white
                          : theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _isRecording
                      ? 'Слушаю вас... Говорите фразу на иврите!'
                      : 'Нажмите на микрофон и произнесите фразу',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _isRecording
                        ? Colors.red
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (!_isRecording && _spokenText.isNotEmpty && _evaluationResult == null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Распознано: $_spokenText',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ],
            ),
          ),

          // Pronunciation Evaluation Result Card
          if (_evaluationResult != null) ...[
            const SizedBox(height: 20),
            PronunciationResultCard(
              result: _evaluationResult!,
              isSavedToSrs: isSaved,
              onRetry: () {
                setState(() {
                  _evaluationResult = null;
                  _spokenText = '';
                });
              },
              onSaveToSrs: widget.addCardToSrsUseCase != null
                  ? _saveCurrentExerciseToSrs
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}
