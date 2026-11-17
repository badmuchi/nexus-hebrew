import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/widgets/shoresh_family_sheet.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../../../dictionary/domain/entities/dictionary_entry.dart';
import '../../../grammar/domain/entities/verb_conjugation.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/morphology_models.dart';
import '../../domain/services/hebrew_morphology_engine.dart';

class SentenceXRaySheet extends StatefulWidget {
  final String sentenceHebrew;
  final String? sentenceRussian;
  final List<DictionaryEntry> allDictionaryEntries;
  final List<VerbLexeme> allGrammarVerbs;
  final Set<String> srsNormalizedForms;
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const SentenceXRaySheet({
    super.key,
    required this.sentenceHebrew,
    this.sentenceRussian,
    this.allDictionaryEntries = const <DictionaryEntry>[],
    this.allGrammarVerbs = const <VerbLexeme>[],
    this.srsNormalizedForms = const <String>{},
    this.audioService,
    this.addCardToSrsUseCase,
  });

  static Future<void> show(
    BuildContext context, {
    required String sentenceHebrew,
    String? sentenceRussian,
    List<DictionaryEntry> allDictionaryEntries = const <DictionaryEntry>[],
    List<VerbLexeme> allGrammarVerbs = const <VerbLexeme>[],
    Set<String> srsNormalizedForms = const <String>{},
    AudioPlaybackService? audioService,
    AddCardToSrsUseCase? addCardToSrsUseCase,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 680),
      builder: (_) => SentenceXRaySheet(
        sentenceHebrew: sentenceHebrew,
        sentenceRussian: sentenceRussian,
        allDictionaryEntries: allDictionaryEntries,
        allGrammarVerbs: allGrammarVerbs,
        srsNormalizedForms: srsNormalizedForms,
        audioService: audioService,
        addCardToSrsUseCase: addCardToSrsUseCase,
      ),
    );
  }

  @override
  State<SentenceXRaySheet> createState() => _SentenceXRaySheetState();
}

class _SentenceXRaySheetState extends State<SentenceXRaySheet> {
  static const _engine = HebrewMorphologyEngine();

  late final SentenceMorphology _morphology;
  int _selectedWordIndex = 0;
  final Set<String> _addedLemmas = <String>{};

  @override
  void initState() {
    super.initState();
    _morphology = _engine.analyzeSentence(
      sentence: widget.sentenceHebrew,
      russianTranslation: widget.sentenceRussian,
      dictionaryEntries: widget.allDictionaryEntries,
      verbs: widget.allGrammarVerbs,
    );
  }

  Future<void> _playTts(String text) async {
    if (widget.audioService == null) return;
    await widget.audioService!.playWithTtsFallback(
      sourcePath: null,
      fallbackHebrewText: text,
    );
  }

