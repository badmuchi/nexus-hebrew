import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/widgets/shoresh_family_sheet.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../../../dictionary/domain/entities/dictionary_entry.dart';
import '../../../dictionary/presentation/widgets/dictionary_entry_detail_sheet.dart';
import '../../../grammar/domain/entities/verb_conjugation.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/story.dart';

Future<void> showStoryWordBottomSheet({
  required BuildContext context,
  required StoryWordToken token,
  required StorySentence sentence,
  required bool isInSrs,
  required AudioPlaybackService audioService,
  required AddCardToSrsUseCase addCardToSrsUseCase,
  required List<DictionaryEntry> allDictionaryEntries,
  required List<VerbLexeme> allGrammarVerbs,
  required Set<String> srsNormalizedForms,
  required VoidCallback onWordAddedToSrs,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    constraints: const BoxConstraints(maxWidth: 600),
    builder: (BuildContext sheetContext) {
      return _StoryWordBottomSheet(
        token: token,
        sentence: sentence,
        isInSrs: isInSrs,
        audioService: audioService,
        addCardToSrsUseCase: addCardToSrsUseCase,
        allDictionaryEntries: allDictionaryEntries,
        allGrammarVerbs: allGrammarVerbs,
        srsNormalizedForms: srsNormalizedForms,
        onWordAddedToSrs: onWordAddedToSrs,
      );
    },
  );
}

class _StoryWordBottomSheet extends StatefulWidget {
  const _StoryWordBottomSheet({
    required this.token,
    required this.sentence,
    required this.isInSrs,
    required this.audioService,
    required this.addCardToSrsUseCase,
    required this.allDictionaryEntries,
    required this.allGrammarVerbs,
    required this.srsNormalizedForms,
    required this.onWordAddedToSrs,
  });

  final StoryWordToken token;
  final StorySentence sentence;
  final bool isInSrs;
  final AudioPlaybackService audioService;
  final AddCardToSrsUseCase addCardToSrsUseCase;
  final List<DictionaryEntry> allDictionaryEntries;
  final List<VerbLexeme> allGrammarVerbs;
  final Set<String> srsNormalizedForms;
  final VoidCallback onWordAddedToSrs;

  @override
  State<_StoryWordBottomSheet> createState() => _StoryWordBottomSheetState();
}

class _StoryWordBottomSheetState extends State<_StoryWordBottomSheet> {
  late bool _isInSrs;
  bool _isPlaying = false;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _isInSrs = widget.isInSrs;
  }

  Future<void> _playAudio() async {
    setState(() => _isPlaying = true);
    await widget.audioService.playWithTtsFallback(
      sourcePath: null,
      fallbackHebrewText: widget.token.wordVocalized,
    );
    if (mounted) {
      setState(() => _isPlaying = false);
    }
  }

  Future<void> _addToSrs() async {
    if (_isInSrs || _isAdding) return;
    setState(() => _isAdding = true);

    final category = widget.token.category != null
        ? LexicalCategory.parseStrict(widget.token.category!).getOrNull() ??
            LexicalCategory.phrase
        : LexicalCategory.phrase;

    final res = await widget.addCardToSrsUseCase(
      AddCardToSrsParams(
        id: 'srs_story_word_${widget.token.wordNormalized}_${DateTime.now().millisecondsSinceEpoch}',
        hebrewVocalized: widget.token.wordVocalized,
        russianTranslation: widget.token.russianTranslation,
        root: widget.token.root,
        binyan: widget.token.binyan ?? Binyan.none,
        category: category,
        exampleHebrewVocalized: widget.sentence.hebrewVocalized,
        exampleRussian: widget.sentence.russianTranslation,
        attribution: const ContentAttribution(
          sourceName: 'Nexus Hebrew Reader',
          licenseName: 'CC BY-SA 4.0',
        ),
      ),
    );

    if (mounted) {
      setState(() => _isAdding = false);
      if (res.isSuccess) {
        setState(() => _isInSrs = true);
        widget.onWordAddedToSrs();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '«${widget.token.wordVocalized}» добавлено в колоду FSRS!',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  DictionaryEntry? _findMatchingDictEntry() {
    final norm = widget.token.wordNormalized;
    for (final entry in widget.allDictionaryEntries) {
      if (entry.hebrew.normalized == norm) {
        return entry;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dictEntry = _findMatchingDictEntry();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          widget.token.wordVocalized,
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (widget.token.transliteration != null)
                        Text(
                          '[${widget.token.transliteration}]',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  icon: Icon(
                    _isPlaying
                        ? Icons.volume_up_rounded
                        : Icons.volume_down_rounded,
                  ),
                  tooltip: 'Озвучить слово',
                  onPressed: _playAudio,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.token.russianTranslation,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (widget.token.category != null)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(widget.token.category!),
                    backgroundColor: theme.colorScheme.surfaceContainerLow,
                  ),
                if (widget.token.binyan != null)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(widget.token.binyan!.hebrewLabel),
                    backgroundColor: theme.colorScheme.surfaceContainerLow,
                  ),
                if (widget.token.root != null)
                  ActionChip(
                    avatar: const Icon(Icons.account_tree_outlined, size: 16),
                    label: Text('Корень: ${widget.token.root!.hyphenated}'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      showShoreshFamilySheet(
                        context: context,
                        root: widget.token.root!,
                        allDictionaryEntries: widget.allDictionaryEntries,
                        allGrammarVerbs: widget.allGrammarVerbs,
                        srsNormalizedForms: widget.srsNormalizedForms,
                        audioService: widget.audioService,
                        addCardToSrsUseCase: widget.addCardToSrsUseCase,
                        onSelectEntry: null,
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: Icon(
                      _isInSrs
                          ? Icons.check_circle_rounded
                          : Icons.bookmark_add_rounded,
                    ),
                    label: Text(
                      _isInSrs ? 'В колоде FSRS' : 'В FSRS в 1 тап',
                    ),
                    onPressed: _isInSrs || _isAdding ? null : _addToSrs,
                  ),
                ),
                if (dictEntry != null) ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.menu_book_outlined, size: 18),
                    label: const Text('Словарь'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      showDictionaryEntryDetailSheet(
                        context: context,
                        initialEntry: dictEntry,
                        onFilterByRoot: (Shoresh r) {
                          showShoreshFamilySheet(
                            context: context,
                            root: r,
                            allDictionaryEntries: widget.allDictionaryEntries,
                            allGrammarVerbs: widget.allGrammarVerbs,
                            srsNormalizedForms: widget.srsNormalizedForms,
                            audioService: widget.audioService,
                            addCardToSrsUseCase: widget.addCardToSrsUseCase,
                            onSelectEntry: null,
                          );
                        },
                      );
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
