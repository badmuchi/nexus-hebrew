import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/logging/app_logger.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/listening/domain/entities/listening_exercise.dart';
import 'package:nexus_hebrew_app/features/listening/domain/usecases/evaluate_dictation.dart';
import 'package:nexus_hebrew_app/features/listening/domain/usecases/get_listening_exercises.dart';
import 'package:nexus_hebrew_app/features/listening/domain/usecases/import_tatoeba_listening.dart';
import 'package:nexus_hebrew_app/features/listening/domain/usecases/play_listening_exercise.dart';
import 'package:nexus_hebrew_app/features/listening/domain/usecases/record_listening_attempt.dart';
import 'package:nexus_hebrew_app/features/listening/presentation/cubit/listening_cubit.dart';
import 'package:nexus_hebrew_app/features/listening/presentation/cubit/listening_state.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/add_card_to_srs.dart';

class _MockGetListeningExercisesUseCase extends Mock
    implements GetListeningExercisesUseCase {}

class _MockPlayListeningExerciseUseCase extends Mock
    implements PlayListeningExerciseUseCase {}

class _MockImportTatoebaListeningUseCase extends Mock
    implements ImportTatoebaListeningUseCase {}

class _MockRecordListeningAttemptUseCase extends Mock
    implements RecordListeningAttemptUseCase {}

class _MockAddCardToSrsUseCase extends Mock implements AddCardToSrsUseCase {}

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}

