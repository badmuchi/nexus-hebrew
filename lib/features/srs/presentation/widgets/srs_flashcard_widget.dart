import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/widgets/hebrew_niqqud_keyboard.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../../domain/entities/fsrs_models.dart';
import '../../domain/entities/srs_card.dart';
import '../cubit/srs_session_state.dart';

class SrsFlashcardWidget extends StatefulWidget {
  final SrsCard card;
  final SrsStudyMode studyMode;
  final bool isAnswerRevealed;
  final bool showNikkud;
  final TypingAnswerEvaluation? typingEvaluation;
  final Map<FsrsRating, int> intervalPreview;
  final AudioPlaybackStatus audioStatus;
  final bool isSubmittingReview;
  final VoidCallback onRevealAnswer;
  final ValueChanged<String> onSubmitTypedAnswer;
  final ValueChanged<FsrsRating> onRateCard;
  final VoidCallback onPlayAudio;

  const SrsFlashcardWidget({
    super.key,
    required this.card,
    required this.studyMode,
    required this.isAnswerRevealed,
    required this.showNikkud,
    required this.intervalPreview,
    required this.audioStatus,
    required this.isSubmittingReview,
    required this.onRevealAnswer,
    required this.onSubmitTypedAnswer,
    required this.onRateCard,
    required this.onPlayAudio,
    this.typingEvaluation,
  });

  @override
  State<SrsFlashcardWidget> createState() => _SrsFlashcardWidgetState();
}

class _SrsFlashcardWidgetState extends State<SrsFlashcardWidget> {
  final TextEditingController _typingController = TextEditingController();
  bool _showVirtualKeyboard = false;

