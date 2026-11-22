import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/audio/offline_audio_cache_service.dart';
import 'package:nexus_hebrew_app/core/database/app_database.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/binyan.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/progress/domain/entities/daily_workout_plan.dart';
import 'package:nexus_hebrew_app/features/progress/domain/entities/learning_progress_summary.dart';
import 'package:nexus_hebrew_app/features/progress/domain/usecases/complete_daily_workout.dart';
import 'package:nexus_hebrew_app/features/progress/domain/usecases/get_daily_workout.dart';
import 'package:nexus_hebrew_app/features/progress/domain/usecases/get_learning_progress.dart';
import 'package:nexus_hebrew_app/features/progress/domain/usecases/search_hebrew_library.dart';
import 'package:nexus_hebrew_app/features/progress/presentation/cubit/progress_cubit.dart';
import 'package:nexus_hebrew_app/features/progress/presentation/screens/daily_workout_screen.dart';
import 'package:nexus_hebrew_app/features/progress/presentation/screens/progress_screen.dart';
import 'package:nexus_hebrew_app/features/progress/presentation/widgets/database_backup_dialog.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/fsrs_models.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/add_card_to_srs.dart';

class _MockGetLearningProgressUseCase extends Mock
    implements GetLearningProgressUseCase {}

class _MockSearchHebrewLibraryUseCase extends Mock
    implements SearchHebrewLibraryUseCase {}

class _MockAddCardToSrsUseCase extends Mock implements AddCardToSrsUseCase {}

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}

class _MockGetDailyWorkoutUseCase extends Mock
    implements GetDailyWorkoutUseCase {}

class _MockCompleteDailyWorkoutUseCase extends Mock
    implements CompleteDailyWorkoutUseCase {}

class _MockAppDatabase extends Mock implements AppDatabase {}

class _MockOfflineAudioCacheService extends Mock
    implements OfflineAudioCacheService {}

