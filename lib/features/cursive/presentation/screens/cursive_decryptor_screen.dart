import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../data/datasources/handwritten_notes_seed_data.dart';
import '../../domain/entities/cursive_letter_map.dart';
import '../../domain/entities/handwritten_note.dart';
import '../widgets/handwritten_note_card.dart';

/// Full interactive workspace for deciphering real-life Hebrew handwritten notes,
/// building cursive alphabet intuition, and playing rapid letter-matching drills.
class CursiveDecryptorScreen extends StatefulWidget {
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;
  final ValueChanged<int>? onXpEarned;

  const CursiveDecryptorScreen({
    super.key,
    this.audioService,
    this.addCardToSrsUseCase,
    this.onXpEarned,
  });

  @override
  State<CursiveDecryptorScreen> createState() => _CursiveDecryptorScreenState();
}

class _CursiveDecryptorScreenState extends State<CursiveDecryptorScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Notes tab state
  HandwrittenNoteCategory? _selectedCategory;
  int _earnedXp = 0;

  // Blitz tab state
  int _blitzScore = 0;
  int _blitzQuestionIndex = 0;
  int? _blitzSelectedOption;
  bool _isBlitzAnswered = false;

  late List<CursiveLetterEntry> _blitzQuestions;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _blitzQuestions = List.of(CursiveLetterMap.entries)..shuffle();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onNoteXpEarned(int xp) {
    setState(() => _earnedXp += xp);
    widget.onXpEarned?.call(xp);
  }

  void _onAnswerBlitz(int selectedIndex, int correctIndex) {
    if (_isBlitzAnswered) return;
    unawaited(HapticFeedback.lightImpact());

    final isCorrect = selectedIndex == correctIndex;
    if (isCorrect) {
      unawaited(HapticFeedback.mediumImpact());
      _blitzScore += 10;
      widget.onXpEarned?.call(10);
    }

    setState(() {
      _blitzSelectedOption = selectedIndex;
      _isBlitzAnswered = true;
    });
  }

  void _nextBlitzQuestion() {
    unawaited(HapticFeedback.lightImpact());
    setState(() {
      _blitzQuestionIndex++;
      _blitzSelectedOption = null;
      _isBlitzAnswered = false;
    });
  }

  Future<void> _addLetterToSrs(CursiveLetterEntry entry) async {
    final useCase = widget.addCardToSrsUseCase;
    if (useCase == null) return;

    final params = AddCardToSrsParams(
      id: 'cursive_${entry.printed}_${entry.isSofit ? 'sofit' : 'reg'}',
      hebrewVocalized: entry.printed,
      russianTranslation:
          'Буква ${entry.nameRussian} (${entry.nameHebrew}) • Ктав Яд: ${entry.visualMnemonicRu}',
      category: LexicalCategory.particle,
      exampleHebrewVocalized: entry.sampleWordHebrew,
      exampleRussian: entry.sampleWordTranslationRu,
    );

    final res = await useCase(params);
    if (mounted) {
      final msg = res.isSuccess
          ? '✓ Буква "${entry.printed}" добавлена в FSRS!'
          : 'Уже есть в колоде или ошибка';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Дешифровщик Ктав Яд (כתב יד)'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.description_outlined), text: 'Записки из жизни'),
            Tab(icon: Icon(Icons.flash_on_rounded), text: 'Блиц букв'),
            Tab(icon: Icon(Icons.menu_book_rounded), text: 'Атлас Ктав Яд'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotesTab(theme),
          _buildBlitzTab(theme),
          _buildAtlasTab(theme),
        ],
      ),
    );
  }

  Widget _buildNotesTab(ThemeData theme) {
    final notes = _selectedCategory == null
        ? HandwrittenNotesSeedData.notes
        : HandwrittenNotesSeedData.notes
            .where((n) => n.category == _selectedCategory)
            .toList();

    return ListView(
      padding: const EdgeInsetsDirectional.all(16),
      children: [
        // Score Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Реальные записки израильтян:',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
              ),
              child: Text(
                '⭐ $_earnedXp XP',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFF57F17)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('Все записки'),
                selected: _selectedCategory == null,
                onSelected: (val) {
                  if (val) setState(() => _selectedCategory = null);
                },
              ),
              const SizedBox(width: 8),
              for (final cat in HandwrittenNoteCategory.values) ...[
                ChoiceChip(
                  label: Text('${cat.emoji} ${cat.titleRu}'),
                  selected: _selectedCategory == cat,
                  onSelected: (val) {
                    setState(() => _selectedCategory = val ? cat : null);
                  },
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        for (final note in notes) ...[
          HandwrittenNoteCard(
            note: note,
            audioService: widget.audioService,
            onXpEarned: _onNoteXpEarned,
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildBlitzTab(ThemeData theme) {
    final currentLetter = _blitzQuestions[_blitzQuestionIndex % _blitzQuestions.length];

    // Generate 4 multiple-choice options (1 correct + 3 random distinct distractors)
    final otherLetters = CursiveLetterMap.entries
        .where((e) => e.printed != currentLetter.printed)
        .toList()
      ..shuffle();
    final options = [
      currentLetter,
      otherLetters[0],
      otherLetters[1],
      otherLetters[2],
    ]..shuffle();

    final correctIndex = options.indexOf(currentLetter);

    return ListView(
      padding: const EdgeInsetsDirectional.all(16),
      children: [
        // Score & Question Index
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Вопрос ${(_blitzQuestionIndex % _blitzQuestions.length) + 1} / ${_blitzQuestions.length}',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
              ),
              child: Text(
                '⭐ $_blitzScore XP',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFF57F17)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Blitz Challenge Card
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(20),
            child: Column(
              children: [
                const Text(
                  'Какая печатная буква соответствует этому описанию рукописи?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFA5D6A7)),
                  ),
                  child: Text(
                    '«${currentLetter.visualMnemonicRu}»',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B5E20),
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Штрих: ${currentLetter.strokeGuideRu}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'Выберите печатную букву:',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),

        // Options 2x2 Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: options.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.5,
          ),
          itemBuilder: (context, index) {
            final option = options[index];
            final isSelected = _blitzSelectedOption == index;
            final isCorrect = index == correctIndex;

            Color borderColor = theme.colorScheme.outlineVariant.withValues(alpha: 0.5);
            Color bgColor = theme.colorScheme.surface;

            if (_isBlitzAnswered) {
              if (isCorrect) {
                borderColor = const Color(0xFF2E7D32);
                bgColor = const Color(0xFF2E7D32).withValues(alpha: 0.12);
              } else if (isSelected) {
                borderColor = Colors.red;
                bgColor = Colors.red.withValues(alpha: 0.1);
              }
            }

            return Material(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: _isBlitzAnswered ? null : () => _onAnswerBlitz(index, correctIndex),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: borderColor,
                      width: isSelected || (_isBlitzAnswered && isCorrect) ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            option.printed,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                        ),
                        Text(
                          option.nameRussian,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        if (_isBlitzAnswered) ...[
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _nextBlitzQuestion,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Следующая буква ➔'),
          ),
        ],
      ],
    );
  }

  Widget _buildAtlasTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsetsDirectional.all(16),
      children: [
        // Top Info Callout
        Container(
          padding: const EdgeInsetsDirectional.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💡', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Зачем нужен Ктав Яд (כתב יד)?',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'В Израиле печатным шрифтом печатают книги, сайты и вывески. Но абсолютно все записки от руки, рецепты врачей, списки покупок и объявления в подъезде пишутся курсивом. Без него невозможно ориентироваться в быту!',
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'Таблица трансформации всех 22 букв и софитов:',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        for (final letter in CursiveLetterMap.entries) ...[
          _buildLetterAtlasTile(theme, letter),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildLetterAtlasTile(ThemeData theme, CursiveLetterEntry letter) {
    return Container(
      padding: const EdgeInsetsDirectional.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          // Letter Big Avatar
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: letter.isSofit
                  ? Colors.deepPurple.withValues(alpha: 0.12)
                  : theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                letter.printed,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: letter.isSofit ? Colors.deepPurple : theme.colorScheme.primary,
                  height: 1.25,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      letter.nameRussian,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 6),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        letter.nameHebrew,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          height: 1.45,
                        ),
                      ),
                    ),
                    if (letter.isSofit) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'СОФИТ',
                          style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  letter.visualMnemonicRu,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Пример: ${letter.sampleWordHebrew} (${letter.sampleWordTranslationRu})',
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Озвучить слово',
            icon: const Icon(Icons.volume_up_rounded, size: 20),
            onPressed: () {
              widget.audioService?.playWithTtsFallback(
                sourcePath: null,
                fallbackHebrewText: letter.sampleWordHebrew,
              );
            },
          ),
          IconButton(
            tooltip: 'В FSRS',
            icon: const Icon(Icons.bookmark_add_outlined, size: 20),
            onPressed: () => _addLetterToSrs(letter),
          ),
        ],
      ),
    );
  }
}
