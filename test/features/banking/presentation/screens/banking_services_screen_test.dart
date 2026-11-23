import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/banking/presentation/screens/banking_services_screen.dart';
import 'package:nexus_hebrew_app/features/banking/presentation/widgets/israeli_check_card.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/add_card_to_srs.dart';

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}
class _MockAddCardToSrsUseCase extends Mock implements AddCardToSrsUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const AddCardToSrsParams(
        id: 'fallback_bank',
        hebrewVocalized: 'עובר ושב',
        russianTranslation: 'текущий счет',
      ),
    );
  });

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

    when(() => srsMock(any())).thenAnswer((_) async => const Success(true));
  });

  Widget buildSubject() {
    return MaterialApp(
      home: BankingServicesScreen(
        audioService: audioMock,
        addCardToSrsUseCase: srsMock,
      ),
    );
  }

  testWidgets('renders Banking screen with 3 tabs and Israeli check simulator', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Банк, Машканта и Битуах Леуми'), findsOneWidget);
    expect(find.text('Банк и Чеки'), findsOneWidget);
    expect(find.text('Машканта'), findsOneWidget);
    expect(find.text('Битуах Леуми и Словарь'), findsOneWidget);

    // Default Tab: Check card
    expect(find.byType(IsraeliCheckCard), findsOneWidget);
    expect(find.textContaining('בַּנְק לְאֻמִּי'), findsOneWidget);
    expect(find.text('לַמּוּטָב בִּלְבַד'), findsOneWidget);
    expect(find.text('₪ 4500.00'), findsOneWidget);
  });

  testWidgets('switching check and answering banking dialogue shows feedback', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Switch to second check: Гарантийный чек безопасности
    final secChip = find.textContaining('Гарантийный чек безопасности');
    expect(secChip, findsOneWidget);
    await tester.ensureVisible(secChip);
    await tester.tap(secChip);
    await tester.pumpAndSettle();

    expect(find.text('₪ 1200.00'), findsOneWidget);

    // Answer banking dialogue
    final firstOption = find.textContaining('עוֹלֶה חָדָשׁ');
    expect(firstOption, findsOneWidget);
    await tester.tap(firstOption);
    await tester.pumpAndSettle();

    expect(find.textContaining('Грамотно и профессионально'), findsOneWidget);
    expect(find.textContaining('Совет инсайдера:'), findsOneWidget);
  });

  testWidgets('navigating to Mortgage and Bituach Leumi tabs functions accurately', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Switch to Tab 2: Машканта
    await tester.tap(find.text('Машканта'));
    await tester.pumpAndSettle();

    expect(find.text('קַלַ״ץ'), findsOneWidget);
    expect(find.textContaining('פְּרַיְם'), findsOneWidget);

    // Switch to Tab 3: Битуах Леуми и Словарь
    await tester.tap(find.text('Битуах Леуми и Словарь'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Найдено терминов:'), findsOneWidget);

    // Search for over va-shav
    final searchInput = find.byType(TextField);
    expect(searchInput, findsOneWidget);
    await tester.enterText(searchInput, 'עובר ושב');
    await tester.pumpAndSettle();

    expect(find.textContaining('עוֹבֵר וָשָׁב'), findsOneWidget);

    // Tap Add to SRS
    final srsButton = find.byTooltip('В словарь FSRS').first;
    await tester.tap(srsButton);
    await tester.pumpAndSettle();

    verify(() => srsMock(any())).called(1);
  });
}
