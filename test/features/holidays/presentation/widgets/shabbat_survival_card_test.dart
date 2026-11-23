import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/holidays/data/datasources/holidays_seed_data.dart';
import 'package:nexus_hebrew_app/features/holidays/presentation/widgets/shabbat_survival_card.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/add_card_to_srs.dart';

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
      home: Scaffold(
        body: SingleChildScrollView(
          child: ShabbatSurvivalCard(
            stages: HolidaysSeedData.shabbatStages,
            audioService: audioMock,
            addCardToSrsUseCase: srsMock,
          ),
        ),
      ),
    );
  }

  testWidgets('renders Shabbat card with 4 stages and initial Friday morning content', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Шаббат в Израиле (שַׁבָּת קֹדֶשׁ)'), findsOneWidget);
    expect(find.text('Этап 1'), findsOneWidget);
    expect(find.text('Этап 2'), findsOneWidget);
    expect(find.text('Этап 3'), findsOneWidget);
    expect(find.text('Этап 4'), findsOneWidget);

    // Initial stage: Friday morning
    expect(find.text('Пятница: Суета и Подготовка'), findsOneWidget);
    expect(find.textContaining('יוֹם שִׁישִׁי'), findsOneWidget);
    expect(find.text('Транспорт и магазины:'), findsOneWidget);
  });

  testWidgets('switching to Stage 2 shows Candle Lighting and transport freeze', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Tap on stage 2
    await tester.tap(find.text('Этап 2'));
    await tester.pumpAndSettle();

    expect(find.text('Заход субботы (Книсат Шаббат)'), findsOneWidget);
    expect(find.textContaining('כְּנִיסַת שַׁבָּת'), findsOneWidget);
  });

  testWidgets('tapping audio icon triggers audio service', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    final headerAudioButton = find.byTooltip('Озвучить пожелание субботы');
    expect(headerAudioButton, findsOneWidget);

    await tester.tap(headerAudioButton);
    await tester.pump();

    verify(
      () => audioMock.playWithTtsFallback(
        sourcePath: null,
        fallbackHebrewText: 'שַׁבָּת שָׁלוֹם וּמְבֹרָךְ!',
      ),
    ).called(1);
  });
}
