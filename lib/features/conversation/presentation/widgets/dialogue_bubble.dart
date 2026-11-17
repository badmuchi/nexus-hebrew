import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../domain/entities/binyan.dart';
import '../../domain/entities/dialogue_node.dart';
import '../../domain/entities/hebrew_text.dart';

class DialogueBubble extends StatelessWidget {
  final DialogueNode node;
  final bool showNikkud;
  final AudioPlaybackStatus audioStatus;
  final bool isInteractionLocked;
  final ValueChanged<DialogueOption> onOptionSelected;
  final VoidCallback? onAudioPressed;
  final VoidCallback? onSaveNodeToSrs;
  final ValueChanged<DialogueOption>? onSaveOptionToSrs;
  final VoidCallback? onXRayPressed;

  const DialogueBubble({
    super.key,
    required this.node,
    required this.onOptionSelected,
    this.showNikkud = true,
    this.audioStatus = AudioPlaybackStatus.idle,
    this.isInteractionLocked = false,
    this.onAudioPressed,
    this.onSaveNodeToSrs,
    this.onSaveOptionToSrs,
    this.onXRayPressed,
  });

  String _pickHebrewText(HebrewText text) {
    return showNikkud ? text.vocalized : text.normalized;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outerDirection = Directionality.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SpeakerHeader(
            speaker: node.speaker,
            showNikkud: showNikkud,
            outerDirection: outerDirection,
          ),
          const SizedBox(height: 8.0),
          Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            _pickHebrewText(node.lineHebrew),
                            textAlign: TextAlign.start,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              height: 1.55,
                            ),
                          ),
                        ),
                      ),
                      if (onAudioPressed != null) ...[
                        const SizedBox(width: 8.0),
                        _AudioActionButton(
                          status: audioStatus,
                          onPressed: onAudioPressed!,
                        ),
                      ],
                      if (onSaveNodeToSrs != null) ...[
                        const SizedBox(width: 4.0),
                        IconButton.outlined(
                          onPressed: onSaveNodeToSrs,
                          tooltip: 'В FSRS в 1 тап',
                          icon: const Icon(Icons.bookmark_add_outlined),
                        ),
                      ],
                      if (onXRayPressed != null) ...[
                        const SizedBox(width: 4.0),
                        IconButton.outlined(
                          onPressed: onXRayPressed,
                          tooltip: 'Рентген фразы 🔬',
                          icon: const Icon(Icons.biotech_rounded),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      node.lineRussian,
                      textAlign: TextAlign.start,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24.0),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              'Выберите реплику:',
              textAlign: TextAlign.start,
              style: theme.textTheme.labelLarge,
            ),
          ),
          const SizedBox(height: 8.0),
          ...node.options.map(
            (option) => Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _DialogueOptionCard(
                      option: option,
                      hebrewDisplay: _pickHebrewText(option.textHebrew),
                      enabled: !isInteractionLocked,
                      onTap: () => onOptionSelected(option),
                    ),
                  ),
                  if (onSaveOptionToSrs != null) ...[
                    const SizedBox(width: 6.0),
                    IconButton.outlined(
                      onPressed: isInteractionLocked
                          ? null
                          : () => onSaveOptionToSrs!(option),
                      tooltip: 'Добавить вариант в FSRS',
                      icon: const Icon(Icons.bookmark_add_outlined),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeakerHeader extends StatelessWidget {
  final SpeakerName speaker;
  final bool showNikkud;
  final TextDirection outerDirection;

  const _SpeakerHeader({
    required this.speaker,
    required this.showNikkud,
    required this.outerDirection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hebrewName = showNikkud
        ? speaker.hebrew.vocalized
        : speaker.hebrew.normalized;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8.0,
      textDirection: outerDirection,
      children: [
        Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            hebrewName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        if (speaker.russian != null)
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              '(${speaker.russian!})',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

class _AudioActionButton extends StatelessWidget {
  final AudioPlaybackStatus status;
  final VoidCallback onPressed;

  const _AudioActionButton({
    required this.status,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (status == AudioPlaybackStatus.loading) {
      return const Padding(
        padding: EdgeInsetsDirectional.all(8.0),
        child: SizedBox(
          width: 24.0,
          height: 24.0,
          child: CircularProgressIndicator(strokeWidth: 2.2),
        ),
      );
    }

    final isPlaying = status == AudioPlaybackStatus.playing;
    return IconButton.filledTonal(
      onPressed: onPressed,
      tooltip: isPlaying ? 'Остановить аудио' : 'Прослушать реплику',
      icon: Icon(isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded),
    );
  }
}

class _DialogueOptionCard extends StatelessWidget {
  final DialogueOption option;
  final String hebrewDisplay;
  final bool enabled;
  final VoidCallback onTap;

  const _DialogueOptionCard({
    required this.option,
    required this.hebrewDisplay,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasGrammarMeta =
        option.root != null || option.binyan != Binyan.none;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsetsDirectional.all(14.0),
        alignment: AlignmentDirectional.centerStart,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      onPressed: enabled ? onTap : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              hebrewDisplay,
              textAlign: TextAlign.start,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 6.0),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              option.textRussian,
              textAlign: TextAlign.start,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (hasGrammarMeta) ...[
            const SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                if (option.root != null)
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Chip(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 4.0,
                      ),
                      label: Text(
                        'שורש: ${option.root!.hyphenated}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
                if (option.binyan != Binyan.none)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 4.0,
                    ),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            'בניין ${option.binyan.hebrewLabel}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            '(${option.binyan.transliteration})',
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