  Future<void> _addLemmaToSrs(WordMorphology word) async {
    if (widget.addCardToSrsUseCase == null) return;

    final params = AddCardToSrsParams(
      id: 'morph_${DateTime.now().microsecondsSinceEpoch}',
      hebrewVocalized: word.lemma,
      russianTranslation: word.translation.isNotEmpty
          ? word.translation
          : word.cleanNormalized,
      root: word.root,
      binyan: word.binyan ?? Binyan.none,
      attribution: const ContentAttribution(
        sourceName: 'Рентген фразы',
        licenseName: 'CC-BY-SA',
      ),
    );

    final res = await widget.addCardToSrsUseCase!(params);
    if (!mounted) return;

    if (res.isSuccess) {
      setState(() {
        _addedLemmas.add(word.lemmaNormalized);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('«${word.lemma}» добавлено в карточки FSRS!'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedWord = _morphology.words.isNotEmpty &&
            _selectedWordIndex < _morphology.words.length
        ? _morphology.words[_selectedWordIndex]
        : null;

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
                    Icons.biotech_rounded,
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
                        'Рентген фразы',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Анатомический разбор слов и приставок иврита',
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

            // Original Sentence Card with interactive word chips
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
                    Text(
                      'Предложение (нажмите на слово для разбора):',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 10,
                        alignment: WrapAlignment.start,
                        children: [
                          for (int i = 0; i < _morphology.words.length; i++)
                            _buildWordSelectorChip(
                              index: i,
                              word: _morphology.words[i],
                              isSelected: i == _selectedWordIndex,
                              theme: theme,
                            ),
                        ],
                      ),
                    ),
                    if (widget.sentenceRussian != null &&
                        widget.sentenceRussian!.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          widget.sentenceRussian!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Selected Word Detail
            if (selectedWord != null) ...[
              _buildWordDetailsCard(selectedWord, theme),
            ] else ...[
              Center(
                child: Text(
                  'Выберите слово для просмотра разбора',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildWordSelectorChip({
    required int index,
    required WordMorphology word,
    required bool isSelected,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedWordIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          word.cleanVocalized,
          textDirection: TextDirection.rtl,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildWordDetailsCard(WordMorphology word, ThemeData theme) {
    final isAlreadyInSrs =
        widget.srsNormalizedForms.contains(word.lemmaNormalized) ||
            _addedLemmas.contains(word.lemmaNormalized);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Formula Header
        Row(
          children: [
            Icon(
              Icons.format_shapes_rounded,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Морфологическая формула',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Visual Equation Blocks
        _buildFormulaVisualRow(word, theme),
        const SizedBox(height: 16),

        // 1. Prefixes block (if any)
        if (word.hasPrefixes) ...[
          _buildPrefixesSection(word.prefixes, theme),
          const SizedBox(height: 12),
        ],

        // 2. Base Lemma block
        _buildBaseLemmaSection(word, isAlreadyInSrs, theme),
        const SizedBox(height: 12),

        // 3. Suffix block (if any)
        if (word.hasSuffix) ...[
          _buildSuffixSection(word.suffix!, theme),
          const SizedBox(height: 12),
        ],

        // 4. Synthesized Meaning Card
        Card(
          elevation: 0,
          color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 22,
                  color: theme.colorScheme.tertiary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Итоговый смысл:',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        word.explanation,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onTertiaryContainer,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormulaVisualRow(WordMorphology word, ThemeData theme) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final p in word.prefixes) ...[
          _buildMorphemeChip(
            label: p.raw,
            subtitle: p.type == MorphemeType.conjunction ? 'союз' : 'предлог',
            color: Colors.blue,
            theme: theme,
          ),
          const Text('+', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
        _buildMorphemeChip(
          label: word.lemma,
          subtitle: 'основа',
          color: Colors.teal,
          theme: theme,
        ),
        if (word.suffix != null) ...[
          const Text('+', style: TextStyle(fontWeight: FontWeight.bold)),
          _buildMorphemeChip(
            label: word.suffix!.raw,
            subtitle: 'суффикс',
            color: Colors.purple,
            theme: theme,
          ),
        ],
      ],
    );
  }

  Widget _buildMorphemeChip({
    required String label,
    required String subtitle,
    required MaterialColor color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color.shade800,
              height: 1.3,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: color.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrefixesSection(List<PrefixToken> prefixes, ThemeData theme) {
    return Card(
      elevation: 0,
      color: Colors.blue.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.blue.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.subdirectory_arrow_right_rounded,
                  color: Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Приставки (אותיות השימוש):',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final p in prefixes) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        p.raw,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        p.meaning,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBaseLemmaSection(
    WordMorphology word,
    bool isAlreadyInSrs,
    ThemeData theme,
  ) {
    return Card(
      elevation: 0,
      color: Colors.teal.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.teal.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.menu_book_rounded,
                  color: Colors.teal,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            word.lemma,
                            textDirection: TextDirection.rtl,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade900,
                              height: 1.4,
                            ),
                          ),
                          const Spacer(),
                          IconButton.filledTonal(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.volume_up_rounded, size: 20),
                            tooltip: 'Озвучить основу слова',
                            onPressed: () => unawaited(_playTts(word.lemma)),
                          ),
                        ],
                      ),
                      Text(
                        word.translation,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (word.partOfSpeech != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Часть речи: ${word.partOfSpeech}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Metadata Chips: Shoresh & Binyan
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (word.root != null)
                  ActionChip(
                    avatar: const Icon(
                      Icons.account_tree_rounded,
                      size: 16,
                      color: Colors.teal,
                    ),
                    label: Text('Корень: ${word.root!.hyphenated}'),
                    onPressed: () => _openShoreshFamily(word.root!),
                  ),
                if (word.binyan != null)
                  Chip(
                    avatar: const Icon(
                      Icons.auto_stories_rounded,
                      size: 16,
                      color: Colors.teal,
                    ),
                    label: Text(
                      'Биньян: ${word.binyan!.hebrewLabel} (${word.binyan!.transliteration})',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Action button: Add to FSRS
            FilledButton.tonalIcon(
              onPressed:
                  isAlreadyInSrs ? null : () => unawaited(_addLemmaToSrs(word)),
              icon: Icon(
                isAlreadyInSrs
                    ? Icons.check_circle_rounded
                    : Icons.bookmark_add_rounded,
                size: 18,
              ),
              label: Text(
                isAlreadyInSrs
                    ? 'Слово уже в FSRS'
                    : 'Добавить основу в FSRS карточки',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuffixSection(SuffixToken suffix, ThemeData theme) {
    return Card(
      elevation: 0,
      color: Colors.purple.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.purple.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(
              Icons.join_right_rounded,
              color: Colors.purple,
              size: 20,
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                suffix.raw,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                suffix.meaning,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openShoreshFamily(Shoresh root) {
    if (widget.audioService == null || widget.addCardToSrsUseCase == null) {
      return;
    }
    unawaited(
      showShoreshFamilySheet(
        context: context,
        root: root,
        allDictionaryEntries: widget.allDictionaryEntries,
        allGrammarVerbs: widget.allGrammarVerbs,
        srsNormalizedForms: widget.srsNormalizedForms,
        audioService: widget.audioService!,
        addCardToSrsUseCase: widget.addCardToSrsUseCase!,
        onSelectEntry: null,
      ),
    );
  }
}
