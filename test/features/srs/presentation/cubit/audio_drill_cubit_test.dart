import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/audio_drill_config.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/fsrs_models.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';
import 'package:nexus_hebrew_app/features/srs/presentation/cubit/audio_drill_cubit.dart';
import 'package:nexus_hebrew_app/features/srs/presentation/cubit/audio_drill_state.dart';

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}

void main() {
  late _MockAudioPlaybackService mockAudio;
  late StreamController<AudioPlaybackEvent> audioStreamCtrl;

  final now = DateTime.utc(2026, 11, 22);

  final weakCard = SrsCard(
    id: 'card_weak',
    hebrew: const HebrewText.fixture(vocalized: 'קָפֶה', normalized: 'קפה'),
    russianTranslation: 'кофе',
    attribution: const ContentAttribution(sourceName: 'test', licenseName: 'CC0'),
    memory: FsrsMemoryState(
      stability: 1.5, // < 3.0 -> weak!
      difficulty: 6.0,
      dueAt: now.add(const Duration(days: 1)),
      reps: 2,
      lapses: 1, // > 0 -> weak!
      state: FsrsCardState.review,
    ),
  );

  final strongCard = SrsCard(
    id: 'card_strong',
    hebrew: const HebrewText.fixture(vocalized: 'שָׁלוֹם', normalized: 'שלום'),
    russianTranslation: 'привет, мир',
    attribution: const ContentAttribution(sourceName: 'test', licenseName: 'CC0'),
    memory: FsrsMemoryState(
      stability: 45.0,
      difficulty: 2.0,
      dueAt: now.add(const Duration(days: 30)),
      reps: 10,
      lapses: 0,
      state: FsrsCardState.review,
    ),
  );

  final dueCard = SrsCard(
    id: 'card_due',
    hebrew: const HebrewText.fixture(vocalized: 'מַיִם', normalized: 'מים'),
    russianTranslation: 'вода',
    attribution: const ContentAttribution(sourceName: 'test', licenseName: 'CC0'),
    memory: FsrsMemoryState(
      stability: 10.0,
      difficulty: 3.0,
      dueAt: now.subtract(const Duration(days: 1)), // In the past -> due!
      reps: 5,
      lapses: 0,
      state: FsrsCardState.review,
    ),
  );

  setUp(() {
    mockAudio = _MockAudioPlaybackService();
    audioStreamCtrl = StreamController<AudioPlaybackEvent>.broadcast();

    when(() => mockAudio.statusStream).thenAnswer((_) => audioStreamCtrl.stream);
    when(() => mockAudio.currentSpeed).thenReturn(1.0);
    when(() => mockAudio.setPlaybackSpeed(any()))
        .thenAnswer((_) async => const Success(null));
    when(() => mockAudio.stop())
        .thenAnswer((_) async => const Success(null));
    when(
      () => mockAudio.playWithTtsFallback(
        sourcePath: any(named: 'sourcePath'),
        fallbackHebrewText: any(named: 'fallbackHebrewText'),
      ),
    ).thenAnswer((_) async => const Success(null));
  });

  tearDown(() async {
    await audioStreamCtrl.close();
  });

  group('AudioDrillCubit', () {
    test('initial state is AudioDrillInitial', () {
      final cubit = AudioDrillCubit(audioService: mockAudio);
      expect(cubit.state, equals(const AudioDrillInitial()));
      cubit.close();
    });

    test('startSession with empty cards list emits AudioDrillError', () {
      final cubit = AudioDrillCubit(audioService: mockAudio);
      cubit.startSession(allCards: []);

      expect(cubit.state, isA<AudioDrillError>());
      cubit.close();
    });

    test('startSession with weakWordsOnly filters weak cards', () {
      final cubit = AudioDrillCubit(audioService: mockAudio);
      cubit.startSession(
        allCards: [weakCard, strongCard],
        config: const AudioDrillConfig(filter: AudioDrillFilter.weakWordsOnly),
      );

      final state = cubit.state;
      expect(state, isA<AudioDrillActive>());
      final active = state as AudioDrillActive;
      expect(active.playlist.length, equals(1));
      expect(active.playlist.first.id, equals('card_weak'));
      cubit.close();
    });

    test('startSession with dueTodayOnly filters due cards', () {
      final cubit = AudioDrillCubit(audioService: mockAudio);
      cubit.startSession(
        allCards: [strongCard, dueCard],
        config: const AudioDrillConfig(filter: AudioDrillFilter.dueTodayOnly),
      );

      final state = cubit.state;
      expect(state, isA<AudioDrillActive>());
      final active = state as AudioDrillActive;
      expect(active.playlist.length, equals(1));
      expect(active.playlist.first.id, equals('card_due'));
      cubit.close();
    });

    test('pause and play control active playback state', () {
      final cubit = AudioDrillCubit(audioService: mockAudio);
      cubit.startSession(allCards: [weakCard, strongCard]);

      expect((cubit.state as AudioDrillActive).isPlaying, isTrue);

      cubit.pause();
      expect((cubit.state as AudioDrillActive).isPlaying, isFalse);

      cubit.play();
      expect((cubit.state as AudioDrillActive).isPlaying, isTrue);

      cubit.togglePlayPause();
      expect((cubit.state as AudioDrillActive).isPlaying, isFalse);

      cubit.close();
    });

    test('next and previous navigate through cards', () {
      final cubit = AudioDrillCubit(audioService: mockAudio);
      cubit.startSession(
        allCards: [weakCard, strongCard, dueCard],
        config: const AudioDrillConfig(filter: AudioDrillFilter.allDeck),
      );

      expect((cubit.state as AudioDrillActive).currentIndex, equals(0));

      cubit.next();
      expect((cubit.state as AudioDrillActive).currentIndex, equals(1));

      cubit.previous();
      expect((cubit.state as AudioDrillActive).currentIndex, equals(0));

      // Previous wraps to last card
      cubit.previous();
      expect((cubit.state as AudioDrillActive).currentIndex, equals(2));

      cubit.close();
    });

    test('setPlaybackSpeed updates speed and notifies audioService', () async {
      final cubit = AudioDrillCubit(audioService: mockAudio);
      cubit.startSession(allCards: [weakCard]);

      await cubit.setPlaybackSpeed(1.25);
      expect((cubit.state as AudioDrillActive).playbackSpeed, equals(1.25));
      verify(() => mockAudio.setPlaybackSpeed(1.25)).called(1);

      await cubit.close();
    });

    test('updateConfig changes config in active state', () {
      final cubit = AudioDrillCubit(audioService: mockAudio);
      cubit.startSession(allCards: [weakCard]);

      const newConfig = AudioDrillConfig(
        direction: AudioDrillDirection.russianToHebrew,
        pauseSeconds: 5.0,
      );
      cubit.updateConfig(newConfig);

      expect((cubit.state as AudioDrillActive).config.direction,
          equals(AudioDrillDirection.russianToHebrew));
      expect((cubit.state as AudioDrillActive).config.pauseSeconds, equals(5.0));

      cubit.close();
    });
  });
}
