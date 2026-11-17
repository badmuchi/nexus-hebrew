import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/widgets/shoresh_family_sheet.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../../../grammar/domain/entities/verb_conjugation.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/dictionary_entry.dart';

/// Aggregated representation of a Hebrew Shoresh (root) with its derived vocabulary.
class ShoreshCluster {
  final Shoresh root;
  final List<DictionaryEntry> dictionaryEntries;
  final List<VerbLexeme> verbLexemes;
  final String primaryMeaningRu;

  const ShoreshCluster({
    required this.root,
    required this.dictionaryEntries,
    required this.verbLexemes,
    required this.primaryMeaningRu,
  });

  int get totalDerivatives => dictionaryEntries.length + verbLexemes.length;
}

/// Interactive Root Explorer ("Коренной компас") widget.
class ShoreshExplorerView extends StatefulWidget {
  const ShoreshExplorerView({
    super.key,
    required this.allEntries,
    required this.verbParadigms,
    required this.srsNormalizedForms,
    required this.audioService,
    required this.addCardToSrsUseCase,
    this.onSelectEntry,
  });

  final List<DictionaryEntry> allEntries;
  final List<VerbLexeme> verbParadigms;
  final Set<String> srsNormalizedForms;
  final AudioPlaybackService audioService;
  final AddCardToSrsUseCase addCardToSrsUseCase;
  final ValueChanged<DictionaryEntry>? onSelectEntry;

  @override
  State<ShoreshExplorerView> createState() => _ShoreshExplorerViewState();
}