void main() {
  final fixedNow = DateTime.utc(2026, 11, 11, 22, 30);

  late _MockGetListeningExercisesUseCase getExercisesUseCase;
  late _MockPlayListeningExerciseUseCase playExerciseUseCase;
  late _MockImportTatoebaListeningUseCase importTatoebaUseCase;
  late _MockRecordListeningAttemptUseCase recordAttemptUseCase;
  late _MockAddCardToSrsUseCase addCardToSrsUseCase;
  late _MockAudioPlaybackService audioService;
  late StreamController<AudioPlaybackEvent> audioEvents;

  final exercise1 = ListeningExercise(
    id: 'listen_beg_1',
    transcript: const HebrewText.fixture(
      vocalized: 'אֲנִי רוֹצֶה קָפֶה',
      normalized: 'אני רוצה קפה',
    ),
    russianTranslation: 'Я хочу кофе',
    audioUrl: 'https://audio.tatoeba.org/sentences/heb/1.mp3',
    difficulty: ListeningDifficulty.beginner,
    focusWords: const <String>['רוֹצֶה', 'קָפֶה'],
    attribution: const ContentAttribution(
      sourceName: 'Tatoeba',
      licenseName: 'CC0 1.0',
    ),
  );

  final importedExercise = ListeningExercise(
    id: 'listen_tatoeba_2',
    transcript: const HebrewText.fixture(
      vocalized: 'שָׁלוֹם רַב',
      normalized: 'שלום רב',
    ),
    russianTranslation: 'Большой привет',
    difficulty: ListeningDifficulty.beginner,
    focusWords: const <String>['שָׁלוֹם'],
    attribution: const ContentAttribution(
      sourceName: 'Tatoeba',
      licenseName: 'CC0 1.0',
    ),
  );

  setUpAll(() {
    registerFallbackValue(const GetListeningExercisesParams());
    registerFallbackValue(
      PlayListeningExerciseParams(exercise: exercise1, speed: 1.0),
    );
    registerFallbackValue(
      const ImportTatoebaListeningParams(query: 'קפה', limit: 8),
    );
    registerFallbackValue(
      RecordListeningAttemptParams(
        exerciseId: 'listen_beg_1',
        wordAccuracy: 1.0,
        isExactMatch: true,
        attemptedAt: fixedNow,
      ),
    );
    registerFallbackValue(
      const AddCardToSrsParams(
        id: 'fallback',
        hebrewVocalized: 'קָפֶה',
        russianTranslation: 'Кофе',
      ),
    );
  });

  setUp(() {
    getExercisesUseCase = _MockGetListeningExercisesUseCase();
    playExerciseUseCase = _MockPlayListeningExerciseUseCase();
    importTatoebaUseCase = _MockImportTatoebaListeningUseCase();
    recordAttemptUseCase = _MockRecordListeningAttemptUseCase();
    addCardToSrsUseCase = _MockAddCardToSrsUseCase();
    audioService = _MockAudioPlaybackService();
    audioEvents = StreamController<AudioPlaybackEvent>.broadcast();

    when(() => audioService.statusStream).thenAnswer((_) => audioEvents.stream);
    when(() => audioService.currentSpeed).thenReturn(1.0);
    when(() => audioService.stop())
        .thenAnswer((_) async => const Success<void, Failure>(null));
    when(() => audioService.setPlaybackSpeed(any()))
        .thenAnswer((_) async => const Success<void, Failure>(null));
    when(() => playExerciseUseCase(any()))
        .thenAnswer((_) async => const Success<void, Failure>(null));
    when(() => recordAttemptUseCase(any()))
        .thenAnswer((_) async => const Success<void, Failure>(null));
  });

  tearDown(() async {
    await audioEvents.close();
  });

  ListeningCubit buildCubit() => ListeningCubit(
        getExercisesUseCase: getExercisesUseCase,
        playExerciseUseCase: playExerciseUseCase,
        evaluateDictationUseCase: const EvaluateDictationUseCase(),
        importTatoebaUseCase: importTatoebaUseCase,
        recordAttemptUseCase: recordAttemptUseCase,
        addCardToSrsUseCase: addCardToSrsUseCase,
        audioService: audioService,
        logger: const NoOpAppLogger(),
        clock: () => fixedNow,
      );

  group('ListeningCubit', () {
    blocTest<ListeningCubit, ListeningState>(
      'emits [ListeningLoading, ListeningLoaded] when exercises load',
      setUp: () {
        when(() => getExercisesUseCase(const GetListeningExercisesParams()))
            .thenAnswer(
          (_) async => Success<List<ListeningExercise>, Failure>(
            <ListeningExercise>[exercise1],
          ),
        );
      },
      build: buildCubit,
      act: (ListeningCubit cubit) => cubit.loadExercises(),
      expect: () => <ListeningState>[
        const ListeningLoading(),
        ListeningLoaded(
          exercises: <ListeningExercise>[exercise1],
          playbackSpeed: 1.0,
        ),
      ],
    );

    blocTest<ListeningCubit, ListeningState>(
      'emits [ListeningLoading, ListeningError] on repository failure',
      setUp: () {
        when(() => getExercisesUseCase(const GetListeningExercisesParams()))
            .thenAnswer(
          (_) async => const Error<List<ListeningExercise>, Failure>(
            CacheFailure('Listening seed failed'),
          ),
        );
      },
      build: buildCubit,
      act: (ListeningCubit cubit) => cubit.loadExercises(),
      expect: () => <ListeningState>[
        const ListeningLoading(),
        const ListeningError(CacheFailure('Listening seed failed')),
      ],
    );

    blocTest<ListeningCubit, ListeningState>(
      'switches speed to 0.75x, plays active exercise, and filters audio events',
      setUp: () {
        when(() => getExercisesUseCase(const GetListeningExercisesParams()))
            .thenAnswer(
          (_) async => Success<List<ListeningExercise>, Failure>(
            <ListeningExercise>[exercise1],
          ),
        );
        when(
          () => playExerciseUseCase(
            PlayListeningExerciseParams(exercise: exercise1, speed: 0.75),
          ),
        ).thenAnswer((_) async {
          audioEvents.add(
            AudioPlaybackEvent(
              status: AudioPlaybackStatus.playing,
              sourcePath: exercise1.audioUrl,
            ),
          );
          return const Success<void, Failure>(null);
        });
      },
      build: buildCubit,
      act: (ListeningCubit cubit) async {
        await cubit.loadExercises();
        await cubit.setPlaybackSpeed(0.75);
        await cubit.togglePlayCurrent();
        audioEvents.add(
          const AudioPlaybackEvent(
            status: AudioPlaybackStatus.playing,
            sourcePath: 'https://other-tab.mp3',
          ),
        );
      },
      expect: () => <ListeningState>[
        const ListeningLoading(),
        ListeningLoaded(exercises: <ListeningExercise>[exercise1]),
        ListeningLoaded(
          exercises: <ListeningExercise>[exercise1],
          playbackSpeed: 0.75,
        ),
        ListeningLoaded(
          exercises: <ListeningExercise>[exercise1],
          playbackSpeed: 0.75,
          audioStatus: AudioPlaybackStatus.loading,
        ),
        ListeningLoaded(
          exercises: <ListeningExercise>[exercise1],
          playbackSpeed: 0.75,
          audioStatus: AudioPlaybackStatus.playing,
        ),
      ],
    );

    blocTest<ListeningCubit, ListeningState>(
      'scores Hebrew dictation, persists attempt log, and surfaces ValidationFailure notice on blank input',
      setUp: () {
        when(() => getExercisesUseCase(const GetListeningExercisesParams()))
            .thenAnswer(
          (_) async => Success<List<ListeningExercise>, Failure>(
            <ListeningExercise>[exercise1],
          ),
        );
      },
      build: buildCubit,
      act: (ListeningCubit cubit) async {
        await cubit.loadExercises();
        await cubit.submitDictation('   ');
        await cubit.submitDictation('אני רוצה קפה');
      },
      expect: () => <ListeningState>[
        const ListeningLoading(),
        ListeningLoaded(exercises: <ListeningExercise>[exercise1]),
        ListeningLoaded(
          exercises: <ListeningExercise>[exercise1],
          transientNotice: 'Введи услышанный текст на иврите для проверки.',
        ),
        ListeningLoaded(
          exercises: <ListeningExercise>[exercise1],
          lastComparison: DictationComparison(
            isExactMatch: true,
            wordAccuracy: 1.0,
            expectedWords: const <String>['אני', 'רוצה', 'קפה'],
            matchedWords: const <String>['אני', 'רוצה', 'קפה'],
            missedWords: const <String>[],
            normalizedUserInput: 'אני רוצה קפה',
            normalizedExpected: 'אני רוצה קפה',
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => recordAttemptUseCase(
            RecordListeningAttemptParams(
              exerciseId: 'listen_beg_1',
              wordAccuracy: 1.0,
              isExactMatch: true,
              attemptedAt: fixedNow,
            ),
          ),
        ).called(1);
      },
    );

    blocTest<ListeningCubit, ListeningState>(
      'imports open-licensed Tatoeba sentences and refreshes queue, or reports failure cleanly',
      setUp: () {
        var callCount = 0;
        when(() => getExercisesUseCase(const GetListeningExercisesParams()))
            .thenAnswer((_) async {
          callCount += 1;
          if (callCount == 1) {
            return Success<List<ListeningExercise>, Failure>(
              <ListeningExercise>[exercise1],
            );
          }
          return Success<List<ListeningExercise>, Failure>(
            <ListeningExercise>[exercise1, importedExercise],
          );
        });
        when(
          () => importTatoebaUseCase(
            const ImportTatoebaListeningParams(query: 'שלום', limit: 8),
          ),
        ).thenAnswer(
          (_) async => Success<List<ListeningExercise>, Failure>(
            <ListeningExercise>[importedExercise],
          ),
        );
      },
      build: buildCubit,
      act: (ListeningCubit cubit) async {
        await cubit.loadExercises();
        await cubit.importFromTatoeba('שלום');
      },
      expect: () => <ListeningState>[
        const ListeningLoading(),
        ListeningLoaded(exercises: <ListeningExercise>[exercise1]),
        ListeningLoaded(
          exercises: <ListeningExercise>[exercise1],
          isImporting: true,
        ),
        ListeningLoaded(
          exercises: <ListeningExercise>[exercise1, importedExercise],
          isImporting: false,
          transientNotice: 'Импортировано из Tatoeba: 1 фраз',
        ),
      ],
    );

    blocTest<ListeningCubit, ListeningState>(
      'emits transientNotice and resets isImporting when Tatoeba import fails',
      setUp: () {
        when(() => getExercisesUseCase(const GetListeningExercisesParams()))
            .thenAnswer(
          (_) async => Success<List<ListeningExercise>, Failure>(
            <ListeningExercise>[exercise1],
          ),
        );
        when(
          () => importTatoebaUseCase(
            const ImportTatoebaListeningParams(query: 'קפה', limit: 8),
          ),
        ).thenAnswer(
          (_) async => const Error<List<ListeningExercise>, Failure>(
            NetworkFailure('Offline: Tatoeba unreachable'),
          ),
        );
      },
      build: buildCubit,
      act: (ListeningCubit cubit) async {
        await cubit.loadExercises();
        await cubit.importFromTatoeba('קפה');
      },
      expect: () => <ListeningState>[
        const ListeningLoading(),
        ListeningLoaded(exercises: <ListeningExercise>[exercise1]),
        ListeningLoaded(
          exercises: <ListeningExercise>[exercise1],
          isImporting: true,
        ),
        ListeningLoaded(
          exercises: <ListeningExercise>[exercise1],
          isImporting: false,
          transientNotice: 'Offline: Tatoeba unreachable',
        ),
      ],
    );

    blocTest<ListeningCubit, ListeningState>(
      'saves listening exercise and focus word to FSRS in one tap',
      setUp: () {
        when(() => getExercisesUseCase(const GetListeningExercisesParams()))
            .thenAnswer(
          (_) async => Success<List<ListeningExercise>, Failure>(
            <ListeningExercise>[exercise1],
          ),
        );
        var call = 0;
        when(() => addCardToSrsUseCase(any())).thenAnswer((_) async {
          call += 1;
          return Success<bool, Failure>(call == 1);
        });
      },
      build: buildCubit,
      act: (ListeningCubit cubit) async {
        await cubit.loadExercises();
        await cubit.saveExerciseToSrs(exercise1);
        await cubit.saveFocusWordToSrs(exercise1, 'קָפֶה');
      },
      expect: () => <ListeningState>[
        const ListeningLoading(),
        ListeningLoaded(exercises: <ListeningExercise>[exercise1]),
        ListeningLoaded(
          exercises: <ListeningExercise>[exercise1],
          transientNotice: 'Фраза добавлена в колоду FSRS!',
        ),
        ListeningLoaded(
          exercises: <ListeningExercise>[exercise1],
          transientNotice: 'Это слово уже есть в колоде FSRS',
        ),
      ],
    );

    blocTest<ListeningCubit, ListeningState>(
      'switches between Word Puzzle mode and Keyboard mode',
      build: buildCubit,
      seed: () => ListeningLoaded(
        exercises: <ListeningExercise>[exercise1],
        answerMode: ListeningAnswerMode.puzzle,
      ),
      act: (ListeningCubit cubit) {
        cubit.setAnswerMode(ListeningAnswerMode.keyboard);
        cubit.setAnswerMode(ListeningAnswerMode.puzzle);
      },
      expect: () => <ListeningState>[
        ListeningLoaded(
          exercises: <ListeningExercise>[exercise1],
          answerMode: ListeningAnswerMode.keyboard,
        ),
        ListeningLoaded(
          exercises: <ListeningExercise>[exercise1],
          answerMode: ListeningAnswerMode.puzzle,
        ),
      ],
    );
  });
}
