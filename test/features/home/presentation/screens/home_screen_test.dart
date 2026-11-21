import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/logging/app_logger.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/binyan.dart';
import 'package:nexus_hebrew_app/features/home/presentation/screens/home_screen.dart';
import 'package:nexus_hebrew_app/features/home/presentation/widgets/contacts_about_sheet.dart';
import 'package:nexus_hebrew_app/features/progress/domain/entities/learning_progress_summary.dart';
import 'package:nexus_hebrew_app/features/progress/domain/usecases/get_learning_progress.dart';
import 'package:nexus_hebrew_app/features/progress/domain/usecases/search_hebrew_library.dart';
import 'package:nexus_hebrew_app/features/progress/presentation/cubit/progress_cubit.dart';
import 'package:nexus_hebrew_app/features/search/presentation/widgets/omni_search_sheet.dart';
import 'package:nexus_hebrew_app/features/srs/domain/repositories/srs_repository.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/add_card_to_srs.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/check_hebrew_typed_answer.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/get_due_srs_cards.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/import_open_tatoeba_cards.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/review_srs_card.dart';
import 'package:nexus_hebrew_app/features/srs/presentation/cubit/srs_session_cubit.dart';

class _MockGetLearningProgressUseCase extends Mock
    implements GetLearningProgressUseCase {}
class _MockSearchHebrewLibraryUseCase extends Mock
    implements SearchHebrewLibraryUseCase {}
class _MockAddCardToSrsUseCase extends Mock implements AddCardToSrsUseCase {}
class _MockAudioService extends Mock implements AudioPlaybackService {}
class _MockSrsRepository extends Mock implements SrsRepository {}