class _ShoreshExplorerViewState extends State<ShoreshExplorerView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  int _filterIndex = 0; // 0: все, 1: 3+ слова, 2: с глаголами, 3: топ-12

  List<ShoreshCluster> _allClusters = [];

  @override
  void initState() {
    super.initState();
    _buildClusters();
  }

  @override
  void didUpdateWidget(covariant ShoreshExplorerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allEntries != widget.allEntries ||
        oldWidget.verbParadigms != widget.verbParadigms) {
      _buildClusters();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _buildClusters() {
    final Map<String, List<DictionaryEntry>> dictByRoot = {};
    for (final entry in widget.allEntries) {
      final r = entry.root;
      if (r != null) {
        dictByRoot.putIfAbsent(r.hyphenated, () => []).add(entry);
      }
    }

    final Map<String, List<VerbLexeme>> verbsByRoot = {};
    for (final verb in widget.verbParadigms) {
      verbsByRoot.putIfAbsent(verb.root.hyphenated, () => []).add(verb);
    }

    final allRootKeys = <String>{...dictByRoot.keys, ...verbsByRoot.keys};
    final clusters = <ShoreshCluster>[];

    for (final key in allRootKeys) {
      final rootObj = Shoresh.create(key).getOrNull();
      if (rootObj == null) continue;

      final dictList = dictByRoot[key] ?? const [];
      final verbList = verbsByRoot[key] ?? const [];

      // Extract primary summary meaning
      final meanings = <String>[];
      for (final v in verbList) {
        if (!meanings.contains(v.russianMeaning)) {
          meanings.add(v.russianMeaning);
        }
      }
      for (final d in dictList) {
        if (!meanings.contains(d.russianTranslation)) {
          meanings.add(d.russianTranslation);
        }
      }
      final primaryMeaning = meanings.take(3).join(', ');

      clusters.add(
        ShoreshCluster(
          root: rootObj,
          dictionaryEntries: dictList,
          verbLexemes: verbList,
          primaryMeaningRu: primaryMeaning,
        ),
      );
    }

    // Sort by richest roots first, then alphabetically
    clusters.sort((a, b) {
      final countCmp = b.totalDerivatives.compareTo(a.totalDerivatives);
      if (countCmp != 0) return countCmp;
      return a.root.hyphenated.compareTo(b.root.hyphenated);
    });

    setState(() {
      _allClusters = clusters;
    });
  }

  List<ShoreshCluster> _getFilteredClusters() {
    var list = _allClusters;

    if (_filterIndex == 1) {
      // 3+ слова
      list = list.where((c) => c.totalDerivatives >= 3).toList();
    } else if (_filterIndex == 2) {
      // с глаголами
      list = list.where((c) => c.verbLexemes.isNotEmpty).toList();
    } else if (_filterIndex == 3) {
      // топ-12
      list = list.take(12).toList();
    }

    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      final cleanQ = q.replaceAll('-', '').replaceAll(' ', '');
      list = list.where((c) {
        final rootClean = c.root.hyphenated.replaceAll('-', '');
        final matchesRoot = rootClean.contains(cleanQ) ||
            c.root.hyphenated.toLowerCase().contains(q);
        final matchesMeaning = c.primaryMeaningRu.toLowerCase().contains(q);
        final matchesDerivatives = c.dictionaryEntries.any(
              (e) =>
                  e.russianTranslation.toLowerCase().contains(q) ||
                  e.hebrew.normalized.contains(cleanQ),
            ) ||
            c.verbLexemes.any(
              (v) =>
                  v.russianMeaning.toLowerCase().contains(q) ||
                  v.lemma.normalized.contains(cleanQ),
            );
        return matchesRoot || matchesMeaning || matchesDerivatives;
      }).toList();
    }

    return list;
  }

  void _openRootSheet(Shoresh root) {
    unawaited(
      showShoreshFamilySheet(
        context: context,
        root: root,
        allDictionaryEntries: widget.allEntries,
        allGrammarVerbs: widget.verbParadigms,
        srsNormalizedForms: widget.srsNormalizedForms,
        audioService: widget.audioService,
        addCardToSrsUseCase: widget.addCardToSrsUseCase,
        onSelectEntry: widget.onSelectEntry,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _getFilteredClusters();

    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 32),
      children: [
        // Hero Card
        _buildHeroCard(theme),
        const SizedBox(height: 14),

        // Search bar
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Поиск корня: כתב, כ-ת-ב, книга, писать...',
            prefixIcon: const Icon(Icons.manage_search_rounded),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _query = '';
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onChanged: (val) {
            setState(() {
              _query = val;
            });
          },
        ),
        const SizedBox(height: 12),

        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: Text('Все корни (${_allClusters.length})'),
                selected: _filterIndex == 0,
                onSelected: (_) => setState(() => _filterIndex = 0),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Семьи 3+ слов'),
                selected: _filterIndex == 1,
                onSelected: (_) => setState(() => _filterIndex = 1),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('С глаголами'),
                selected: _filterIndex == 2,
                onSelected: (_) => setState(() => _filterIndex = 2),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('🔥 Топ-12 ключевых'),
                selected: _filterIndex == 3,
                onSelected: (_) => setState(() => _filterIndex = 3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (filtered.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsetsDirectional.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.filter_alt_off_rounded,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Ни один корень не найден по запросу «$_query»',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          )
        else
          ...filtered.map((cluster) => _buildRootCard(theme, cluster)),
      ],
    );
  }

  Widget _buildHeroCard(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: theme.colorScheme.tertiary.withValues(alpha: 0.25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsetsDirectional.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.account_tree_rounded,
                size: 32,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Коренной компас · מַצְפֵּן שָׁרָשִׁים',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'В иврите из одного 3-буквенного корня вырастает целое дерево: глаголы разных пород, существительные и профессии. Нажимай на любой корень для интерактивного разбора.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRootCard(ThemeData theme, ShoreshCluster cluster) {
    final previewWords = <String>[];
    for (final v in cluster.verbLexemes) {
      final form = v.infinitive?.vocalized ?? v.lemma.vocalized;
      previewWords.add('$form (${v.russianMeaning})');
      if (previewWords.length >= 4) break;
    }
    if (previewWords.length < 4) {
      for (final d in cluster.dictionaryEntries) {
        final form = d.hebrew.vocalized;
        previewWords.add('$form (${d.russianTranslation})');
        if (previewWords.length >= 4) break;
      }
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsetsDirectional.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openRootSheet(cluster.root),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Root chip with Hebrew text
                  Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        cluster.root.hyphenated,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ),
                  // Derivative counter badge
                  Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${cluster.totalDerivatives} сл.',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Meaning
              if (cluster.primaryMeaningRu.isNotEmpty)
                Text(
                  cluster.primaryMeaningRu,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 10),

              // Derivative pills
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: previewWords.map((word) {
                  return Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Text(
                      word,
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),

              // Footer tap hint
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  'Исследовать древо →',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
