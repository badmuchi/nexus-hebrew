import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../../../slang/data/datasources/slang_seed_datasource.dart';
import '../../../slang/data/repositories/slang_repository_impl.dart';
import '../../../slang/domain/usecases/get_slang_expressions.dart';
import '../../../slang/presentation/screens/slang_screen.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/presentation/widgets/anki_export_dialog.dart';
import '../../domain/entities/dictionary_entry.dart';
import '../cubit/dictionary_cubit.dart';
import '../cubit/dictionary_state.dart';
import '../widgets/add_dictionary_word_dialog.dart';
import '../widgets/dictionary_entry_detail_sheet.dart';
import '../widgets/shoresh_explorer_view.dart';

enum DictionaryTabMode { words, roots }

/// Bilingual offline-first Hebrew-Russian dictionary with shoresh families,
/// morphological filters, 1-tap FSRS saving, audio, and online Tatoeba lookup.
class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  DictionaryTabMode _tabMode = DictionaryTabMode.words;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<DictionaryCubit, DictionaryState>(
      listenWhen: (DictionaryState prev, DictionaryState curr) =>
          curr is DictionaryLoaded &&
          (curr.transientNotice != null ||
              _searchController.text != curr.filter.query),
      listener: (BuildContext context, DictionaryState state) {
        if (state is! DictionaryLoaded) return;
        if (_searchController.text != state.filter.query) {
          _searchController.value = TextEditingValue(
            text: state.filter.query,
            selection: TextSelection.collapsed(
              offset: state.filter.query.length,
            ),
          );
        }
        if (state.transientNotice != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.transientNotice!)));
          context.read<DictionaryCubit>().clearTransientNotice();
        }
      },
      builder: (BuildContext context, DictionaryState state) {
        final loaded = state is DictionaryLoaded ? state : null;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              _tabMode == DictionaryTabMode.roots
                  ? '🌳 Коренной компас'
                  : (loaded == null
                      ? 'Словарь'
                      : loaded.filter.hasActiveFilters
                          ? 'Словарь (${loaded.visibleMatches.length} / ${loaded.allEntries.length})'
                          : 'Словарь · ${loaded.allEntries.length}'),
            ),
            actions: [
              if (loaded != null) ...[
                if (_tabMode == DictionaryTabMode.words)
                  IconButton(
                    tooltip: loaded.showNikkud
                        ? 'Скрыть огласовки'
                        : 'Показать огласовки',
                    onPressed: () =>
                        context.read<DictionaryCubit>().toggleNikkud(),
                    icon: Icon(
                      loaded.showNikkud
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                    ),
                  ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  tooltip: 'Ещё действия',
                  onSelected: (value) {
                    final cubit = context.read<DictionaryCubit>();
                    if (value == 'slang') {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => SlangScreen(
                            getSlangUseCase: GetSlangExpressionsUseCase(
                              SlangRepositoryImpl(
                                dataSource: AssetSlangSeedDataSource(
                                  logger: const DeveloperAppLogger(),
                                ),
                              ),
                            ),
                            audioService: cubit.audioService,
                            addCardToSrsUseCase: cubit.addCardToSrsUseCase,
                          ),
                        ),
                      );
                    } else if (value == 'anki') {
                      unawaited(
                        AnkiExportDialog.showDictionaryExport(
                          context,
                          entries: loaded.allEntries,
                        ),
                      );
                    } else if (value == 'add_word') {
                      unawaited(showAddDictionaryWordDialog(context));
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'add_word',
                      child: Row(
                        children: [
                          Icon(Icons.add_circle_outline_rounded, size: 20),
                          SizedBox(width: 8),
                          Text('Добавить своё слово'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'slang',
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded,
                            size: 20,
                            color: Colors.deepOrangeAccent,
                          ),
                          SizedBox(width: 8),
                          Text('Сабра-гид: Сленг 🇮🇱'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'anki',
                      child: Row(
                        children: [
                          Icon(Icons.download_for_offline_outlined, size: 20),
                          SizedBox(width: 8),
                          Text('Экспорт в Anki (TSV/CSV)'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          body: switch (state) {
            DictionaryInitial() || DictionaryLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            DictionaryError(:final failure) => _DictionaryErrorView(
                message: failure.message,
                onRetry: () =>
                    unawaited(context.read<DictionaryCubit>().loadDictionary()),
              ),
            DictionaryLoaded() => _buildLoadedBody(context, theme, state),
          },
        );
      },
    );
  }

  Widget _buildLoadedBody(
    BuildContext context,
    ThemeData theme,
    DictionaryLoaded state,
  ) {
    final cubit = context.read<DictionaryCubit>();

    final showBinyanBar = state.filter.category == LexicalCategory.verb ||
        state.filter.binyan != null;
    final hasQuery = state.filter.query.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 6, 16, 4),
          child: SegmentedButton<DictionaryTabMode>(
            segments: const [
              ButtonSegment(
                value: DictionaryTabMode.words,
                label: Text('Словарь'),
                icon: Icon(Icons.menu_book_rounded),
              ),
              ButtonSegment(
                value: DictionaryTabMode.roots,
                label: Text('Коренной компас 🌳'),
                icon: Icon(Icons.account_tree_rounded),
              ),
            ],
            selected: {_tabMode},
            onSelectionChanged: (Set<DictionaryTabMode> next) {
              setState(() {
                _tabMode = next.first;
              });
            },
          ),
        ),
        if (_tabMode == DictionaryTabMode.roots)
          Expanded(
            child: ShoreshExplorerView(
              allEntries: state.allEntries,
              verbParadigms: state.verbParadigms,
              srsNormalizedForms: state.srsNormalizedForms,
              audioService: cubit.audioService,
              addCardToSrsUseCase: cubit.addCardToSrsUseCase,
              onSelectEntry: (DictionaryEntry entry) {
                unawaited(
                  showDictionaryEntryDetailSheet(
                    context: context,
                    initialEntry: entry,
                    onFilterByRoot: (Shoresh root) => cubit.filterByRoot(root),
                  ),
                );
              },
            ),
          )
        else ...[
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText:
                  'Поиск: иврит (с/без никуда), русский, корень כ-ת-ב...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: state.filter.query.isNotEmpty
                  ? IconButton(
                      tooltip: 'Очистить',
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        cubit.updateQuery('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onChanged: cubit.updateQuery,
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: FilterChip(
                  label: const Text('Все'),
                  selected: !state.filter.hasActiveFilters ||
                      (state.filter.category == null &&
                          !state.filter.onlyInSrs &&
                          !state.filter.onlyWithRoot &&
                          state.filter.binyan == null &&
                          state.filter.rootFilter == null),
                  onSelected: (_) {
                    _searchController.clear();
                    cubit.clearAllFilters();
                  },
                ),
              ),
              ...LexicalCategory.values.map(
                (LexicalCategory cat) => Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: FilterChip(
                    label: Text(_shortCategoryLabel(cat)),
                    selected: state.filter.category == cat,
                    onSelected: (bool selected) =>
                        cubit.selectCategory(selected ? cat : null),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: FilterChip(
                  avatar: const Icon(Icons.bookmark_added_outlined, size: 16),
                  label: const Text('В FSRS'),
                  selected: state.filter.onlyInSrs,
                  onSelected: (_) => cubit.toggleOnlyInSrs(),
                ),
              ),
              FilterChip(
                avatar: const Icon(Icons.hub_outlined, size: 16),
                label: const Text('С корнем'),
                selected: state.filter.onlyWithRoot,
                onSelected: (_) => cubit.toggleOnlyWithRoot(),
              ),
            ],
          ),
        ),
        if (showBinyanBar)
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 0),
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ChoiceChip(
                    label: const Text('Все биньяны'),
                    selected: state.filter.binyan == null,
                    onSelected: (_) => cubit.selectBinyan(null),
                  ),
                ),
                ...Binyan.values
                    .where((Binyan b) => b != Binyan.none)
                    .map(
                      (Binyan binyan) => Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: ChoiceChip(
                          label: Text(
                            '${binyan.hebrewLabel} · ${binyan.transliteration}',
                          ),
                          selected: state.filter.binyan == binyan,
                          onSelected: (bool selected) =>
                              cubit.selectBinyan(selected ? binyan : null),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        if (state.filter.rootFilter != null)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
            child: Material(
              color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 6, 8, 6),
                child: Row(
                  children: [
                    const Icon(Icons.hub_rounded, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            'Однокоренные · שורש ${state.filter.rootFilter!.hyphenated}',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => cubit.filterByRoot(null),
                      child: const Text('Сбросить'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 6),
        Expanded(
          child: state.visibleMatches.isEmpty
              ? _EmptyDictionaryView(
                  query: state.filter.query.trim(),
                  isSearchingOnline: state.isSearchingOnline,
                  onSearchOnline: () => unawaited(cubit.searchOnline()),
                  onResetFilters: () {
                    _searchController.clear();
                    cubit.clearAllFilters();
                  },
                )
              : ListView.builder(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 24),
                  itemCount: state.visibleMatches.length + (hasQuery ? 1 : 0),
                  itemBuilder: (BuildContext context, int index) {
                    if (index == state.visibleMatches.length) {
                      return _OnlineSearchPromptCard(
                        query: state.filter.query.trim(),
                        isSearchingOnline: state.isSearchingOnline,
                        lastOnlineQuery: state.lastOnlineQuery,
                        lastOnlineCount: state.lastOnlineResultsCount,
                        onSearchOnline: () => unawaited(cubit.searchOnline()),
                      );
                    }

                    final match = state.visibleMatches[index];
                    final entry = match.entry;
                    final isPlaying =
                        state.activeSpokenHebrew == entry.hebrew.vocalized &&
                            state.audioStatus == AudioPlaybackStatus.playing;

                    return _DictionaryEntryCard(
                      match: match,
                      showNikkud: state.showNikkud,
                      isPlaying: isPlaying,
                      onTap: () => unawaited(
                        showDictionaryEntryDetailSheet(
                          context: context,
                          initialEntry: entry,
                          onFilterByRoot: (Shoresh root) =>
                              cubit.filterByRoot(root),
                        ),
                      ),
                      onSpeak: () => unawaited(cubit.speakEntry(entry)),
                      onSaveToSrs: () => unawaited(cubit.saveToSrs(entry)),
                      onFilterRoot: entry.root == null
                          ? null
                          : () => cubit.filterByRoot(entry.root),
                    );
                  },
                ),
          ),
        ],
      ],
    );
  }

  static String _shortCategoryLabel(LexicalCategory category) {
    switch (category) {
      case LexicalCategory.verb:
        return 'Глаголы';
      case LexicalCategory.noun:
        return 'Сущ.';
      case LexicalCategory.adjective:
        return 'Прил.';
      case LexicalCategory.phrase:
        return 'Фразы';
      case LexicalCategory.particle:
        return 'Служебные';
    }
  }
}

class _DictionaryEntryCard extends StatelessWidget {
  const _DictionaryEntryCard({
    required this.match,
    required this.showNikkud,
    required this.isPlaying,
    required this.onTap,
    required this.onSpeak,
    required this.onSaveToSrs,
    this.onFilterRoot,
  });

  final DictionarySearchMatch match;
  final bool showNikkud;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onSpeak;
  final VoidCallback onSaveToSrs;
  final VoidCallback? onFilterRoot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entry = match.entry;
    final hebrewText = showNikkud ? entry.hebrew.vocalized : entry.hebrew.normalized;

    return Card(
      elevation: 0,
      margin: const EdgeInsetsDirectional.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text(
                              hebrewText,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        if (entry.transliteration != null &&
                            entry.transliteration!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '[${entry.transliteration!}]',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.russianTranslation,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (entry.formsSummary != null) ...[
                      const SizedBox(height: 4),
                      Directionality(
                        textDirection: RegExp(r'[А-Яа-яЁё]').hasMatch(entry.formsSummary!)
                            ? TextDirection.ltr
                            : TextDirection.rtl,
                        child: Text(
                          entry.formsSummary!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _MiniMetaTag(
                          label: entry.category.labelRu,
                          color: theme.colorScheme.surfaceContainerHighest,
                          textColor: theme.colorScheme.onSurfaceVariant,
                        ),
                        if (entry.binyan != Binyan.none)
                          _MiniMetaTag(
                            label: entry.binyan.transliteration,
                            color: theme.colorScheme.tertiaryContainer
                                .withValues(alpha: 0.7),
                            textColor: theme.colorScheme.onTertiaryContainer,
                          ),
                        if (entry.root != null)
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: onFilterRoot,
                            child: _MiniMetaTag(
                              label: entry.root!.hyphenated,
                              isRtl: true,
                              color: theme.colorScheme.secondaryContainer
                                  .withValues(alpha: 0.75),
                              textColor: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        if (entry.frequencyRank != null &&
                            entry.frequencyRank! <= 500)
                          _MiniMetaTag(
                            label: entry.frequencyRank! <= 100
                                ? 'Топ-100'
                                : 'Топ-500',
                            color: theme.colorScheme.primaryContainer
                                .withValues(alpha: 0.65),
                            textColor: theme.colorScheme.onPrimaryContainer,
                          ),
                        if (entry.isUserAdded)
                          _MiniMetaTag(
                            label: 'Своё',
                            color: theme.colorScheme.primaryContainer,
                            textColor: theme.colorScheme.onPrimaryContainer,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: isPlaying ? 'Остановить' : 'Озвучить',
                    onPressed: onSpeak,
                    icon: Icon(
                      isPlaying
                          ? Icons.stop_circle_outlined
                          : Icons.volume_up_outlined,
                    ),
                  ),
                  IconButton(
                    tooltip: match.isInSrs
                        ? 'Уже в колоде FSRS'
                        : 'В FSRS в 1 тап',
                    onPressed: onSaveToSrs,
                    icon: Icon(
                      match.isInSrs
                          ? Icons.bookmark_added_rounded
                          : Icons.bookmark_add_outlined,
                      color: match.isInSrs ? theme.colorScheme.primary : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniMetaTag extends StatelessWidget {
  const _MiniMetaTag({
    required this.label,
    required this.color,
    required this.textColor,
    this.isRtl = false,
  });

  final String label;
  final Color color;
  final Color textColor;
  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
    );
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(8, 3, 8, 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: isRtl
          ? Directionality(textDirection: TextDirection.rtl, child: text)
          : text,
    );
  }
}

class _OnlineSearchPromptCard extends StatelessWidget {
  const _OnlineSearchPromptCard({
    required this.query,
    required this.isSearchingOnline,
    required this.onSearchOnline,
    this.lastOnlineQuery,
    this.lastOnlineCount,
  });

  final String query;
  final bool isSearchingOnline;
  final VoidCallback onSearchOnline;
  final String? lastOnlineQuery;
  final int? lastOnlineCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alreadySearched = lastOnlineQuery == query;

    return Card(
      elevation: 0,
      margin: const EdgeInsetsDirectional.only(top: 6),
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(14),
        child: Row(
          children: [
            Icon(
              Icons.travel_explore_rounded,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alreadySearched
                        ? 'Tatoeba по «$query»: загружено ${lastOnlineCount ?? 0}'
                        : 'Нужны живые примеры с «$query»?',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Поиск по открытой базе Tatoeba (CC BY) в обе стороны с сохранением офлайн',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonal(
              onPressed: isSearchingOnline ? null : onSearchOnline,
              child: isSearchingOnline
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Найти'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDictionaryView extends StatelessWidget {
  const _EmptyDictionaryView({
    required this.query,
    required this.isSearchingOnline,
    required this.onSearchOnline,
    required this.onResetFilters,
  });

  final String query;
  final bool isSearchingOnline;
  final VoidCallback onSearchOnline;
  final VoidCallback onResetFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.menu_book_outlined,
                size: 46,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                query.isEmpty
                    ? 'По выбранным фильтрам ничего не найдено.'
                    : 'По запросу «$query» локально ничего не найдено.',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  if (query.isNotEmpty)
                    FilledButton.icon(
                      onPressed: isSearchingOnline ? null : onSearchOnline,
                      icon: isSearchingOnline
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cloud_download_outlined),
                      label: const Text('Искать в Tatoeba'),
                    ),
                  OutlinedButton(
                    onPressed: onResetFilters,
                    child: const Text('Сбросить фильтры'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DictionaryErrorView extends StatelessWidget {
  const _DictionaryErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 42),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}
