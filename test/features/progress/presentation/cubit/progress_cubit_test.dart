import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/binyan.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/progress/domain/entities/learning_progress_summary.dart';
import 'package:nexus_hebrew_app/features/progress/domain/usecases/get_learning_progress.dart';
import 'package:nexus_hebrew_app/features/progress/domain/usecases/search_hebrew_library.dart';
import 'package:nexus_hebrew_app/features/progress/presentation/cubit/progress_cubit.dart';
import 'package:nexus_hebrew_app/features/progress/presentation/cubit/progress_state.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/add_card_to_srs.dart';

class _MockGetLearningProgressUseCase extends Mock
    implements GetLearningProgressUseCase {}

class _MockSearchHebrewLibraryUseCase extends Mock
    implements SearchHebrewLibraryUseCase {}

class _MockAddCardToSrsUseCase extends Mock implements AddCardToSrsUseCase {}

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}

void main() {
  final fixedNow = DateTime.utc(2026, 11, 12, 12, 0);

  late _MockGetLearningProgressUseCase getProgressUseCase;
  late _MockSearchHebrewLibraryUseCase searchLibraryUseCase;
  late _MockAddCardToSrsUseCase addCardToSrsUseCase;
  late _MockAudioPlaybackService audioService;
  late StreamController<AudioPlaybackEvent> audioEvents;

  final summaryInitial = LearningProgressSummary(
    totalSrsCards: 12,
    dueSrsCards: 3,
    newCards: 8,
    learningCards: 2,
    reviewCards: 2,
    relearningCards: 0,
    totalSrsReviews: 14,
    currentStreakDays: 2,
    activeTodayCount: 4,
    grammarAttempts: 6,
    grammarCorrect: 5,
    binyanStats: const <BinyanAccuracyStat>[
      BinyanAccuracyStat(
        binyan: Binyan.paal,
        totalAttempts: 6,
        correctAttempts: 5,
      ),
    ],
    listeningAttempts: 4,
    listeningExactMatches: 3,
    averageListeningAccuracy: 0.9,
  );

  final summaryAfterAdd = LearningProgressSummary(
    totalSrsCards: 13,
    dueSrsCards: 4,
    newCards: 9,
    learningCards: 2,
    reviewCards: 2,
    relearningCards: 0,
    totalSrsReviews: 14,
    currentStreakDays: 2,
    activeTodayCount: 4,
    grammarAttempts: 6,
    grammarCorrect: 5,
    binyanStats: const <BinyanAccuracyStat>[
      BinyanAccuracyStat(
        binyan: Binyan.paal,
        totalAttempts: 6,
        correctAttempts: 5,
      ),
    ],
    listeningAttempts: 4,
    listeningExactMatches: 3,
    averageListeningAccuracy: 0.9,
  );

  const verbHit = GlobalHebrewSearchResult(
    id: 'verb_paal_katav',
    kind: SearchSourceKind.grammar,
    hebrew: HebrewText.fixture(vocalized: 'לִכְתֹּב', normalized: 'לכתוב'),
    russianMeaning: 'писать',
    root: Shoresh.fixture(<String>['כ', 'ת', 'ב']),
    binyan: Binyan.paal,
  );

  setUpAll(() {
    registerFallbackValue(GetLearningProgressParams(asOf: fixedNow));
    registerFallbackValue(const SearchHebrewLibraryParams(query: 'כתב'));
    registerFallbackValue(
      const AddCardToSrsParams(
        id: 'fallback',
        hebrewVocalized: 'לִכְתֹּב',
        russianTranslation: 'писать',
      ),
    );
  });

  setUp(() {
    getProgressUseCase = _MockGetLearningProgressUseCase();
    searchLibraryUseCase = _MockSearchHebrewLibraryUseCase();
    addCardToSrsUseCase = _MockAddCardToSrsUseCase();
    audioService = _MockAudioPlaybackService();
    audioEvents = StreamController<AudioPlaybackEvent>.broadcast();

    when(() => audioService.statusStream).thenAnswer((_) => audioEvents.stream);
    when(() => audioService.stop())
        .thenAnswer((_) async => const Success<void, Failure>(null));
  });

  tearDown(() async {
    await audioEvents.close();
  });

  ProgressCubit buildCubit() => ProgressCubit(
        getProgressUseCase: getProgressUseCase,
        searchLibraryUseCase: searchLibraryUseCase,
        addCardToSrsUseCase: addCardToSrsUseCase,
        audioService: audioService,
        clock: () => fixedNow,
      );

  group('ProgressCubit', () {
    blocTest<ProgressCubit, ProgressState>(
      'emits [ProgressLoading, ProgressLoaded] when summary loads',
      setUp: () {
        when(() => getProgressUseCase(GetLearningProgressParams(asOf: fixedNow)))
            .thenAnswer(
          (_) async => Success<LearningProgressSummary, Failure>(summaryInitial),
        );
      },
      build: buildCubit,
      act: (ProgressCubit cubit) => cubit.loadProgress(),
      expect: () => <ProgressState>[
        const ProgressLoading(),
        ProgressLoaded(summary: summaryInitial),
      ],
    );

    blocTest<ProgressCubit, ProgressState>(
      'emits [ProgressLoading, ProgressError] when summary load fails',
      setUp: () {
        when(() => getProgressUseCase(GetLearningProgressParams(asOf: fixedNow)))
            .thenAnswer(
          (_) async => const Error<LearningProgressSummary, Failure>(
            CacheFailure('Stats unavailable'),
          ),
        );
      },
      build: buildCubit,
      act: (ProgressCubit cubit) => cubit.loadProgress(),
      expect: () => <ProgressState>[
        const ProgressLoading(),
        const ProgressError(CacheFailure('Stats unavailable')),
      ],
    );

    blocTest<ProgressCubit, ProgressState>(
      'searches across modules, adds hit to FSRS, and updates summary count',
      setUp: () {
        var calls = 0;
        when(() => getProgressUseCase(GetLearningProgressParams(asOf: fixedNow)))
            .thenAnswer((_) async {
          calls += 1;
          return Success<LearningProgressSummary, Failure>(
            calls == 1 ? summaryInitial : summaryAfterAdd,
          );
        });
        when(
          () => searchLibraryUseCase(
            const SearchHebrewLibraryParams(query: 'כתב'),
          ),
        ).thenAnswer(
          (_) async => const Success<List<GlobalHebrewSearchResult>, Failure>(
            <GlobalHebrewSearchResult>[verbHit],
          ),
        );
        when(() => addCardToSrsUseCase(any()))
            .thenAnswer((_) async => const Success<bool, Failure>(true));
      },
      build: buildCubit,
      act: (ProgressCubit cubit) async {
        await cubit.loadProgress();
        await cubit.search('כתב');
        await cubit.saveHitToSrs(verbHit);
      },
      expect: () => <ProgressState>[
        const ProgressLoading(),
        ProgressLoaded(summary: summaryInitial),
        ProgressLoaded(
          summary: summaryInitial,
          searchQuery: 'כתב',
          isSearching: true,
        ),
        ProgressLoaded(
          summary: summaryInitial,
          searchQuery: 'כתב',
          searchResults: const <GlobalHebrewSearchResult>[verbHit],
          isSearching: false,
        ),
        ProgressLoaded(
          summary: summaryAfterAdd,
          searchQuery: 'כתב',
          searchResults: const <GlobalHebrewSearchResult>[verbHit],
          isSearching: false,
          transientNotice: 'Добавлено в колоду FSRS!',
        ),
      ],
      verify: (_) {
        final captured =
            verify(() => addCardToSrsUseCase(captureAny())).captured.single
                as AddCardToSrsParams;
        expect(captured.category, LexicalCategory.verb);
        expect(captured.binyan, Binyan.paal);
      },
    );

    blocTest<ProgressCubit, ProgressState>(
      'surfaces transientNotice when search fails and tracks matching TTS audio',
      setUp: () {
        when(() => getProgressUseCase(GetLearningProgressParams(asOf: fixedNow)))
            .thenAnswer(
          (_) async => Success<LearningProgressSummary, Failure>(summaryInitial),
        );
        when(
          () => searchLibraryUseCase(
            const SearchHebrewLibraryParams(query: 'שגיאה'),
          ),
        ).thenAnswer(
          (_) async => const Error<List<GlobalHebrewSearchResult>, Failure>(
            CacheFailure('Search failed'),
          ),
        );
        when(
          () => audioService.playWithTtsFallback(
            sourcePath: null,
            fallbackHebrewText: 'לִכְתֹּב',
          ),
        ).thenAnswer((_) async {
          audioEvents.add(
            const AudioPlaybackEvent(
              status: AudioPlaybackStatus.playing,
              sourcePath: 'tts://he-IL/לִכְתֹּב',
            ),
          );
          return const Success<void, Failure>(null);
        });
      },
      build: buildCubit,
      act: (ProgressCubit cubit) async {
        await cubit.loadProgress();
        await cubit.search('שגיאה');
        await cubit.speakHit(verbHit);
      },
      expect: () => <ProgressState>[
        const ProgressLoading(),
        ProgressLoaded(summary: summaryInitial),
        ProgressLoaded(
          summary: summaryInitial,
          searchQuery: 'שגיאה',
          isSearching: true,
        ),
        ProgressLoaded(
          summary: summaryInitial,
          searchQuery: 'שגיאה',
          isSearching: false,
          transientNotice: 'Search failed',
        ),
        ProgressLoaded(
          summary: summaryInitial,
          searchQuery: 'שגיאה',
          isSearching: false,
          transientNotice: 'Search failed',
          activeSpokenHebrew: 'לִכְתֹּב',
          audioStatus: AudioPlaybackStatus.loading,
        ),
        ProgressLoaded(
          summary: summaryInitial,
          searchQuery: 'שגיאה',
          isSearching: false,
          transientNotice: 'Search failed',
          activeSpokenHebrew: 'לִכְתֹּב',
          audioStatus: AudioPlaybackStatus.playing,
        ),
      ],
    );
  });
}
