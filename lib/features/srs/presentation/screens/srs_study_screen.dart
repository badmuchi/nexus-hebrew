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
import '../widgets/audio_drill_config_sheet.dart';
import '../widgets/deck_import_dialog.dart';
import '../widgets/srs_flashcard_widget.dart';
import 'audio_drill_screen.dart';
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

  void _showDeckImportDialog(BuildContext context) {
    if (addCardToSrsUseCase == null) return;
    unawaited(
      DeckImportDialog.show(
        context,
        addCardToSrsUseCase: addCardToSrsUseCase!,
        onImportCompleted: () {
          unawaited(context.read<SrsSessionCubit>().loadDueCards());
        },
      ),
    );
  }

  Future<void> _openHandsFreePlayer(
      BuildContext context, SrsSessionState state) async {
    final activeCards = state is SrsSessionActive ? state.queue : <SrsCard>[];
    List<SrsCard> cardsToUse = List<SrsCard>.from(activeCards);
    if (cardsToUse.isEmpty) {
      final dictState = context.read<DictionaryCubit>().state;
      if (dictState is DictionaryLoaded) {
        cardsToUse = dictState.allEntries
            .map((e) => SrsCard(
                  id: e.id,
                  hebrew: e.hebrew,
                  russianTranslation: e.russianTranslation,
                  root: e.root,
                  binyan: e.binyan,
                  audioUrl: e.audioUrl,
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

    final config = await AudioDrillConfigSheet.show(context);
    if (config != null && context.mounted) {
      unawaited(AudioDrillScreen.launch(
        context,
        allCards: cardsToUse,
        audioService: audioService,
        initialConfig: config,
      ));
    }
  }

  void _openSpeedSprint(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SpeedSprintScreen(
          audioService: audioService,
          addCardToSrsUseCase: addCardToSrsUseCase,
        ),
      ),
    );
  }

  void _openMatchPairs(BuildContext context, SrsSessionState state) {
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
  }

  void _exportToAnki(BuildContext context, SrsSessionState state) {
    final activeCards =
        state is SrsSessionActive ? state.queue : <SrsCard>[];
    if (activeCards.isNotEmpty) {
      unawaited(
        AnkiExportDialog.showSrsExport(context, cards: activeCards),
      );
    } else {
      final dictState = context.read<DictionaryCubit>().state;
      if (dictState is DictionaryLoaded && dictState.allEntries.isNotEmpty) {
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
                tooltip: 'Hands-Free аудиотренажер 🎧',
                icon: const Icon(Icons.headphones_rounded),
                onPressed: () => _openHandsFreePlayer(context, state),
              ),
              if (isImporting)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Center(
                    child: SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(strokeWidth: 2.0),
                    ),
                  ),
                )
              else
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  tooltip: 'Дополнительные режимы и инструменты',
                  onSelected: (value) {
                    switch (value) {
                      case 'sprint':
                        _openSpeedSprint(context);
                        break;
                      case 'pairs':
                        _openMatchPairs(context, state);
                        break;
                      case 'hands_free':
                        _openHandsFreePlayer(context, state);
                        break;
                      case 'import_tatoeba':
                        unawaited(_showTatoebaImportDialog(context));
                        break;
                      case 'import_deck':
                        _showDeckImportDialog(context);
                        break;
                      case 'export_anki':
                        _exportToAnki(context, state);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'sprint',
                      child: Row(
                        children: [
                          Icon(Icons.bolt_rounded, color: Colors.amber),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Блиц-спринт',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '60 сек на реакцию',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'pairs',
                      child: Row(
                        children: [
                          Icon(Icons.grid_view_rounded, color: Colors.purpleAccent),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Быстрые пары',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Мини-игра на сопоставление',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'hands_free',
                      child: Row(
                        children: [
                          Icon(Icons.headphones_rounded, color: Colors.blueAccent),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Иврит на ходу',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Аудиоплеер без экрана',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'import_tatoeba',
                      child: Row(
                        children: [
                          Icon(Icons.cloud_download_rounded, color: Colors.teal),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Фразы из Tatoeba',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Импорт живых фраз',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'import_deck',
                      child: Row(
                        children: [
                          Icon(Icons.file_download_rounded, color: Colors.deepPurple),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Импорт колоды',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Anki TSV / CSV / JSON',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'export_anki',
                      child: Row(
                        children: [
                          Icon(Icons.download_for_offline_outlined, color: Colors.indigo),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Экспорт в Anki',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'TSV/CSV файл колоды',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                  onImportDeck: addCardToSrsUseCase != null
                      ? () => _showDeckImportDialog(context)
                      : null,
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
  final VoidCallback? onImportDeck;
  final VoidCallback onStartSprint;
  final VoidCallback onStartHandsFree;

  const _SrsEmptyBody({
    required this.reviewedCount,
    required this.isImporting,
    required this.onRefresh,
    required this.onImportTatoeba,
    this.onImportDeck,
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
            if (onImportDeck != null) ...[
              const SizedBox(height: 10.0),
              FilledButton.tonalIcon(
                onPressed: onImportDeck,
                icon: const Icon(Icons.file_download_rounded),
                label: const Text('Импортировать свою колоду (Anki/JSON)'),
              ),
            ],
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
