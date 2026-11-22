import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/audio/offline_audio_cache_service.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/settings/app_settings_storage.dart';
import '../../../assessment/presentation/screens/level_assessment_screen.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../../../gamification/presentation/widgets/memory_stability_badges_section.dart';
import '../../../gamification/presentation/widgets/sabra_league_card.dart';
import '../../../scenes/data/repositories/scenes_repository_impl.dart';
import '../../../scenes/presentation/screens/scenes_catalog_screen.dart';
import '../../../shoresh/presentation/screens/shoresh_catalog_screen.dart';
import '../../../srs/domain/entities/fsrs_models.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/presentation/screens/audio_drill_screen.dart';
import '../../../srs/presentation/widgets/audio_drill_config_sheet.dart';
import '../../domain/entities/daily_workout_plan.dart';
import '../../domain/entities/learning_progress_summary.dart';
import '../../domain/usecases/complete_daily_workout.dart';
import '../../domain/usecases/get_daily_workout.dart';
import '../cubit/progress_cubit.dart';
import '../cubit/progress_state.dart';
import '../widgets/database_backup_dialog.dart';
import '../widgets/fsrs_memory_dashboard_card.dart';
import 'daily_workout_screen.dart';

/// Unified progress analytics & global shoresh/Hebrew search workspace.
class ProgressScreen extends StatefulWidget {
  final AudioPlaybackService? audioService;
  final OfflineAudioCacheService? audioCacheService;
  final AppSettingsStorage? settingsStorage;
  final AppDatabase? database;
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;
  final GetDailyWorkoutUseCase? getDailyWorkoutUseCase;
  final CompleteDailyWorkoutUseCase? completeDailyWorkoutUseCase;

  const ProgressScreen({
    super.key,
    this.audioService,
    this.audioCacheService,
    this.settingsStorage,
    this.database,
    this.currentThemeMode = ThemeMode.system,
    this.onThemeModeChanged,
    this.getDailyWorkoutUseCase,
    this.completeDailyWorkoutUseCase,
  });

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final TextEditingController _searchController = TextEditingController();
  double _currentSpeed = 1.0;
  bool _isPlayingSample = false;
  DailyWorkoutPlan? _dailyWorkoutPlan;
  String? _assessedLevel;
  late final OfflineAudioCacheService _cacheService;
  int _cachedAudioCount = 0;
  DateTime? _lastPreloadDate;
  bool _isPreloadingAudio = false;
  AudioPreloadProgress? _preloadProgress;
  StreamSubscription<AudioPreloadProgress>? _preloadSub;

  @override
  void initState() {
    super.initState();
    _currentSpeed = widget.audioService?.currentSpeed ?? 1.0;
    _cacheService = widget.audioCacheService ??
        OfflineAudioCacheServiceImpl(
          settingsStorage: widget.settingsStorage ??
              SecureAppSettingsStorage.withDefaultOptions(
                logger: const DeveloperAppLogger(),
              ),
          logger: const DeveloperAppLogger(),
        );
    unawaited(_loadDailyWorkout());
    unawaited(_loadAssessedLevel());
    unawaited(_loadAudioCacheStats());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _preloadSub?.cancel();
    super.dispose();
  }

  Future<void> _loadAudioCacheStats() async {
    final count = await _cacheService.getCachedAudioCount();
    final date = await _cacheService.getLastPreloadDate();
    if (mounted) {
      setState(() {
        _cachedAudioCount = count;
        _lastPreloadDate = date;
      });
    }
  }

