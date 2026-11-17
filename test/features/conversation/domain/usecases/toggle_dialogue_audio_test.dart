import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/usecases/toggle_dialogue_audio.dart';

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}

void main() {
  late ToggleDialogueAudioUseCase useCase;
  late _MockAudioPlaybackService mockAudioService;

  setUp(() {
    mockAudioService = _MockAudioPlaybackService();
    useCase = ToggleDialogueAudioUseCase(mockAudioService);
  });

  group('ToggleDialogueAudioUseCase', () {
    test('запускает воспроизведение если плеер в состоянии idle', () async {
      when(() => mockAudioService.currentState)
          .thenReturn(const AudioPlaybackEvent.idle());
      when(() => mockAudioService.play('assets/audio/market_dialogue_1.mp3'))
          .thenAnswer((_) async => const Success(null));

      final result = await useCase.execute('assets/audio/market_dialogue_1.mp3');

      expect(result, equals(const Success<void, Failure>(null)));
      verify(() => mockAudioService.play('assets/audio/market_dialogue_1.mp3'))
          .called(1);
      verifyNever(() => mockAudioService.stop());
    });

    test('останавливает воспроизведение если тот же трек уже играет', () async {
      when(() => mockAudioService.currentState).thenReturn(
        const AudioPlaybackEvent(
          sourcePath: 'assets/audio/market_dialogue_1.mp3',
          status: AudioPlaybackStatus.playing,
        ),
      );
      when(() => mockAudioService.stop())
          .thenAnswer((_) async => const Success(null));

      final result = await useCase.execute('assets/audio/market_dialogue_1.mp3');

      expect(result, equals(const Success<void, Failure>(null)));
      verify(() => mockAudioService.stop()).called(1);
      verifyNever(() => mockAudioService.play(any()));
    });

    test('возвращает ValidationFailure если audioPath null или пустой', () async {
      final nullRes = await useCase.execute(null);
      final blankRes = await useCase.execute('   ');

      expect(nullRes.failureOrNull(), isA<ValidationFailure>());
      expect(blankRes.failureOrNull(), isA<ValidationFailure>());
      verifyNever(() => mockAudioService.play(any()));
      verifyNever(() => mockAudioService.stop());
    });

    test('пробрасывает AudioFailure если аудио-сервис не смог загрузить файл', () async {
      const audioFailure = AudioFailure('Missing audio asset');
      when(() => mockAudioService.currentState)
          .thenReturn(const AudioPlaybackEvent.idle());
      when(() => mockAudioService.play('assets/audio/missing.mp3'))
          .thenAnswer((_) async => const Error(audioFailure));

      final result = await useCase.execute('assets/audio/missing.mp3');

      expect(result, equals(const Error<void, Failure>(audioFailure)));
    });

    test('использует playWithTtsFallback если передан fallbackHebrewText', () async {
      when(() => mockAudioService.currentState)
          .thenReturn(const AudioPlaybackEvent.idle());
      when(
        () => mockAudioService.playWithTtsFallback(
          sourcePath: null,
          fallbackHebrewText: 'שָׁלוֹם!',
        ),
      ).thenAnswer((_) async => const Success(null));

      final result = await useCase.execute(
        null,
        fallbackHebrewText: 'שָׁלוֹם!',
      );

      expect(result, equals(const Success<void, Failure>(null)));
      verify(
        () => mockAudioService.playWithTtsFallback(
          sourcePath: null,
          fallbackHebrewText: 'שָׁלוֹם!',
        ),
      ).called(1);
    });
  });
}
