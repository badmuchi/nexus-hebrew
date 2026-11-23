import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/core/speech/speech_recognition_service.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/add_card_to_srs.dart';
import 'package:nexus_hebrew_app/features/voice_ai/presentation/screens/voice_ai_companion_screen.dart';
import 'package:nexus_hebrew_app/features/voice_ai/presentation/widgets/sabra_speech_bubble.dart';
import 'package:nexus_hebrew_app/features/voice_ai/presentation/widgets/voice_answer_suggestion_card.dart';

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}
class _MockAddCardToSrsUseCase extends Mock implements AddCardToSrsUseCase {}
class _MockSpeechRecognitionService extends Mock implements SpeechRecognitionService {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const AddCardToSrsParams(
        id: 'fallback_voice',
        hebrewVocalized: 'שלום',
        russianTranslation: 'привет',
      ),
    );
  });

  late _MockAudioPlaybackService audioMock;
  late _MockAddCardToSrsUseCase srsMock;
  late _MockSpeechRecognitionService speechMock;
  late StreamController<String> textStreamController;

  setUp(() {
    audioMock = _MockAudioPlaybackService();
    srsMock = _MockAddCardToSrsUseCase();
    speechMock = _MockSpeechRecognitionService();
    textStreamController = StreamController<String>.broadcast();

    when(
      () => audioMock.playWithTtsFallback(
        sourcePath: any(named: 'sourcePath'),
        fallbackHebrewText: any(named: 'fallbackHebrewText'),
      ),
    ).thenAnswer((_) async => const Success(null));

    when(() => srsMock(any())).thenAnswer((_) async => const Success(true));

    when(() => speechMock.textStream).thenAnswer((_) => textStreamController.stream);
    when(() => speechMock.isSupported).thenReturn(true);
    when(() => speechMock.isListening).thenReturn(false);
    when(() => speechMock.initialize(language: any(named: 'language')))
        .thenAnswer((_) async => const Success(true));
    when(() => speechMock.startListening()).thenAnswer((_) async => const Success(null));
    when(() => speechMock.stopListening()).thenAnswer((_) async => const Success(null));
    when(() => speechMock.dispose()).thenAnswer((_) async {});
  });

  tearDown(() {
    textStreamController.close();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: VoiceAiCompanionScreen(
        audioService: audioMock,
        addCardToSrsUseCase: srsMock,
        speechService: speechMock,
      ),
    );
  }

  testWidgets('renders Voice AI screen with Sabra bubble and answer options', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Сабра AI'), findsWidgets);
    expect(find.text('Кофе на Дизенгоф'), findsOneWidget);
    expect(find.text('Рынок Кармель'), findsOneWidget);

    // Initial Sabra speech bubble
    expect(find.byType(SabraSpeechBubble), findsOneWidget);
    expect(find.textContaining('מָה אֶפְשָׁר לְהָכִין לְךָ הַיּוֹם'), findsOneWidget);

    // Cultural hint card
    expect(find.textContaining('Культурный код и грамматика'), findsOneWidget);

    // Answer suggestion cards
    expect(find.byType(VoiceAnswerSuggestionCard), findsNWidgets(2));
    expect(find.textContaining('הָפוּךְ קָטָן'), findsOneWidget);
  });

  testWidgets('selecting suggested response evaluates accuracy and advances turn', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Tap first suggested answer: הפוך קטן
    final firstAnswer = find.textContaining('הָפוּךְ קָטָן');
    await tester.tap(firstAnswer);
    await tester.pumpAndSettle();

    // Feedback banner appears with accuracy and button to advance
    expect(find.textContaining('Точность'), findsOneWidget);
    final advanceButton = find.textContaining('Продолжить диалог');
    expect(advanceButton, findsOneWidget);

    // Advance to Turn 2
    await tester.tap(advanceButton);
    await tester.pumpAndSettle();

    // Turn 2 Sabra speech
    expect(find.textContaining('תִּרְצֶה גַּם מַשֶּׁהוּ מָתוֹק לְיַד'), findsOneWidget);
  });

  testWidgets('switching scenario updates dialogue content', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Switch to Shuk Carmel
    final shukChip = find.text('Рынок Кармель');
    expect(shukChip, findsOneWidget);
    await tester.tap(shukChip);
    await tester.pumpAndSettle();

    expect(find.textContaining('הַכֹּל דְּבַשׁ הַיּוֹם'), findsOneWidget);
    expect(find.textContaining('וָואלָה, מַמָּשׁ מָתוֹק'), findsOneWidget);
  });
}
