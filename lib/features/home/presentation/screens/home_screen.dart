import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/settings/app_settings_storage.dart';
import '../../../assessment/presentation/screens/level_assessment_screen.dart';
import '../../../gamification/domain/services/sabra_quest_service.dart';
import '../../../gamification/presentation/widgets/sabra_daily_quests_card.dart';
import '../../../goals/domain/entities/daily_goal.dart';
import '../../../goals/domain/services/daily_goal_service.dart';
import '../../../goals/presentation/widgets/daily_goal_rings_card.dart';
import '../../../progress/domain/entities/daily_workout_plan.dart';
import '../../../progress/domain/usecases/get_daily_workout.dart';
import '../../../progress/presentation/cubit/progress_cubit.dart';
import '../../../progress/presentation/cubit/progress_state.dart';
import '../../../scenes/data/repositories/scenes_repository_impl.dart';
import '../../../scenes/domain/repositories/scenes_repository.dart';
import '../../../scenes/presentation/screens/scenes_catalog_screen.dart';
import '../../../search/domain/services/omni_search_engine.dart';
import '../../../search/presentation/widgets/omni_search_sheet.dart';
import '../../../search/presentation/widgets/omni_spotlight_bar.dart';
import '../../../slang/domain/usecases/get_slang_expressions.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../../srs/presentation/cubit/srs_session_cubit.dart';
import '../../../srs/presentation/cubit/srs_session_state.dart';
import '../../domain/entities/word_of_the_day.dart';
import '../widgets/contacts_about_sheet.dart';
import '../widgets/quick_access_grid.dart';
import '../widgets/word_of_the_day_card.dart';

/// Central Home Dashboard presenting greetings, daily streak, Word of the Day,
/// and instant navigation to all Hebrew learning modules.
class HomeScreen extends StatefulWidget {
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;
  final GetDailyWorkoutUseCase? getDailyWorkoutUseCase;
  final AppSettingsStorage? settingsStorage;
  final GetSlangExpressionsUseCase? getSlangUseCase;
  final ValueChanged<int>? onNavigateToTab;
  final AppDatabase? database;

