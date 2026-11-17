import 'dart:async';

import 'package:flutter/material.dart';

import '../../features/conversation/domain/entities/hebrew_text.dart';
import '../../features/dictionary/domain/entities/dictionary_entry.dart';
import '../../features/grammar/domain/entities/verb_conjugation.dart';
import '../../features/srs/domain/entities/srs_card.dart';
import '../../features/srs/domain/usecases/add_card_to_srs.dart';
import '../audio/audio_playback_service.dart';

Future<void> showShoreshFamilySheet({
  required BuildContext context,
  required Shoresh root,
  required List<DictionaryEntry> allDictionaryEntries,
  required List<VerbLexeme> allGrammarVerbs,
  required Set<String> srsNormalizedForms,
  required AudioPlaybackService audioService,
  required AddCardToSrsUseCase addCardToSrsUseCase,
  required ValueChanged<DictionaryEntry>? onSelectEntry,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 680),
    builder: (BuildContext sheetContext) {
      return _ShoreshFamilySheet(
        root: root,
        allDictionaryEntries: allDictionaryEntries,
        allGrammarVerbs: allGrammarVerbs,
        srsNormalizedForms: srsNormalizedForms,
        audioService: audioService,
        addCardToSrsUseCase: addCardToSrsUseCase,
        onSelectEntry: onSelectEntry,
      );
    },
  );
}

class _ShoreshFamilySheet extends StatefulWidget {
  const _ShoreshFamilySheet({
    required this.root,
    required this.allDictionaryEntries,
    required this.allGrammarVerbs,
    required this.srsNormalizedForms,
    required this.audioService,
    required this.addCardToSrsUseCase,
    required this.onSelectEntry,
  });

  final Shoresh root;
  final List<DictionaryEntry> allDictionaryEntries;
  final List<VerbLexeme> allGrammarVerbs;
  final Set<String> srsNormalizedForms;
  final AudioPlaybackService audioService;
  final AddCardToSrsUseCase addCardToSrsUseCase;
  final ValueChanged<DictionaryEntry>? onSelectEntry;

  @override
  State<_ShoreshFamilySheet> createState() => _ShoreshFamilySheetState();
}

class _ShoreshFamilySheetState extends State<_ShoreshFamilySheet> {
  late final Set<String> _srsSet;
  String? _currentlyPlayingWord;

  @override
  void initState() {
    super.initState();
    _srsSet = Set<String>.from(widget.srsNormalizedForms);
  }

  Future<void> _playHebrew(String vocalized, {String? audioUrl}) async {
    setState(() {
      _currentlyPlayingWord = vocalized;
    });
    await widget.audioService.playWithTtsFallback(
      sourcePath: audioUrl,
      fallbackHebrewText: vocalized,
    );
    if (mounted) {
      setState(() {
        _currentlyPlayingWord = null;
      });
    }
  }

  Future<void> _addToSrs(DictionaryEntry entry) async {
    final res = await widget.addCardToSrsUseCase(
      AddCardToSrsParams(
        id: 'srs_shoresh_${entry.id}_${DateTime.now().millisecondsSinceEpoch}',
        hebrewVocalized: entry.hebrew.vocalized,
        russianTranslation: entry.russianTranslation,
        root: entry.root,
        binyan: entry.binyan,
        category: entry.category,
        exampleHebrewVocalized: entry.exampleHebrew?.vocalized,
        exampleRussian: entry.exampleRussian,
        audioUrl: entry.audioUrl,
        attribution: ContentAttribution(
          sourceName: entry.attribution.sourceName,
          licenseName: entry.attribution.licenseName,
        ),
      ),
    );
    if (res.isSuccess && mounted) {
      setState(() {
        _srsSet.add(entry.hebrew.normalized);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('«${entry.hebrew.vocalized}» добавлено в FSRS!'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compactRoot = widget.root.compact;

    final matchingWords = widget.allDictionaryEntries.where((entry) {
      final r = entry.root;
      return r != null && r.compact == compactRoot;
    }).toList();

    final matchingVerbs = widget.allGrammarVerbs.where((v) {
      return v.root.compact == compactRoot;
    }).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (BuildContext context, ScrollController scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 8),
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      widget.root.hyphenated,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
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
                        'Семья корня',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Однокоренные слова и формы глаголов',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (matchingWords.isEmpty && matchingVerbs.isEmpty)
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'Пока нет однокоренных слов в базе для корня ${widget.root.hyphenated}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            if (matchingWords.isNotEmpty) ...[
              Text(
                'Слова в словаре (${matchingWords.length})',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              ...matchingWords.map((DictionaryEntry entry) {
                final isInSrs = _srsSet.contains(entry.hebrew.normalized);
                final isPlaying =
                    _currentlyPlayingWord == entry.hebrew.vocalized;

                return Card(
                  elevation: 0,
                  margin: const EdgeInsetsDirectional.only(bottom: 8),
                  color: theme.colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    leading: IconButton(
                      icon: Icon(
                        isPlaying
                            ? Icons.volume_up_rounded
                            : Icons.volume_down_rounded,
                        color: isPlaying
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      tooltip: 'Озвучить',
                      onPressed: () => _playHebrew(entry.hebrew.vocalized),
                    ),
                    title: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          entry.hebrew.vocalized,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    subtitle: Text(
                      '${entry.category.labelRu} · ${entry.russianTranslation}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isInSrs
                                ? Icons.bookmark_added_rounded
                                : Icons.bookmark_add_outlined,
                            color: isInSrs
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          tooltip:
                              isInSrs ? 'В колоде FSRS' : 'Добавить в FSRS',
                          onPressed:
                              isInSrs ? null : () => _addToSrs(entry),
                        ),
                        if (widget.onSelectEntry != null)
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios_rounded,
                                size: 16),
                            tooltip: 'Открыть карточку',
                            onPressed: () {
                              Navigator.of(context).pop();
                              widget.onSelectEntry!(entry);
                            },
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
            if (matchingVerbs.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Глаголы (${matchingVerbs.length})',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              ...matchingVerbs.map((VerbLexeme verb) {
                final infinitive = verb.infinitive;
                return Card(
                  elevation: 0,
                  margin: const EdgeInsetsDirectional.only(bottom: 8),
                  color: theme.colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    title: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          infinitive?.vocalized ?? verb.lemma.vocalized,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    subtitle: Text(
                      '${verb.binyan.hebrewLabel} (${verb.binyan.transliteration}) · ${verb.russianMeaning}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.volume_down_rounded),
                      tooltip: 'Озвучить инфинитив',
                      onPressed: () => _playHebrew(
                        infinitive?.vocalized ?? verb.lemma.vocalized,
                      ),
                    ),
                  ),
                );
              }),
            ],
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}
