import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/holidays/presentation/screens/holidays_shabbat_screen.dart';
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
      home: HolidaysShabbatScreen(
        audioService: audioMock,
        addCardToSrsUseCase: srsMock,
      ),
    );
  }

  testWidgets('renders screen with title and three tabs', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Шаббат, Праздники и Традиции Израиля'), findsOneWidget);
    expect(find.text('Шаббат в Израиле'), findsOneWidget);
    expect(find.text('Праздники'), findsOneWidget);
    expect(find.text('Этикет и Словарь'), findsOneWidget);

    // Initial Tab: Shabbat
    expect(find.text('Шаббат в Израиле (שַׁבָּת קֹדֶשׁ)'), findsOneWidget);
    expect(find.text('Шпаргалка передвижения в Шаббат'), findsOneWidget);
  });

  testWidgets('navigating to Holidays tab allows filtering by season', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Switch to tab 2: Праздники
    await tester.tap(find.text('Праздники'));
    await tester.pumpAndSettle();

    // Shows holidays like Еврейский Новый год, Судный день
    expect(find.text('Еврейский Новый год'), findsOneWidget);
    expect(find.text('Судный день'), findsOneWidget);

    // Filter by Autumn
    final autumnChip = find.textContaining('Осенние праздники');
    expect(autumnChip, findsOneWidget);
    await tester.tap(autumnChip);
    await tester.pumpAndSettle();

    expect(find.text('Еврейский Новый год'), findsOneWidget);
  });

  testWidgets('navigating to Etiquette & Glossary tab allows answering scenario and searching glossary', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Switch to tab 3: Этикет и Словарь
    await tester.tap(find.text('Этикет и Словарь'));
    await tester.pumpAndSettle();

    // Scenario header and situation
    expect(find.textContaining('Коллега по команде / Босс'), findsOneWidget);
    expect(find.textContaining('Пятница 13:00'), findsOneWidget);

    // Tap first option
    final firstOption = find.textContaining('שַׁבָּת שָׁלוֹם גַּם לְךָ');
    expect(firstOption, findsOneWidget);
    await tester.tap(firstOption);
    await tester.pumpAndSettle();

    // Explanation should appear
    expect(find.textContaining('классическое дружелюбное пожелание'), findsOneWidget);

    // Search glossary
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, 'קידוש');
    await tester.pumpAndSettle();

    expect(find.textContaining('קִדּוּשׁ'), findsWidgets);
  });
}
