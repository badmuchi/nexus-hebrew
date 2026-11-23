import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/add_card_to_srs.dart';
import 'package:nexus_hebrew_app/features/yael_exam/data/datasources/yael_exam_seed_data.dart';
import 'package:nexus_hebrew_app/features/yael_exam/presentation/screens/yael_exam_screen.dart';
import 'package:nexus_hebrew_app/features/yael_exam/presentation/widgets/yael_score_certificate.dart';

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}
class _MockAddCardToSrsUseCase extends Mock implements AddCardToSrsUseCase {}

void main() {
  late _MockAudioPlaybackService audioMock;
  late _MockAddCardToSrsUseCase srsMock;

  setUp(() {
    audioMock = _MockAudioPlaybackService();
    srsMock = _MockAddCardToSrsUseCase();

    when(
      () => audioMock.playWithTtsFallback(
        sourcePath: any(named: 'sourcePath'),
        fallbackHebrewText: any(named: 'fallbackHebrewText'),
      ),
    ).thenAnswer((_) async => const Success(null));
  });

  Widget buildSubject() {
    return MaterialApp(
      home: YaelExamScreen(
        audioService: audioMock,
        addCardToSrsUseCase: srsMock,
      ),
    );
  }

  testWidgets('renders YAEL exam screen with timer, passage, prompt and options', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Экзамен Яэль и Ульпан Алеф'), findsOneWidget);
    expect(find.text('Вопрос 1 из 12'), findsOneWidget);
    expect(find.textContaining('Понимание прочитанного текста'), findsOneWidget);
    expect(find.text('Возрождение иврита и Бен-Йехуда'), findsOneWidget);

    // 4 option chips
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
    expect(find.text('D'), findsOneWidget);
  });

  testWidgets('selecting option enables next button and allows stepping forward', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Tap option A
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();

    // Tap next
    await tester.tap(find.text('Далее'));
    await tester.pumpAndSettle();

    expect(find.text('Вопрос 2 из 12'), findsOneWidget);
  });

  testWidgets('completing all 12 questions displays YaelScoreCertificate', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    final total = YaelExamSeedData.examQuestions.length;
    for (int i = 0; i < total; i++) {
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      final buttonText = i == total - 1 ? 'Завершить экзамен' : 'Далее';
      await tester.tap(find.text(buttonText));
      await tester.pumpAndSettle();
    }

    expect(find.byType(YaelScoreCertificate), findsOneWidget);
    expect(find.text('РЕЗУЛЬТАТ ТЕСТА ЯЭЛЬ (צִיּוּן מִבְחַן יַעֵ״ל)'), findsOneWidget);
    expect(find.text('Разбор ответов'), findsOneWidget);
    expect(find.text('Пройти заново'), findsOneWidget);

    // Tap review mistakes
    await tester.tap(find.text('Разбор ответов'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Правило:'), findsOneWidget);
    expect(find.text('К сертификату'), findsOneWidget);
  });
}
