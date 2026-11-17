import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../../domain/entities/verb_conjugation.dart';
import '../../domain/services/hebrew_conjugation_highlighter.dart';

/// Displays a bilingual, RTL-isolated conjugation table for one [VerbLexeme]
/// with optional color-coded morphological breakdown (root, prefix, suffix, infix).
class ConjugationTableWidget extends StatefulWidget {
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
  State<ConjugationTableWidget> createState() => _ConjugationTableWidgetState();
}

class _ConjugationTableWidgetState extends State<ConjugationTableWidget> {
  bool _colorCoded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final forms = widget.verb.formsForTense(widget.selectedTense);

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Таблица спряжения',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                FilterChip(
                  label: const Text('Анатомия'),
                  avatar: const Icon(Icons.colorize_rounded, size: 16),
                  selected: _colorCoded,
                  onSelected: (val) {
                    setState(() {
                      _colorCoded = val;
                    });
                  },
                ),
              ],
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
              selected: <VerbTense>{widget.selectedTense},
              onSelectionChanged: (Set<VerbTense> selected) {
                if (selected.isNotEmpty) {
                  widget.onTenseChanged(selected.first);
                }
              },
            ),
            if (_colorCoded) ...[
              const SizedBox(height: 12),
              _MorphologyLegend(
                rootHyphenated: widget.verb.root.hyphenated,
              ),
            ],
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
                  root: widget.verb.root,
                  colorCoded: _colorCoded,
                  showNikkud: widget.showNikkud,
                  isPlaying: widget.activeSpokenHebrew == item.form.vocalized &&
                      widget.audioStatus == AudioPlaybackStatus.playing,
                  onSpeak: () => widget.onSpeakForm(item.form.vocalized),
                  onSaveToSrs: widget.onSaveFormToSrs == null
                      ? null
                      : () => widget.onSaveFormToSrs!(item),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MorphologyLegend extends StatelessWidget {
  const _MorphologyLegend({
    required this.rootHyphenated,
  });

  final String rootHyphenated;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _LegendChip(
          color: Colors.green.shade800,
          label: 'Корень ($rootHyphenated)',
        ),
        _LegendChip(
          color: Colors.blue.shade800,
          label: 'Приставка',
        ),
        _LegendChip(
          color: Colors.deepOrange.shade800,
          label: 'Окончание',
        ),
        _LegendChip(
          color: Colors.purple.shade800,
          label: 'Основа',
        ),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConjugationRow extends StatelessWidget {
  const _ConjugationRow({
    required this.form,
    required this.root,
    required this.colorCoded,
    required this.showNikkud,
    required this.isPlaying,
    required this.onSpeak,
    this.onSaveToSrs,
  });

  final ConjugatedForm form;
  final Shoresh root;
  final bool colorCoded;
  final bool showNikkud;
  final bool isPlaying;
  final VoidCallback onSpeak;
  final VoidCallback? onSaveToSrs;

  static const _highlighter = HebrewConjugationHighlighter();

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
                  child: colorCoded
                      ? _buildHighlightedHebrew(theme, displayedHebrew)
                      : Text(
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

  Widget _buildHighlightedHebrew(ThemeData theme, String text) {
    final segments = _highlighter.highlight(
      vocalizedForm: text,
      root: root,
    );

    return Text.rich(
      TextSpan(
        children: segments.map((seg) {
          final color = switch (seg.role) {
            MorphologicalRole.root => Colors.green.shade800,
            MorphologicalRole.prefix => Colors.blue.shade800,
            MorphologicalRole.suffix => Colors.deepOrange.shade800,
            MorphologicalRole.infix => Colors.purple.shade800,
            MorphologicalRole.base => theme.colorScheme.onSurface,
          };
          return TextSpan(
            text: seg.text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          );
        }).toList(),
      ),
      textAlign: TextAlign.right,
    );
  }
}
