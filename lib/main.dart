import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/audio/audio_playback_service.dart';
import 'core/audio/hybrid_audio_playback_service.dart';
import 'core/audio/just_audio_playback_service.dart';
import 'core/audio/tts_speech_service.dart';
import 'core/database/app_database.dart';
import 'core/logging/app_logger.dart';
import 'core/network/dio_client_factory.dart';
import 'core/security/secure_token_storage.dart';
import 'core/settings/app_settings_storage.dart';
import 'features/conversation/data/datasources/dialogue_local_datasource.dart';
import 'features/conversation/data/datasources/dialogue_remote_datasource.dart';
import 'features/conversation/data/datasources/dialogue_seed_datasource.dart';
import 'features/conversation/data/repositories/conversation_repository_impl.dart';
import 'features/conversation/domain/repositories/conversation_repository.dart';
import 'features/conversation/domain/usecases/get_active_dialogue.dart';
import 'features/conversation/domain/usecases/select_dialogue_option.dart';
import 'features/conversation/domain/usecases/toggle_dialogue_audio.dart';
import 'features/conversation/presentation/cubit/conversation_cubit.dart';
import 'features/conversation/presentation/screens/conversation_screen.dart';
import 'features/dictionary/data/datasources/dictionary_local_datasource.dart';
import 'features/dictionary/data/datasources/dictionary_remote_datasource.dart';
import 'features/dictionary/data/datasources/dictionary_seed_datasource.dart';
import 'features/dictionary/data/repositories/dictionary_repository_impl.dart';
import 'features/dictionary/domain/repositories/dictionary_repository.dart';
import 'features/dictionary/domain/usecases/add_custom_dictionary_entry.dart';
import 'features/dictionary/domain/usecases/search_dictionary_entries.dart';
import 'features/dictionary/domain/usecases/search_online_dictionary.dart';
import 'features/dictionary/presentation/cubit/dictionary_cubit.dart';
import 'features/dictionary/presentation/screens/dictionary_screen.dart';
import 'features/grammar/data/datasources/grammar_local_datasource.dart';
import 'features/grammar/data/datasources/grammar_seed_datasource.dart';
import 'features/grammar/data/repositories/grammar_repository_impl.dart';
import 'features/grammar/domain/repositories/grammar_repository.dart';
import 'features/grammar/domain/usecases/check_verb_conjugation.dart';
import 'features/grammar/domain/usecases/get_verbs_by_binyan.dart';
import 'features/grammar/domain/usecases/record_grammar_practice.dart';
import 'features/grammar/presentation/cubit/grammar_cubit.dart';
import 'features/grammar/presentation/screens/grammar_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/listening/data/datasources/listening_local_datasource.dart';
import 'features/listening/data/datasources/listening_seed_datasource.dart';
import 'features/listening/data/repositories/listening_repository_impl.dart';
import 'features/listening/domain/repositories/listening_repository.dart';
import 'features/listening/domain/usecases/evaluate_dictation.dart';
import 'features/listening/domain/usecases/get_listening_exercises.dart';
import 'features/listening/domain/usecases/import_tatoeba_listening.dart';
import 'features/listening/domain/usecases/play_listening_exercise.dart';
import 'features/listening/domain/usecases/record_listening_attempt.dart';
import 'features/listening/presentation/cubit/listening_cubit.dart';
import 'features/listening/presentation/screens/listening_screen.dart';
import 'features/progress/data/datasources/progress_local_datasource.dart';
import 'features/progress/data/repositories/progress_repository_impl.dart';
import 'features/progress/domain/repositories/progress_repository.dart';
import 'features/progress/domain/usecases/complete_daily_workout.dart';
import 'features/progress/domain/usecases/get_daily_workout.dart';
import 'features/progress/domain/usecases/get_learning_progress.dart';
import 'features/progress/domain/usecases/search_hebrew_library.dart';
import 'features/progress/presentation/cubit/progress_cubit.dart';
import 'features/progress/presentation/screens/progress_screen.dart';
import 'features/srs/data/datasources/srs_local_datasource.dart';
import 'features/srs/data/datasources/srs_seed_datasource.dart';
import 'features/srs/data/datasources/tatoeba_remote_datasource.dart';
import 'features/srs/data/repositories/srs_repository_impl.dart';
import 'features/srs/domain/repositories/srs_repository.dart';
import 'features/srs/domain/usecases/add_card_to_srs.dart';
import 'features/srs/domain/usecases/check_hebrew_typed_answer.dart';
import 'features/srs/domain/usecases/get_due_srs_cards.dart';
import 'features/srs/domain/usecases/import_open_tatoeba_cards.dart';
import 'features/srs/domain/usecases/review_srs_card.dart';
import 'features/srs/presentation/cubit/srs_session_cubit.dart';
import 'features/srs/presentation/cubit/srs_session_state.dart';
import 'features/srs/presentation/screens/srs_study_screen.dart';
import 'features/slang/data/datasources/slang_seed_datasource.dart';
import 'features/slang/data/repositories/slang_repository_impl.dart';
import 'features/slang/domain/repositories/slang_repository.dart';
import 'features/slang/domain/usecases/get_slang_expressions.dart';
import 'features/stories/data/datasources/stories_seed_datasource.dart';
import 'features/stories/data/repositories/stories_repository_impl.dart';
import 'features/stories/domain/repositories/stories_repository.dart';
import 'features/stories/domain/usecases/get_stories.dart';
import 'features/stories/domain/usecases/mark_story_completed.dart';
import 'features/stories/presentation/cubit/stories_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const logger = DeveloperAppLogger();
  final database = AppDatabase();
  final tokenStorage = FlutterSecureTokenStorage.withDefaultOptions(
    logger: logger,
  );
  final settingsStorage = SecureAppSettingsStorage.withDefaultOptions(
    logger: logger,
  );
  final apiConfig = ApiEnvironmentConfig.fromEnvironment();
  final dio = DioClientFactory.create(
    config: apiConfig,
    tokenStorage: tokenStorage,
    logger: logger,
  );

  final primaryAudio = JustAudioPlaybackService(logger: logger);
  late final HybridAudioPlaybackService audioService;
  final ttsService = createPlatformTtsSpeechService(
    logger: logger,
    onComplete: () => audioService.handleTtsComplete(),
    onError: (String message) => audioService.handleTtsError(message),
  );
  audioService = HybridAudioPlaybackService(
    primaryAudioService: primaryAudio,
    ttsService: ttsService,
    logger: logger,
  );

  final savedSpeed = await settingsStorage.readPlaybackSpeed();
  await audioService.setPlaybackSpeed(savedSpeed);

  final dialogueSeedDataSource = AssetDialogueSeedDataSource(logger: logger);
  final srsSeedDataSource = AssetSrsSeedDataSource(logger: logger);
  final listeningSeedDataSource = AssetListeningSeedDataSource(logger: logger);
  final dictionarySeedDataSource =
      AssetDictionarySeedDataSource(logger: logger);

  await _syncSeedAudioPaths(
    database: database,
    dialogueSeedDataSource: dialogueSeedDataSource,
    srsSeedDataSource: srsSeedDataSource,
    listeningSeedDataSource: listeningSeedDataSource,
    dictionarySeedDataSource: dictionarySeedDataSource,
    logger: logger,
  );

  final conversationRepo = ConversationRepositoryImpl(
    remoteDataSource: DioDialogueRemoteDataSource(
      dio: dio,
      config: apiConfig,
      logger: logger,
    ),
    localDataSource: DriftDialogueLocalDataSource(
      database: database,
      logger: logger,
    ),
    seedDataSource: dialogueSeedDataSource,
    logger: logger,
  );

  final tatoebaRemoteDataSource = DioTatoebaRemoteDataSource(
    dio: dio,
    logger: logger,
  );

  final srsRepo = SrsRepositoryImpl(
    localDataSource: DriftSrsLocalDataSource(
      database: database,
      logger: logger,
    ),
    seedDataSource: srsSeedDataSource,
    tatoebaRemoteDataSource: tatoebaRemoteDataSource,
    logger: logger,
  );

  final grammarRepo = GrammarRepositoryImpl(
    localDataSource: DriftGrammarLocalDataSource(
      database: database,
      logger: logger,
    ),
    seedDataSource: AssetGrammarSeedDataSource(logger: logger),
    logger: logger,
  );

  final listeningRepo = ListeningRepositoryImpl(
    localDataSource: DriftListeningLocalDataSource(
      database: database,
      logger: logger,
    ),
    seedDataSource: listeningSeedDataSource,
    remoteDataSource: tatoebaRemoteDataSource,
    logger: logger,
  );

  final dictionaryRepo = DictionaryRepositoryImpl(
    localDataSource: DriftDictionaryLocalDataSource(
      database: database,
      logger: logger,
    ),
    seedDataSource: dictionarySeedDataSource,
    remoteDataSource: OpenDictionaryRemoteDataSource(
      dio: dio,
      logger: logger,
    ),
    logger: logger,
  );

  final progressRepo = ProgressRepositoryImpl(
    localDataSource: DriftProgressLocalDataSource(
      database: database,
      logger: logger,
    ),
  );

  final storiesSeedDataSource = AssetStoriesSeedDataSource(logger: logger);
  final storiesRepo = StoriesRepositoryImpl(
    seedDataSource: storiesSeedDataSource,
    logger: logger,
  );

  final slangSeedDataSource = AssetSlangSeedDataSource(logger: logger);
  final slangRepo = SlangRepositoryImpl(
    dataSource: slangSeedDataSource,
  );

  runApp(
    NexusHebrewApp(
      database: database,
      conversationRepository: conversationRepo,
      srsRepository: srsRepo,
      grammarRepository: grammarRepo,
      listeningRepository: listeningRepo,
      dictionaryRepository: dictionaryRepo,
      progressRepository: progressRepo,
      storiesRepository: storiesRepo,
      slangRepository: slangRepo,
      audioService: audioService,
      settingsStorage: settingsStorage,
      logger: logger,
    ),
  );
}

