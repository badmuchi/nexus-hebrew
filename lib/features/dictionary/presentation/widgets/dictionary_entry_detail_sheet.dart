import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../../../grammar/domain/entities/verb_conjugation.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../domain/entities/dictionary_entry.dart';
import '../cubit/dictionary_cubit.dart';
import '../cubit/dictionary_state.dart';

/// Opens a detailed lexical sheet for [initialEntry] with live FSRS, audio,
/// shoresh family, and verb paradigm links.
Future<void> showDictionaryEntryDetailSheet({
  required BuildContext context,
  required DictionaryEntry initialEntry,
  required ValueChanged<Shoresh> onFilterByRoot,
}) {
  final cubit = context.read<DictionaryCubit>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 680),
    builder: (BuildContext sheetContext) {
      return BlocProvider<DictionaryCubit>.value(
        value: cubit,
        child: _DictionaryEntryDetailSheet(
          initialEntry: initialEntry,
          onFilterByRoot: (Shoresh root) {
            Navigator.of(sheetContext).pop();
            onFilterByRoot(root);
          },
        ),
      );
    },
  );
}

class _DictionaryEntryDetailSheet extends StatefulWidget {
  const _DictionaryEntryDetailSheet({
    required this.initialEntry,
    required this.onFilterByRoot,
  });

  final DictionaryEntry initialEntry;
  final ValueChanged<Shoresh> onFilterByRoot;

  @override
  State<_DictionaryEntryDetailSheet> createState() =>
      _DictionaryEntryDetailSheetState();
}