void main() {
  late _MockGetLearningProgressUseCase getProgressUseCase;
  late _MockSearchHebrewLibraryUseCase searchLibraryUseCase;
  late _MockAddCardToSrsUseCase addCardToSrsUseCase;
  late _MockAudioPlaybackService audioService;
  late StreamController<AudioPlaybackEvent> audioEvents;

  final summary = LearningProgressSummary(
    totalSrsCards: 15,
    dueSrsCards: 2,
    newCards: 5,
    learningCards: 4,
    reviewCards: 6,
    relearningCards: 0,
    totalSrsReviews: 20,
    currentStreakDays: 4,
    activeTodayCount: 5,
    grammarAttempts: 8,
    grammarCorrect: 7,
    binyanStats: const <BinyanAccuracyStat>[
      BinyanAccuracyStat(
        binyan: Binyan.paal,
        totalAttempts: 5,
        correctAttempts: 5,
      ),
    ],
    listeningAttempts: 4,
    listeningExactMatches: 3,
    averageListeningAccuracy: 0.88,
  );

  setUpAll(() {
    registerFallbackValue(GetLearningProgressParams(asOf: DateTime.now()));
    registerFallbackValue(const SearchHebrewLibraryParams(query: 'test'));
  });

  setUp(() {
    getProgressUseCase = _MockGetLearningProgressUseCase();
    searchLibraryUseCase = _MockSearchHebrewLibraryUseCase();
    addCardToSrsUseCase = _MockAddCardToSrsUseCase();
    audioService = _MockAudioPlaybackService();
    audioEvents = StreamController<AudioPlaybackEvent>.broadcast();

    when(() => audioService.statusStream).thenAnswer((_) => audioEvents.stream);
    when(() => audioService.currentSpeed).thenReturn(1.0);
    when(() => audioService.setPlaybackSpeed(any()))
        .thenAnswer((_) async => const Success(null));
    when(() => getProgressUseCase(any()))
        .thenAnswer((_) async => Success(summary));
    when(() => searchLibraryUseCase(any()))
        .thenAnswer((_) async => const Success(<GlobalHebrewSearchResult>[]));
  });

  tearDown(() async {
    await audioEvents.close();
  });

  ProgressCubit buildCubit() {
    return ProgressCubit(
      getProgressUseCase: getProgressUseCase,
      searchLibraryUseCase: searchLibraryUseCase,
      addCardToSrsUseCase: addCardToSrsUseCase,
      audioService: audioService,
    );
  }

  Widget createSubject(ProgressCubit cubit) {
    return MaterialApp(
      home: BlocProvider<ProgressCubit>.value(
        value: cubit,
        child: const ProgressScreen(),
      ),
    );
  }

  testWidgets('Отображает уровень, XP и карточку Достижений', (tester) async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await cubit.loadProgress();

    await tester.pumpWidget(createSubject(cubit));
    await tester.pumpAndSettle();

    expect(find.text('Прогресс · Поиск'), findsOneWidget);
    expect(find.textContaining('XP накоплено'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Карта активности'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Карта активности'), findsOneWidget);
    expect(find.text('Серия: 4 дн.'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Достижения и бейджи 🏆'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Достижения и бейджи 🏆'), findsOneWidget);
    // Должны быть бейджи
    expect(find.text('Блиц-спринтер ⚡️'), findsOneWidget);
    expect(find.text('Ударный режим 🔥'), findsOneWidget);
    expect(find.text('База FSRS 🧠'), findsOneWidget);
  });

  testWidgets('Тап по бейджу открывает диалог с описанием и прогрессом', (tester) async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await cubit.loadProgress();

    await tester.pumpWidget(createSubject(cubit));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Ударный режим 🔥'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    // Нажимаем на бейдж Ударный режим
    await tester.tap(find.text('Ударный режим 🔥'));
    await tester.pumpAndSettle();

    // Проверяем диалог
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Удерживай серию занятий 3 дня подряд'), findsOneWidget);
    expect(find.text('Понятно'), findsOneWidget);

    await tester.tap(find.text('Понятно'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Отображает блок Настройки озвучки и темпа речи с сегментами скорости', (tester) async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await cubit.loadProgress();

    await tester.pumpWidget(createSubject(cubit));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Настройки озвучки и темпа речи'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Настройки озвучки и темпа речи'), findsOneWidget);
    expect(find.text('0.75x'), findsOneWidget);
    expect(find.text('1.0x'), findsOneWidget);
  });

  testWidgets('Кнопка в AppBar и блок Тема оформления переключают тему', (tester) async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await cubit.loadProgress();

    ThemeMode? selectedTheme;

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProgressCubit>.value(
          value: cubit,
          child: ProgressScreen(
            currentThemeMode: ThemeMode.light,
            onThemeModeChanged: (mode) => selectedTheme = mode,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Быстрая кнопка темы в AppBar
    final themeToggleBtn = find.byTooltip('Переключить на тёмную тему');
    expect(themeToggleBtn, findsOneWidget);
    await tester.tap(themeToggleBtn);
    expect(selectedTheme, ThemeMode.dark);

    // Скроллим к блоку темы
    await tester.scrollUntilVisible(
      find.text('Тема оформления'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Тема оформления'), findsOneWidget);
    expect(find.text('Системная'), findsOneWidget);
    expect(find.text('Светлая'), findsOneWidget);
    expect(find.text('Тёмная'), findsOneWidget);

    await tester.tap(find.text('Тёмная'));
    expect(selectedTheme, ThemeMode.dark);
  });

  testWidgets('Отображает карточку Тренировка дня и открывает DailyWorkoutScreen', (tester) async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await cubit.loadProgress();

    final getWorkoutMock = _MockGetDailyWorkoutUseCase();
    final completeWorkoutMock = _MockCompleteDailyWorkoutUseCase();

    final plan = DailyWorkoutPlan(
      date: DateTime.utc(2026, 11, 16),
      cards: [
        SrsCard(
          id: 'card-1',
          hebrew: const HebrewText.fixture(vocalized: 'שָׁלוֹם', normalized: 'שלום'),
          russianTranslation: 'Привет',
          memory: FsrsMemoryState.initial(now: DateTime.utc(2026, 1, 1)),
          attribution: const ContentAttribution(sourceName: 'Seed', licenseName: 'CC-BY'),
        ),
      ],
      isCompletedToday: false,
    );

    when(() => getWorkoutMock.call(asOf: any(named: 'asOf')))
        .thenAnswer((_) async => Success(plan));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProgressCubit>.value(
          value: cubit,
          child: ProgressScreen(
            getDailyWorkoutUseCase: getWorkoutMock,
            completeDailyWorkoutUseCase: completeWorkoutMock,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Тренировка дня · 5 минут'), findsOneWidget);
    expect(find.text('+50 XP'), findsOneWidget);
    expect(find.text('Начать тренировку дня'), findsOneWidget);

    await tester.tap(find.text('Начать тренировку дня'));
    await tester.pumpAndSettle();

    expect(find.byType(DailyWorkoutScreen), findsOneWidget);
  });

  testWidgets('Отображает карточку Резервная копия прогресса при наличии database', (tester) async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await cubit.loadProgress();

    final db = _MockAppDatabase();
    when(() => db.getAllSrsCards()).thenAnswer((_) async => []);
    when(() => db.getAllSrsReviewLogs()).thenAnswer((_) async => []);
    when(() => db.getAllGrammarPracticeLogs()).thenAnswer((_) async => []);
    when(() => db.getAllListeningAttemptLogs()).thenAnswer((_) async => []);
    when(() => db.getAllDictionaryEntries()).thenAnswer((_) async => []);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProgressCubit>.value(
          value: cubit,
          child: ProgressScreen(database: db),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Резервная копия прогресса'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Резервная копия прогресса'), findsOneWidget);
    expect(find.text('Бэкап'), findsOneWidget);

    await tester.tap(find.text('Бэкап'));
    await tester.pumpAndSettle();

    expect(find.byType(DatabaseBackupDialog), findsOneWidget);
  });

  testWidgets('Отображает карточки Мастер корней и Ситуации в Израиле', (tester) async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await cubit.loadProgress();

    await tester.pumpWidget(createSubject(cubit));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Лаборатория корней (Шореш)'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Лаборатория корней (Шореш)'), findsOneWidget);
    expect(find.text('Открыть древо корней и квест'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Реальный Израиль: Быт'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Реальный Израиль: Быт'), findsOneWidget);
    expect(find.text('Перейти к бытовым ситуациям'), findsOneWidget);
  });

  testWidgets('Отображает карточку определения уровня CEFR', (tester) async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await cubit.loadProgress();

    await tester.pumpWidget(createSubject(cubit));
    await tester.pumpAndSettle();

    expect(find.text('Определить уровень иврита'), findsOneWidget);
    expect(find.text('Пройти'), findsOneWidget);
  });

  testWidgets('Отображает контролы офлайн-кэша аудио и запускает предзагрузку', (tester) async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    await cubit.loadProgress();

    final cacheMock = _MockOfflineAudioCacheService();
    when(() => cacheMock.getCachedAudioCount()).thenAnswer((_) async => 524);
    when(() => cacheMock.getLastPreloadDate())
        .thenAnswer((_) async => DateTime.utc(2026, 11, 22));
    when(() => cacheMock.preloadAllEssentialAudio(
          additionalUrls: any(named: 'additionalUrls'),
        )).thenAnswer(
      (_) => Stream.value(
        const AudioPreloadProgress(
          total: 524,
          completed: 524,
          failed: 0,
          currentItem: 'Готово',
          isFinished: true,
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProgressCubit>.value(
          value: cubit,
          child: ProgressScreen(
            audioCacheService: cacheMock,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Офлайн-кэш озвучки'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Офлайн-кэш озвучки'), findsOneWidget);
    expect(find.text('524 файлов готово без интернета ✈️'), findsOneWidget);
    expect(find.text('Обновить офлайн-аудио'), findsOneWidget);

    await tester.tap(find.text('Обновить офлайн-аудио'));
    await tester.pumpAndSettle();

    verify(() => cacheMock.preloadAllEssentialAudio()).called(1);
  });
}
