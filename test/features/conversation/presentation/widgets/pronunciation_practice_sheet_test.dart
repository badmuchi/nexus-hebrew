import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/core/speech/speech_recognition_service.dart';
import 'package:nexus_hebrew_app/features/conversation/presentation/widgets/pronunciation_practice_sheet.dart';

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}
class _MockSpeechRecognitionService extends Mock implements SpeechRecognitionService {}

void main() {
  late _MockAudioPlaybackService audioMock;
  late _MockSpeechRecognitionService speechMock;
  late StreamController<String> speechStreamController;

  setUp(() {
    audioMock = _MockAudioPlaybackService();
    speechMock = _MockSpeechRecognitionService();
    speechStreamController = StreamController<String>.broadcast();

    when(() => speechMock.isSupported).thenReturn(true);
    when(() => speechMock.isListening).thenReturn(false);
    when(() => speechMock.textStream).thenAnswer((_) => speechStreamController.stream);
    when(() => speechMock.initialize(language: any(named: 'language')))
        .thenAnswer((_) async => const Success(true));
    when(() => speechMock.startListening()).thenAnswer((_) async => const Success(null));
    when(() => speechMock.stopListening()).thenAnswer((_) async => const Success(null));
    when(() => speechMock.dispose()).thenAnswer((_) async {});

    when(
      () => audioMock.playWithTtsFallback(
        sourcePath: any(named: 'sourcePath'),
        fallbackHebrewText: any(named: 'fallbackHebrewText'),
      ),
    ).thenAnswer((_) async => const Success(null));
  });

  tearDown(() async {
    await speechStreamController.close();
  });

  Widget createSubject({ValueChanged<int>? onXpEarned}) {
    return MaterialApp(
      home: Scaffold(
        body: PronunciationPracticeSheet(
          phraseVocalized: 'שָׁלוֹם, מַה נִּשְׁמַע?',
          phraseRussian: 'Привет, как дела?',
          transliteration: 'Shalom, ma nishma?',
          audioService: audioMock,
          speechService: speechMock,
          onXpEarned: onXpEarned,
        ),
      ),
    );
  }

  group('PronunciationPracticeSheet', () {
    testWidgets('рендерит эталонную фразу, перевод, кнопку образца и микрофон', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('Тренажёр произношения'), findsOneWidget);
      expect(find.text('שָׁלוֹם, מַה נִּשְׁמַע?'), findsOneWidget);
      expect(find.text('Привет, как дела?'), findsOneWidget);
      expect(find.text('Образец'), findsOneWidget);
      expect(find.byIcon(Icons.mic_rounded), findsNWidgets(2));
    });

    testWidgets('кнопка Образец запускает эталонное аудио через TTS', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Образец'));
      await tester.pump();

      verify(
        () => audioMock.playWithTtsFallback(
          sourcePath: null,
          fallbackHebrewText: 'שָׁלוֹם, מַה נִּשְׁמַע?',
        ),
      ).called(1);
    });

    testWidgets('запись речи и оценка точности отображает результат и начисляет XP', (tester) async {
      int? earnedXp;

      await tester.pumpWidget(createSubject(onXpEarned: (xp) => earnedXp = xp));
      await tester.pumpAndSettle();

      // Нажимаем микрофон для старта (большая кнопка)
      await tester.tap(find.byIcon(Icons.mic_rounded).last);
      await tester.pumpAndSettle();

      verify(() => speechMock.startListening()).called(1);
      expect(find.text('Слушаю вас... Говорите на иврите!'), findsOneWidget);

      // Стрим распознавания эмитит услышанный текст
      speechStreamController.add('שלום מה נשמע');
      await tester.pumpAndSettle();

      expect(find.text('שלום מה נשמע'), findsOneWidget);

      // Нажимаем стоп для завершения и оценки
      await tester.tap(find.byIcon(Icons.stop_rounded));
      await tester.pumpAndSettle();

      verify(() => speechMock.stopListening()).called(1);

      // Скроллим к карточке оценки
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Проверяем карточку оценки
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('!מוּשְׁלָם'), findsOneWidget);
      expect(earnedXp, 15);
    });
  });
}
