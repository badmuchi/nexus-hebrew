import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/result/result.dart';
import '../../../../core/speech/speech_recognition_service.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../data/repositories/ai_roleplay_repository_impl.dart';
import '../../domain/entities/ai_roleplay_scenario.dart';
import '../../domain/repositories/ai_roleplay_repository.dart';
import 'ai_roleplay_chat_screen.dart';

class AiRoleplayCatalogScreen extends StatefulWidget {
  final AiRoleplayRepository? repository;
  final AudioPlaybackService? audioService;
  final SpeechRecognitionService? speechService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const AiRoleplayCatalogScreen({
    super.key,
    this.repository,
    this.audioService,
    this.speechService,
    this.addCardToSrsUseCase,
  });

  @override
  State<AiRoleplayCatalogScreen> createState() =>
      _AiRoleplayCatalogScreenState();
}

class _AiRoleplayCatalogScreenState extends State<AiRoleplayCatalogScreen> {
  late final AiRoleplayRepository _repository;
  List<AiRoleplayScenario> _scenarios = [];
  bool _isLoading = true;
  String _selectedLevel = 'Все';

  static const List<String> _levelFilters = ['Все', 'A1', 'A2', 'B1'];

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? AiRoleplayRepositoryImpl();
    _loadScenarios();
  }

  Future<void> _loadScenarios() async {
    setState(() => _isLoading = true);
    final res = await _repository.getScenarios();
    if (!mounted) return;
    if (res case Success(:final data)) {
      setState(() {
        _scenarios = data;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _openChat(AiRoleplayScenario scenario) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AiRoleplayChatScreen(
          scenario: scenario,
          repository: _repository,
          audioService: widget.audioService,
          speechService: widget.speechService,
          addCardToSrsUseCase: widget.addCardToSrsUseCase,
        ),
      ),
    );
  }

  List<AiRoleplayScenario> get _filteredScenarios {
    if (_selectedLevel == 'Все') return _scenarios;
    return _scenarios.where((s) => s.level.contains(_selectedLevel)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI-Собеседник • Диалоги'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Обновить сценарии',
            onPressed: _loadScenarios,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Header promo banner
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primaryContainer,
                            theme.colorScheme.tertiaryContainer,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withAlpha(200),
                              shape: BoxShape.circle,
                            ),
                            child: const Text('🎙️', style: TextStyle(fontSize: 30)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Интерактивная практика иврита',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Погружайся в израильские ситуации, общайся голосом или текстом с огласовками, получай моментальные советы по грамматике.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Level filter chips
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Wrap(
                      spacing: 8,
                      children: _levelFilters.map((lvl) {
                        final isSelected = _selectedLevel == lvl;
                        return FilterChip(
                          selected: isSelected,
                          label: Text(lvl == 'Все' ? 'Все уровни' : 'Уровень $lvl'),
                          onSelected: (_) {
                            setState(() => _selectedLevel = lvl);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Scenarios list
                if (_filteredScenarios.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text('Сценарии для выбранного фильтра не найдены.'),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final scenario = _filteredScenarios[index];
                          return _ScenarioCard(
                            scenario: scenario,
                            onTap: () => _openChat(scenario),
                          );
                        },
                        childCount: _filteredScenarios.length,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  final AiRoleplayScenario scenario;
  final VoidCallback onTap;

  const _ScenarioCard({
    required this.scenario,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final character = scenario.character;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(120),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row: Emoji + Title + Level badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      scenario.badgeEmoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scenario.titleRussian,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Wrap(
                          spacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              '${character.avatarEmoji} ${character.nameRussian}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '• ${scenario.category}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      scenario.level,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                scenario.descriptionRussian,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),

              // Footer: Action button & quick chips count
              Row(
                children: [
                  Icon(
                    Icons.quickreply_outlined,
                    size: 16,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${scenario.suggestedPrompts.length} готовых реплик',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const Spacer(),
                  FilledButton.tonalIcon(
                    onPressed: onTap,
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                    label: const Text('Начать диалог'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
