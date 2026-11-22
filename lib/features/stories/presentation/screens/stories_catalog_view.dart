import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/database/app_database.dart';
import '../../../dictionary/presentation/cubit/dictionary_cubit.dart';
import '../../../grammar/presentation/cubit/grammar_cubit.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/story.dart';
import '../../domain/services/weak_words_story_generator.dart';
import '../cubit/stories_cubit.dart';
import '../cubit/stories_state.dart';
import '../widgets/custom_text_importer_sheet.dart';
import '../widgets/story_card.dart';
import 'story_reader_screen.dart';

class StoriesCatalogView extends StatelessWidget {
  const StoriesCatalogView({
    super.key,
    required this.audioService,
    required this.addCardToSrsUseCase,
    this.database,
  });

  final AudioPlaybackService audioService;
  final AddCardToSrsUseCase addCardToSrsUseCase;
  final AppDatabase? database;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoriesCubit, StoriesState>(
      builder: (context, state) {
        final cubit = context.read<StoriesCubit>();

        return switch (state) {
          StoriesInitial() || StoriesLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
          StoriesError(:final message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: cubit.loadStories,
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            ),
          StoriesLoaded(
            :final visibleStories,
            :final completedStoryIds,
            :final activeLevelFilter,
          ) =>
            _CatalogContent(
              stories: visibleStories,
              completedIds: completedStoryIds,
              activeLevel: activeLevelFilter,
              onFilterChanged: cubit.setLevelFilter,
              audioService: audioService,
              addCardToSrsUseCase: addCardToSrsUseCase,
              database: database,
            ),
        };
      },
    );
  }
}

class _CatalogContent extends StatelessWidget {
  const _CatalogContent({
    required this.stories,
    required this.completedIds,
    required this.activeLevel,
    required this.onFilterChanged,
    required this.audioService,
    required this.addCardToSrsUseCase,
    this.database,
  });

  final List<Story> stories;
  final Set<String> completedIds;
  final String activeLevel;
  final ValueChanged<String> onFilterChanged;
  final AudioPlaybackService audioService;
  final AddCardToSrsUseCase addCardToSrsUseCase;
  final AppDatabase? database;

  Future<void> _generateAndOpenFsrsStory(BuildContext context) async {
    List<WeakWordTarget> weakWords;
    try {
      if (database != null) {
        final cards = await database!.getAllSrsCards();
        weakWords = WeakWordsStoryGenerator.extractWeakWords(cards);
      } else {
        weakWords = WeakWordsStoryGenerator.extractWeakWords(const []);
      }
    } catch (_) {
      weakWords = WeakWordsStoryGenerator.extractWeakWords(const []);
    }

    final story = WeakWordsStoryGenerator.generateStory(weakWords: weakWords);
    if (!context.mounted) return;

    final storiesCubit = context.read<StoriesCubit>();
    DictionaryCubit? dictCubit;
    GrammarCubit? grammarCubit;
    try {
      dictCubit = context.read<DictionaryCubit>();
    } catch (_) {}
    try {
      grammarCubit = context.read<GrammarCubit>();
    } catch (_) {}

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: storiesCubit),
            if (dictCubit != null) BlocProvider.value(value: dictCubit),
            if (grammarCubit != null) BlocProvider.value(value: grammarCubit),
          ],
          child: StoryReaderScreen(
            story: story,
            audioService: audioService,
            addCardToSrsUseCase: addCardToSrsUseCase,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        // FSRS Weak Words Smart Story Generator Card
        Card(
          elevation: 0,
          color: (isDark ? Colors.amber.shade900 : Colors.amber.shade100)
              .withValues(alpha: isDark ? 0.25 : 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: Colors.amber.withValues(alpha: 0.4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('🪄', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Персональный рассказ FSRS',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Адаптивный сюжет на базе ваших трудных слов из памяти',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: () => _generateAndOpenFsrsStory(context),
                  child: const Text('Создать'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Custom text / news importer action
        Card(
          elevation: 0,
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.auto_stories_rounded,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Умная читалка любого текста',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Вставь новость, пост или песню с разбором',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonal(
                  onPressed: () => showCustomTextImporterSheet(
                    context: context,
                    audioService: audioService,
                    addCardToSrsUseCase: addCardToSrsUseCase,
                  ),
                  child: const Text('Вставить'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Level filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: const Text('Все уровни'),
                selected: activeLevel == 'all',
                onSelected: (_) => onFilterChanged('all'),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('A1 · Начальный'),
                selected: activeLevel == 'A1',
                onSelected: (_) => onFilterChanged('A1'),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('A2 · Продолжающий'),
                selected: activeLevel == 'A2',
                onSelected: (_) => onFilterChanged('A2'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Progress header
        Row(
          children: [
            Text(
              'Рассказы (${stories.length})',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.check_circle_outline_rounded,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              'Прочитано: ${completedIds.length}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Cards
        for (final story in stories)
          StoryCard(
            story: story,
            isCompleted: completedIds.contains(story.id),
            onTap: () {
              final storiesCubit = context.read<StoriesCubit>();
              DictionaryCubit? dictCubit;
              GrammarCubit? grammarCubit;
              try {
                dictCubit = context.read<DictionaryCubit>();
              } catch (_) {}
              try {
                grammarCubit = context.read<GrammarCubit>();
              } catch (_) {}

              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: storiesCubit),
                      if (dictCubit != null) BlocProvider.value(value: dictCubit),
                      if (grammarCubit != null)
                        BlocProvider.value(value: grammarCubit),
                    ],
                    child: StoryReaderScreen(
                      story: story,
                      audioService: audioService,
                      addCardToSrsUseCase: addCardToSrsUseCase,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
