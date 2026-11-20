import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/omni_search_result.dart';
import '../../domain/services/omni_search_engine.dart';
import 'omni_search_result_tile.dart';

/// Modal Spotlight / Omni-Search sheet offering cross-domain Hebrew search.
class OmniSearchSheet extends StatefulWidget {
  const OmniSearchSheet({
    super.key,
    required this.engine,
    this.audioService,
    this.addCardToSrsUseCase,
    this.onNavigateToTab,
  });

  final OmniSearchEngine engine;
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;
  final void Function(int tabIndex)? onNavigateToTab;

  /// Convenience method to open the modal sheet.
  static Future<void> show(
    BuildContext context, {
    required OmniSearchEngine engine,
    AudioPlaybackService? audioService,
    AddCardToSrsUseCase? addCardToSrsUseCase,
    void Function(int tabIndex)? onNavigateToTab,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => OmniSearchSheet(
        engine: engine,
        audioService: audioService,
        addCardToSrsUseCase: addCardToSrsUseCase,
        onNavigateToTab: onNavigateToTab,
      ),
    );
  }

  @override
  State<OmniSearchSheet> createState() => _OmniSearchSheetState();
}

class _OmniSearchSheetState extends State<OmniSearchSheet> {
  final TextEditingController _queryController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  OmniResultCategory? _selectedCategory;
  List<OmniSearchResult> _results = [];

  static const List<String> _quickSuggestions = [
    'שָׁלוֹם',
    'סַבָּבָּה',
    'בְּבַקָּשָׁה',
    'כתב',
    'שלי',
    'א',
  ];

  @override
  void initState() {
    super.initState();
    _queryController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _queryController.removeListener(_onSearchChanged);
    _queryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _queryController.text;
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }

    final found = widget.engine.search(
      query,
      categoryFilter: _selectedCategory,
    );
    setState(() => _results = found);
  }

  void _onCategorySelected(OmniResultCategory? category) {
    setState(() => _selectedCategory = category);
    _onSearchChanged();
  }

  void _applySuggestion(String text) {
    _queryController.text = text;
    _queryController.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.88,
      child: Column(
        children: [
          // Drag handle & top bar
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Icon(
                  Icons.manage_search_rounded,
                  color: theme.colorScheme.primary,
                  size: 26,
                ),
                const SizedBox(width: 8),
                Text(
                  'Быстрый поиск (Omni-Search)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Закрыть',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Search Input Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: TextField(
              controller: _queryController,
              focusNode: _focusNode,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Иврит, русский, корень, сленг, буква...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _queryController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _queryController.clear();
                          _focusNode.requestFocus();
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark
                    ? theme.colorScheme.surfaceVariant.withOpacity(0.5)
                    : theme.colorScheme.surfaceVariant.withOpacity(0.35),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Все категории'),
                  selected: _selectedCategory == null,
                  onSelected: (_) => _onCategorySelected(null),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 6),
                for (final cat in OmniResultCategory.values) ...[
                  FilterChip(
                    label: Text(cat.labelRu),
                    selected: _selectedCategory == cat,
                    onSelected: (selected) => _onCategorySelected(
                      selected ? cat : null,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          ),

          const Divider(height: 12),

          // Content Area: Results, Suggestions, or Empty State
          Expanded(
            child: _buildBody(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    final query = _queryController.text.trim();

    // 1. Initial State: Quick Suggestions
    if (query.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Быстрый старт & популярные запросы:',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final suggestion in _quickSuggestions)
                ActionChip(
                  label: Text(
                    suggestion,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onPressed: () => _applySuggestion(suggestion),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Совет по поиску',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Вы можете вводить слова как на иврите с огласовками (שָׁלוֹם) или без (שלום), так и на русском («привет», «мир», «до свидания»), по названию букв («алеф», «бет») или по 3 буквам корня («כתב»).',
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.4,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // 2. No Results Found
    if (_results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 56,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'Ничего не найдено по запросу «$query»',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Попробуйте изменить запрос, снять фильтр категории или ввести слово без огласовок.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Results List
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            'Найдено результатов: ${_results.length}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _results.length,
            padding: const EdgeInsets.only(bottom: 24),
            itemBuilder: (context, index) {
              final result = _results[index];
              return OmniSearchResultTile(
                result: result,
                audioService: widget.audioService,
                addCardToSrsUseCase: widget.addCardToSrsUseCase,
                onTap: () {
                  Navigator.of(context).pop();
                  _handleResultTap(result);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _handleResultTap(OmniSearchResult result) {
    if (widget.onNavigateToTab == null) return;

    switch (result.category) {
      case OmniResultCategory.alphabet:
        widget.onNavigateToTab!(1); // Alphabet tab
      case OmniResultCategory.dictionary:
        widget.onNavigateToTab!(2); // Dictionary tab
      case OmniResultCategory.grammar:
      case OmniResultCategory.preposition:
        widget.onNavigateToTab!(3); // Grammar tab
      case OmniResultCategory.slang:
        widget.onNavigateToTab!(4); // Slang / Conversation tab
    }
  }
}
