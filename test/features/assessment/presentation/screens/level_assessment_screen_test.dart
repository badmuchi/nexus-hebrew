import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/assessment/data/datasources/level_quiz_seed_data.dart';
import 'package:nexus_hebrew_app/features/assessment/presentation/screens/level_assessment_screen.dart';
import 'package:nexus_hebrew_app/features/assessment/presentation/widgets/level_certificate_card.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/add_card_to_srs.dart';

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}
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
  late _MockAddCardToSrsUseCase addCardToSrsMock;

  setUp(() {
    audioMock = _MockAudioPlaybackService();
    addCardToSrsMock = _MockAddCardToSrsUseCase();

    when(
      () => audioMock.playWithTtsFallback(
        sourcePath: any(named: 'sourcePath'),
        fallbackHebrewText: any(named: 'fallbackHebrewText'),
      ),
    ).thenAnswer((_) async => const Success(null));

    when(() => addCardToSrsMock(any()))
        .thenAnswer((_) async => const Success(true));
  });

  Future<void> pumpSubject(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: LevelAssessmentScreen(
          audioService: audioMock,
          addCardToSrsUseCase: addCardToSrsMock,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders title, question counter, prompt and 4 options', (tester) async {
    await pumpSubject(tester);

    expect(find.text('Тест на уровень иврита'), findsOneWidget);
    expect(find.text('1 / 18'), findsOneWidget);
    expect(find.text('A1 (Начальный (Алеф))'), findsOneWidget);
    expect(find.text('Грамматика и Биньяны'), findsOneWidget);

    // 4 option chips (A, B, C, D)
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
    expect(find.text('D'), findsOneWidget);
  });

  testWidgets('selecting option enables next button and advances to next question', (tester) async {
    await pumpSubject(tester);

    final nextButton = find.text('Далее');
    // Initially disabled before selecting an answer
    final nextButtonWidget = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Далее'),
    );
    expect(nextButtonWidget.onPressed, isNull);

    // Select option B
    final optionB = find.text('B');
    await tester.tap(optionB);
    await tester.pumpAndSettle();

    // Now enabled
    final enabledNext = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Далее'),
    );
    expect(enabledNext.onPressed, isNotNull);

    await tester.tap(nextButton);
    await tester.pumpAndSettle();

    // Now on question 2
    expect(find.text('2 / 18'), findsOneWidget);
  });

  testWidgets('playing audio triggers audio service playWithTtsFallback', (tester) async {
    await pumpSubject(tester);

    final audioButton = find.text('Прослушать вопрос');
    expect(audioButton, findsOneWidget);

    await tester.tap(audioButton);
    await tester.pump();

    verify(
      () => audioMock.playWithTtsFallback(
        sourcePath: any(named: 'sourcePath'),
        fallbackHebrewText: any(named: 'fallbackHebrewText'),
      ),
    ).called(1);
  });

  testWidgets('completing all 18 questions shows LevelCertificateCard', (tester) async {
    await pumpSubject(tester);

    final total = LevelQuizSeedData.diagnosticQuestions.length;
    for (int i = 0; i < total; i++) {
      // Select option A (index 0)
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      final actionText = i == total - 1 ? 'Завершить тест' : 'Далее';
      await tester.tap(find.text(actionText));
      await tester.pumpAndSettle();
    }

    // Verify diploma certificate is displayed
    expect(find.byType(LevelCertificateCard), findsOneWidget);
    expect(find.text('NEXUS HEBREW DIPLOMA'), findsOneWidget);
    expect(find.text('Диагностика навыков:'), findsOneWidget);
    expect(find.text('Индивидуальный план развития:'), findsOneWidget);
  });
}
