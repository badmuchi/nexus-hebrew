import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../dictionary/domain/entities/dictionary_entry.dart';
import '../../../dictionary/presentation/cubit/dictionary_cubit.dart';
import '../../../dictionary/presentation/cubit/dictionary_state.dart';
import '../../../grammar/domain/entities/verb_conjugation.dart';
import '../../../grammar/presentation/cubit/grammar_cubit.dart';
import '../../../grammar/presentation/cubit/grammar_state.dart';
import '../../../morphology/presentation/widgets/sentence_xray_sheet.dart';
import '../../../slang/data/datasources/slang_seed_datasource.dart';
import '../../../slang/data/repositories/slang_repository_impl.dart';
import '../../../slang/domain/usecases/get_slang_expressions.dart';
import '../../../slang/presentation/screens/slang_screen.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../../srs/presentation/cubit/srs_session_cubit.dart';
import '../../../srs/presentation/cubit/srs_session_state.dart';
import '../../../stories/presentation/screens/stories_catalog_view.dart';
import '../../domain/entities/dialogue_node.dart';
import '../../domain/entities/dialogue_scenario_info.dart';
import '../cubit/conversation_cubit.dart';
import '../cubit/conversation_state.dart';
import '../widgets/dialogue_bubble.dart';
import '../widgets/dialogue_history_sheet.dart';
import '../widgets/scenario_catalog_sheet.dart';

class ConversationScreen extends StatefulWidget {
  static const String initialNodeId = 'node_market_start';

  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const ConversationScreen({
    super.key,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  int _activeTabIndex = 0; // 0: Диалоги, 1: Истории
  String _selectedScenarioId = ConversationScreen.initialNodeId;
  String? _selectedCategory;
  final List<DialogueNode> _sessionHistory = [];

  void _onScenarioSelected(String scenarioId) {
    if (_selectedScenarioId == scenarioId) return;
    setState(() {
      _selectedScenarioId = scenarioId;
      _sessionHistory.clear();
    });
    context.read<ConversationCubit>().loadDialogueNode(
          scenarioId,
          resetHistory: true,
        );
  }

  void _openScenarioCatalog() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ScenarioCatalogSheet(
        activeScenarioId: _selectedScenarioId,
        onSelectScenario: _onScenarioSelected,
      ),
    );
  }