Future<void> _syncSeedAudioPaths({
  required AppDatabase database,
  required DialogueSeedDataSource dialogueSeedDataSource,
  required SrsSeedDataSource srsSeedDataSource,
  required ListeningSeedDataSource listeningSeedDataSource,
  required DictionarySeedDataSource dictionarySeedDataSource,
  required AppLogger logger,
}) async {
  try {
    final dialogueFuture = dialogueSeedDataSource.loadAllSeedNodes();
    final listeningFuture = listeningSeedDataSource.loadSeedExercises();
    final srsFuture = srsSeedDataSource.loadSeedCards();
    final dictionaryFuture = dictionarySeedDataSource.loadSeedEntries();

    final dialogueNodes = (await dialogueFuture).getOrNull();
    final listeningItems = (await listeningFuture).getOrNull();
    final srsCards = (await srsFuture).getOrNull();
    final dictionaryEntries = (await dictionaryFuture).getOrNull();

    final dialogueAudioById = <String, String>{
      if (dialogueNodes != null)
        for (final node in dialogueNodes)
          if (node.audioPath != null && node.audioPath!.trim().isNotEmpty)
            node.id: node.audioPath!.trim(),
    };
    final listeningAudioById = <String, String>{
      if (listeningItems != null)
        for (final item in listeningItems)
          if (item.audioUrl != null && item.audioUrl!.trim().isNotEmpty)
            item.id: item.audioUrl!.trim(),
    };
    final srsAudioById = <String, String>{
      if (srsCards != null)
        for (final card in srsCards)
          if (card.audioUrl != null && card.audioUrl!.trim().isNotEmpty)
            card.id: card.audioUrl!.trim(),
    };
    final dictionaryAudioById = <String, String>{
      if (dictionaryEntries != null)
        for (final entry in dictionaryEntries)
          if (entry.audioUrl != null && entry.audioUrl!.trim().isNotEmpty)
            entry.id: entry.audioUrl!.trim(),
    };

    if (dialogueAudioById.isEmpty &&
        listeningAudioById.isEmpty &&
        srsAudioById.isEmpty &&
        dictionaryAudioById.isEmpty) {
      return;
    }

    await database.backfillSeedAudio(
      dialogueAudioById: dialogueAudioById,
      listeningAudioById: listeningAudioById,
      srsAudioById: srsAudioById,
      dictionaryAudioById: dictionaryAudioById,
    );
  } on Object catch (error) {
    logger.warning(
      'SeedAudioSync',
      'Non-fatal audio path backfill skipped: $error',
    );
  }
}

