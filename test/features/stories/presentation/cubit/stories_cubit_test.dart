import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/logging/app_logger.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/repositories/dictionary_repository.dart';
import 'package:nexus_hebrew_app/features/stories/domain/entities/story.dart';
import 'package:nexus_hebrew_app/features/stories/domain/repositories/stories_repository.dart';
import 'package:nexus_hebrew_app/features/stories/domain/usecases/get_stories.dart';
import 'package:nexus_hebrew_app/features/stories/domain/usecases/mark_story_completed.dart';
import 'package:nexus_hebrew_app/features/stories/presentation/cubit/stories_cubit.dart';
import 'package:nexus_hebrew_app/features/stories/presentation/cubit/stories_state.dart';

class _MockStoriesRepository extends Mock implements StoriesRepository {}

class _MockDictionaryRepository extends Mock implements DictionaryRepository {}

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}

void main() {
  late _MockStoriesRepository storiesRepo;
  late _MockDictionaryRepository dictRepo;
  late _MockAudioPlaybackService audioService;
  late StreamController<AudioPlaybackEvent> audioStreamController;

  const testSentence = StorySentence(
    id: 's1',
    hebrewVocalized: 'בֹּקֶר טוֹב',
    hebrewNormalized: 'בוקר טוב',
    russianTranslation: 'Доброе утро',
    audioUrl: null,
    tokens: [
      StoryWordToken(
        wordVocalized: 'בֹּקֶר',
        wordNormalized: 'בוקר',
        russianTranslation: 'утро',
      ),
    ],
  );

  final testStory = Story(
    id: 'story_1',
    titleHebrew: HebrewText.create('בֹּקֶר').getOrNull()!,
    titleRussian: 'Утро',
    level: 'A1',
    readingTimeMinutes: 2,
    coverEmoji: '☕',
    summaryRussian: 'Короткий рассказ',
    paragraphs: [
      const StoryParagraph(id: 'p1', sentences: [testSentence]),
    ],
  );

  setUp(() {
    storiesRepo = _MockStoriesRepository();
    dictRepo = _MockDictionaryRepository();
    audioService = _MockAudioPlaybackService();
    audioStreamController = StreamController<AudioPlaybackEvent>.broadcast();

    when(() => audioService.statusStream)
        .thenAnswer((_) => audioStreamController.stream);
    when(() => audioService.currentSpeed).thenReturn(1.0);
    when(() => audioService.setPlaybackSpeed(any()))
        .thenAnswer((_) async => const Success<void, Failure>(null));
    when(() => audioService.stop())
        .thenAnswer((_) async => const Success<void, Failure>(null));
    when(
      () => audioService.playWithTtsFallback(
        sourcePath: any(named: 'sourcePath'),
        fallbackHebrewText: any(named: 'fallbackHebrewText'),
      ),
    ).thenAnswer((_) async => const Success<void, Failure>(null));
    when(() => dictRepo.getSrsNormalizedForms())
        .thenAnswer((_) async => const Success<Set<String>, Failure>(<String>{}));
  });

  tearDown(() async {
    await audioStreamController.close();
  });

  StoriesCubit buildCubit() {
    return StoriesCubit(
      getStoriesUseCase: GetStoriesUseCase(storiesRepo),
      markCompletedUseCase: MarkStoryCompletedUseCase(storiesRepo),
      dictionaryRepository: dictRepo,
      audioService: audioService,
      logger: const DeveloperAppLogger(),
    );
  }

  group('StoriesCubit', () {
    test('initial state is StoriesInitial', () {
      expect(buildCubit().state, equals(const StoriesInitial()));
    });

    blocTest<StoriesCubit, StoriesState>(
      'loads stories successfully',
      setUp: () {
        when(() => storiesRepo.getStories())
            .thenAnswer((_) async => Success([testStory]));
      },
      build: buildCubit,
      act: (cubit) => cubit.loadStories(),
      expect: () => [
        const StoriesLoading(),
        isA<StoriesLoaded>()
            .having((s) => s.allStories.length, 'allStories length', 1)
            .having((s) => s.visibleStories.length, 'visibleStories length', 1),
      ],
    );

    blocTest<StoriesCubit, StoriesState>(
      'filters visible stories by level',
      setUp: () {
        when(() => storiesRepo.getStories())
            .thenAnswer((_) async => Success([testStory]));
      },
      build: buildCubit,
      seed: () => StoriesLoaded(
        allStories: [testStory],
        completedStoryIds: const {},
      ),
      act: (cubit) {
        cubit.setLevelFilter('A2');
      },
      expect: () => [
        isA<StoriesLoaded>()
            .having((s) => s.activeLevelFilter, 'filter', 'A2')
            .having((s) => s.visibleStories.length, 'visible', 0),
      ],
    );

    blocTest<StoriesCubit, StoriesState>(
      'toggles nikkud and translation settings',
      build: buildCubit,
      seed: () => StoriesLoaded(
        allStories: [testStory],
        completedStoryIds: const {},
        showNikkud: true,
        showTranslation: true,
      ),
      act: (cubit) {
        cubit.toggleNikkud();
        cubit.toggleTranslation();
        cubit.adjustFontSize(2.0);
      },
      expect: () => [
        isA<StoriesLoaded>().having((s) => s.showNikkud, 'nikkud', false),
        isA<StoriesLoaded>().having((s) => s.showTranslation, 'translation', false),
        isA<StoriesLoaded>().having((s) => s.fontSizeDelta, 'fontSizeDelta', 2.0),
      ],
    );

    blocTest<StoriesCubit, StoriesState>(
      'marks story completed',
      setUp: () {
        when(() => storiesRepo.markStoryCompleted('story_1'))
            .thenAnswer((_) async => const Success(null));
      },
      build: buildCubit,
      seed: () => StoriesLoaded(
        allStories: [testStory],
        completedStoryIds: const {},
      ),
      act: (cubit) => cubit.markCompleted('story_1'),
      expect: () => [
        isA<StoriesLoaded>()
            .having((s) => s.completedStoryIds.contains('story_1'), 'contains', true)
            .having((s) => s.transientNotice, 'notice', isNotNull),
      ],
    );

    blocTest<StoriesCubit, StoriesState>(
      'plays sentence and updates playingSentenceId until audio completes',
      build: buildCubit,
      seed: () => StoriesLoaded(
        allStories: [testStory],
        completedStoryIds: const {},
      ),
      act: (cubit) async {
        final future = cubit.playSentence(testSentence);
        await Future<void>.delayed(Duration.zero);
        audioStreamController.add(
          const AudioPlaybackEvent(
            sourcePath: null,
            status: AudioPlaybackStatus.completed,
          ),
        );
        await future;
      },
      expect: () => [
        isA<StoriesLoaded>().having((s) => s.playingSentenceId, 'sentenceId', 's1'),
        isA<StoriesLoaded>().having((s) => s.playingSentenceId, 'sentenceId', isNull),
      ],
      verify: (_) {
        verify(
          () => audioService.playWithTtsFallback(
            sourcePath: null,
            fallbackHebrewText: 'בֹּקֶר טוֹב',
          ),
        ).called(1);
      },
    );

    blocTest<StoriesCubit, StoriesState>(
      'plays full story sequentially and resets when done',
      build: buildCubit,
      seed: () => StoriesLoaded(
        allStories: [testStory],
        completedStoryIds: const {},
      ),
      act: (cubit) async {
        final future = cubit.playFullStory(testStory);
        await Future<void>.delayed(Duration.zero);
        audioStreamController.add(
          const AudioPlaybackEvent(
            sourcePath: null,
            status: AudioPlaybackStatus.completed,
          ),
        );
        await future;
      },
      expect: () => [
        isA<StoriesLoaded>()
            .having((s) => s.isPlayingStory, 'isPlayingStory', true),
        isA<StoriesLoaded>()
            .having((s) => s.playingSentenceId, 'sentenceId', 's1')
            .having((s) => s.isPlayingStory, 'isPlayingStory', true),
        isA<StoriesLoaded>()
            .having((s) => s.playingSentenceId, 'sentenceId', isNull)
            .having((s) => s.isPlayingStory, 'isPlayingStory', false),
      ],
    );

    blocTest<StoriesCubit, StoriesState>(
      'stops audio playback immediately and cancels story loop',
      build: buildCubit,
      seed: () => StoriesLoaded(
        allStories: [testStory],
        completedStoryIds: const {},
        isPlayingStory: true,
        playingSentenceId: 's1',
      ),
      act: (cubit) => cubit.stopAudio(),
      expect: () => [
        isA<StoriesLoaded>()
            .having((s) => s.isPlayingStory, 'isPlayingStory', false)
            .having((s) => s.playingSentenceId, 'sentenceId', isNull),
      ],
      verify: (_) {
        verify(() => audioService.stop()).called(1);
      },
    );

    blocTest<StoriesCubit, StoriesState>(
      'updates playbackSpeed successfully',
      build: buildCubit,
      seed: () => StoriesLoaded(
        allStories: [testStory],
        completedStoryIds: const {},
        playbackSpeed: 1.0,
      ),
      act: (cubit) => cubit.setPlaybackSpeed(0.85),
      expect: () => [
        isA<StoriesLoaded>()
            .having((s) => s.playbackSpeed, 'playbackSpeed', 0.85),
      ],
      verify: (_) {
        verify(() => audioService.setPlaybackSpeed(0.85)).called(1);
      },
    );
  });
}
