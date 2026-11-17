import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../dictionary/presentation/cubit/dictionary_cubit.dart';
import '../../../dictionary/presentation/cubit/dictionary_state.dart';
import '../../domain/entities/fsrs_models.dart';
import '../../domain/entities/srs_card.dart';
import '../../domain/usecases/add_card_to_srs.dart';
import '../cubit/srs_session_cubit.dart';
import '../cubit/srs_session_state.dart';
import '../widgets/anki_export_dialog.dart';
import '../widgets/srs_flashcard_widget.dart';
import 'hands_free_player_screen.dart';
import 'match_pairs_screen.dart';
import 'speed_sprint_screen.dart';

class SrsStudyScreen extends StatelessWidget {
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const SrsStudyScreen({
    super.key,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  Future<void> _showTatoebaImportDialog(BuildContext context) async {
    final cubit = context.read<SrsSessionCubit>();
    final controller = TextEditingController(text: 'קפה');
    final query = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Импорт из Tatoeba (CC-BY)'),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: TextField(
            controller: controller,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              labelText: 'Слово на иврите (например שלום / קפה)',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Загрузить'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (query != null && query.trim().isNotEmpty) {
      await cubit.importFromTatoeba(query);
    }
  }

  void _openHandsFreePlayer(BuildContext context, SrsSessionState state) {
    final List<HandsFreeItem> items = [];
    if (state is SrsSessionActive) {
      for (final c in state.queue) {
        items.add(HandsFreeItem.fromSrsCard(c));
      }
    }
    if (items.isEmpty) {
      final dictState = context.read<DictionaryCubit>().state;
      if (dictState is DictionaryLoaded) {
        for (final entry in dictState.allEntries.take(30)) {
          items.add(
            HandsFreeItem(
              id: entry.id,
              hebrewVocalized: entry.hebrew.vocalized,
              hebrewNormalized: entry.hebrew.normalized,
              russianTranslation: entry.russianTranslation,
              audioUrl: entry.audioUrl,
              transliteration: entry.transliteration,
            ),
          );
        }
      }
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HandsFreePlayerScreen(
          items: items,
          audioService: audioService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SrsSessionCubit, SrsSessionState>(
      listenWhen: (previous, current) {
        final nextNotice = switch (current) {
          SrsSessionActive(:final transientNotice) => transientNotice,
          SrsSessionEmpty(:final transientNotice) => transientNotice,
          _ => null,
        };
        final prevNotice = switch (previous) {
          SrsSessionActive(:final transientNotice) => transientNotice,
          SrsSessionEmpty(:final transientNotice) => transientNotice,
          _ => null,
        };
        return nextNotice != null && nextNotice != prevNotice;
      },
      listener: (context, state) {
        final notice = switch (state) {
          SrsSessionActive(:final transientNotice) => transientNotice,
          SrsSessionEmpty(:final transientNotice) => transientNotice,
          _ => null,
        };
        if (notice != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(notice)));
          context.read<SrsSessionCubit>().clearTransientNotice();
        }
      },
      builder: (context, state) {
        final cubit = context.read<SrsSessionCubit>();
        final activeState = state is SrsSessionActive ? state : null;
        final isImporting = switch (state) {
          SrsSessionActive(:final isImporting) => isImporting,
          SrsSessionEmpty(:final isImporting) => isImporting,
          _ => false,
        };

        return Scaffold(
          appBar: AppBar(
            title: Text(
              activeState == null
                  ? 'FSRS Повторение'
                  : 'FSRS (${activeState.remainingCount} осталось)',
            ),
            actions: [
              if (activeState != null) ...[
                IconButton(
                  onPressed: cubit.toggleStudyMode,
                  tooltip: activeState.studyMode == SrsStudyMode.flashcard
                      ? 'Режим ввода на иврите'
                      : 'Режим карточки',
                  icon: Icon(
                    activeState.studyMode == SrsStudyMode.flashcard
                        ? Icons.keyboard_rounded
                        : Icons.style_rounded,
                  ),
                ),
                IconButton(
                  onPressed: cubit.toggleNikkudVisibility,
                  tooltip: activeState.showNikkud
                      ? 'Скрыть огласовки'
                      : 'Показать огласовки',
                  icon: Icon(
                    activeState.showNikkud
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                  ),
                ),
              ],
              IconButton(
                onPressed: () => _openHandsFreePlayer(context, state),
                tooltip: 'Иврит на ходу (Аудио)',
                icon: const Icon(Icons.headphones_rounded),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SpeedSprintScreen(
                        audioService: audioService,
                        addCardToSrsUseCase: addCardToSrsUseCase,
                      ),
                    ),
                  );
                },
                tooltip: 'Блиц-спринт (60 сек)',
                icon: const Icon(Icons.bolt_rounded, color: Colors.amber),
              ),
              IconButton(
                onPressed: () {
                  final activeCards =
                      state is SrsSessionActive ? state.queue : <SrsCard>[];
                  List<SrsCard> cardsToUse = activeCards;
                  if (cardsToUse.isEmpty) {
                    final dictState = context.read<DictionaryCubit>().state;
                    if (dictState is DictionaryLoaded) {
                      cardsToUse = dictState.allEntries
                          .map((e) => SrsCard(
                                id: e.id,
                                hebrew: e.hebrew,
                                russianTranslation: e.russianTranslation,
                                memory: FsrsMemoryState.initial(
                                  now: DateTime.now().toUtc(),
                                ),
                                attribution: const ContentAttribution(
                                  sourceName: 'Dictionary',
                                  licenseName: 'CC-BY',
                                ),
                              ))
                          .toList();
                    }
                  }

                  if (cardsToUse.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Слова загружаются, попробуйте через секунду'),
                      ),
                    );
                    return;
                  }

                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MatchPairsScreen(
                        cards: cardsToUse,
                        audioService: audioService,
                      ),
                    ),
                  );
                },
                tooltip: 'Быстрые пары (Мини-игра)',
                icon: const Icon(Icons.grid_view_rounded, color: Colors.purpleAccent),
              ),
              IconButton(
                onPressed: () {
                  final activeCards =
                      state is SrsSessionActive ? state.queue : <SrsCard>[];
                  if (activeCards.isNotEmpty) {
                    unawaited(
                      AnkiExportDialog.showSrsExport(context, cards: activeCards),
                    );
                  } else {
                    final dictState = context.read<DictionaryCubit>().state;
                    if (dictState is DictionaryLoaded &&
                        dictState.allEntries.isNotEmpty) {
                      unawaited(
                        AnkiExportDialog.showDictionaryExport(
                          context,
                          entries: dictState.allEntries,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Нет доступных карточек для экспорта'),
                        ),
                      );
                    }
                  }
                },
                tooltip: 'Экспорт в Anki (TSV/CSV)',
                icon: const Icon(Icons.download_for_offline_outlined),
              ),
              IconButton(
                onPressed: isImporting
                    ? null
                    : () => unawaited(_showTatoebaImportDialog(context)),
                tooltip: 'Подгрузить фразы из Tatoeba',
                icon: isImporting
                    ? const SizedBox(
                        width: 20.0,
                        height: 20.0,
                        child: CircularProgressIndicator(strokeWidth: 2.0),
                      )
                    : const Icon(Icons.cloud_download_rounded),
              ),
            ],
          ),
          body: SafeArea(
            child: switch (state) {
              SrsSessionInitial() || SrsSessionLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
              SrsSessionError(:final failure) => _SrsErrorBody(
                  message: failure.message,
                  onRetry: () => unawaited(cubit.loadDueCards()),
                ),
              SrsSessionEmpty(:final reviewedCount, :final isImporting) =>
                _SrsEmptyBody(
                  reviewedCount: reviewedCount,
                  isImporting: isImporting,
                  onRefresh: () => unawaited(cubit.loadDueCards()),
                  onImportTatoeba: () =>
                      unawaited(_showTatoebaImportDialog(context)),
                  onStartSprint: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => SpeedSprintScreen(
                          audioService: audioService,
                          addCardToSrsUseCase: addCardToSrsUseCase,
                        ),
                      ),
                    );
                  },
                  onStartHandsFree: () => _openHandsFreePlayer(context, state),
                ),
              SrsSessionActive() => SrsFlashcardWidget(
                  card: state.currentCard,
                  studyMode: state.studyMode,
                  isAnswerRevealed: state.isAnswerRevealed,
                  showNikkud: state.showNikkud,
                  typingEvaluation: state.typingEvaluation,
                  intervalPreview: state.intervalPreview,
                  audioStatus: state.audioStatus,
                  isSubmittingReview: state.isSubmittingReview,
                  onRevealAnswer: cubit.revealAnswer,
                  onSubmitTypedAnswer: cubit.submitTypedAnswer,
                  onRateCard: (rating) => unawaited(cubit.rateCard(rating)),
                  onPlayAudio: () => unawaited(cubit.playCurrentCardAudio()),
                ),
            },
          ),
        );
      },
    );
  }
}

