import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/listening/domain/entities/listening_exercise.dart';
import 'package:nexus_hebrew_app/features/listening/domain/usecases/play_listening_exercise.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}

void main() {
  late _MockAudioPlaybackService audioService;
  late PlayListeningExerciseUseCase useCase;

  final exercise = ListeningExercise(
    id: 'listen_1',
    transcript: const HebrewText.fixture(
      vocalized: 'שָׁלוֹם חֲבֵרִים',
      normalized: 'שלום חברים',
    ),
    russianTranslation: 'Привет, друзья',
    audioUrl: 'https://audio.tatoeba.org/sentences/heb/10.mp3',
    difficulty: ListeningDifficulty.beginner,
    focusWords: const <String>['שָׁלוֹם'],
    attribution: const ContentAttribution(
      sourceName: 'Tatoeba',
      licenseName: 'CC0 1.0',
    ),
  );

  setUp(() {
    audioService = _MockAudioPlaybackService();
    useCase = PlayListeningExerciseUseCase(audioService);
  });

  group('PlayListeningExerciseUseCase', () {
    test('sets speed and plays audio with TTS fallback on valid speed', () async {
      when(() => audioService.setPlaybackSpeed(0.75))
          .thenAnswer((_) async => const Success<void, Failure>(null));
      when(
        () => audioService.playWithTtsFallback(
          sourcePath: exercise.audioUrl,
          fallbackHebrewText: exercise.transcript.vocalized,
        ),
      ).thenAnswer((_) async => const Success<void, Failure>(null));

      final result = await useCase(
        PlayListeningExerciseParams(exercise: exercise, speed: 0.75),
      );

      expect(result.isSuccess, isTrue);
      verifyInOrder(<void Function()>[
        () => audioService.setPlaybackSpeed(0.75),
        () => audioService.playWithTtsFallback(
              sourcePath: exercise.audioUrl,
              fallbackHebrewText: exercise.transcript.vocalized,
            ),
      ]);
    });

    test('returns ValidationFailure when requested speed is out of bounds',
        () async {
      final result = await useCase(
        PlayListeningExerciseParams(exercise: exercise, speed: 2.5),
      );

      expect(result.isError, isTrue);
      expect(result.failureOrNull(), isA<ValidationFailure>());
      verifyZeroInteractions(audioService);
    });

    test('stops before playback and returns AudioFailure when speed change fails',
        () async {
      const failure = AudioFailure('Speed unsupported');
      when(() => audioService.setPlaybackSpeed(0.75))
          .thenAnswer((_) async => const Error<void, Failure>(failure));

      final result = await useCase(
        PlayListeningExerciseParams(exercise: exercise, speed: 0.75),
      );

      expect(result.isError, isTrue);
      expect(result.failureOrNull(), failure);
      verifyNever(
        () => audioService.playWithTtsFallback(
          sourcePath: any(named: 'sourcePath'),
          fallbackHebrewText: any(named: 'fallbackHebrewText'),
        ),
      );
    });
  });
}
