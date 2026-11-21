import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/shoresh_entity.dart';
import '../bloc/shoresh_bloc.dart';
import '../bloc/shoresh_event.dart';
import '../bloc/shoresh_state.dart';
import '../widgets/shoresh_derivative_tile.dart';
import 'shoresh_detective_game_screen.dart';

/// Screen displaying the complete morphological family tree for a single Hebrew root.
class ShoreshFamilyScreen extends StatefulWidget {
  const ShoreshFamilyScreen({
    super.key,
    required this.root,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  final ShoreshRoot root;
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  @override
  State<ShoreshFamilyScreen> createState() => _ShoreshFamilyScreenState();
}

class _ShoreshFamilyScreenState extends State<ShoreshFamilyScreen> {
  ShoreshPartOfSpeech? _filterPartOfSpeech;

  void _onAddToSrs(ShoreshDerivative derivative) async {
    final useCase = widget.addCardToSrsUseCase;
    if (useCase == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final res = await useCase(
      AddCardToSrsParams(
        id: 'shoresh_${derivative.id}',
        hebrewVocalized: derivative.hebrewVocalized,
        russianTranslation: derivative.russianMeaning,
        exampleHebrewVocalized: derivative.exampleSentenceHebrew,
        exampleRussian: derivative.exampleSentenceRussian,
      ),
    );

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          res.isSuccess
              ? 'Слово "${derivative.hebrewVocalized}" добавлено в SRS-карточки!'
              : 'Не удалось добавить слово',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onPlayAudio(ShoreshDerivative derivative) async {
    final service = widget.audioService;
    if (service != null) {
      await service.playWithTtsFallback(
        sourcePath: derivative.audioPath,
        fallbackHebrewText: derivative.hebrewVocalized,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final filteredDerivatives = _filterPartOfSpeech == null
        ? widget.root.derivatives
        : widget.root.derivatives
            .where((d) => d.partOfSpeech == _filterPartOfSpeech)
            .toList();

    return BlocBuilder<ShoreshBloc, ShoreshState>(
      builder: (context, state) {
        final showNikkud = state is ShoreshCatalogLoaded ? state.showNikkud : true;

        return Scaffold(
          appBar: AppBar(
            title: Text('Семья корня ${widget.root.lettersDisplay}'),
            actions: [
              IconButton(
                icon: Icon(
                  showNikkud
                      ? Icons.subtitles_rounded
                      : Icons.subtitles_off_rounded,
                ),
                tooltip: showNikkud ? 'Скрыть огласовки' : 'Показать огласовки',
                onPressed: () {
                  context.read<ShoreshBloc>().add(const ToggleShoreshNikkudEvent());
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Root Banner Card
              _RootBannerCard(root: widget.root),
              const SizedBox(height: 16),

              // Filter Chips by Part of Speech
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('Все слова'),
                      selected: _filterPartOfSpeech == null,
                      onSelected: (_) {
                        setState(() => _filterPartOfSpeech = null);
                      },
                    ),
                    const SizedBox(width: 8),
                    for (final pos in ShoreshPartOfSpeech.values) ...[
                      if (widget.root.derivatives.any((d) => d.partOfSpeech == pos)) ...[
                        FilterChip(
                          avatar: Text(pos.emoji),
                          label: Text(pos.labelRu),
                          selected: _filterPartOfSpeech == pos,
                          onSelected: (selected) {
                            setState(() {
                              _filterPartOfSpeech = selected ? pos : null;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Section Header
              Text(
                'Производные слова (${filteredDerivatives.length}):',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              // Derivatives List
              for (final derivative in filteredDerivatives)
                ShoreshDerivativeTile(
                  derivative: derivative,
                  showNikkud: showNikkud,
                  onAddToSrs: widget.addCardToSrsUseCase != null
                      ? () => _onAddToSrs(derivative)
                      : null,
                  onPlayAudio: widget.audioService != null
                      ? () => _onPlayAudio(derivative)
                      : null,
                ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: FilledButton.icon(
                icon: const Icon(Icons.psychology_rounded),
                label: const Text('Тренировать корень в детектив-квизе'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ShoreshDetectiveGameScreen(
                        bloc: context.read<ShoreshBloc>(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RootBannerCard extends StatelessWidget {
  const _RootBannerCard({required this.root});

  final ShoreshRoot root;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                root.lettersDisplay,
                textDirection: TextDirection.rtl,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: colorScheme.primary,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  root.categoryRu,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            root.primaryMeaningRu,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    root.culturalNoteRu,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