void main() {
  late _MockGetLearningProgressUseCase getProgressUseCase;
  late _MockSearchHebrewLibraryUseCase searchLibraryUseCase;
  late _MockAddCardToSrsUseCase addCardToSrsUseCase;
  late _MockAudioService audioService;
  late _MockSrsRepository srsRepository;

  late ProgressCubit progressCubit;
  late SrsSessionCubit srsSessionCubit;
  late StreamController<AudioPlaybackEvent> audioEvents;

  final testSummary = LearningProgressSummary(
    totalSrsCards: 15,
    dueSrsCards: 2,
    newCards: 5,
    learningCards: 4,
    reviewCards: 6,
    relearningCards: 0,
    totalSrsReviews: 20,
    currentStreakDays: 5,
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
    registerFallbackValue(DateTime.now());
  });

  setUp(() {
    getProgressUseCase = _MockGetLearningProgressUseCase();
    searchLibraryUseCase = _MockSearchHebrewLibraryUseCase();
    addCardToSrsUseCase = _MockAddCardToSrsUseCase();
    audioService = _MockAudioService();
    srsRepository = _MockSrsRepository();

    audioEvents = StreamController<AudioPlaybackEvent>.broadcast();
    when(() => audioService.statusStream).thenAnswer((_) => audioEvents.stream);
    when(() => audioService.currentState).thenReturn(const AudioPlaybackEvent.idle());
    when(() => audioService.stop()).thenAnswer((_) async => const Success(null));
    when(() => audioService.dispose()).thenAnswer((_) async => const Success(null));
    when(() => audioService.playWithTtsFallback(
          sourcePath: any(named: 'sourcePath'),
          fallbackHebrewText: any(named: 'fallbackHebrewText'),
        )).thenAnswer((_) async => const Success(null));

    when(() => getProgressUseCase(any())).thenAnswer(
      (_) async => Success(testSummary),
    );
    when(() => searchLibraryUseCase(any())).thenAnswer(
      (_) async => const Success(<GlobalHebrewSearchResult>[]),
    );
    when(() => srsRepository.getDueCards(asOf: any(named: 'asOf'), limit: any(named: 'limit')))
        .thenAnswer((_) async => const Success([]));

    progressCubit = ProgressCubit(
      getProgressUseCase: getProgressUseCase,
      searchLibraryUseCase: searchLibraryUseCase,
      addCardToSrsUseCase: addCardToSrsUseCase,
      audioService: audioService,
    );

    srsSessionCubit = SrsSessionCubit(
      getDueCardsUseCase: GetDueSrsCardsUseCase(srsRepository),
      reviewCardUseCase: ReviewSrsCardUseCase(repository: srsRepository),
      checkTypedAnswerUseCase: const CheckHebrewTypedAnswerUseCase(),
      importTatoebaCardsUseCase: ImportOpenTatoebaCardsUseCase(srsRepository),
      audioService: audioService,
      logger: const DeveloperAppLogger(),
    );
  });

  tearDown(() async {
    await audioEvents.close();
    await progressCubit.close();
    await srsSessionCubit.close();
  });

  Widget buildWidget({ValueChanged<int>? onNavigateToTab}) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ProgressCubit>.value(value: progressCubit),
          BlocProvider<SrsSessionCubit>.value(value: srsSessionCubit),
        ],
        child: HomeScreen(
          audioService: audioService,
          addCardToSrsUseCase: addCardToSrsUseCase,
          onNavigateToTab: onNavigateToTab,
        ),
      ),
    );
  }

  group('HomeScreen', () {
    testWidgets('рендерит приветствие, карточку Слова Дня и сетку разделов', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Nexus Hebrew'), findsWidgets);
      expect(find.text('СЛОВО ДНЯ'), findsOneWidget);
      expect(find.text('Тест уровня ➔'), findsOneWidget);
      expect(find.text('Разделы обучения:'), findsOneWidget);

      expect(find.text('Диалоги'), findsOneWidget);
      expect(find.text('FSRS Карточки'), findsOneWidget);
      expect(find.text('7 Биньянов'), findsOneWidget);
      expect(find.text('Аудирование'), findsOneWidget);
      expect(find.text('Словарь'), findsOneWidget);
      expect(find.text('Прогресс'), findsOneWidget);
      expect(find.text('Алеф-Бет'), findsOneWidget);
      expect(find.text('Микро-рассказы'), findsOneWidget);
      expect(find.text('Израильский сленг'), findsOneWidget);
      expect(find.text('Матрица корней'), findsOneWidget);
    });

    testWidgets('навигация по клику на раздел вызывает onNavigateToTab', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      int? tappedTab;
      await tester.pumpWidget(
        buildWidget(onNavigateToTab: (index) => tappedTab = index),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Диалоги'));
      await tester.pumpAndSettle();
      expect(tappedTab, 1);

      await tester.tap(find.text('FSRS Карточки'));
      await tester.pumpAndSettle();
      expect(tappedTab, 2);

      await tester.tap(find.text('7 Биньянов'));
      await tester.pumpAndSettle();
      expect(tappedTab, 3);

      tappedTab = null;
      await tester.tap(find.text('Матрица корней'));
      await tester.pumpAndSettle();
      expect(tappedTab, 3);
    });

    testWidgets('открывает ContactsAboutSheet по нажатию на кнопку инфо', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final infoBtn = find.byTooltip('О приложении и контакты');
      expect(infoBtn, findsOneWidget);
      await tester.tap(infoBtn);
      await tester.pumpAndSettle();

      expect(find.byType(ContactsAboutSheet), findsOneWidget);
      expect(find.text('badmuchi'), findsOneWidget);
      expect(find.text('GitHub Репозиторий'), findsOneWidget);
      expect(find.text('Живая Web-версия (GitHub Pages)'), findsOneWidget);
    });

    testWidgets('открывает OmniSearchSheet по нажатию на иконку поиска в AppBar', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final searchBtn = find.byTooltip('Быстрый поиск (Omni-Search)');
      expect(searchBtn, findsOneWidget);
      await tester.tap(searchBtn);
      await tester.pumpAndSettle();

      expect(find.byType(OmniSearchSheet), findsOneWidget);
      expect(find.text('Быстрый поиск (Omni-Search)'), findsOneWidget);
    });

    testWidgets('открывает OmniSearchSheet по нажатию на строку поиска в дашборде', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final searchBar = find.text('Поиск по словарю, сленгу, корням и алфавиту...');
      expect(searchBar, findsOneWidget);
      await tester.tap(searchBar);
      await tester.pumpAndSettle();

      expect(find.byType(OmniSearchSheet), findsOneWidget);
    });
  });
}
