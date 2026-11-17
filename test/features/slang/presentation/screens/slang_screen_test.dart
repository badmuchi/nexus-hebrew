import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/slang/domain/entities/slang_expression.dart';
import 'package:nexus_hebrew_app/features/slang/domain/usecases/get_slang_expressions.dart';
import 'package:nexus_hebrew_app/features/slang/presentation/screens/slang_screen.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/add_card_to_srs.dart';

class _MockGetSlangExpressionsUseCase extends Mock
    implements GetSlangExpressionsUseCase {}
class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}
class _MockAddCardToSrsUseCase extends Mock implements AddCardToSrsUseCase {}

void main() {
  late _MockGetSlangExpressionsUseCase getSlangMock;
  late _MockAudioPlaybackService audioMock;
  late _MockAddCardToSrsUseCase addSrsMock;

  final testExpressions = [
    const SlangExpression(
      id: 'slang_1',
      hebrew: HebrewText.fixture(vocalized: 'סַבָּבָּה', normalized: 'סבבה'),
      transliteration: 'sababa',
      translationRu: 'Отлично, круто',
      literalTranslationRu: 'из арабского',
      culturalNoteRu: 'Самое популярное слово в Израиле',
      category: SlangCategory.street,
      exampleHebrew: 'הַכֹּל סַבָּבָּה!',
      exampleTranslationRu: 'Всё круто!',
    ),
    const SlangExpression(
      id: 'slang_2',
      hebrew: HebrewText.fixture(vocalized: 'יַאלְלָה', normalized: 'יאללה'),
      transliteration: 'yalla',
      translationRu: 'Давай, погнали',
      literalTranslationRu: 'из арабского',
      culturalNoteRu: 'Мотор израильской речи',
      category: SlangCategory.street,
      exampleHebrew: 'יַאלְלָה, בּוֹא!',
      exampleTranslationRu: 'Давай, пошли!',
    ),
  ];

  setUpAll(() {
    registerFallbackValue(SlangCategory.all);
    registerFallbackValue(
      const AddCardToSrsParams(
        id: 'fallback',
        hebrewVocalized: 'א',
        russianTranslation: 'fallback',
      ),
    );
  });

  setUp(() {
    getSlangMock = _MockGetSlangExpressionsUseCase();
    audioMock = _MockAudioPlaybackService();
    addSrsMock = _MockAddCardToSrsUseCase();

    when(() => getSlangMock.call(
          category: any(named: 'category'),
          query: any(named: 'query'),
        )).thenAnswer((_) async => Success(testExpressions));

    when(() => audioMock.playWithTtsFallback(
          sourcePath: any(named: 'sourcePath'),
          fallbackHebrewText: any(named: 'fallbackHebrewText'),
        )).thenAnswer((_) async => const Success<void, Failure>(null));

    when(() => addSrsMock.call(any()))
        .thenAnswer((_) async => const Success(true));
  });

  Widget createSubject() {
    return MaterialApp(
      home: SlangScreen(
        getSlangUseCase: getSlangMock,
        audioService: audioMock,
        addCardToSrsUseCase: addSrsMock,
      ),
    );
  }

  group('SlangScreen', () {
    testWidgets('отображает список выражений и фильтрует по поиску', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('Сабра-гид: Сленг 🇮🇱'), findsOneWidget);
      expect(find.text('סַבָּבָּה'), findsOneWidget);
      expect(find.text('יַאלְלָה'), findsOneWidget);

      // Раскрываем справку «Откуда пошло?»
      await tester.tap(find.text('Откуда пошло?').first);
      await tester.pumpAndSettle();
      expect(find.text('Самое популярное слово в Израиле'), findsOneWidget);

      // Поиск
      await tester.enterText(find.byType(TextField), 'yalla');
      await tester.pumpAndSettle();
      expect(find.text('יַאלְלָה'), findsOneWidget);
      expect(find.text('סַבָּבָּה'), findsNothing);
    });

    testWidgets('кнопка В FSRS сохраняет выражение в колоду', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final srsBtn = find.text('В FSRS').first;
      await tester.tap(srsBtn);
      await tester.pumpAndSettle();

      verify(() => addSrsMock.call(any())).called(1);
      expect(find.textContaining('сохранено в колоду FSRS!'), findsOneWidget);
    });
  });
}
