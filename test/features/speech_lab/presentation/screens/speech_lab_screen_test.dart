import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/core/speech/speech_recognition_service.dart';
import 'package:nexus_hebrew_app/features/speech_lab/presentation/screens/speech_lab_screen.dart';
import 'package:nexus_hebrew_app/features/speech_lab/presentation/widgets/pronunciation_result_card.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/add_card_to_srs.dart';

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}
class _MockSpeechRecognitionService extends Mock implements SpeechRecognitionService {}
class _MockAddCardToSrsUseCase extends Mock implements AddCardToSrsUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const AddCardToSrsParams(
        id: 'fallback',
        hebrewVocalized: 'שלום',
        russianTranslation: 'Привет',
      ),
    );
  });

  late _MockAudioPlaybackService audioMock;
  late _MockSpeechRecognitionService speechMock;
  late _MockAddCardToSrsUseCase addCardToSrsMock;
  late StreamController<String> speechStreamController;

  setUp(() {
    audioMock = _MockAudioPlaybackService();
    speechMock = _MockSpeechRecognitionService();
    addCardToSrsMock = _MockAddCardToSrsUseCase();
    speechStreamController = StreamController<String>.broadcast();

    when(() => speechMock.isSupported).thenReturn(true);
    when(() => speechMock.isListening).thenReturn(false);
    when(() => speechMock.textStream)
        .thenAnswer((_) => speechStreamController.stream);
    when(() => speechMock.initialize(language: any(named: 'language')))
        .thenAnswer((_) async => const Success(true));
    when(() => speechMock.startListening())
        .thenAnswer((_) async => const Success(null));
    when(() => speechMock.stopListening())
        .thenAnswer((_) async => const Success(null));
    when(() => speechMock.dispose()).thenAnswer((_) async {});

    when(() => audioMock.setPlaybackSpeed(any()))
        .thenAnswer((_) async => const Success(null));
    when(
      () => audioMock.playWithTtsFallback(
        sourcePath: any(named: 'sourcePath'),
        fallbackHebrewText: any(named: 'fallbackHebrewText'),
      ),
    ).thenAnswer((_) async => const Success(null));

    when(() => addCardToSrsMock(any()))
        .thenAnswer((_) async => const Success(true));
  });

  tearDown(() async {
    await speechStreamController.close();
  });

  Future<void> pumpSubject(WidgetTester tester, {ValueChanged<int>? onXpEarned}) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: SpeechLabScreen(
          audioService: audioMock,
          speechService: speechMock,
          addCardToSrsUseCase: addCardToSrsMock,
          onXpEarned: onXpEarned,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders title, exercise card, audio and mic buttons', (tester) async {
    await pumpSubject(tester);

    expect(find.text('Лаборатория речи'), findsOneWidget);
    expect(find.text('Эталонное звучание:'), findsOneWidget);
    expect(find.text('1.0x Нормально'), findsOneWidget);
    expect(find.text('0.75x Медленно'), findsOneWidget);
    expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
    expect(find.text('Все фразы'), findsOneWidget);
  });

  testWidgets('switches to next exercise on next button tap', (tester) async {
    await pumpSubject(tester);

    expect(find.text('1 из 25'), findsOneWidget);

    final nextButton = find.byTooltip('Следующая фраза');
    await tester.tap(nextButton);
    await tester.pumpAndSettle();

    expect(find.text('2 из 25'), findsOneWidget);
  });

  testWidgets('plays slow audio at 0.75x on button tap', (tester) async {
    await pumpSubject(tester);

    final slowButton = find.text('0.75x Медленно');
    await tester.tap(slowButton);
    await tester.pump();

    verify(() => audioMock.setPlaybackSpeed(0.75)).called(1);
    verify(
      () => audioMock.playWithTtsFallback(
        sourcePath: any(named: 'sourcePath'),
        fallbackHebrewText: any(named: 'fallbackHebrewText'),
      ),
    ).called(1);
  });

  testWidgets('evaluates spoken speech and renders PronunciationResultCard', (tester) async {
    int earnedXp = 0;
    await pumpSubject(tester, onXpEarned: (xp) => earnedXp += xp);

    // Start recording
    final micButton = find.byIcon(Icons.mic_rounded);
    await tester.tap(micButton);
    await tester.pump();

    verify(() => speechMock.startListening()).called(1);

    // Simulate speech stream input matching the target phrase
    speechStreamController.add('אפשר קפה הפוך חזק עם חלב שיבולת שועל');
    await tester.pump();

    // Stop recording
    final stopButton = find.byIcon(Icons.stop_rounded);
    await tester.tap(stopButton);
    await tester.pumpAndSettle();

    verify(() => speechMock.stopListening()).called(1);

    // Verify PronunciationResultCard is rendered
    expect(find.byType(PronunciationResultCard), findsOneWidget);
    expect(find.text('Пословный фонетический разбор:'), findsOneWidget);
    expect(earnedXp, greaterThan(0));
  });

  testWidgets('saves phrase to FSRS on + FSRS button tap', (tester) async {
    await pumpSubject(tester);

    // Start & stop to trigger evaluation
    await tester.tap(find.byIcon(Icons.mic_rounded));
    await tester.pump();
    speechStreamController.add('אפשר קפה הפוך');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.stop_rounded));
    await tester.pumpAndSettle();

    final fsrsButton = find.text('+ FSRS');
    expect(fsrsButton, findsOneWidget);

    await tester.tap(fsrsButton);
    await tester.pumpAndSettle();

    verify(() => addCardToSrsMock(any())).called(1);
    expect(find.text('В FSRS ✓'), findsOneWidget);
  });
}
