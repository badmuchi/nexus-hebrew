import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/add_card_to_srs.dart';
import 'package:nexus_hebrew_app/features/srs/presentation/widgets/deck_import_dialog.dart';

class _MockAddCardToSrsUseCase extends Mock implements AddCardToSrsUseCase {}

void main() {
  late _MockAddCardToSrsUseCase mockAddCardUseCase;

  setUpAll(() {
    registerFallbackValue(
      const AddCardToSrsParams(
        id: 'fallback_id',
        hebrewVocalized: 'שָׁלוֹם',
        russianTranslation: 'Привет',
      ),
    );
  });

  setUp(() {
    mockAddCardUseCase = _MockAddCardToSrsUseCase();
    when(() => mockAddCardUseCase(any()))
        .thenAnswer((_) async => const Success(true));
  });

  Widget createSubject({VoidCallback? onImportCompleted}) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () {
                DeckImportDialog.show(
                  context,
                  addCardToSrsUseCase: mockAddCardUseCase,
                  onImportCompleted: onImportCompleted,
                );
              },
              child: const Text('Open Import'),
            ),
          ),
        ),
      ),
    );
  }

  group('DeckImportDialog', () {
    testWidgets('открывается и отображает чипы шаблонов и поле ввода', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.tap(find.text('Open Import'));
      await tester.pumpAndSettle();

      expect(find.text('Импорт колоды слов'), findsOneWidget);
      expect(find.text('Anki TSV'), findsOneWidget);
      expect(find.text('JSON'), findsOneWidget);
      expect(find.text('Список слов'), findsOneWidget);
      expect(find.text('Вставьте текст выше'), findsOneWidget);
    });

    testWidgets('загрузка шаблона Anki TSV распознает карточки и активирует импорт', (tester) async {
      var completed = false;
      await tester.pumpWidget(createSubject(onImportCompleted: () => completed = true));
      await tester.tap(find.text('Open Import'));
      await tester.pumpAndSettle();

      // Нажимаем на шаблон Anki TSV
      await tester.tap(find.text('Anki TSV'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Формат: Anki TSV'), findsOneWidget);
      expect(find.textContaining('Распознано: 3 карточек'), findsOneWidget);
      expect(find.text('שָׁלוֹם'), findsOneWidget);
      expect(find.text('Импортировать 3 карточек'), findsOneWidget);

      // Запускаем импорт
      await tester.tap(find.text('Импортировать 3 карточек'));
      await tester.pumpAndSettle();

      verify(() => mockAddCardUseCase(any())).called(3);
      expect(completed, isTrue);
      expect(find.textContaining('Успешно импортировано 3 карточек'), findsOneWidget);
    });

    testWidgets('загрузка шаблона JSON корректно распознает карточки', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.tap(find.text('Open Import'));
      await tester.pumpAndSettle();

      // Нажимаем на шаблон JSON
      await tester.tap(find.text('JSON'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Формат: JSON'), findsOneWidget);
      expect(find.textContaining('Распознано: 2 карточек'), findsOneWidget);
      expect(find.text('בּוֹקֶר טוֹב'), findsOneWidget);
      expect(find.text('Импортировать 2 карточек'), findsOneWidget);
    });
  });
}
