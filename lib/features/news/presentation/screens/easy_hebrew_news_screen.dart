import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../data/datasources/easy_hebrew_news_seed_data.dart';
import '../../domain/entities/easy_hebrew_article.dart';
import '../widgets/word_lookup_sheet.dart';

/// Interactive adapted news reader in easy Hebrew (Israel Kan Reka format)
/// with Nikkud toggle, audio read-aloud, and word-by-word instant lookup.
class EasyHebrewNewsScreen extends StatefulWidget {
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const EasyHebrewNewsScreen({
    super.key,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  @override
  State<EasyHebrewNewsScreen> createState() => _EasyHebrewNewsScreenState();
}

class _EasyHebrewNewsScreenState extends State<EasyHebrewNewsScreen> {
  final List<EasyHebrewArticle> _allArticles = EasyHebrewNewsSeedData.articles;
  NewsCategory? _selectedCategory;
  EasyHebrewArticle? _selectedArticle;

  bool _showNikkud = true;
  bool _showTranslations = true;
  int? _activePlayingParagraphIndex;

  List<EasyHebrewArticle> get _filteredArticles {
    if (_selectedCategory == null) return _allArticles;
    return _allArticles.where((a) => a.category == _selectedCategory).toList();
  }

  void _openArticle(EasyHebrewArticle article) {
    unawaited(HapticFeedback.lightImpact());
    setState(() {
      _selectedArticle = article;
      _activePlayingParagraphIndex = null;
    });
  }

  void _closeArticle() {
    unawaited(HapticFeedback.lightImpact());
    setState(() {
      _selectedArticle = null;
      _activePlayingParagraphIndex = null;
    });
  }

  Future<void> _playParagraphAudio(NewsParagraph paragraph) async {
    setState(() => _activePlayingParagraphIndex = paragraph.index);
    if (widget.audioService != null) {
      await widget.audioService!.playWithTtsFallback(
        sourcePath: paragraph.audioPath,
        fallbackHebrewText: paragraph.hebrewWithNikkud,
      );
    }
  }

  void _showWordLookup(NewsWordVocabulary vocab) {
    unawaited(HapticFeedback.selectionClick());
    WordLookupSheet.show(
      context: context,
      wordHebrewWithNikkud: vocab.hebrewWithNikkud,
      wordHebrewNormalized: vocab.hebrewNormalized,
      translationRu: vocab.translationRu,
      root: vocab.root,
      audioService: widget.audioService,
      addCardToSrsUseCase: widget.addCardToSrsUseCase,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedArticle != null
              ? _selectedArticle!.category.titleRu
              : 'Новости на лёгком иврите',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: _selectedArticle != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _closeArticle,
              )
            : null,
        actions: [
          IconButton(
            tooltip: _showNikkud ? 'Скрыть огласовки' : 'Показать огласовки',
            icon: Icon(
              _showNikkud ? Icons.visibility_rounded : Icons.visibility_off_rounded,
            ),
            onPressed: () => setState(() => _showNikkud = !_showNikkud),
          ),
          if (_selectedArticle != null)
            IconButton(
              tooltip: _showTranslations ? 'Скрыть перевод' : 'Показать перевод',
              icon: Icon(
                _showTranslations
                    ? Icons.translate_rounded
                    : Icons.g_translate_outlined,
              ),
              onPressed: () =>
                  setState(() => _showTranslations = !_showTranslations),
            ),
        ],
      ),
      body: _selectedArticle != null
          ? _buildArticleReaderView(_selectedArticle!)
          : _buildArticleFeedView(),
    );
  }

  // ---------------------------------------------------------------------------
  // Feed View
  // ---------------------------------------------------------------------------
  Widget _buildArticleFeedView() {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Text('📰 ', style: TextStyle(fontSize: 28)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'חֲדָשׁוֹת בְּעִבְרִית קַלָּה',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Актуальные события Израиля, адаптированные для уровней Алеф и Бет со звуком и всплывающим словарем.',
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
            const SizedBox(height: 14),

            // Category Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('Все новости'),
                      selected: _selectedCategory == null,
                      onSelected: (_) => setState(() => _selectedCategory = null),
                    ),
                  ),
                  for (final cat in NewsCategory.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        avatar: Text(cat.iconEmoji),
                        label: Text(cat.titleRu),
                        selected: _selectedCategory == cat,
                        onSelected: (_) => setState(() => _selectedCategory = cat),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Article Cards
            for (final article in _filteredArticles) ...[
              _buildArticleCard(theme, article),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildArticleCard(ThemeData theme, EasyHebrewArticle article) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openArticle(article),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top tags row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(article.category.iconEmoji, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        article.category.titleRu,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Text(
                          article.readingLevelRu,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '⏱ ${article.readingMinutes} мин',
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Hebrew Title
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  _showNikkud
                      ? article.titleHebrewWithNikkud
                      : article.titleHebrewNormalized,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Russian Title
              Text(
                article.titleRu,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),

              // Summary
              Text(
                article.summaryRu,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Article Reader View
  // ---------------------------------------------------------------------------
  Widget _buildArticleReaderView(EasyHebrewArticle article) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Metadata header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(article.category.iconEmoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      article.dateString,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Уровень: ${article.readingLevelRu}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Main Title
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                _showNikkud
                    ? article.titleHebrewWithNikkud
                    : article.titleHebrewNormalized,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              article.titleRu,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Paragraphs
            for (final p in article.paragraphs) ...[
              _buildParagraphTile(theme, p),
              const SizedBox(height: 14),
            ],

            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 12),

            // Vocabulary Section
            _buildVocabularySection(theme, article.vocabulary),
          ],
        ),
      ),
    );
  }

  Widget _buildParagraphTile(ThemeData theme, NewsParagraph p) {
    final isPlaying = _activePlayingParagraphIndex == p.index;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isPlaying
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.25)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPlaying
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: isPlaying ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '§ ${p.index + 1}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              if (widget.audioService != null)
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause_circle_rounded : Icons.play_circle_fill_rounded,
                    color: isPlaying ? theme.colorScheme.primary : Colors.grey.shade700,
                  ),
                  tooltip: 'Озвучить абзац',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _playParagraphAudio(p),
                ),
            ],
          ),
          const SizedBox(height: 4),

          // Hebrew Paragraph Text
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              _showNikkud ? p.hebrewWithNikkud : p.hebrewNormalized,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),

          if (_showTranslations) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                p.translationRu,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVocabularySection(
    ThemeData theme,
    List<NewsWordVocabulary> vocabulary,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text('📚 ', style: TextStyle(fontSize: 20)),
            Text(
              'Словарь статьи (нажмите для перевода и FSRS)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: vocabulary.map((vocab) {
            return ActionChip(
              avatar: const Text('🌱', style: TextStyle(fontSize: 12)),
              label: Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  _showNikkud ? vocab.hebrewWithNikkud : vocab.hebrewNormalized,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ),
              onPressed: () => _showWordLookup(vocab),
            );
          }).toList(),
        ),
      ],
    );
  }
}