class NexusHebrewApp extends StatefulWidget {
  final AppDatabase? database;
  final ConversationRepository conversationRepository;
  final SrsRepository srsRepository;
  final GrammarRepository grammarRepository;
  final ListeningRepository listeningRepository;
  final DictionaryRepository dictionaryRepository;
  final ProgressRepository progressRepository;
  final StoriesRepository? storiesRepository;
  final SlangRepository? slangRepository;
  final AudioPlaybackService audioService;
  final AppSettingsStorage? settingsStorage;
  final AppLogger logger;

  const NexusHebrewApp({
    super.key,
    this.database,
    required this.conversationRepository,
    required this.srsRepository,
    required this.grammarRepository,
    required this.listeningRepository,
    required this.dictionaryRepository,
    required this.progressRepository,
    this.storiesRepository,
    this.slangRepository,
    required this.audioService,
    this.settingsStorage,
    required this.logger,
  });

  @override
  State<NexusHebrewApp> createState() => _NexusHebrewAppState();
}

class _NexusHebrewAppState extends State<NexusHebrewApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final mode =
        await widget.settingsStorage?.readThemeMode() ?? ThemeMode.system;
    if (mounted) {
      setState(() {
        _themeMode = mode;
      });
    }
  }

  Future<void> _onThemeModeChanged(ThemeMode newMode) async {
    setState(() {
      _themeMode = newMode;
    });
    await widget.settingsStorage?.writeThemeMode(newMode);
  }

  @override
  void dispose() {
    unawaited(widget.audioService.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final addCardToSrsUseCase = AddCardToSrsUseCase(
      repository: widget.srsRepository,
    );
    final getDailyWorkoutUseCase = GetDailyWorkoutUseCase(
      srsRepository: widget.srsRepository,
      grammarRepository: widget.grammarRepository,
      listeningRepository: widget.listeningRepository,
      settingsStorage: widget.settingsStorage,
    );
    final completeDailyWorkoutUseCase = CompleteDailyWorkoutUseCase(
      settingsStorage: widget.settingsStorage,
    );
    final slangDataSource = AssetSlangSeedDataSource(logger: widget.logger);
    final slangRepo = widget.slangRepository ??
        SlangRepositoryImpl(dataSource: slangDataSource);
    final getSlangUseCase = GetSlangExpressionsUseCase(slangRepo);

    return MultiBlocProvider(
      providers: [
          BlocProvider<ConversationCubit>(
            create: (_) {
              final cubit = ConversationCubit(
                getDialogueUseCase:
                    GetActiveDialogueUseCase(widget.conversationRepository),
                selectOptionUseCase:
                    SelectDialogueOptionUseCase(widget.conversationRepository),
                toggleAudioUseCase:
                    ToggleDialogueAudioUseCase(widget.audioService),
                addCardToSrsUseCase: addCardToSrsUseCase,
                audioService: widget.audioService,
                settingsStorage: widget.settingsStorage,
                logger: widget.logger,
              );
              unawaited(
                cubit.loadDialogueNode(ConversationScreen.initialNodeId),
              );
              return cubit;
            },
          ),
          BlocProvider<SrsSessionCubit>(
            create: (_) {
              final cubit = SrsSessionCubit(
                getDueCardsUseCase: GetDueSrsCardsUseCase(widget.srsRepository),
                reviewCardUseCase:
                    ReviewSrsCardUseCase(repository: widget.srsRepository),
                checkTypedAnswerUseCase: const CheckHebrewTypedAnswerUseCase(),
                importTatoebaCardsUseCase:
                    ImportOpenTatoebaCardsUseCase(widget.srsRepository),
                audioService: widget.audioService,
                logger: widget.logger,
              );
              unawaited(cubit.loadDueCards());
              return cubit;
            },
          ),
          BlocProvider<GrammarCubit>(
            create: (_) {
              final cubit = GrammarCubit(
                getVerbsUseCase: GetVerbsByBinyanUseCase(
                  widget.grammarRepository,
                ),
                checkConjugationUseCase: const CheckVerbConjugationUseCase(),
                recordPracticeUseCase: RecordGrammarPracticeUseCase(
                  widget.grammarRepository,
                ),
                addCardToSrsUseCase: addCardToSrsUseCase,
                audioService: widget.audioService,
                logger: widget.logger,
              );
              unawaited(cubit.loadVerbs());
              return cubit;
            },
          ),
          BlocProvider<ListeningCubit>(
            create: (_) {
              final cubit = ListeningCubit(
                getExercisesUseCase: GetListeningExercisesUseCase(
                  widget.listeningRepository,
                ),
                playExerciseUseCase: PlayListeningExerciseUseCase(
                  widget.audioService,
                ),
                evaluateDictationUseCase: const EvaluateDictationUseCase(),
                importTatoebaUseCase: ImportTatoebaListeningUseCase(
                  widget.listeningRepository,
                ),
                recordAttemptUseCase: RecordListeningAttemptUseCase(
                  widget.listeningRepository,
                ),
                addCardToSrsUseCase: addCardToSrsUseCase,
                audioService: widget.audioService,
                logger: widget.logger,
              );
              unawaited(cubit.loadExercises());
              return cubit;
            },
          ),
          BlocProvider<DictionaryCubit>(
            create: (_) {
              final cubit = DictionaryCubit(
                repository: widget.dictionaryRepository,
                grammarRepository: widget.grammarRepository,
                searchUseCase: const SearchDictionaryEntriesUseCase(),
                addCustomEntryUseCase: AddCustomDictionaryEntryUseCase(
                  repository: widget.dictionaryRepository,
                ),
                searchOnlineUseCase: SearchOnlineDictionaryUseCase(
                  widget.dictionaryRepository,
                ),
                addCardToSrsUseCase: addCardToSrsUseCase,
                audioService: widget.audioService,
                logger: widget.logger,
              );
              unawaited(cubit.loadDictionary());
              return cubit;
            },
          ),
          BlocProvider<ProgressCubit>(
            create: (_) {
              final cubit = ProgressCubit(
                getProgressUseCase: GetLearningProgressUseCase(
                  widget.progressRepository,
                ),
                searchLibraryUseCase: SearchHebrewLibraryUseCase(
                  widget.progressRepository,
                ),
                addCardToSrsUseCase: addCardToSrsUseCase,
                audioService: widget.audioService,
              );
              unawaited(cubit.loadProgress());
              return cubit;
            },
          ),
          BlocProvider<StoriesCubit>(
            create: (_) {
              final repo = widget.storiesRepository ??
                  StoriesRepositoryImpl(
                    seedDataSource:
                        AssetStoriesSeedDataSource(logger: widget.logger),
                    logger: widget.logger,
                  );
              final cubit = StoriesCubit(
                getStoriesUseCase: GetStoriesUseCase(repo),
                markCompletedUseCase: MarkStoryCompletedUseCase(repo),
                dictionaryRepository: widget.dictionaryRepository,
                audioService: widget.audioService,
                settingsStorage: widget.settingsStorage,
                logger: widget.logger,
              );
              unawaited(cubit.loadStories());
              return cubit;
            },
          ),
        ],
        child: MaterialApp(
          title: 'Nexus Hebrew',
          debugShowCheckedModeBanner: false,
          themeMode: _themeMode,
          theme: ThemeData(
            colorSchemeSeed: const Color(0xFF1565C0),
            brightness: Brightness.light,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorSchemeSeed: const Color(0xFF1565C0),
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            useMaterial3: true,
          ),
          home: _MainShell(
            database: widget.database,
            audioService: widget.audioService,
            settingsStorage: widget.settingsStorage,
            addCardToSrsUseCase: addCardToSrsUseCase,
            getDailyWorkoutUseCase: getDailyWorkoutUseCase,
            completeDailyWorkoutUseCase: completeDailyWorkoutUseCase,
            getSlangUseCase: getSlangUseCase,
            currentThemeMode: _themeMode,
            onThemeModeChanged: _onThemeModeChanged,
          ),
        ),
      );
    }
  }