class _SrsEmptyBody extends StatelessWidget {
  final int reviewedCount;
  final bool isImporting;
  final VoidCallback onRefresh;
  final VoidCallback onImportTatoeba;
  final VoidCallback onStartSprint;
  final VoidCallback onStartHandsFree;

  const _SrsEmptyBody({
    required this.reviewedCount,
    required this.isImporting,
    required this.onRefresh,
    required this.onImportTatoeba,
    required this.onStartSprint,
    required this.onStartHandsFree,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.task_alt_rounded,
              size: 56.0,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12.0),
            Text(
              'На сегодня все карточки пройдены!',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            if (reviewedCount > 0) ...[
              const SizedBox(height: 6.0),
              Text(
                'Повторено за сессию: $reviewedCount',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 20.0),
            FilledButton.tonalIcon(
              onPressed: onStartSprint,
              icon: const Icon(Icons.bolt_rounded),
              label: const Text('Размяться в Блиц-спринте (60 сек)'),
            ),
            const SizedBox(height: 10.0),
            FilledButton.icon(
              onPressed: isImporting ? null : onImportTatoeba,
              icon: const Icon(Icons.cloud_download_rounded),
              label: const Text('Подгрузить фразы из Tatoeba'),
            ),
            const SizedBox(height: 10.0),
            OutlinedButton.icon(
              onPressed: onStartHandsFree,
              icon: const Icon(Icons.headphones_rounded),
              label: const Text('Слушать на ходу (Аудио)'),
            ),
            const SizedBox(height: 10.0),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Проверить очередь снова'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SrsErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _SrsErrorBody({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.0,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 12.0),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16.0),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}
