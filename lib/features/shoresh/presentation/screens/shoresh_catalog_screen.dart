import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../data/repositories/shoresh_repository_impl.dart';
import '../../domain/entities/shoresh_entity.dart';
import '../../domain/repositories/shoresh_repository.dart';
import '../../domain/usecases/get_mastered_shoresh_roots_use_case.dart';
import '../../domain/usecases/get_shoresh_family_use_case.dart';
import '../../domain/usecases/get_shoresh_quiz_use_case.dart';
import '../../domain/usecases/get_shoresh_roots_use_case.dart';
import '../../domain/usecases/save_shoresh_mastery_use_case.dart';
import '../bloc/shoresh_bloc.dart';
import '../bloc/shoresh_event.dart';
import '../bloc/shoresh_state.dart';
import '../widgets/shoresh_root_card.dart';
import 'shoresh_detective_game_screen.dart';
import 'shoresh_family_screen.dart';

/// Catalog screen presenting all 35 Hebrew root families with filtering,
/// mastery indicators, and a shortcut to the Root Detective simulator.
class ShoreshCatalogScreen extends StatelessWidget {
  const ShoreshCatalogScreen({
    super.key,
    this.repository,
    this.bloc,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  final ShoreshRepository? repository;
  final ShoreshBloc? bloc;
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider.value(
        value: bloc!,
        child: _ShoreshCatalogView(
          audioService: audioService,
          addCardToSrsUseCase: addCardToSrsUseCase,
        ),
      );
    }

    final repo = repository ?? ShoreshRepositoryImpl();
    return BlocProvider(
      create: (_) => ShoreshBloc(
        getShoreshRootsUseCase: GetShoreshRootsUseCase(repo),
        getShoreshFamilyUseCase: GetShoreshFamilyUseCase(repo),
        getMasteredShoreshRootsUseCase: GetMasteredShoreshRootsUseCase(repo),
        getShoreshQuizUseCase: GetShoreshQuizUseCase(repo),
        saveShoreshMasteryUseCase: SaveShoreshMasteryUseCase(repo),
      )..add(const LoadShoreshCatalogEvent()),
      child: _ShoreshCatalogView(
        audioService: audioService,
        addCardToSrsUseCase: addCardToSrsUseCase,
      ),
    );
  }
}

class _ShoreshCatalogView extends StatefulWidget {
  const _ShoreshCatalogView({
    this.audioService,
    this.addCardToSrsUseCase,
  });

  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  @override
  State<_ShoreshCatalogView> createState() => _ShoreshCatalogViewState();
}

class _ShoreshCatalogViewState extends State<_ShoreshCatalogView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openRootDetail(BuildContext context, ShoreshRoot root) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<ShoreshBloc>(),
          child: ShoreshFamilyScreen(
            root: root,
            audioService: widget.audioService,
            addCardToSrsUseCase: widget.addCardToSrsUseCase,
          ),
        ),
      ),
    );
  }

  void _openDetectiveGame(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ShoreshDetectiveGameScreen(
          bloc: context.read<ShoreshBloc>(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Лаборатория корней'),
        actions: [
          BlocBuilder<ShoreshBloc, ShoreshState>(
            builder: (context, state) {
              final showNikkud =
                  state is ShoreshCatalogLoaded ? state.showNikkud : true;
              return IconButton(
                icon: Icon(
                  showNikkud
                      ? Icons.subtitles_rounded
                      : Icons.subtitles_off_rounded,
                ),
                tooltip: showNikkud ? 'Скрыть огласовки' : 'Показать огласовки',
                onPressed: () {
                  context
                      .read<ShoreshBloc>()
                      .add(const ToggleShoreshNikkudEvent());
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ShoreshBloc, ShoreshState>(
        builder: (context, state) {
          if (state is ShoreshLoading || state is ShoreshInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ShoreshError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: colorScheme.error),
              ),
            );
          }

          final loaded = state as ShoreshCatalogLoaded;
          final masteredCount = loaded.masteredRootIds.values
              .where((m) => m)
              .length;

          return CustomScrollView(
            slivers: [
              // Hero Banner with Detective CTA
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: _DetectiveLabBanner(
                    masteredCount: masteredCount,
                    totalRoots: loaded.allRoots.length,
                    onStartDetective: () => _openDetectiveGame(context),
                  ),
                ),
              ),

              // Search Box
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Поиск корня, значения или слова...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                context.read<ShoreshBloc>().add(
                                      const FilterShoreshCatalogEvent(
                                        searchQuery: '',
                                      ),
                                    );
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      context.read<ShoreshBloc>().add(
                            FilterShoreshCatalogEvent(searchQuery: val),
                          );
                    },
                  ),
                ),
              ),

              // Category Filter Chips
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 48,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: const Text('Все категории'),
                          selected: loaded.selectedCategory == null,
                          onSelected: (_) {
                            context.read<ShoreshBloc>().add(
                                  const FilterShoreshCatalogEvent(),
                                );
                          },
                        ),
                      ),
                      for (final category in loaded.categories)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category),
                            selected: loaded.selectedCategory == category,
                            onSelected: (selected) {
                              context.read<ShoreshBloc>().add(
                                    FilterShoreshCatalogEvent(
                                      category: selected ? category : null,
                                    ),
                                  );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Roots Grid
              if (loaded.filteredRoots.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'Корни не найдены. Попробуйте другой запрос.',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount =
                          constraints.crossAxisExtent >= 600 ? 3 : 2;
                      final childAspectRatio =
                          constraints.crossAxisExtent >= 600 ? 1.35 : 1.15;

                      return SliverGrid(
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: childAspectRatio,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final root = loaded.filteredRoots[index];
                            final isMastered =
                                loaded.masteredRootIds[root.id] == true;

                            return ShoreshRootCard(
                              root: root,
                              isMastered: isMastered,
                              onTap: () => _openRootDetail(context, root),
                            );
                          },
                          childCount: loaded.filteredRoots.length,
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DetectiveLabBanner extends StatelessWidget {
  const _DetectiveLabBanner({
    required this.masteredCount,
    required this.totalRoots,
    required this.onStartDetective,
  });

  final int masteredCount;
  final int totalRoots;
  final VoidCallback onStartDetective;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.tertiaryContainer.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                child: const Text('🔍', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Шореш-Детектив',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Освоено $masteredCount из $totalRoots корневых семейств',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimaryContainer
                            .withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            icon: const Icon(Icons.play_arrow_rounded, size: 20),
            label: const Text('Пройти квест «Раскрой корень»'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onStartDetective,
          ),
        ],
      ),
    );
  }
}
