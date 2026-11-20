import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/search/domain/services/omni_search_engine.dart';
import 'package:nexus_hebrew_app/features/search/presentation/widgets/omni_search_sheet.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/add_card_to_srs.dart';

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}

class _MockAddCardToSrsUseCase extends Mock implements AddCardToSrsUseCase {}

void main() {
  late _MockAudioPlaybackService audioMock;
  late _MockAddCardToSrsUseCase srsMock;
  late OmniSearchEngine engine;

  setUpAll(() {
    registerFallbackValue(
      const AddCardToSrsParams(
        id: 'fallback',
        hebrewVocalized: 'שָׁלוֹם',
        russianTranslation: 'Мир',
      ),
    );
  });

  setUp(() {
    audioMock = _MockAudioPlaybackService();
    srsMock = _MockAddCardToSrsUseCase();
    engine = OmniSearchEngine.withStaticDefaults();

    when(
      () => audioMock.playWithTtsFallback(
        sourcePath: any(named: 'sourcePath'),
        fallbackHebrewText: any(named: 'fallbackHebrewText'),
      ),
    ).thenAnswer((_) async => const Success(null));

    when(() => srsMock.call(any())).thenAnswer((_) async => const Success(true));
  });

  Widget createSubject({void Function(int)? onNavigateToTab}) {
    return MaterialApp(
      home: Scaffold(
        body: OmniSearchSheet(
          engine: engine,
          audioService: audioMock,
          addCardToSrsUseCase: srsMock,
          onNavigateToTab: onNavigateToTab,
        ),
      ),
    );
  }

  testWidgets('renders initial search view with input, chips, and quick suggestions', (tester) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    expect(find.text('Быстрый поиск (Omni-Search)'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Все категории'), findsOneWidget);
    expect(find.text('Словарь'), findsOneWidget);
    expect(find.text('Сленг'), findsOneWidget);
    expect(find.text('Грамматика'), findsOneWidget);
    expect(find.text('Алфавит'), findsOneWidget);

    expect(find.text('Быстрый старт & популярные запросы:'), findsOneWidget);
    expect(find.text('שָׁלוֹם'), findsOneWidget);
    expect(find.text('💡 Совет по поиску'), findsOneWidget);
  });

  testWidgets('typing query searches and displays result tiles', (tester) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'אלף');
    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsOneWidget);
    expect(find.textContaining('Найдено результатов:'), findsOneWidget);
    expect(find.textContaining('Алеф'), findsWidgets);
  });

  testWidgets('category filter chip limits search results', (tester) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'שֶׁל');
    await tester.pumpAndSettle();

    // Select 'Предлоги'
    await tester.scrollUntilVisible(
      find.text('Предлоги'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Предлоги'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Найдено результатов:'), findsOneWidget);
    expect(find.text('Предлог'), findsWidgets);
  });

  testWidgets('tapping quick suggestion populates search and runs search', (tester) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.text('שלי'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'שלי'), findsOneWidget);
    expect(find.textContaining('Найдено результатов:'), findsOneWidget);
  });

  testWidgets('shows empty state when no matching results', (tester) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'несуществующееСлово12345');
    await tester.pumpAndSettle();

    expect(find.textContaining('Ничего не найдено по запросу'), findsOneWidget);
    expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
  });

  testWidgets('audio button calls audioService.playWithTtsFallback', (tester) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'אלף');
    await tester.pumpAndSettle();

    final volumeBtn = find.byIcon(Icons.volume_up_rounded).first;
    await tester.tap(volumeBtn);
    await tester.pumpAndSettle();

    verify(
      () => audioMock.playWithTtsFallback(
        sourcePath: null,
        fallbackHebrewText: any(named: 'fallbackHebrewText'),
      ),
    ).called(1);
  });

  testWidgets('FSRS bookmark button calls addCardToSrsUseCase and shows SnackBar', (tester) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'אלף');
    await tester.pumpAndSettle();

    final bookmarkBtn = find.byIcon(Icons.bookmark_add_outlined).first;
    await tester.tap(bookmarkBtn);
    await tester.pumpAndSettle();

    verify(() => srsMock.call(any())).called(1);

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('добавлено в FSRS'), findsOneWidget);
  });

  testWidgets('tapping result tile calls onNavigateToTab with correct index', (tester) async {
    int? navigatedTab;
    await tester.pumpWidget(createSubject(onNavigateToTab: (t) => navigatedTab = t));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'אלף');
    await tester.pumpAndSettle();

    // Tap on the first result card
    final firstCard = find.textContaining('Алеф').first;
    await tester.tap(firstCard);
    await tester.pumpAndSettle();

    expect(navigatedTab, 1); // Alphabet tab
  });
}
