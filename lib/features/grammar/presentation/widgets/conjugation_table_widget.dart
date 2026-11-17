import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../domain/entities/verb_conjugation.dart';

/// Displays a bilingual, RTL-isolated conjugation table for one [VerbLexeme].
class ConjugationTableWidget extends StatelessWidget {
  const ConjugationTableWidget({
    super.key,
    required this.verb,
    required this.selectedTense,
    required this.showNikkud,
    required this.activeSpokenHebrew,
    required this.audioStatus,
    required this.onTenseChanged,
    required this.onSpeakForm,
    this.onSaveFormToSrs,
  });

  final VerbLexeme verb;
  final VerbTense selectedTense;
  final bool showNikkud;
  final String? activeSpokenHebrew;
  final AudioPlaybackStatus audioStatus;
  final ValueChanged<VerbTense> onTenseChanged;
  final ValueChanged<String> onSpeakForm;
  final ValueChanged<ConjugatedForm>? onSaveFormToSrs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final forms = verb.formsForTense(selectedTense);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Таблица спряжения',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<VerbTense>(
              segments: VerbTense.values
                  .map(
                    (VerbTense tense) => ButtonSegment<VerbTense>(
                      value: tense,
                      label: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text(
                              tense.hebrewLabel,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            tense.russianLabel,
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(growable: false),
              selected: <VerbTense>{selectedTense},
              onSelectionChanged: (Set<VerbTense> selected) {
                if (selected.isNotEmpty) {
                  onTenseChanged(selected.first);
                }
              },
            ),
            const SizedBox(height: 14),
            if (forms.isEmpty)
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 12),
                child: Text(
                  'Для выбранного времени формы отсутствуют.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              ...forms.map(
                (ConjugatedForm item) => _ConjugationRow(
                  form: item,
                  showNikkud: showNikkud,
                  isPlaying: activeSpokenHebrew == item.form.vocalized &&
                      audioStatus == AudioPlaybackStatus.playing,
                  onSpeak: () => onSpeakForm(item.form.vocalized),
                  onSaveToSrs: onSaveFormToSrs == null
                      ? null
                      : () => onSaveFormToSrs!(item),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ConjugationRow extends StatelessWidget {
  const _ConjugationRow({
    required this.form,
    required this.showNikkud,
    required this.isPlaying,
    required this.onSpeak,
    this.onSaveToSrs,
  });

  final ConjugatedForm form;
  final bool showNikkud;
  final bool isPlaying;
  final VoidCallback onSpeak;
  final VoidCallback? onSaveToSrs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayedHebrew =
        showNikkud ? form.form.vocalized : form.form.normalized;

    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: 8),
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPlaying
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    form.person.hebrewPronoun,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  form.person.russianLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    displayedHebrew,
                    textAlign: TextAlign.right,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  form.transliteration,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Озвучить форму',
            onPressed: onSpeak,
            icon: Icon(
              isPlaying ? Icons.stop_circle_outlined : Icons.volume_up_outlined,
              color: isPlaying
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (onSaveToSrs != null)
            IconButton(
              tooltip: 'Добавить форму в FSRS',
              onPressed: onSaveToSrs,
              icon: Icon(
                Icons.bookmark_add_outlined,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
