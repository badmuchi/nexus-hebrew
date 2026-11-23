import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/army_tzahal/presentation/screens/army_tzahal_screen.dart';
import 'package:nexus_hebrew_app/features/army_tzahal/presentation/widgets/army_term_card.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/add_card_to_srs.dart';

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}
class _MockAddCardToSrsUseCase extends Mock implements AddCardToSrsUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const AddCardToSrsParams(
        id: 'fallback_army',
        hebrewVocalized: 'שלום',
        russianTranslation: 'привет',
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
      home: ArmyTzahalScreen(
        audioService: audioMock,
        addCardToSrsUseCase: srsMock,
      ),
    );
  }

  testWidgets('renders Army & Tzahal screen with 3 tabs and slang terms', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('ЦАХАЛ и Шерут Леуми'), findsOneWidget);
    expect(find.text('Сленг и словарь'), findsOneWidget);
    expect(find.text('Собеседование (Цав Ришон)'), findsOneWidget);
    expect(find.text('Шерут Леуми и Звания'), findsOneWidget);

    // Initial slang terms
    expect(find.byType(ArmyTermCard), findsWidgets);
    expect(find.text('פַּקָּ״ל'), findsOneWidget);
    expect(find.textContaining('מַשַּׁקִּית תַּ״שׁ'), findsOneWidget);
  });

  testWidgets('search filters military slang terms and tap FSRS adds card', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, 'пакаль');
    await tester.pumpAndSettle();

    expect(find.text('פַּקָּ״ל'), findsOneWidget);
    expect(find.textContaining('מַשַּׁקִּית תַּ״שׁ'), findsNothing);

    // Tap 'В словарь FSRS'
    final fsrsButton = find.byTooltip('В словарь FSRS');
    expect(fsrsButton, findsOneWidget);
    await tester.tap(fsrsButton);
    await tester.pumpAndSettle();

    verify(() => srsMock(any())).called(1);
  });

  testWidgets('navigating to Tsav Rishon tab and answering question shows advice', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Switch to Tab 2
    final tab2 = find.text('Собеседование (Цав Ришон)');
    await tester.tap(tab2);
    await tester.pumpAndSettle();

    expect(find.textContaining('Личное интервью'), findsOneWidget);
    expect(find.textContaining('אֵיךְ אַתָּה מִתְמוֹדֵד עִם קְשָׁיִים'), findsOneWidget);

    // Tap best answer
    final bestOption = find.textContaining('אֲנִי מְאֹד רוֹצֶה לִתְרֹם');
    expect(bestOption, findsOneWidget);
    await tester.tap(bestOption);
    await tester.pumpAndSettle();

    expect(find.textContaining('Отличный ответ для интервьюера!'), findsOneWidget);
    expect(find.textContaining('Совет инсайдера:'), findsOneWidget);
  });
}
