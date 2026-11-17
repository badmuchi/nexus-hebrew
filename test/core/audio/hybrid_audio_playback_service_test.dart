import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/audio/hybrid_audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/audio/tts_speech_service.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/logging/app_logger.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';

class _MockPrimaryAudioService extends Mock implements AudioPlaybackService {}

class _MockTtsSpeechService extends Mock implements TtsSpeechService {}

void main() {
  late _MockPrimaryAudioService primaryAudio;
  late _MockTtsSpeechService ttsService;
  late StreamController<AudioPlaybackEvent> primaryStream;
  late HybridAudioPlaybackService hybridService;

  setUp(() {
    primaryAudio = _MockPrimaryAudioService();
    ttsService = _MockTtsSpeechService();
    primaryStream = StreamController<AudioPlaybackEvent>.broadcast();

    when(() => primaryAudio.statusStream).thenAnswer((_) => primaryStream.stream);
    when(() => primaryAudio.setPlaybackSpeed(any()))
        .thenAnswer((_) async => const Success(null));
    when(() => primaryAudio.stop())
        .thenAnswer((_) async => const Success(null));
    when(() => primaryAudio.dispose())
        .thenAnswer((_) async => const Success(null));
    when(() => ttsService.setSpeed(any()))
        .thenAnswer((_) async => const Success(null));
    when(() => ttsService.stop())
        .thenAnswer((_) async => const Success(null));
    when(() => ttsService.dispose()).thenAnswer((_) async {});

    hybridService = HybridAudioPlaybackService(
      primaryAudioService: primaryAudio,
      ttsService: ttsService,
      logger: const NoOpAppLogger(),
    );
  });

  tearDown(() async {
    await hybridService.dispose();
    await primaryStream.close();
  });

  group('HybridAudioPlaybackService', () {
    test('воспроизводит оригинальное аудио если источник доступен', () async {
      when(() => primaryAudio.play('https://audio.tatoeba.org/sentences/heb/1.mp3'))
          .thenAnswer((_) async => const Success(null));

      final res = await hybridService.playWithTtsFallback(
        sourcePath: 'https://audio.tatoeba.org/sentences/heb/1.mp3',
        fallbackHebrewText: 'שָׁלוֹם',
      );

      expect(res, equals(const Success<void, Failure>(null)));
      verify(() => primaryAudio.play('https://audio.tatoeba.org/sentences/heb/1.mp3'))
          .called(1);
      verifyNever(() => ttsService.speak(any(), languageTag: any(named: 'languageTag')));
    });

    test('переключается на he-IL TTS если primary аудио не задано или упало', () async {
      when(() => primaryAudio.play('assets/audio/missing.mp3'))
          .thenAnswer((_) async => const Error(AudioFailure('Missing file')));
      when(() => ttsService.speak('שָׁלוֹם', languageTag: 'he-IL'))
          .thenAnswer((_) async => const Success(null));

      final res = await hybridService.playWithTtsFallback(
        sourcePath: 'assets/audio/missing.mp3',
        fallbackHebrewText: 'שָׁלוֹם',
      );

      expect(res, equals(const Success<void, Failure>(null)));
      verify(() => ttsService.speak('שָׁלוֹם', languageTag: 'he-IL')).called(1);
    });

    test('возвращает AudioFailure если и аудио, и TTS недоступны', () async {
      const ttsError = AudioFailure('TTS engine missing');
      when(() => ttsService.speak('שָׁלוֹם', languageTag: 'he-IL'))
          .thenAnswer((_) async => const Error(ttsError));

      final res = await hybridService.playWithTtsFallback(
        sourcePath: null,
        fallbackHebrewText: 'שָׁלוֹם',
      );

      expect(res, equals(const Error<void, Failure>(ttsError)));
    });

    test('setPlaybackSpeed применяет скорость к обоим движкам и отклоняет невалидную', () async {
      final invalidRes = await hybridService.setPlaybackSpeed(0.0);
      expect(invalidRes.failureOrNull(), isA<ValidationFailure>());

      final validRes = await hybridService.setPlaybackSpeed(0.75);
      expect(validRes, equals(const Success<void, Failure>(null)));
      expect(hybridService.currentSpeed, equals(0.75));
      verify(() => primaryAudio.setPlaybackSpeed(0.75)).called(1);
      verify(() => ttsService.setSpeed(0.75)).called(1);
    });

    test('транслирует завершение и ошибку TTS в statusStream для сброса кнопки', () async {
      when(() => ttsService.speak('שָׁלוֹם', languageTag: 'he-IL'))
          .thenAnswer((_) async => const Success(null));

      final emitted = <AudioPlaybackEvent>[];
      final sub = hybridService.statusStream.listen(emitted.add);

      await hybridService.playWithTtsFallback(
        sourcePath: null,
        fallbackHebrewText: 'שָׁלוֹם',
      );
      hybridService.handleTtsComplete();
      hybridService.handleTtsError('synthesis-failed');
      await Future<void>.delayed(Duration.zero);

      expect(
        emitted.map((e) => e.status).toList(),
        equals([
          AudioPlaybackStatus.playing,
          AudioPlaybackStatus.completed,
          AudioPlaybackStatus.error,
        ]),
      );
      await sub.cancel();
    });
  });
}