class _MainShell extends StatefulWidget {
  final AppDatabase? database;
  final AudioPlaybackService? audioService;
  final AppSettingsStorage? settingsStorage;
  final AddCardToSrsUseCase? addCardToSrsUseCase;
  final GetDailyWorkoutUseCase? getDailyWorkoutUseCase;
  final CompleteDailyWorkoutUseCase? completeDailyWorkoutUseCase;
  final GetSlangExpressionsUseCase? getSlangUseCase;
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  const _MainShell({
    this.database,
    this.audioService,
    this.settingsStorage,
    this.addCardToSrsUseCase,
    this.getDailyWorkoutUseCase,
    this.completeDailyWorkoutUseCase,
    this.getSlangUseCase,
    this.currentThemeMode = ThemeMode.system,
    this.onThemeModeChanged,
  });

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  static const double _railBreakpoint = 840.0;
  static const double _extendedRailBreakpoint = 1120.0;

  int _selectedIndex = 0;

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 2 && context.read<SrsSessionCubit>().state is SrsSessionEmpty) {
      unawaited(context.read<SrsSessionCubit>().loadDueCards());
    } else if (index == 5) {
      unawaited(context.read<DictionaryCubit>().refreshSrsStatus());
    } else if (index == 6) {
      unawaited(context.read<ProgressCubit>().loadProgress());
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(
        audioService: widget.audioService,
        addCardToSrsUseCase: widget.addCardToSrsUseCase,
        getDailyWorkoutUseCase: widget.getDailyWorkoutUseCase,
        settingsStorage: widget.settingsStorage,
        getSlangUseCase: widget.getSlangUseCase,
        onNavigateToTab: _onDestinationSelected,
      ),
      ConversationScreen(
        audioService: widget.audioService,
        addCardToSrsUseCase: widget.addCardToSrsUseCase,
      ),
      SrsStudyScreen(
        audioService: widget.audioService,
        addCardToSrsUseCase: widget.addCardToSrsUseCase,
      ),
      GrammarScreen(
        audioService: widget.audioService,
        addCardToSrsUseCase: widget.addCardToSrsUseCase,
      ),
      ListeningScreen(
        audioService: widget.audioService,
        addCardToSrsUseCase: widget.addCardToSrsUseCase,
      ),
      const DictionaryScreen(),
      ProgressScreen(
        database: widget.database,
        audioService: widget.audioService,
        settingsStorage: widget.settingsStorage,
        currentThemeMode: widget.currentThemeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
        getDailyWorkoutUseCase: widget.getDailyWorkoutUseCase,
        completeDailyWorkoutUseCase: widget.completeDailyWorkoutUseCase,
      ),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final useRail = constraints.maxWidth >= _railBreakpoint;
        final extendedRail = constraints.maxWidth >= _extendedRailBreakpoint;
        final compactBottomLabels = constraints.maxWidth < 480.0;
        final body = IndexedStack(
          index: _selectedIndex,
          children: pages,
        );

        if (useRail) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  extended: extendedRail,
                  labelType: extendedRail
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.all,
                  onDestinationSelected: _onDestinationSelected,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_rounded),
                      label: Text('Главная'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.forum_outlined),
                      selectedIcon: Icon(Icons.forum_rounded),
                      label: Text('Диалоги'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.style_outlined),
                      selectedIcon: Icon(Icons.style_rounded),
                      label: Text('FSRS'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.account_tree_outlined),
                      selectedIcon: Icon(Icons.account_tree_rounded),
                      label: Text('Грамматика'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.headphones_outlined),
                      selectedIcon: Icon(Icons.headphones_rounded),
                      label: Text('Аудирование'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.menu_book_outlined),
                      selectedIcon: Icon(Icons.menu_book_rounded),
                      label: Text('Словарь'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.insights_outlined),
                      selectedIcon: Icon(Icons.insights_rounded),
                      label: Text('Прогресс'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: body),
              ],
            ),
          );
        }

        final baseTheme = Theme.of(context);
        return Scaffold(
          body: body,
          bottomNavigationBar: NavigationBarTheme(
            data: baseTheme.navigationBarTheme.copyWith(
              labelTextStyle: WidgetStatePropertyAll<TextStyle?>(
                baseTheme.textTheme.labelSmall?.copyWith(
                  fontSize: compactBottomLabels ? 10.0 : 11.5,
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Главная',
                ),
                NavigationDestination(
                  icon: Icon(Icons.forum_outlined),
                  selectedIcon: Icon(Icons.forum_rounded),
                  label: 'Диалоги',
                ),
                NavigationDestination(
                  icon: Icon(Icons.style_outlined),
                  selectedIcon: Icon(Icons.style_rounded),
                  label: 'FSRS',
                ),
                NavigationDestination(
                  icon: Icon(Icons.account_tree_outlined),
                  selectedIcon: Icon(Icons.account_tree_rounded),
                  label: 'Грамматика',
                ),
                NavigationDestination(
                  icon: Icon(Icons.headphones_outlined),
                  selectedIcon: Icon(Icons.headphones_rounded),
                  label: 'Аудирование',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book_rounded),
                  label: 'Словарь',
                ),
                NavigationDestination(
                  icon: Icon(Icons.insights_outlined),
                  selectedIcon: Icon(Icons.insights_rounded),
                  label: 'Прогресс',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
