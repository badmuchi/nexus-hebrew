import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/listening_exercise.dart';
import '../cubit/listening_cubit.dart';
import '../cubit/listening_state.dart';
import '../widgets/listening_player_card.dart';
import '../widgets/minimal_pairs_view.dart';
import '../widgets/word_puzzle_input_card.dart';

/// Hebrew audio comprehension & dictation screen with speed control and Tatoeba import.
class ListeningScreen extends StatefulWidget {
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const ListeningScreen({
    super.key,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen> {
  final TextEditingController _dictationController = TextEditingController();
  int _listeningModeIndex = 0;

  @override
  void dispose() {
    _dictationController.dispose();
    super.dispose();
  }

  Future<void> _showImportDialog(BuildContext context) async {
    final queryController = TextEditingController(text: 'עבודה');
    final cubit = context.read<ListeningCubit>();

    final confirmedQuery = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Импорт из Tatoeba (CC0/CC-BY)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Введи слово или тему на иврите — подтянем живые фразы с переводом и открытой озвучкой:',
              ),
              const SizedBox(height: 12),
              Directionality(
                textDirection: TextDirection.rtl,
                child: TextField(
                  controller: queryController,
                  textDirection: TextDirection.rtl,
                  decoration: const InputDecoration(
                    hintText: 'Например: קפה, שלום, ספר',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(queryController.text),
              child: const Text('Загрузить'),
            ),
          ],
        );
      },
    );

    queryController.dispose();

    if (confirmedQuery != null && confirmedQuery.trim().isNotEmpty) {
      await cubit.importFromTatoeba(confirmedQuery.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String appBarTitle = _listeningModeIndex == 0
        ? 'Аудирование · Диктант'
        : 'Аудирование · Минимальные пары';

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [
          BlocBuilder<ListeningCubit, ListeningState>(
            builder: (BuildContext context, ListeningState state) {
              final showNikkud =
                  state is ListeningLoaded ? state.showNikkud : true;
              final isImporting =
                  state is ListeningLoaded ? state.isImporting : false;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilterChip(
                    label: const Text('Огласовки'),
                    selected: showNikkud,
                    onSelected: state is ListeningLoaded
                        ? (_) => context.read<ListeningCubit>().toggleNikkud()
                        : null,
                  ),
                  const SizedBox(width: 4),
                  if (_listeningModeIndex == 0)
                    IconButton(
                      tooltip: 'Импорт из Tatoeba',
                      onPressed: (state is ListeningLoaded && !isImporting)
                          ? () => unawaited(_showImportDialog(context))
                          : null,
                      icon: isImporting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cloud_download_outlined),
                    ),
                ],
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 8),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment<int>(
                  value: 0,
                  icon: Icon(Icons.headphones_rounded),
                  label: Text('Диктанты'),
                ),
                ButtonSegment<int>(
                  value: 1,
                  icon: Icon(Icons.hearing_rounded),
                  label: Text('Минимальные пары'),
                ),
              ],
              selected: {_listeningModeIndex},
              onSelectionChanged: (Set<int> newSelection) {
                setState(() {
                  _listeningModeIndex = newSelection.first;
                });
              },
            ),
          ),
        ),
      ),
      body: BlocConsumer<ListeningCubit, ListeningState>(
        listenWhen: (ListeningState prev, ListeningState curr) =>
            curr is ListeningLoaded && curr.transientNotice != null,
        listener: (BuildContext context, ListeningState state) {
          if (state is ListeningLoaded && state.transientNotice != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.transientNotice!)),
            );
            context.read<ListeningCubit>().clearTransientNotice();
          }
        },
        builder: (BuildContext context, ListeningState state) {
          final showNikkud =
              state is ListeningLoaded ? state.showNikkud : true;
          if (_listeningModeIndex == 1) {
            return MinimalPairsView(
              audioService: widget.audioService,
              addCardToSrsUseCase: widget.addCardToSrsUseCase,
              showNikkud: showNikkud,
            );
          }

          switch (state) {
            case ListeningInitial():
            case ListeningLoading():
              return const Center(child: CircularProgressIndicator());
            case ListeningError(:final failure):
              return _ListeningErrorView(
                message: failure.message,
                onRetry: () =>
                    unawaited(context.read<ListeningCubit>().loadExercises()),
              );
            case ListeningLoaded():
              return _buildLoadedBody(context, theme, state);
          }
        },
      ),
    );
  }

  Widget _buildLoadedBody(
    BuildContext context,
    ThemeData theme,
    ListeningLoaded state,
  ) {
    final exercise = state.currentExercise;

    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 24),
      children: [
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ChoiceChip(
                  label: const Text('Все уровни'),
                  selected: state.selectedDifficulty == null,
                  onSelected: (_) {
                    _dictationController.clear();
                    unawaited(
                      context.read<ListeningCubit>().filterByDifficulty(null),
                    );
                  },
                ),
              ),
              ...ListeningDifficulty.values.map(
                (ListeningDifficulty tier) => Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ChoiceChip(
                    label: Text(tier.russianLabel),
                    selected: state.selectedDifficulty == tier,
                    onSelected: (_) {
                      _dictationController.clear();
                      unawaited(
                        context.read<ListeningCubit>().filterByDifficulty(tier),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (exercise == null)
          Card(
            child: Padding(
              padding: const EdgeInsetsDirectional.all(20),
              child: Text(
                'Для выбранного уровня пока нет аудиоупражнений.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          )
        else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton.outlined(
                tooltip: 'Предыдущее упражнение',
                onPressed: () {
                  _dictationController.clear();
                  unawaited(context.read<ListeningCubit>().previousExercise());
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                'Упражнение ${state.currentIndex + 1} из ${state.exercises.length}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton.outlined(
                tooltip: 'Следующее упражнение',
                onPressed: () {
                  _dictationController.clear();
                  unawaited(context.read<ListeningCubit>().nextExercise());
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ListeningPlayerCard(
            exercise: exercise,
            playbackSpeed: state.playbackSpeed,
            audioStatus: state.audioStatus,
            showFocusWordsHint: state.showFocusWordsHint,
            showTranscript: state.showTranscript,
            showNikkud: state.showNikkud,
            onTogglePlay: () =>
                unawaited(context.read<ListeningCubit>().togglePlayCurrent()),
            onSpeedChanged: (double speed) => unawaited(
              context.read<ListeningCubit>().setPlaybackSpeed(speed),
            ),
            onToggleFocusWords: () =>
                context.read<ListeningCubit>().toggleFocusWordsHint(),
            onToggleTranscript: () =>
                context.read<ListeningCubit>().toggleTranscriptReveal(),
            onSaveExerciseToSrs: () => unawaited(
              context.read<ListeningCubit>().saveExerciseToSrs(exercise),
            ),
            onSaveFocusWordToSrs: (String word) => unawaited(
              context.read<ListeningCubit>().saveFocusWordToSrs(exercise, word),
            ),
          ),
          const SizedBox(height: 14),
          WordPuzzleInputCard(
            exercise: exercise,
            showNikkud: state.showNikkud,
            answerMode: state.answerMode,
            comparison: state.lastComparison,
            audioService: widget.audioService,
            keyboardController: _dictationController,
            onModeChanged: context.read<ListeningCubit>().setAnswerMode,
            onSubmit: (String text) => unawaited(
              context.read<ListeningCubit>().submitDictation(text),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Источник: ${exercise.attribution.sourceName} (${exercise.attribution.licenseName})',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _ListeningErrorView extends StatelessWidget {
  const _ListeningErrorView({
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
