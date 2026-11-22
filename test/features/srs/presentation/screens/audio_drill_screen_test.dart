import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/audio_drill_config.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/fsrs_models.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';
import 'package:nexus_hebrew_app/features/srs/presentation/screens/audio_drill_screen.dart';
import 'package:nexus_hebrew_app/features/srs/presentation/widgets/audio_drill_config_sheet.dart';

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}

void main() {
  late _MockAudioPlaybackService mockAudio;
  late StreamController<AudioPlaybackEvent> audioStreamCtrl;

  final testCard = SrsCard(
    id: 'card_drill_1',
    hebrew: const HebrewText.fixture(vocalized: 'קָפֶה', normalized: 'קפה'),
    russianTranslation: 'кофе',
    attribution: const ContentAttribution(sourceName: 'test', licenseName: 'CC0'),
    memory: FsrsMemoryState.initial(now: DateTime.utc(2026, 11, 22)),
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

  Widget buildSubject() {
    return MaterialApp(
      home: AudioDrillScreen(
        allCards: [testCard],
        audioService: mockAudio,
        initialConfig: const AudioDrillConfig(
          filter: AudioDrillFilter.allDeck,
          pauseSeconds: 10.0,
        ),
      ),
    );
  }

  testWidgets('AudioDrillScreen renders player UI elements and controls', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('FSRS Аудиотренажер 🎧'), findsOneWidget);
    expect(find.text('קָפֶה'), findsOneWidget);
    expect(find.text('1 из 1'), findsOneWidget);

    // Controls
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);
    expect(find.byIcon(Icons.skip_previous_rounded), findsOneWidget);
    expect(find.text('1.0x'), findsOneWidget);

    // Tap pause
    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pump();
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

    // Tap play
    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pump();
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

    // Pause before ending test to cancel pending loop timers
    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('AudioDrillScreen tune button opens AudioDrillConfigSheet', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    // Tap settings button
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(AudioDrillConfigSheet), findsOneWidget);
    expect(find.text('Какие слова тренировать:'), findsOneWidget);
    expect(find.text('Направление тренировки:'), findsOneWidget);

    // Close sheet and pause cubit
    Navigator.of(tester.element(find.byType(AudioDrillConfigSheet))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pump(const Duration(milliseconds: 200));
  });
}