  void _startAudioPreload() {
    if (_isPreloadingAudio) return;
    setState(() {
      _isPreloadingAudio = true;
      _preloadProgress = const AudioPreloadProgress.idle();
    });

    _preloadSub?.cancel();
    _preloadSub = _cacheService.preloadAllEssentialAudio().listen(
      (progress) {
        if (!mounted) return;
        setState(() {
          _preloadProgress = progress;
          if (progress.isFinished) {
            _isPreloadingAudio = false;
            _cachedAudioCount = progress.completed;
            _lastPreloadDate = DateTime.now();
          }
        });

        if (progress.isFinished) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Вся озвучка (${progress.completed} файлов) успешно синхронизирована для офлайн-работы! ✈️',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      onError: (Object error) {
        if (!mounted) return;
        setState(() {
          _isPreloadingAudio = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка предзагрузки аудио: $error'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  Future<void> _clearAudioCache() async {
    await _cacheService.clearCache();
    await _loadAudioCacheStats();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Кэш загруженных аудиозаписей очищен'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _loadAssessedLevel() async {
    final level = await widget.settingsStorage?.readAssessedLevel();
    if (mounted) {
      setState(() => _assessedLevel = level);
    }
  }

  Future<void> _loadDailyWorkout() async {
    if (widget.getDailyWorkoutUseCase == null) return;
    final result = await widget.getDailyWorkoutUseCase!.call();
    if (mounted) {
      setState(() {
        _dailyWorkoutPlan = result.getOrNull();
      });
    }
  }

  void _openDailyWorkout() {
    if (_dailyWorkoutPlan == null) return;
    final completeUseCase = widget.completeDailyWorkoutUseCase ??
        CompleteDailyWorkoutUseCase(settingsStorage: widget.settingsStorage);

    Navigator.of(context)
        .push(
      MaterialPageRoute<void>(
        builder: (_) => DailyWorkoutScreen(
          plan: _dailyWorkoutPlan!,
          completeUseCase: completeUseCase,
          audioService: widget.audioService,
          onCompleted: () {
            unawaited(_loadDailyWorkout());
            unawaited(context.read<ProgressCubit>().loadProgress());
          },
        ),
      ),
    ).then((_) {
      if (!mounted) return;
      unawaited(_loadDailyWorkout());
      unawaited(context.read<ProgressCubit>().loadProgress());
    });
  }

  Future<void> _openAudioDrill(BuildContext context) async {
    final database = widget.database;
    List<SrsCard> cards = [];
    if (database != null) {
      final rows = await database.getAllSrsCards();
      cards = rows
          .map((r) => SrsCard(
                id: r.id,
                hebrew: HebrewText.create(r.hebrewVocalized).getOrNull() ??
                    HebrewText.fixture(
                      vocalized: r.hebrewVocalized,
                      normalized: r.hebrewNormalized,
                    ),
                russianTranslation: r.russianTranslation,
                root: r.root != null
                    ? Shoresh.create(r.root!).getOrNull()
                    : null,
                audioUrl: r.audioUrl,
                memory: FsrsMemoryState(
                  stability: r.stability,
                  difficulty: r.difficulty,
                  dueAt: r.dueAt,
                  reps: r.reps,
                  lapses: r.lapses,
                  state: switch (r.fsrsState) {
                    'learning' => FsrsCardState.learning,
                    'review' => FsrsCardState.review,
                    'relearning' => FsrsCardState.relearning,
                    _ => FsrsCardState.review,
                  },
                  lastReviewedAt: r.lastReviewedAt,
                ),
                attribution: ContentAttribution(
                  sourceName: r.sourceName,
                  licenseName: r.licenseName,
                ),
              ))
          .toList();
    }

    if (!context.mounted) return;
    final config = await AudioDrillConfigSheet.show(context);
    if (config != null && context.mounted) {
      if (cards.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('В колоде пока нет карточек для тренировки')),
        );
        return;
      }
      unawaited(AudioDrillScreen.launch(
        context,
        allCards: cards,
        audioService: widget.audioService,
        initialConfig: config,
      ));
    }
  }

  Future<void> _updateSpeed(double speed) async {
    setState(() {
      _currentSpeed = speed;
    });
    await widget.audioService?.setPlaybackSpeed(speed);
    await widget.settingsStorage?.writePlaybackSpeed(speed);
  }

  Future<void> _playSample() async {
    if (_isPlayingSample) return;
    setState(() {
      _isPlayingSample = true;
    });
    await widget.audioService?.playWithTtsFallback(
      sourcePath: null,
      fallbackHebrewText: 'שָׁלוֹם! בְּרוּכִים הַבָּאִים לְאֶפְלִיקַצְיַת לִמּוּד עִבְרִית.',
    );
    if (mounted) {
      setState(() {
        _isPlayingSample = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Прогресс · Поиск'),
        actions: [
          IconButton(
            tooltip: theme.brightness == Brightness.dark
                ? 'Переключить на светлую тему'
                : 'Переключить на тёмную тему',
            onPressed: () {
              final isDark = theme.brightness == Brightness.dark;
              final nextMode = isDark ? ThemeMode.light : ThemeMode.dark;
              widget.onThemeModeChanged?.call(nextMode);
            },
            icon: Icon(
              theme.brightness == Brightness.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
          ),
          IconButton(
            tooltip: 'Обновить статистику',
            onPressed: () =>
                unawaited(context.read<ProgressCubit>().loadProgress()),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: BlocConsumer<ProgressCubit, ProgressState>(
        listenWhen: (ProgressState prev, ProgressState curr) =>
            curr is ProgressLoaded && curr.transientNotice != null,
        listener: (BuildContext context, ProgressState state) {
          if (state is ProgressLoaded && state.transientNotice != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.transientNotice!)),
              );
            context.read<ProgressCubit>().clearTransientNotice();
          }
        },
        builder: (BuildContext context, ProgressState state) {
          switch (state) {
            case ProgressInitial():
            case ProgressLoading():
              return const Center(child: CircularProgressIndicator());
            case ProgressError(:final failure):
              return _ProgressErrorView(
                message: failure.message,
                onRetry: () =>
                    unawaited(context.read<ProgressCubit>().loadProgress()),
              );
            case ProgressLoaded():
              return _buildLoadedBody(context, theme, state);
          }
        },
      ),
    );
  }

  Widget _buildLoadedBody(
    BuildContext context,
    ThemeData theme,
    ProgressLoaded state,
  ) {
    final summary = state.summary;

    return RefreshIndicator(
      onRefresh: () => context.read<ProgressCubit>().loadProgress(),
      child: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 28),
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Сквозной поиск: иврит, корень (כ-ת-ב) или перевод...',
              prefixIcon: const Icon(Icons.manage_search_rounded),
              suffixIcon: state.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        unawaited(context.read<ProgressCubit>().search(''));
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onChanged: (String value) =>
                unawaited(context.read<ProgressCubit>().search(value)),
          ),
          if (state.searchQuery.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            if (state.isSearching)
              const Center(child: CircularProgressIndicator())
            else if (state.searchResults.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsetsDirectional.all(16),
                  child: Text(
                    'Ничего не найдено по запросу «${state.searchQuery.trim()}».',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              )
            else
              ...state.searchResults.map(
                (GlobalHebrewSearchResult hit) => _SearchResultTile(
                  hit: hit,
                  isPlaying: state.activeSpokenHebrew == hit.hebrew.vocalized &&
                      state.audioStatus == AudioPlaybackStatus.playing,
                  onSpeak: () =>
                      unawaited(context.read<ProgressCubit>().speakHit(hit)),
                  onSaveToSrs: () =>
                      unawaited(context.read<ProgressCubit>().saveHitToSrs(hit)),
                ),
              ),
          ],
          const SizedBox(height: 16),
          if (_dailyWorkoutPlan != null) ...[
            _DailyWorkoutHeroCard(
              plan: _dailyWorkoutPlan!,
              onStartWorkout: _openDailyWorkout,
            ),
            const SizedBox(height: 12),
          ],
          _LevelAssessmentBannerCard(
            assessedLevel: _assessedLevel,
            onStartAssessment: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => LevelAssessmentScreen(
                    audioService: widget.audioService,
                    settingsStorage: widget.settingsStorage,
                    onLevelUpdated: (result) {
                      setState(() => _assessedLevel = result.determinedLevel);
                    },
                  ),
                ),
              ).then((_) => unawaited(_loadAssessedLevel()));
            },
          ),
          const SizedBox(height: 12),
          _LevelAndXpHeroCard(summary: summary),
          const SizedBox(height: 12),
          SabraLeagueCard(weeklyXp: _calculateWeeklyXp(summary)),
          const SizedBox(height: 12),
          _StreakHeroCard(summary: summary),
          const SizedBox(height: 12),
          _ActivityHeatmapCard(summary: summary),
          const SizedBox(height: 12),
          _AchievementsGridCard(summary: summary),
          const SizedBox(height: 12),
          MemoryStabilityBadgesSection(summary: summary),
          const SizedBox(height: 12),
          FsrsMemoryDashboardCard(
            summary: summary,
            onStartAudioDrill: () => _openAudioDrill(context),
          ),
          const SizedBox(height: 12),
          _GrammarStatsCard(summary: summary),
          const SizedBox(height: 12),
          _ListeningStatsCard(summary: summary),
          const SizedBox(height: 12),
          _ShoreshMasteryCard(
            summary: summary,
            onOpenShoreshLab: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ShoreshCatalogScreen(
                  audioService: widget.audioService,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _ScenesProgressCard(
            summary: summary,
            onOpenScenes: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ScenesCatalogScreen(
                  repository: ScenesRepositoryImpl(database: widget.database),
                  audioService: widget.audioService,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _ThemeSettingsCard(
            currentThemeMode: widget.currentThemeMode,
            onThemeModeChanged: widget.onThemeModeChanged,
          ),
          const SizedBox(height: 12),
          _AudioSettingsCard(
            currentSpeed: _currentSpeed,
            onSpeedChanged: (double speed) => unawaited(_updateSpeed(speed)),
            onPlaySample: () => unawaited(_playSample()),
            isPlayingSample: _isPlayingSample,
            cachedAudioCount: _cachedAudioCount,
            lastPreloadDate: _lastPreloadDate,
            isPreloadingAudio: _isPreloadingAudio,
            preloadProgress: _preloadProgress,
            onPreloadAudio: _startAudioPreload,
            onClearCache: () => unawaited(_clearAudioCache()),
          ),
          if (widget.database != null) ...[
            const SizedBox(height: 12),
            _BackupSettingsCard(
              onOpenBackup: () => DatabaseBackupDialog.show(
                context,
                database: widget.database!,
                settingsStorage: widget.settingsStorage,
                onRestored: () =>
                    unawaited(context.read<ProgressCubit>().loadProgress()),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LevelAssessmentBannerCard extends StatelessWidget {
  final String? assessedLevel;
  final VoidCallback onStartAssessment;

  const _LevelAssessmentBannerCard({
    this.assessedLevel,
    required this.onStartAssessment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasLevel = assessedLevel != null;

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsetsDirectional.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.military_tech_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasLevel
                        ? 'Твой уровень: $assessedLevel 🎯'
                        : 'Определить уровень иврита',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasLevel
                        ? 'CEFR диагностика активна • Персональный трек'
                        : 'Диагностика A1 ➔ B1 с дипломом и разбором',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              onPressed: onStartAssessment,
              child: Text(hasLevel ? 'Тест ➔' : 'Пройти'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackupSettingsCard extends StatelessWidget {
  final VoidCallback onOpenBackup;

  const _BackupSettingsCard({required this.onOpenBackup});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsetsDirectional.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.backup_rounded,
                color: theme.colorScheme.onTertiaryContainer,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Резервная копия прогресса',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Экспорт и импорт базы данных в формате JSON',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: onOpenBackup,
              icon: const Icon(Icons.sync_rounded, size: 18),
              label: const Text('Бэкап'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeSettingsCard extends StatelessWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  const _ThemeSettingsCard({
    required this.currentThemeMode,
    required this.onThemeModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsetsDirectional.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.palette_rounded,
                    color: theme.colorScheme.onSecondaryContainer,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Тема оформления',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Выбор светлого, тёмного или системного интерфейса',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.system,
                  label: Text('Системная'),
                  icon: Icon(Icons.brightness_auto_rounded),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.light,
                  label: Text('Светлая'),
                  icon: Icon(Icons.light_mode_rounded),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark,
                  label: Text('Тёмная'),
                  icon: Icon(Icons.dark_mode_rounded),
                ),
              ],
              selected: {currentThemeMode},
              onSelectionChanged: (Set<ThemeMode> newSelection) {
                onThemeModeChanged?.call(newSelection.first);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioSettingsCard extends StatelessWidget {
  final double currentSpeed;
  final ValueChanged<double> onSpeedChanged;
  final VoidCallback onPlaySample;
  final bool isPlayingSample;
  final int cachedAudioCount;
  final DateTime? lastPreloadDate;
  final bool isPreloadingAudio;
  final AudioPreloadProgress? preloadProgress;
  final VoidCallback onPreloadAudio;
  final VoidCallback onClearCache;

  const _AudioSettingsCard({
    required this.currentSpeed,
    required this.onSpeedChanged,
    required this.onPlaySample,
    required this.isPlayingSample,
    this.cachedAudioCount = 0,
    this.lastPreloadDate,
    this.isPreloadingAudio = false,
    this.preloadProgress,
    required this.onPreloadAudio,
    required this.onClearCache,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalizedSpeed = [0.75, 0.85, 1.0, 1.25].contains(currentSpeed)
        ? currentSpeed
        : 1.0;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsetsDirectional.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.speed_rounded,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Настройки озвучки и темпа речи',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Применяется к диалогам, рассказам, аудированию и карточкам',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<double>(
              segments: const [
                ButtonSegment<double>(
                  value: 0.75,
                  label: Text('0.75x'),
                  tooltip: 'Медленно',
                ),
                ButtonSegment<double>(
                  value: 0.85,
                  label: Text('0.85x'),
                  tooltip: 'Умеренно',
                ),
                ButtonSegment<double>(
                  value: 1.0,
                  label: Text('1.0x'),
                  tooltip: 'Обычная',
                ),
                ButtonSegment<double>(
                  value: 1.25,
                  label: Text('1.25x'),
                  tooltip: 'Быстро',
                ),
              ],
              selected: {normalizedSpeed},
              onSelectionChanged: (Set<double> newSelection) {
                onSpeedChanged(newSelection.first);
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: isPlayingSample ? null : onPlaySample,
              icon: Icon(
                isPlayingSample
                    ? Icons.volume_up_rounded
                    : Icons.play_arrow_rounded,
              ),
              label: Text(
                isPlayingSample
                    ? 'Озвучивается...'
                    : 'Прослушать образец (!שָׁלוֹם! בְּרוּכִים הַבָּאִים)',
              ),
            ),
            const Divider(height: 32),
            Row(
              children: [
                Container(
                  padding: const EdgeInsetsDirectional.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.offline_pin_rounded,
                    color: theme.colorScheme.onSecondaryContainer,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Офлайн-кэш озвучки',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cachedAudioCount > 0
                            ? '$cachedAudioCount файлов готово без интернета ✈️'
                            : 'Синхронизируйте аудио для занятий офлайн',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cachedAudioCount > 0
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: cachedAudioCount > 0 ? FontWeight.w600 : null,
                        ),
                      ),
                      if (lastPreloadDate != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Синхронизировано: ${lastPreloadDate!.day.toString().padLeft(2, '0')}.${lastPreloadDate!.month.toString().padLeft(2, '0')}.${lastPreloadDate!.year}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (cachedAudioCount > 0 && !isPreloadingAudio)
                  IconButton(
                    onPressed: onClearCache,
                    tooltip: 'Очистить загруженный кэш',
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                  ),
              ],
            ),
            if (isPreloadingAudio) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: preloadProgress?.progressRatio,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      preloadProgress?.currentItem ?? 'Синхронизация...',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${preloadProgress?.completed ?? 0} / ${preloadProgress?.total ?? 0} (${preloadProgress?.percent ?? 0}%)',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: isPreloadingAudio ? null : onPreloadAudio,
              icon: isPreloadingAudio
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_for_offline_rounded),
              label: Text(
                isPreloadingAudio
                    ? 'Загрузка озвучки (${preloadProgress?.percent ?? 0}%)...'
                    : (cachedAudioCount > 0
                        ? 'Обновить офлайн-аудио'
                        : 'Предзагрузить всю озвучку 📥'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakHeroCard extends StatelessWidget {
  const _StreakHeroCard({required this.summary});

  final LearningProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Row(
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              size: 40,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Серия: ${summary.currentStreakDays} дн.',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Упражнений сегодня: ${summary.activeTodayCount}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityHeatmapCard extends StatelessWidget {
  const _ActivityHeatmapCard({required this.summary});

  final LearningProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);

    final currentWeekday = today.weekday;
    final endDate = today.add(Duration(days: 7 - currentWeekday));
    const totalWeeks = 12;
    const totalDays = totalWeeks * 7;
    final startDate = endDate.subtract(const Duration(days: totalDays - 1));

    int daysWithActivity = 0;
    for (int i = 0; i < totalDays; i++) {
      final date = startDate.add(Duration(days: i));
      if (date.isAfter(today)) continue;
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      if ((summary.activityByDate[key] ?? 0) > 0) {
        daysWithActivity++;
      }
    }

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Карта активности',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$daysWithActivity активных дн.',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 6, top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildWeekdayLabel('Пн', theme),
                        const SizedBox(height: 16),
                        _buildWeekdayLabel('Ср', theme),
                        const SizedBox(height: 16),
                        _buildWeekdayLabel('Пт', theme),
                      ],
                    ),
                  ),
                  for (int w = 0; w < totalWeeks; w++) ...[
                    Column(
                      children: [
                        for (int d = 0; d < 7; d++) ...[
                          _buildDayCell(
                            date: startDate.add(Duration(days: w * 7 + d)),
                            today: today,
                            theme: theme,
                          ),
                          const SizedBox(height: 3),
                        ],
                      ],
                    ),
                    const SizedBox(width: 3),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Меньше',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 4),
                _buildLegendCell(theme.colorScheme.surfaceContainerHighest),
                _buildLegendCell(const Color(0xFF81C784)),
                _buildLegendCell(const Color(0xFF4CAF50)),
                _buildLegendCell(const Color(0xFF2E7D32)),
                _buildLegendCell(const Color(0xFF1B5E20)),
                const SizedBox(width: 4),
                Text(
                  'Больше',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayLabel(String text, ThemeData theme) {
    return SizedBox(
      height: 13,
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 9.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDayCell({
    required DateTime date,
    required DateTime today,
    required ThemeData theme,
  }) {
    final isFuture = date.isAfter(today);
    final key =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final count = isFuture ? 0 : (summary.activityByDate[key] ?? 0);

    Color cellColor;
    if (isFuture) {
      cellColor = Colors.transparent;
    } else if (count == 0) {
      cellColor =
          theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);
    } else if (count <= 2) {
      cellColor = const Color(0xFF81C784);
    } else if (count <= 5) {
      cellColor = const Color(0xFF4CAF50);
    } else if (count <= 8) {
      cellColor = const Color(0xFF2E7D32);
    } else {
      cellColor = const Color(0xFF1B5E20);
    }

    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    return Tooltip(
      message: isFuture
          ? ''
          : '${date.day}.${date.month.toString().padLeft(2, '0')}: $count ${count == 1 ? 'действие' : 'действий'}',
      child: Container(
        width: 13,
        height: 13,
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(3),
          border: isToday
              ? Border.all(color: theme.colorScheme.primary, width: 1.5)
              : null,
        ),
      ),
    );
  }

  Widget _buildLegendCell(Color color) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _GrammarStatsCard extends StatelessWidget {
  const _GrammarStatsCard({required this.summary});

  final LearningProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (summary.grammarAccuracy * 100).round();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Грамматика и биньяны',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  summary.grammarAttempts == 0
                      ? 'Нет попыток'
                      : '$percent% (${summary.grammarCorrect}/${summary.grammarAttempts})',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (summary.binyanStats.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...summary.binyanStats.map((BinyanAccuracyStat stat) {
                final binyanPercent = (stat.accuracyRate * 100).round();
                return Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${stat.binyan.hebrewLabel} · ${stat.binyan.transliteration}',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('$binyanPercent% (${stat.correctAttempts}/${stat.totalAttempts})'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(value: stat.accuracyRate),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _ListeningStatsCard extends StatelessWidget {
  const _ListeningStatsCard({required this.summary});

  final LearningProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avgPercent = (summary.averageListeningAccuracy * 100).round();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Аудирование и диктанты',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              summary.listeningAttempts == 0
                  ? 'Пока не пройдено ни одного диктанта.'
                  : 'Попыток: ${summary.listeningAttempts} · Точных совпадений: ${summary.listeningExactMatches} · Средняя точность: $avgPercent%',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.hit,
    required this.isPlaying,
    required this.onSpeak,
    required this.onSaveToSrs,
  });

  final GlobalHebrewSearchResult hit;
  final bool isPlaying;
  final VoidCallback onSpeak;
  final VoidCallback onSaveToSrs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsetsDirectional.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text(hit.kind.labelRu),
                      ),
                      if (hit.root != null)
                        Chip(
                          visualDensity: VisualDensity.compact,
                          label: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text(hit.root!.hyphenated),
                          ),
                        ),
                      if (hit.binyan != Binyan.none)
                        Chip(
                          visualDensity: VisualDensity.compact,
                          label: Text(hit.binyan.transliteration),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      hit.hebrew.vocalized,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    hit.russianMeaning,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Озвучить',
              onPressed: onSpeak,
              icon: Icon(
                isPlaying ? Icons.stop_circle_outlined : Icons.volume_up_outlined,
              ),
            ),
            IconButton(
              tooltip: 'В FSRS в 1 тап',
              onPressed: onSaveToSrs,
              icon: const Icon(Icons.bookmark_add_outlined),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressErrorView extends StatelessWidget {
  const _ProgressErrorView({
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

class _LevelInfo {
  final int level;
  final String titleHebrew;
  final String titleRu;
  final String transliteration;
  final int minXp;
  final int maxXp;

  const _LevelInfo({
    required this.level,
    required this.titleHebrew,
    required this.titleRu,
    required this.transliteration,
    required this.minXp,
    required this.maxXp,
  });
}

const List<_LevelInfo> _kLevels = [
  _LevelInfo(
    level: 1,
    titleHebrew: 'טִירוֹן',
    titleRu: 'Новобранец',
    transliteration: 'Tiron',
    minXp: 0,
    maxXp: 150,
  ),
  _LevelInfo(
    level: 2,
    titleHebrew: 'תַּלְמִיד',
    titleRu: 'Ученик',
    transliteration: 'Talmid',
    minXp: 150,
    maxXp: 400,
  ),
  _LevelInfo(
    level: 3,
    titleHebrew: 'מִתְקַדֵּם',
    titleRu: 'Продвинутый',
    transliteration: 'Mitkadem',
    minXp: 400,
    maxXp: 850,
  ),
  _LevelInfo(
    level: 4,
    titleHebrew: 'בָּקִיא',
    titleRu: 'Знаток',
    transliteration: 'Baki',
    minXp: 850,
    maxXp: 1600,
  ),
  _LevelInfo(
    level: 5,
    titleHebrew: 'צַבָּר',
    titleRu: 'Сабра',
    transliteration: 'Tsabar',
    minXp: 1600,
    maxXp: 4000,
  ),
];

int _calculateTotalXp(LearningProgressSummary summary) {
  final srsPoints = (summary.totalSrsCards * 10) + (summary.totalSrsReviews * 15);
  final grammarPoints = (summary.grammarAttempts * 20);
  final listeningPoints = (summary.listeningAttempts * 25);
  final streakPoints = (summary.currentStreakDays * 40);
  final shoreshPoints = (summary.masteredShoreshCount * 50);
  final scenePoints = (summary.completedScenesCount * 100);
  return srsPoints + grammarPoints + listeningPoints + streakPoints + shoreshPoints + scenePoints;
}

int _calculateWeeklyXp(LearningProgressSummary summary) {
  if (summary.activityByDate.isNotEmpty) {
    final now = DateTime.now().toUtc();
    var weeklyActions = 0;
    for (var i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      weeklyActions += summary.activityByDate[key] ?? 0;
    }
    if (weeklyActions > 0) {
      return (weeklyActions * 25) + (summary.activeTodayCount * 10);
    }
  }
  final total = _calculateTotalXp(summary);
  return (total % 1000) + (summary.activeTodayCount * 25) + 60;
}

_LevelInfo _getLevelForXp(int xp) {
  for (final lvl in _kLevels.reversed) {
    if (xp >= lvl.minXp) return lvl;
  }
  return _kLevels.first;
}

class _LevelAndXpHeroCard extends StatelessWidget {
  const _LevelAndXpHeroCard({required this.summary});

  final LearningProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalXp = _calculateTotalXp(summary);
    final currentLevel = _getLevelForXp(totalXp);
    final isMaxLevel = currentLevel.level == _kLevels.last.level;

    final progressInLevel = isMaxLevel
        ? 1.0
        : (totalXp - currentLevel.minXp) /
            (currentLevel.maxXp - currentLevel.minXp).clamp(1, 999999);
    final xpNeeded = isMaxLevel ? 0 : currentLevel.maxXp - totalXp;

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.tertiary,
                      ],
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${currentLevel.level}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text(
                              currentLevel.titleHebrew,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${currentLevel.titleRu} · ${currentLevel.transliteration})',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$totalXp XP накоплено',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progressInLevel.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isMaxLevel
                  ? '🏆 Достигнут высший уровень знатока иврита!'
                  : 'Ещё $xpNeeded XP до уровня ${_kLevels[currentLevel.level].titleRu} (${_kLevels[currentLevel.level].titleHebrew})',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final String progressText;

  const _AchievementItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.progressText,
  });
}

class _AchievementsGridCard extends StatelessWidget {
  const _AchievementsGridCard({required this.summary});

  final LearningProgressSummary summary;

  List<_AchievementItem> _buildAchievements(int totalXp) {
    return [
      _AchievementItem(
        id: 'sprint',
        title: 'Блиц-спринтер ⚡️',
        description: 'Разминка в скоростном спринте на 60 секунд',
        icon: Icons.bolt_rounded,
        isUnlocked: summary.totalSrsCards > 0 || summary.activeTodayCount > 0,
        progressText: (summary.totalSrsCards > 0 || summary.activeTodayCount > 0)
            ? 'Разблокировано!'
            : 'Сыграй в Блиц-спринт',
      ),
      _AchievementItem(
        id: 'streak',
        title: 'Ударный режим 🔥',
        description: 'Удерживай серию занятий 3 дня подряд',
        icon: Icons.local_fire_department_rounded,
        isUnlocked: summary.currentStreakDays >= 3,
        progressText: '${summary.currentStreakDays} / 3 дн.',
      ),
      _AchievementItem(
        id: 'fsrs',
        title: 'База FSRS 🧠',
        description: 'Накопи 10+ карточек в личном повторении',
        icon: Icons.style_rounded,
        isUnlocked: summary.totalSrsCards >= 10,
        progressText: '${summary.totalSrsCards} / 10 карт.',
      ),
      _AchievementItem(
        id: 'grammar',
        title: 'Знаток биньянов 🎯',
        description: 'Выполни 5+ тренировок спряжения глаголов',
        icon: Icons.spellcheck_rounded,
        isUnlocked: summary.grammarAttempts >= 5,
        progressText: '${summary.grammarAttempts} / 5 трен.',
      ),
      _AchievementItem(
        id: 'listening',
        title: 'Чуткое ухо 🎧',
        description: 'Выполни 3+ упражнений на аудирование',
        icon: Icons.headphones_rounded,
        isUnlocked: summary.listeningAttempts >= 3,
        progressText: '${summary.listeningAttempts} / 3 упр.',
      ),
      _AchievementItem(
        id: 'shoresh',
        title: 'Коренной мастер 🌳',
        description: 'Накопи 400+ очков опыта в обучении',
        icon: Icons.account_tree_rounded,
        isUnlocked: totalXp >= 400,
        progressText: '$totalXp / 400 XP',
      ),
    ];
  }

  void _showAchievementDialog(BuildContext context, _AchievementItem item) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          item.icon,
          size: 40,
          color: item.isUnlocked ? Colors.amber.shade700 : Colors.grey,
        ),
        title: Text(item.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.description, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: item.isUnlocked
                    ? Colors.green.withValues(alpha: 0.15)
                    : Colors.grey.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.isUnlocked ? '✓ Выполнено!' : item.progressText,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: item.isUnlocked ? Colors.green.shade700 : Colors.grey,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalXp = _calculateTotalXp(summary);
    final achievements = _buildAchievements(totalXp);
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Достижения и бейджи 🏆',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$unlockedCount / ${achievements.length}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: achievements.map((item) {
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showAchievementDialog(context, item),
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 72) / 2 > 140
                        ? (MediaQuery.of(context).size.width - 72) / 2
                        : 140,
                    padding: const EdgeInsetsDirectional.all(10),
                    decoration: BoxDecoration(
                      color: item.isUnlocked
                          ? theme.colorScheme.secondaryContainer.withValues(alpha: 0.35)
                          : theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: item.isUnlocked
                            ? theme.colorScheme.secondary.withValues(alpha: 0.4)
                            : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          size: 24,
                          color: item.isUnlocked
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: item.isUnlocked
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item.progressText,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  color: item.isUnlocked
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyWorkoutHeroCard extends StatelessWidget {
  final DailyWorkoutPlan plan;
  final VoidCallback onStartWorkout;

  const _DailyWorkoutHeroCard({
    required this.plan,
    required this.onStartWorkout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = plan.isCompletedToday;

    return Card(
      elevation: 0,
      color: isDone
          ? theme.colorScheme.surfaceContainerHighest
          : theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDone
              ? theme.colorScheme.outlineVariant
              : theme.colorScheme.primary.withValues(alpha: 0.5),
          width: isDone ? 1.0 : 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsetsDirectional.all(10),
                  decoration: BoxDecoration(
                    color: isDone
                        ? Colors.green.withValues(alpha: 0.15)
                        : theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isDone
                        ? Icons.check_circle_rounded
                        : Icons.track_changes_rounded,
                    color: isDone ? Colors.green : Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isDone
                                  ? 'Тренировка дня выполнена ✓'
                                  : 'Тренировка дня · 5 минут',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isDone
                                  ? Colors.green.withValues(alpha: 0.15)
                                  : theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isDone ? '+50 XP получено' : '+50 XP',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: isDone
                                    ? Colors.green.shade800
                                    : theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isDone
                            ? 'Дневная норма закрыта! Серия дней защищена. Можно повторить для закрепления.'
                            : '${plan.totalSteps} шагов тренировки (карточки, грамматика, аудирование, корень, сцена)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            isDone
                ? OutlinedButton.icon(
                    onPressed: onStartWorkout,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Пройти повторно для закрепления'),
                  )
                : FilledButton.icon(
                    onPressed: onStartWorkout,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Начать тренировку дня'),
                  ),
          ],
        ),
      ),
    );
  }
}

class _ShoreshMasteryCard extends StatelessWidget {
  const _ShoreshMasteryCard({
    required this.summary,
    required this.onOpenShoreshLab,
  });

  final LearningProgressSummary summary;
  final VoidCallback onOpenShoreshLab;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mastered = summary.masteredShoreshCount;
    final total = summary.totalShoreshCount;
    final ratio = total > 0 ? (mastered / total).clamp(0.0, 1.0) : 0.0;

    final rank = switch (ratio) {
      >= 0.8 => 'Шериф Морфологии 🕵️‍♂️✨',
      >= 0.4 => 'Старший Детектив 🔍',
      _ => 'Младший Следователь 📜',
    };

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.biotech_rounded,
                    color: Colors.teal,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Лаборатория корней (Шореш)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Ранг: $rank',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Освоено корневых семейств:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$mastered из $total (${(ratio * 100).toInt()}%)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
              color: Colors.teal,
              backgroundColor: Colors.teal.withValues(alpha: 0.15),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onOpenShoreshLab,
              icon: const Icon(Icons.hub_rounded, size: 18),
              label: const Text('Открыть древо корней и квест'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScenesProgressCard extends StatelessWidget {
  const _ScenesProgressCard({
    required this.summary,
    required this.onOpenScenes,
  });

  final LearningProgressSummary summary;
  final VoidCallback onOpenScenes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final completed = summary.completedScenesCount;
    final total = summary.totalScenesCount;
    final ratio = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.location_city_rounded,
                    color: Colors.blue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Реальный Израиль: Быт',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Готовность к живым ситуациям',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Пройдено локаций:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$completed из $total ситуаций',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
              color: Colors.blue,
              backgroundColor: Colors.blue.withValues(alpha: 0.15),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onOpenScenes,
              icon: const Icon(Icons.explore_rounded, size: 18),
              label: const Text('Перейти к бытовым ситуациям'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