  void _openDialogueHistory(DialogueNode activeNode, bool showNikkud) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DialogueHistorySheet(
        historyNodes: _sessionHistory,
        activeNode: activeNode,
        showNikkud: showNikkud,
        audioService: widget.audioService,
      ),
    );
  }

  String _currentScenarioLabel() {
    for (final s in DialogueScenarioInfo.allScenarios) {
      if (s.id == _selectedScenarioId) return '${s.emoji} ${s.titleRussian}';
    }
    return 'Диалог';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConversationCubit, ConversationState>(
      listenWhen: (previous, current) =>
          current is ConversationLoaded &&
          current.transientNotice != null &&
          (previous is! ConversationLoaded ||
              previous.transientNotice != current.transientNotice),
      listener: (context, state) {
        if (state is ConversationLoaded && state.transientNotice != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.transientNotice!)),
            );
          context.read<ConversationCubit>().clearTransientNotice();
        }
      },
      builder: (context, state) {
        final theme = Theme.of(context);
        final cubit = context.read<ConversationCubit>();
        final loadedState = state is ConversationLoaded ? state : null;

        if (loadedState != null) {
          if (loadedState.navigationHistory.isEmpty &&
              _sessionHistory.isNotEmpty &&
              _sessionHistory.first.id != loadedState.activeNode.id) {
            _sessionHistory.clear();
          }
          if (_sessionHistory.isEmpty ||
              _sessionHistory.last.id != loadedState.activeNode.id) {
            if (!_sessionHistory.any((n) => n.id == loadedState.activeNode.id)) {
              _sessionHistory.add(loadedState.activeNode);
            }
          }
        }

        final filteredScenarios = _selectedCategory == null ||
                _selectedCategory == 'Все'
            ? DialogueScenarioInfo.allScenarios
            : DialogueScenarioInfo.allScenarios
                .where((s) => s.category == _selectedCategory)
                .toList(growable: false);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              _activeTabIndex == 0 ? _currentScenarioLabel() : 'Читалка историй',
            ),
            leading: _activeTabIndex == 0 &&
                    loadedState != null &&
                    loadedState.canGoBack
                ? IconButton(
                    onPressed: () {
                      if (_sessionHistory.length > 1) {
                        _sessionHistory.removeLast();
                      }
                      cubit.navigateBack();
                    },
                    tooltip: 'Назад по диалогу',
                    icon: const Icon(Icons.arrow_back),
                  )
                : null,
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SlangScreen(
                        getSlangUseCase: GetSlangExpressionsUseCase(
                          SlangRepositoryImpl(
                            dataSource: AssetSlangSeedDataSource(
                              logger: const DeveloperAppLogger(),
                            ),
                          ),
                        ),
                        audioService: widget.audioService,
                        addCardToSrsUseCase: widget.addCardToSrsUseCase,
                      ),
                    ),
                  );
                },
                tooltip: 'Сабра-гид: Сленг 🇮🇱',
                icon: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.deepOrangeAccent,
                ),
              ),
              if (_activeTabIndex == 0) ...[
                IconButton(
                  onPressed: _openScenarioCatalog,
                  tooltip: 'Каталог сценариев (8)',
                  icon: const Icon(Icons.explore_outlined),
                ),
                if (loadedState != null) ...[
                  IconButton(
                    onPressed: () => _openDialogueHistory(
                      loadedState.activeNode,
                      loadedState.showNikkud,
                    ),
                    tooltip: 'История реплик',
                    icon: const Icon(Icons.history_edu_rounded),
                  ),
                  IconButton(
                    onPressed: cubit.toggleNikkudVisibility,
                    tooltip: loadedState.showNikkud
                        ? 'Скрыть огласовки (некудот)'
                        : 'Показать огласовки (некудот)',
                    icon: Icon(
                      loadedState.showNikkud
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                    ),
                  ),
                  PopupMenuButton<double>(
                    tooltip: 'Скорость речи персонажа',
                    initialValue: loadedState.playbackSpeed,
                    onSelected: (speed) => cubit.setPlaybackSpeed(speed),
                    itemBuilder: (context) => [
                      _buildSpeedMenuItem(
                        context,
                        0.75,
                        '0.75x — Медленно',
                        loadedState.playbackSpeed,
                      ),
                      _buildSpeedMenuItem(
                        context,
                        0.85,
                        '0.85x — Умеренно',
                        loadedState.playbackSpeed,
                      ),
                      _buildSpeedMenuItem(
                        context,
                        1.0,
                        '1.0x — Обычная',
                        loadedState.playbackSpeed,
                      ),
                      _buildSpeedMenuItem(
                        context,
                        1.25,
                        '1.25x — Быстро',
                        loadedState.playbackSpeed,
                      ),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.speed_rounded,
                                size: 15,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${loadedState.playbackSpeed == 1.0 ? "1.0" : loadedState.playbackSpeed.toString()}x',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                IconButton(
                  onPressed: () {
                    _sessionHistory.clear();
                    cubit.loadDialogueNode(
                      _selectedScenarioId,
                      resetHistory: true,
                    );
                  },
                  tooltip: 'Начать сценарий заново',
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 4),
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment<int>(
                      value: 0,
                      icon: Icon(Icons.forum_outlined),
                      label: Text('Сценарии'),
                    ),
                    ButtonSegment<int>(
                      value: 1,
                      icon: Icon(Icons.auto_stories_outlined),
                      label: Text('Истории'),
                    ),
                  ],
                  selected: {_activeTabIndex},
                  onSelectionChanged: (Set<int> newSelection) {
                    setState(() {
                      _activeTabIndex = newSelection.first;
                    });
                  },
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: _activeTabIndex == 1
                ? (widget.audioService != null &&
                        widget.addCardToSrsUseCase != null
                    ? StoriesCatalogView(
                        audioService: widget.audioService!,
                        addCardToSrsUseCase: widget.addCardToSrsUseCase!,
                      )
                    : const Center(
                        child: Text('Сервисы историй инициализируются...'),
                      ))
                : Column(
                    children: [
                      // Scenario chips switcher
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          16,
                          8,
                          16,
                          8,
                        ),
                        child: Row(
                          children: [
                            for (final scenario in filteredScenarios) ...[
                              ChoiceChip(
                                label: Text(
                                  '${scenario.emoji} ${scenario.titleRussian}',
                                ),
                                selected: _selectedScenarioId == scenario.id,
                                onSelected: (bool selected) {
                                  if (selected) {
                                    _onScenarioSelected(scenario.id);
                                  }
                                },
                              ),
                              const SizedBox(width: 8),
                            ],
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: switch (state) {
                          ConversationInitial() ||
                          ConversationLoading() =>
                            const Center(child: CircularProgressIndicator()),
                          ConversationError(
                            :final errorMessage,
                            :final retryNodeId,
                          ) =>
                            _ErrorBody(
                              message: errorMessage,
                              onRetry: () => cubit.loadDialogueNode(
                                retryNodeId ?? _selectedScenarioId,
                              ),
                            ),
                          ConversationLoaded(
                            :final activeNode,
                            :final showNikkud,
                            :final audioStatus,
                            :final isTransitioning,
                          ) =>
                            DialogueBubble(
                              node: activeNode,
                              showNikkud: showNikkud,
                              audioStatus: audioStatus,
                              isInteractionLocked: isTransitioning,
                              onOptionSelected: cubit.selectOption,
                              onAudioPressed: () =>
                                  unawaited(cubit.toggleAudio()),
                              onSaveNodeToSrs: () =>
                                  unawaited(cubit.saveNodeToSrs()),
                              onSaveOptionToSrs: (DialogueOption opt) =>
                                  unawaited(cubit.saveOptionToSrs(opt)),
                              onXRayPressed: () {
                                final dictState =
                                    context.read<DictionaryCubit>().state;
                                final entries = dictState is DictionaryLoaded
                                    ? dictState.allEntries
                                    : const <DictionaryEntry>[];
                                final grammarState =
                                    context.read<GrammarCubit>().state;
                                final verbs = grammarState is GrammarLoaded
                                    ? grammarState.verbs
                                    : const <VerbLexeme>[];
                                final srsState =
                                    context.read<SrsSessionCubit>().state;
                                final srsForms = srsState is SrsSessionActive
                                    ? srsState.queue
                                        .map((c) => c.hebrew.normalized)
                                        .toSet()
                                    : const <String>{};
                                unawaited(
                                  SentenceXRaySheet.show(
                                    context,
                                    sentenceHebrew:
                                        activeNode.lineHebrew.vocalized,
                                    sentenceRussian: activeNode.lineRussian,
                                    allDictionaryEntries: entries,
                                    allGrammarVerbs: verbs,
                                    srsNormalizedForms: srsForms,
                                    audioService: widget.audioService,
                                    addCardToSrsUseCase:
                                        widget.addCardToSrsUseCase,
                                  ),
                                );
                              },
                            ),
                        },
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  PopupMenuItem<double> _buildSpeedMenuItem(
    BuildContext context,
    double speed,
    String label,
    double currentSpeed,
  ) {
    final theme = Theme.of(context);
    final isSelected = (currentSpeed - speed).abs() < 0.01;
    return PopupMenuItem<double>(
      value: speed,
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_rounded : Icons.speed_rounded,
            size: 18,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected ? theme.colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({
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
            const SizedBox(height: 16.0),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16.0),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Повторить попытку'),
            ),
          ],
        ),
      ),
    );
  }
}