  const HomeScreen({
    super.key,
    this.audioService,
    this.addCardToSrsUseCase,
    this.getDailyWorkoutUseCase,
    this.settingsStorage,
    this.getSlangUseCase,
    this.onNavigateToTab,
    this.database,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showNikkud = true;
  DailyWorkoutPlan? _dailyWorkout;
  bool _isLoadingWorkout = false;
  String? _assessedLevel;
  late final OmniSearchEngine _searchEngine = OmniSearchEngine.withStaticDefaults();
  late final ScenesRepository _scenesRepository = ScenesRepositoryImpl(database: widget.database);
  late final SabraQuestService _sabraQuestService = SabraQuestService(storage: widget.settingsStorage);
  late final DailyGoalService _dailyGoalService = DailyGoalService(storage: widget.settingsStorage);
  DailyGoalProgress? _dailyGoal;

  @override
  void initState() {
    super.initState();
    _loadWorkoutPlan();
    _loadAssessedLevel();
    _populateSearchEngine();
    _loadDailyGoal();
  }

  Future<void> _loadDailyGoal() async {
    final progress = await _dailyGoalService.loadGoalProgress();
    if (mounted) {
      setState(() => _dailyGoal = progress);
    }
  }

  Future<void> _onGoalIntensityChanged(DailyGoalIntensity intensity) async {
    final updated = await _dailyGoalService.updateIntensity(intensity);
    if (mounted) {
      setState(() => _dailyGoal = updated);
    }
  }

  Future<void> _loadAssessedLevel() async {
    final level = await widget.settingsStorage?.readAssessedLevel();
    if (mounted) {
      setState(() => _assessedLevel = level);
    }
  }

  void _openLevelAssessment() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LevelAssessmentScreen(
          audioService: widget.audioService,
          addCardToSrsUseCase: widget.addCardToSrsUseCase,
          settingsStorage: widget.settingsStorage,
          onLevelUpdated: (result) {
            setState(() => _assessedLevel = result.determinedLevel);
            unawaited(_loadWorkoutPlan());
          },
        ),
      ),
    ).then((_) => unawaited(_loadAssessedLevel()));
  }

  void _populateSearchEngine() {
    if (widget.getSlangUseCase != null) {
      widget.getSlangUseCase!().then((res) {
        if (mounted && res.isSuccess) {
          _searchEngine.addSlangExpressions(res.getOrNull()!);
        }
      });
    }
  }

  void _openScenesCatalog() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ScenesCatalogScreen(
          repository: _scenesRepository,
          audioService: widget.audioService,
          addCardToSrsUseCase: widget.addCardToSrsUseCase,
        ),
      ),
    );
  }

  void _openOmniSearch() {
    OmniSearchSheet.show(
      context,
      engine: _searchEngine,
      audioService: widget.audioService,
      addCardToSrsUseCase: widget.addCardToSrsUseCase,
      onNavigateToTab: widget.onNavigateToTab,
    );
  }

  Future<void> _loadWorkoutPlan() async {
    if (widget.getDailyWorkoutUseCase == null) return;
    setState(() => _isLoadingWorkout = true);

    final res = await widget.getDailyWorkoutUseCase!();
    if (mounted) {
      setState(() {
        _isLoadingWorkout = false;
        _dailyWorkout = res.getOrNull();
      });
    }
  }

  void _openContactsAbout() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const ContactsAboutSheet(),
    );
  }

  (String hebrew, String russian) _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return ('בֹּקֶר טוֹב!', 'Доброе утро!');
    } else if (hour >= 12 && hour < 17) {
      return ('צָהֳרַיִם טוֹבִים!', 'Добрый день!');
    } else if (hour >= 17 && hour < 22) {
      return ('עֶרֶב טוֹב!', 'Добрый вечер!');
    } else {
      return ('לַיְלָה טוֹב!', 'Доброй ночи!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final (greetingHebrew, greetingRussian) = _getGreeting();
    final todayWord = WordOfTheDay.getForDate();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsetsDirectional.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'נ',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: theme.colorScheme.primary,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
            const SizedBox(width: 10),
            const Flexible(
              child: Text(
                'Nexus Hebrew',
                style: TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Быстрый поиск (Omni-Search)',
            icon: const Icon(Icons.search_rounded),
            onPressed: _openOmniSearch,
          ),
          IconButton(
            tooltip: _showNikkud ? 'Огласовки включены' : 'Огласовки выключены',
            icon: Icon(
              _showNikkud ? Icons.spellcheck_rounded : Icons.abc_rounded,
              color: _showNikkud ? theme.colorScheme.primary : theme.colorScheme.outline,
            ),
            onPressed: () {
              setState(() => _showNikkud = !_showNikkud);
            },
          ),
          IconButton(
            tooltip: 'О приложении и контакты',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: _openContactsAbout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 32),
        children: [
          // Greeting & Daily Pulse Banner
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: Text(
                                greetingHebrew,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.primary,
                                  height: 1.25,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$greetingRussian Готов к практике?',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          BlocBuilder<ProgressCubit, ProgressState>(
                            builder: (context, state) {
                              final streak = state is ProgressLoaded
                                  ? state.summary.currentStreakDays
                                  : 0;
                              return Container(
                                padding: const EdgeInsetsDirectional.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.orange.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('🔥', style: TextStyle(fontSize: 14)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$streak ${streak == 1 ? 'день' : (streak >= 2 && streak <= 4 ? 'дня' : 'дней')}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.deepOrange,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _openLevelAssessment,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer
                                    .withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.military_tech_rounded,
                                    size: 14,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _assessedLevel != null
                                        ? 'Уровень: $_assessedLevel'
                                        : 'Тест уровня ➔',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Status indicators: Due cards & Daily Workout
                  Row(
                    children: [
                      Expanded(
                        child: BlocBuilder<SrsSessionCubit, SrsSessionState>(
                          builder: (context, state) {
                            final dueCount = state is SrsSessionActive
                                ? state.remainingCount
                                : (state is SrsSessionEmpty ? 0 : 0);
                            return InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => widget.onNavigateToTab?.call(2),
                              child: Container(
                                padding: const EdgeInsetsDirectional.all(10),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.colorScheme.outlineVariant
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.style_outlined,
                                      color: theme.colorScheme.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Карточки FSRS',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                              color: theme
                                                  .colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                          Text(
                                            dueCount > 0
                                                ? '$dueCount на сегодня'
                                                : 'Все повторены ✓',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: dueCount > 0
                                                  ? theme.colorScheme.primary
                                                  : Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => widget.onNavigateToTab?.call(6),
                          child: Container(
                            padding: const EdgeInsetsDirectional.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _dailyWorkout?.isCompletedToday == true
                                      ? Icons.check_circle_rounded
                                      : Icons.fitness_center_rounded,
                                  color: _dailyWorkout?.isCompletedToday == true
                                      ? Colors.green
                                      : theme.colorScheme.secondary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Тренировка дня',
                                        style:
                                            theme.textTheme.labelSmall?.copyWith(
                                          color:
                                              theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      Text(
                                        _dailyWorkout?.isCompletedToday == true
                                            ? 'Выполнена! 🎉'
                                            : (_isLoadingWorkout
                                                ? 'Загрузка...'
                                                : 'Начать ➔'),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color:
                                              _dailyWorkout?.isCompletedToday ==
                                                      true
                                                  ? Colors.green
                                                  : theme.colorScheme.secondary,
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
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Spotlight Search Bar Trigger
          OmniSpotlightBar(onTap: _openOmniSearch),
          const SizedBox(height: 16),

          // Daily Activity Rings & Goals
          if (_dailyGoal != null) ...[
            DailyGoalRingsCard(
              progress: _dailyGoal!,
              onIntensityChanged: _onGoalIntensityChanged,
              onNavigateToCards: () => widget.onNavigateToTab?.call(2),
              onNavigateToPractice: () => widget.onNavigateToTab?.call(6),
              onNavigateToQuests: () => widget.onNavigateToTab?.call(4),
            ),
            const SizedBox(height: 16),
          ],

          // Sabra Daily Quests & Streaks
          BlocBuilder<ProgressCubit, ProgressState>(
            builder: (context, state) {
              final streak = state is ProgressLoaded
                  ? state.summary.currentStreakDays
                  : 0;
              return SabraDailyQuestsCard(
                questService: _sabraQuestService,
                streakDays: streak,
                onXpClaimed: (_) {
                  unawaited(context.read<ProgressCubit>().loadProgress());
                  unawaited(_dailyGoalService.recordActivity(questsDelta: 1).then((up) {
                    if (mounted) setState(() => _dailyGoal = up);
                  }));
                },
                onNavigateToDialogue: () => widget.onNavigateToTab?.call(4),
                onNavigateToSrs: () => widget.onNavigateToTab?.call(2),
                onNavigateToShoresh: () => widget.onNavigateToTab?.call(1),
              );
            },
          ),
          const SizedBox(height: 16),

          // Word of the Day Section
          WordOfTheDayCard(
            word: todayWord,
            showNikkud: _showNikkud,
            audioService: widget.audioService,
            addCardToSrsUseCase: widget.addCardToSrsUseCase,
          ),
          const SizedBox(height: 16),

          // Real Israel Scenes Banner
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            color: theme.colorScheme.primaryContainer.withValues(alpha: isDark ? 0.3 : 0.2),
            child: InkWell(
              onTap: _openScenesCatalog,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text('🏙️', style: TextStyle(fontSize: 26)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Реальный Израиль',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'НОВОЕ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Шуферсаль, Рав-Кав, Поликлиника, Кафе • 6 сцен',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Quick Access Grid Section
          Text(
            'Разделы обучения:',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          QuickAccessGrid(
            onNavigateToTab: widget.onNavigateToTab,
            audioService: widget.audioService,
            addCardToSrsUseCase: widget.addCardToSrsUseCase,
            getSlangUseCase: widget.getSlangUseCase,
            database: widget.database,
          ),
          const SizedBox(height: 24),

          // Footer info with contact button
          Center(
            child: Column(
              children: [
                TextButton.icon(
                  onPressed: _openContactsAbout,
                  icon: const Icon(Icons.favorite_rounded, color: Colors.red, size: 16),
                  label: Text(
                    'Nexus Hebrew · badmuchi',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  'Офлайн база данных · FSRS алгоритм · 7 Биньянов',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
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
