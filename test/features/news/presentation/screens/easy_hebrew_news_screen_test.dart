import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/news/presentation/screens/easy_hebrew_news_screen.dart';
import 'package:nexus_hebrew_app/features/news/presentation/widgets/word_lookup_sheet.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/add_card_to_srs.dart';

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}
class _MockAddCardToSrsUseCase extends Mock implements AddCardToSrsUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const AddCardToSrsParams(
        id: 'fallback_news',
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
      home: EasyHebrewNewsScreen(
        audioService: audioMock,
        addCardToSrsUseCase: srsMock,
      ),
    );
  }

  testWidgets('renders Easy Hebrew News feed with banner and article cards', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Новости на лёгком иврите'), findsOneWidget);
    expect(find.text('חֲדָשׁוֹת בְּעִבְרִית קַלָּה'), findsOneWidget);
    expect(find.text('Все новости'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Хайтек и наука'), findsOneWidget);

    // Article title checks
    expect(find.textContaining('סְטַארְטְאַפּ יִשְׂרְאֵלִי'), findsOneWidget);
    expect(find.textContaining('Свитков Мёртвого моря'), findsOneWidget);
  });

  testWidgets('filtering by category filters article list', (tester) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Tap 'Погода и природа'
    final weatherChip = find.widgetWithText(ChoiceChip, 'Погода и природа');
    expect(weatherChip, findsOneWidget);
    await tester.ensureVisible(weatherChip);
    await tester.tap(weatherChip);
    await tester.pumpAndSettle();

    expect(find.textContaining('הַשֶּׁלֶג חָזַר לַחֶרְמוֹן'), findsOneWidget);
    // Solar article should now be filtered out
    expect(find.textContaining('סְטַארְטְאַפּ יִשְׂרְאֵלִי'), findsNothing);
  });

  testWidgets('opening article displays reader view and tapping vocabulary opens lookup sheet', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Tap first article: Solar Negev
    final firstArticle = find.textContaining('סְטַארְטְאַפּ יִשְׂרְאֵלִי');
    await tester.tap(firstArticle);
    await tester.pumpAndSettle();

    // Reader view is open
    expect(find.textContaining('חֶבְרַת הַזְּנֵק (סְטַארְטְאַפּ)'), findsOneWidget);
    expect(find.text('Словарь статьи (нажмите для перевода и FSRS)'), findsOneWidget);

    // Tap vocabulary chip: חֶבְרַת הַזְנֵק
    final vocabChip = find.textContaining('חֶבְרַת הַזְנֵק');
    expect(vocabChip, findsOneWidget);
    await tester.tap(vocabChip);
    await tester.pumpAndSettle();

    // Word lookup sheet is visible
    expect(find.byType(WordLookupSheet), findsOneWidget);
    expect(find.text('стартап'), findsOneWidget);
    expect(find.textContaining('ז-נ-ק'), findsOneWidget);

    // Tap 'Сохранить в FSRS карточки'
    final saveButton = find.text('Сохранить в FSRS карточки');
    expect(saveButton, findsOneWidget);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    verify(() => srsMock(any())).called(1);
  });
}