  @override
  void didUpdateWidget(covariant SrsFlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.card.id != widget.card.id ||
        oldWidget.studyMode != widget.studyMode) {
      _typingController.clear();
      _showVirtualKeyboard = false;
    }
  }

  @override
  void dispose() {
    _typingController.dispose();
    super.dispose();
  }

  String _pickHebrewDisplay(String vocalized, String normalized) {
    return widget.showNikkud ? vocalized : normalized;
  }

  String _formatInterval(FsrsRating rating) {
    final days = widget.intervalPreview[rating];
    if (days == null || days == 0) {
      return rating == FsrsRating.again ? '10 мин' : '12 ч';
    }
    return '$days д.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = widget.card;
    final isTypingMode = widget.studyMode == SrsStudyMode.typing;

    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text(card.category.labelRu),
                      ),
                      _AudioButton(
                        status: widget.audioStatus,
                        hasRemoteAudio: card.audioUrl != null &&
                            (card.audioUrl!.startsWith('http://') ||
                                card.audioUrl!.startsWith('https://')),
                        onPressed: widget.onPlayAudio,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  if (!isTypingMode || widget.isAnswerRevealed) ...[
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        _pickHebrewDisplay(
                          card.hebrew.vocalized,
                          card.hebrew.normalized,
                        ),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                  ],
                  if (isTypingMode) ...[
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        card.russianTranslation,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14.0),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextField(
                        controller: _typingController,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.start,
                        enabled: !widget.isAnswerRevealed,
                        decoration: InputDecoration(
                          labelText: 'Введите слово или фразу (можно без огласовок)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showVirtualKeyboard
                                  ? Icons.keyboard_hide_rounded
                                  : Icons.keyboard_rounded,
                              color: _showVirtualKeyboard
                                  ? theme.colorScheme.primary
                                  : null,
                            ),
                            tooltip: _showVirtualKeyboard
                                ? 'Скрыть клавиатуру'
                                : 'Экранная клавиатура (иврит + огласовки)',
                            onPressed: () {
                              setState(() {
                                _showVirtualKeyboard = !_showVirtualKeyboard;
                              });
                            },
                          ),
                        ),
                        onSubmitted: widget.isAnswerRevealed
                            ? null
                            : widget.onSubmitTypedAnswer,
                      ),
                    ),
                    if (!widget.isAnswerRevealed) ...[
                      const SizedBox(height: 12.0),
                      FilledButton.icon(
                        onPressed: () => widget.onSubmitTypedAnswer(
                          _typingController.text,
                        ),
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Проверить ввод'),
                      ),
                      if (_showVirtualKeyboard) ...[
                        const SizedBox(height: 12.0),
                        HebrewNiqqudKeyboard(
                          controller: _typingController,
                          onSubmitted: () => widget.onSubmitTypedAnswer(
                            _typingController.text,
                          ),
                          onClose: () {
                            setState(() {
                              _showVirtualKeyboard = false;
                            });
                          },
                        ),
                      ],
                    ],
                  ],
                  if (widget.typingEvaluation != null) ...[
                    const SizedBox(height: 12.0),
                    _TypingResultBanner(evaluation: widget.typingEvaluation!),
                  ],
                  if (widget.isAnswerRevealed) ...[
                    const Divider(height: 28.0),
                    if (!isTypingMode)
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          card.russianTranslation,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (card.root != null || card.binyan != Binyan.none) ...[
                      const SizedBox(height: 12.0),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8.0,
                        runSpacing: 6.0,
                        children: [
                          if (card.root != null)
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: Chip(
                                label: Text(
                                  'שורש: ${card.root!.hyphenated}',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ),
                          if (card.binyan != Binyan.none)
                            Chip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: Text(
                                      'בניין ${card.binyan.hebrewLabel}',
                                      style:
                                          theme.textTheme.labelMedium?.copyWith(
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4.0),
                                  Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: Text(
                                      '(${card.binyan.transliteration})',
                                      style: theme.textTheme.labelMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                    if (card.exampleHebrew != null) ...[
                      const SizedBox(height: 14.0),
                      Container(
                        padding: const EdgeInsetsDirectional.all(12.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: Text(
                                _pickHebrewDisplay(
                                  card.exampleHebrew!.vocalized,
                                  card.exampleHebrew!.normalized,
                                ),
                                textAlign: TextAlign.start,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  height: 1.5,
                                ),
                              ),
                            ),
                            if (card.exampleRussian != null) ...[
                              const SizedBox(height: 4.0),
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(
                                  card.exampleRussian!,
                                  textAlign: TextAlign.start,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12.0),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        'Источник: ${card.attribution.sourceName} · ${card.attribution.licenseName}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          if (!widget.isAnswerRevealed && !isTypingMode)
            FilledButton.icon(
              onPressed: widget.onRevealAnswer,
              icon: const Icon(Icons.flip_rounded),
              label: const Text('Показать перевод и разбор'),
            ),
          if (widget.isAnswerRevealed)
            Row(
              children: FsrsRating.values.map((rating) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 4.0,
                    ),
                    child: FilledButton.tonal(
                      onPressed: widget.isSubmittingReview
                          ? null
                          : () => widget.onRateCard(rating),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsetsDirectional.symmetric(
                          vertical: 12.0,
                          horizontal: 4.0,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            rating.labelRu,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            _formatInterval(rating),
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(growable: false),
            ),
        ],
      ),
    );
  }
}

class _AudioButton extends StatelessWidget {
  final AudioPlaybackStatus status;
  final bool hasRemoteAudio;
  final VoidCallback onPressed;

  const _AudioButton({
    required this.status,
    required this.hasRemoteAudio,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (status == AudioPlaybackStatus.loading) {
      return const Padding(
        padding: EdgeInsetsDirectional.all(8.0),
        child: SizedBox(
          width: 22.0,
          height: 22.0,
          child: CircularProgressIndicator(strokeWidth: 2.0),
        ),
      );
    }
    final isPlaying = status == AudioPlaybackStatus.playing;
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded),
      label: Text(
        isPlaying
            ? 'Стоп'
            : (hasRemoteAudio ? 'Аудио носителя' : 'Озвучить (he-IL)'),
      ),
    );
  }
}

class _TypingResultBanner extends StatelessWidget {
  final TypingAnswerEvaluation evaluation;

  const _TypingResultBanner({required this.evaluation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMatch = evaluation.isMatch;
    final containerColor = isMatch
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.errorContainer;
    final onContainerColor = isMatch
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onErrorContainer;

    return Container(
      padding: const EdgeInsetsDirectional.all(12.0),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          Icon(
            isMatch ? Icons.check_circle_rounded : Icons.close_rounded,
            color: onContainerColor,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              isMatch
                  ? 'Точно! Совпадает без огласовок.'
                  : 'Не совпало. Твой ввод: ${evaluation.normalizedUserInput}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: onContainerColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