class _DictionaryEntryDetailSheetState
    extends State<_DictionaryEntryDetailSheet> {
  late DictionaryEntry _entry;

  @override
  void initState() {
    super.initState();
    _entry = widget.initialEntry;
  }

  String _pickHebrew(HebrewText text, bool showNikkud) =>
      showNikkud ? text.vocalized : text.normalized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<DictionaryCubit, DictionaryState>(
      builder: (BuildContext context, DictionaryState state) {
        final cubit = context.read<DictionaryCubit>();
        final loaded = state is DictionaryLoaded ? state : null;
        final showNikkud = loaded?.showNikkud ?? true;
        final isInSrs =
            loaded?.srsNormalizedForms.contains(_entry.hebrew.normalized) ??
                false;

        final isPlayingWord = loaded != null &&
            loaded.activeSpokenHebrew == _entry.hebrew.vocalized &&
            loaded.audioStatus == AudioPlaybackStatus.playing;
        final isPlayingExample = loaded != null &&
            _entry.exampleHebrew != null &&
            loaded.activeSpokenHebrew == _entry.exampleHebrew!.vocalized &&
            loaded.audioStatus == AudioPlaybackStatus.playing;

        final related = cubit.findRelatedWords(_entry);
        final verbParadigm = cubit.findMatchingVerbParadigm(_entry);
        final audioBadge = _audioSourceLabel(_entry.audioUrl);

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.94,
          builder: (BuildContext context, ScrollController scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 28),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: SelectableText(
                              _pickHebrew(_entry.hebrew, showNikkud),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (_entry.transliteration != null &&
                              _entry.transliteration!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              '[${_entry.transliteration!}]',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: isPlayingWord ? 'Остановить' : audioBadge,
                      onPressed: () => unawaited(cubit.speakEntry(_entry)),
                      icon: Icon(
                        isPlayingWord
                            ? Icons.stop_rounded
                            : Icons.volume_up_rounded,
                      ),
                    ),
                    const SizedBox(width: 8),
                    isInSrs
                        ? FilledButton.tonalIcon(
                            onPressed: () => unawaited(cubit.saveToSrs(_entry)),
                            icon: const Icon(Icons.bookmark_added_rounded),
                            label: const Text('В FSRS'),
                          )
                        : FilledButton.icon(
                            onPressed: () => unawaited(cubit.saveToSrs(_entry)),
                            icon: const Icon(Icons.bookmark_add_outlined),
                            label: const Text('В FSRS'),
                          ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _entry.russianTranslation,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      avatar: Icon(_categoryIcon(_entry.category), size: 16),
                      label: Text(_entry.category.labelRu),
                    ),
                    if (_entry.root != null)
                      ActionChip(
                        avatar: const Icon(Icons.hub_outlined, size: 16),
                        label: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text('Корень ${_entry.root!.hyphenated}'),
                        ),
                        tooltip: 'Показать все однокоренные слова',
                        onPressed: () => widget.onFilterByRoot(_entry.root!),
                      ),
                    if (_entry.binyan != Binyan.none)
                      Chip(
                        label: Text(
                          '${_entry.binyan.hebrewLabel} · ${_entry.binyan.transliteration}',
                        ),
                      ),
                    if (_entry.frequencyRank != null)
                      Chip(
                        label: Text(_frequencyLabel(_entry.frequencyRank!)),
                      ),
                    Chip(label: Text(audioBadge)),
                  ],
                ),
                if (_entry.formsSummary != null) ...[
                  const SizedBox(height: 14),
                  _InfoPanel(
                    title: 'Формы слова',
                    child: Directionality(
                      textDirection: RegExp(r'[А-Яа-яЁё]').hasMatch(_entry.formsSummary!)
                          ? TextDirection.ltr
                          : TextDirection.rtl,
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          _entry.formsSummary!,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ),
                ],
                if (verbParadigm != null) ...[
                  const SizedBox(height: 14),
                  _VerbMiniParadigmPanel(
                    lexeme: verbParadigm,
                    showNikkud: showNikkud,
                  ),
                ],
                if (_entry.exampleHebrew != null) ...[
                  const SizedBox(height: 14),
                  _InfoPanel(
                    title: 'Пример употребления',
                    trailing: IconButton(
                      tooltip: isPlayingExample ? 'Остановить' : 'Озвучить пример',
                      onPressed: () => unawaited(cubit.speakExample(_entry)),
                      icon: Icon(
                        isPlayingExample
                            ? Icons.stop_circle_outlined
                            : Icons.volume_up_outlined,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            _pickHebrew(_entry.exampleHebrew!, showNikkud),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (_entry.exampleRussian != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _entry.exampleRussian!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                if (related.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Однокоренные (${related.length})',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (_entry.root != null)
                        TextButton(
                          onPressed: () => widget.onFilterByRoot(_entry.root!),
                          child: const Text('Фильтр в словаре'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...related.take(8).map(
                        (DictionaryEntry rel) => Card(
                          elevation: 0,
                          margin: const EdgeInsetsDirectional.only(bottom: 6),
                          color: theme.colorScheme.surfaceContainerLow,
                          child: ListTile(
                            dense: true,
                            title: Directionality(
                              textDirection: TextDirection.rtl,
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  _pickHebrew(rel.hebrew, showNikkud),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            subtitle: Text(
                              '${rel.category.labelRu} · ${rel.russianTranslation}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () {
                              setState(() {
                                _entry = rel;
                              });
                            },
                          ),
                        ),
                      ),
                ],
                const SizedBox(height: 16),
                Text(
                  'Источник: ${_entry.attribution.sourceName} (${_entry.attribution.licenseName})',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static String _audioSourceLabel(String? url) {
    if (url == null || url.trim().isEmpty) {
      return 'Озвучка he-IL (TTS)';
    }
    final lower = url.trim().toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return 'Аудио носителя';
    }
    return 'Офлайн MP3';
  }

  static String _frequencyLabel(int rank) {
    if (rank <= 100) return 'Топ-100 (#$rank)';
    if (rank <= 500) return 'Топ-500 (#$rank)';
    if (rank <= 1500) return 'Частое (#$rank)';
    return 'Частотность #$rank';
  }

  static IconData _categoryIcon(LexicalCategory category) {
    switch (category) {
      case LexicalCategory.verb:
        return Icons.bolt_rounded;
      case LexicalCategory.noun:
        return Icons.inventory_2_outlined;
      case LexicalCategory.adjective:
        return Icons.palette_outlined;
      case LexicalCategory.phrase:
        return Icons.chat_bubble_outline_rounded;
      case LexicalCategory.particle:
        return Icons.link_rounded;
    }
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsetsDirectional.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _VerbMiniParadigmPanel extends StatelessWidget {
  const _VerbMiniParadigmPanel({
    required this.lexeme,
    required this.showNikkud,
  });

  final VerbLexeme lexeme;
  final bool showNikkud;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final present = lexeme.findForm(
      VerbTense.present,
      GrammaticalPerson.masculineSingular,
    );
    final past = lexeme.findForm(
      VerbTense.past,
      GrammaticalPerson.thirdMasculineSingular,
    );
    final future = lexeme.findForm(
      VerbTense.future,
      GrammaticalPerson.thirdMasculineSingular,
    );

    final rows = <(String, String)>[
      if (lexeme.infinitive != null)
        (
          'Инфинитив',
          showNikkud
              ? lexeme.infinitive!.vocalized
              : lexeme.infinitive!.normalized,
        ),
      if (present != null)
        (
          'Наст. (он)',
          showNikkud ? present.form.vocalized : present.form.normalized,
        ),
      if (past != null)
        (
          'Прош. (он)',
          showNikkud ? past.form.vocalized : past.form.normalized,
        ),
      if (future != null)
        (
          'Буд. (он)',
          showNikkud ? future.form.vocalized : future.form.normalized,
        ),
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

    return _InfoPanel(
      title: 'Формы спряжения (${lexeme.binyan.transliteration})',
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        children: rows
            .map(
              ((String, String) item) => Container(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(10, 6, 10, 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.$1,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        item.$2,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}
