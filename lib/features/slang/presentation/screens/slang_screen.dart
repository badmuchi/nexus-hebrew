import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/slang_expression.dart';
import '../../domain/usecases/get_slang_expressions.dart';

class SlangScreen extends StatefulWidget {
  final GetSlangExpressionsUseCase getSlangUseCase;
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const SlangScreen({
    super.key,
    required this.getSlangUseCase,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  @override
  State<SlangScreen> createState() => _SlangScreenState();
}

class _SlangScreenState extends State<SlangScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SlangExpression> _allExpressions = [];
  List<SlangExpression> _filteredExpressions = [];
  SlangCategory _selectedCategory = SlangCategory.all;
  bool _isLoading = true;
  String? _currentlyPlayingId;

  @override
  void initState() {
    super.initState();
    _loadSlang();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSlang() async {
    setState(() {
      _isLoading = true;
    });
    final res = await widget.getSlangUseCase.call();
    if (mounted) {
      setState(() {
        _isLoading = false;
        _allExpressions = res.getOrNull() ?? [];
        _applyFilters();
      });
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredExpressions = _allExpressions.where((item) {
        if (_selectedCategory != SlangCategory.all &&
            item.category != _selectedCategory) {
          return false;
        }
        if (query.isNotEmpty) {
          final matchesHebrew = item.hebrew.vocalized.contains(query) ||
              item.hebrew.normalized.contains(query);
          final matchesRu = item.translationRu.toLowerCase().contains(query);
          final matchesTranslit =
              item.transliteration.toLowerCase().contains(query);
          return matchesHebrew || matchesRu || matchesTranslit;
        }
        return true;
      }).toList(growable: false);
    });
  }

  Future<void> _playAudio(SlangExpression expression) async {
    if (_currentlyPlayingId != null) return;
    setState(() {
      _currentlyPlayingId = expression.id;
    });
    try {
      await widget.audioService?.playWithTtsFallback(
        sourcePath: expression.audioUrl,
        fallbackHebrewText: expression.hebrew.vocalized,
      );
    } finally {
      if (mounted) {
        setState(() {
          _currentlyPlayingId = null;
        });
      }
    }
  }

  Future<void> _saveToSrs(SlangExpression expression) async {
    if (widget.addCardToSrsUseCase == null) return;

    final params = AddCardToSrsParams(
      id: 'slang_${expression.id}',
      hebrewVocalized: expression.hebrew.vocalized,
      russianTranslation:
          '${expression.translationRu} (${expression.literalTranslationRu})',
      category: LexicalCategory.phrase,
      exampleHebrewVocalized: expression.exampleHebrew,
      exampleRussian: expression.exampleTranslationRu,
      audioUrl: expression.audioUrl,
      attribution: const ContentAttribution(
        sourceName: 'Sabra Slang Guide',
        licenseName: 'CC-BY',
      ),
    );

    final res = await widget.addCardToSrsUseCase!.call(params);
    if (!mounted) return;

    final isNew = res.getOrNull() ?? false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNew
              ? 'Выражение «${expression.hebrew.vocalized}» сохранено в колоду FSRS!'
              : '«${expression.hebrew.vocalized}» уже есть в вашей колоде',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Сабра-гид: Сленг 🇮🇱'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск сленга (сабаба, ялла, огонь)...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onChanged: (_) => _applyFilters(),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: SlangCategory.values.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(cat.titleRu),
                    onSelected: (val) {
                      setState(() {
                        _selectedCategory = cat;
                        _applyFilters();
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredExpressions.isEmpty
                    ? Center(
                        child: Text(
                          'Ничего не найдено',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: _filteredExpressions.length,
                        itemBuilder: (context, index) {
                          final item = _filteredExpressions[index];
                          return _SlangExpressionCard(
                            expression: item,
                            isPlaying: _currentlyPlayingId == item.id,
                            onPlay: () => _playAudio(item),
                            onSaveSrs: () => _saveToSrs(item),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _SlangExpressionCard extends StatefulWidget {
  final SlangExpression expression;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onSaveSrs;

  const _SlangExpressionCard({
    required this.expression,
    required this.isPlaying,
    required this.onPlay,
    required this.onSaveSrs,
  });

  @override
  State<_SlangExpressionCard> createState() => _SlangExpressionCardState();
}

class _SlangExpressionCardState extends State<_SlangExpressionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.expression;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.colorScheme.surfaceContainerLow,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item.hebrew.vocalized,
                            textDirection: TextDirection.rtl,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.transliteration,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.translationRu,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  icon: Icon(
                    widget.isPlaying
                        ? Icons.volume_up_rounded
                        : Icons.play_arrow_rounded,
                  ),
                  onPressed: widget.onPlay,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Буквально: ${item.literalTranslationRu}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    item.exampleHebrew,
                    textDirection: TextDirection.rtl,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.exampleTranslationRu,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    child: Row(
                      children: [
                        Icon(
                          _expanded
                              ? Icons.expand_less_rounded
                              : Icons.lightbulb_outline_rounded,
                          size: 18,
                          color: theme.colorScheme.tertiary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _expanded ? 'Скрыть контекст' : 'Откуда пошло?',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.tertiary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: widget.onSaveSrs,
                  icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                  label: const Text('В FSRS'),
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item.culturalNoteRu,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
