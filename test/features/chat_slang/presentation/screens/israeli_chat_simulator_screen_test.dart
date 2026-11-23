import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/chat_slang/presentation/screens/israeli_chat_simulator_screen.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/add_card_to_srs.dart';

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}
class _MockAddCardToSrsUseCase extends Mock implements AddCardToSrsUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const AddCardToSrsParams(
        id: 'fallback_slang',
        hebrewVocalized: 'תכלס',
        russianTranslation: 'по факту',
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
      home: IsraeliChatSimulatorScreen(
        audioService: audioMock,
        addCardToSrsUseCase: srsMock,
      ),
    );
  }

  testWidgets('renders chat simulator with tabs and default Vaad Bayit messages', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('WhatsApp и сленг Израиля'), findsOneWidget);
    expect(find.text('Симулятор переписок'), findsOneWidget);
    expect(find.text('Словарь аббревиатур'), findsOneWidget);

    // Default Vaad Bayit
    expect(find.textContaining('Ваад Байт'), findsWidgets);
    expect(find.text('שלמה (ועד)'), findsOneWidget);
    expect(find.textContaining('קוֹרְקִינֶט'), findsWidgets);
  });

  testWidgets('switching chat channel and sending a reply updates messages and shows feedback', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Switch to High-Tech Dev Team
    final techChip = find.text('Хайтек Dev Team — Slack/WhatsApp');
    expect(techChip, findsOneWidget);
    await tester.tap(techChip);
    await tester.pumpAndSettle();

    expect(find.textContaining('צֶוֶת Dev'), findsOneWidget);
    expect(find.text('תומר (Team Lead)'), findsOneWidget);

    // Pick first reply option
    final replyOption = find.textContaining('אֲנִי כְּבָר עַל זֶה');
    expect(replyOption, findsOneWidget);
    await tester.tap(replyOption);
    await tester.pumpAndSettle();

    // Tap send button
    final sendButton = find.text('Отправить сообщение в группу');
    expect(sendButton, findsOneWidget);
    await tester.tap(sendButton);
    await tester.pumpAndSettle();

    // Verify feedback banner
    expect(find.textContaining('Отличный выбор'), findsOneWidget);
    expect(find.textContaining('Правило этикета:'), findsOneWidget);
  });

  testWidgets('navigating to Slang Glossary allows searching and adding to SRS', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Switch to tab 2: Словарь аббревиатур
    await tester.tap(find.text('Словарь аббревиатур'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Найдено выражений:'), findsOneWidget);

    // Search for amlak
    final searchInput = find.byType(TextField);
    expect(searchInput, findsOneWidget);
    await tester.enterText(searchInput, 'אמלק');
    await tester.pumpAndSettle();

    // Both in search text field and card badge
    expect(find.text('אמלק'), findsWidgets);
    expect(find.textContaining('Слишком длинно, не читал'), findsOneWidget);

    // Tap Add to SRS bookmark icon
    final bookmarkBtn = find.byTooltip('В словарь FSRS');
    expect(bookmarkBtn, findsOneWidget);
    await tester.tap(bookmarkBtn);
    await tester.pumpAndSettle();

    verify(() => srsMock(any())).called(1);
  });
}
