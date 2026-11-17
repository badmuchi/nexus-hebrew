import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../data/datasources/hebrew_alphabet_seed_data.dart';
import '../../domain/entities/hebrew_letter.dart';
import '../widgets/alphabet_quiz_sheet.dart';
import '../widgets/cursive_practice_canvas.dart';
import '../widgets/gematria_calculator_view.dart';
import '../widgets/letter_detail_sheet.dart';
import '../widgets/nikkud_explorer_view.dart';
import '../widgets/numbers_and_time_view.dart';

/// Full interactive workspace for Hebrew Alef-Bet, Cursive script (Ktav Yad),
/// Nikkud (vowels), and Gematria calculations.
class AlphabetScreen extends StatefulWidget {
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const AlphabetScreen({
    super.key,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  @override
  State<AlphabetScreen> createState() => _AlphabetScreenState();
}

class _AlphabetScreenState extends State<AlphabetScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  LetterCategory? _selectedCategory;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openLetterDetail(HebrewLetter letter) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => LetterDetailSheet(
        letter: letter,
        audioService: widget.audioService,
        addCardToSrsUseCase: widget.addCardToSrsUseCase,
      ),
    );
  }

  void _openCursiveCanvas(HebrewLetter letter) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => CursivePracticeCanvas(
        letter: letter,
        audioService: widget.audioService,
      ),
    );
  }

  void _openQuiz() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AlphabetQuizSheet(),
    );
  }

  void _speakText(String text) {
    widget.audioService?.playWithTtsFallback(
      sourcePath: null,
      fallbackHebrewText: text,
    );
  }

  List<HebrewLetter> _getFilteredLetters() {
    return HebrewAlphabetSeedData.letters.where((letter) {
      if (_selectedCategory != null && letter.category != _selectedCategory) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesRussian = letter.nameRussian.toLowerCase().contains(query);
        final matchesPrinted = letter.printed.contains(query);
        final matchesFinal =
            letter.finalFormPrinted?.contains(query) ?? false;
        final matchesTranslit =
            letter.transliteration.toLowerCase().contains(query);
        final matchesExample =
            letter.exampleWordHebrew.contains(query) ||
            letter.exampleWordRussian.toLowerCase().contains(query);
        if (!matchesRussian &&
            !matchesPrinted &&
            !matchesFinal &&
            !matchesTranslit &&
            !matchesExample) {
          return false;
        }
      }
      return true;
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Алеф-Бет · Прописи · Никуд'),
        actions: [
          IconButton.filledTonal(
            tooltip: 'Викторина по алфавиту',
            icon: const Icon(Icons.quiz_rounded),
            onPressed: _openQuiz,
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(
              icon: Icon(Icons.spellcheck_rounded),
              text: 'Буквы и прописи',
            ),
            Tab(
              icon: Icon(Icons.format_size_rounded),
              text: 'Огласовки (Никуд)',
            ),
            Tab(
              icon: Icon(Icons.calculate_outlined),
              text: 'Гематрия',
            ),
            Tab(
              icon: Icon(Icons.pin_outlined),
              text: 'Числа и время',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLettersTab(theme, colorScheme),
          NikkudExplorerView(audioService: widget.audioService),
          const GematriaCalculatorView(),
          NumbersAndTimeView(
            audioService: widget.audioService,
            addCardToSrsUseCase: widget.addCardToSrsUseCase,
          ),
        ],
      ),
    );
  }

  Widget _buildLettersTab(ThemeData theme, ColorScheme colorScheme) {
    final filtered = _getFilteredLetters();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Поиск буквы (Алеф, א, Bet, папа)...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              contentPadding: const EdgeInsetsDirectional.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ChoiceChip(
                  label: const Text('Все (22)'),
                  selected: _selectedCategory == null,
                  onSelected: (_) => setState(() => _selectedCategory = null),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ChoiceChip(
                  label: const Text('Бегед-Кефет (с дагешем)'),
                  selected: _selectedCategory == LetterCategory.begedKefet,
                  onSelected: (_) => setState(
                    () => _selectedCategory = LetterCategory.begedKefet,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ChoiceChip(
                  label: const Text('Гортанные (גרוניות)'),
                  selected: _selectedCategory == LetterCategory.guttural,
                  onSelected: (_) => setState(
                    () => _selectedCategory = LetterCategory.guttural,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ChoiceChip(
                  label: const Text('Конечные формы (софит)'),
                  selected: _selectedCategory == LetterCategory.sofit,
                  onSelected: (_) => setState(
                    () => _selectedCategory = LetterCategory.sofit,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    'Буквы по запросу не найдены',
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 24),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.88,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (BuildContext context, int index) {
                    final letter = filtered[index];
                    return _LetterCard(
                      letter: letter,
                      onTap: () => _openLetterDetail(letter),
                      onDrawTap: () => _openCursiveCanvas(letter),
                      onSpeakTap: () => _speakText(letter.nameHebrew),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _LetterCard extends StatelessWidget {
  final HebrewLetter letter;
  final VoidCallback onTap;
  final VoidCallback onDrawTap;
  final VoidCallback onSpeakTap;

  const _LetterCard({
    required this.letter,
    required this.onTap,
    required this.onDrawTap,
    required this.onSpeakTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer.withValues(
                        alpha: 0.7,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${letter.gematria}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: onDrawTap,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.all(4),
                          child: Icon(
                            Icons.draw_outlined,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      InkWell(
                        onTap: onSpeakTap,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.all(4),
                          child: Icon(
                            Icons.volume_up_rounded,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      letter.printed,
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                        height: 1.35,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    if (letter.hasFinalForm) ...[
                      const SizedBox(width: 6),
                      Text(
                        '(${letter.finalFormPrinted!})',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.outline,
                          height: 1.35,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              Text(
                letter.nameRussian,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                letter.nameHebrew,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.outline,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
