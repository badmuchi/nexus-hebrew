import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/story.dart';
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
  });

  final AudioPlaybackService audioService;
  final AddCardToSrsUseCase addCardToSrsUseCase;

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
  });

  final List<Story> stories;
  final Set<String> completedIds;
  final String activeLevel;
  final ValueChanged<String> onFilterChanged;
  final AudioPlaybackService audioService;
  final AddCardToSrsUseCase addCardToSrsUseCase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
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
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider.value(
                    value: storiesCubit,
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
