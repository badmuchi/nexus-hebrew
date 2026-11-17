import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/alphabet/data/datasources/hebrew_alphabet_seed_data.dart';
import 'package:nexus_hebrew_app/features/alphabet/presentation/screens/alphabet_screen.dart';
import 'package:nexus_hebrew_app/features/alphabet/presentation/widgets/alphabet_quiz_sheet.dart';
import 'package:nexus_hebrew_app/features/alphabet/presentation/widgets/cursive_practice_canvas.dart';
import 'package:nexus_hebrew_app/features/alphabet/presentation/widgets/gematria_calculator_view.dart';
import 'package:nexus_hebrew_app/features/alphabet/presentation/widgets/letter_detail_sheet.dart';
import 'package:nexus_hebrew_app/features/alphabet/presentation/widgets/nikkud_explorer_view.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('AlphabetScreen', () {
    testWidgets('renders all tabs and displays letter cards', (tester) async {
      await tester.pumpWidget(createTestWidget(const AlphabetScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Алеф-Бет · Прописи · Никуд'), findsOneWidget);
      expect(find.text('Буквы и прописи'), findsOneWidget);
      expect(find.text('Огласовки (Никуд)'), findsOneWidget);
      expect(find.text('Гематрия'), findsOneWidget);

      // Verify letters are present
      expect(find.text('א'), findsWidgets);
      expect(find.text('Алеф'), findsOneWidget);
    });

    testWidgets('filters letters by search query', (tester) async {
      await tester.pumpWidget(createTestWidget(const AlphabetScreen()));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Шин');
      await tester.pumpAndSettle();

      expect(find.text('Шин / Син'), findsOneWidget);
      expect(find.text('Алеф'), findsNothing);
    });

    testWidgets('switches to Nikkud and Gematria tabs', (tester) async {
      await tester.pumpWidget(createTestWidget(const AlphabetScreen()));
      await tester.pumpAndSettle();

      // Switch to Nikkud tab
      await tester.tap(find.text('Огласовки (Никуд)'));
      await tester.pumpAndSettle();

      expect(find.byType(NikkudExplorerView), findsOneWidget);
      expect(find.text('Что такое никуд (נִקּוּד)?'), findsOneWidget);
      expect(find.textContaining('Камац'), findsWidgets);

      // Switch to Gematria tab
      await tester.tap(find.text('Гематрия'));
      await tester.pumpAndSettle();

      expect(find.byType(GematriaCalculatorView), findsOneWidget);
      expect(find.text('Значение гематрии'), findsOneWidget);
      expect(find.text('376'), findsOneWidget); // Default "שלום"
    });

    testWidgets('tapping letter opens LetterDetailSheet modal', (tester) async {
      await tester.pumpWidget(createTestWidget(const AlphabetScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Алеф'));
      await tester.pumpAndSettle();

      expect(find.byType(LetterDetailSheet), findsOneWidget);
      expect(find.text('Фонетика и звучание'), findsOneWidget);
      expect(find.text('Тренировать прописи'), findsOneWidget);
    });

    testWidgets('quiz action button opens AlphabetQuizSheet', (tester) async {
      await tester.pumpWidget(createTestWidget(const AlphabetScreen()));
      await tester.pumpAndSettle();

      final quizButton = find.byIcon(Icons.quiz_rounded);
      expect(quizButton, findsOneWidget);

      await tester.tap(quizButton);
      await tester.pumpAndSettle();

      expect(find.byType(AlphabetQuizSheet), findsOneWidget);
      expect(find.textContaining('Викторина: Вопрос'), findsOneWidget);
    });
  });

  group('CursivePracticeCanvas', () {
    testWidgets('allows drawing strokes, undo, and clear', (tester) async {
      final alef = HebrewAlphabetSeedData.letters.first;

      await tester.pumpWidget(
        createTestWidget(
          CursivePracticeCanvas(letter: alef),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Прописи · Алеф'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      // Simulate drawing a stroke
      final gestureArea = find.byKey(const Key('cursive_drawing_area'));
      await tester.drag(gestureArea, const Offset(30, 30));
      await tester.pumpAndSettle();

      // Undo button should now be enabled
      final undoButton = find.widgetWithText(OutlinedButton, 'Отмена');
      expect(undoButton, findsOneWidget);
      await tester.ensureVisible(undoButton);
      await tester.tap(undoButton);
      await tester.pumpAndSettle();

      // Draw another stroke and clear
      await tester.drag(gestureArea, const Offset(40, 40));
      await tester.pumpAndSettle();

      final clearButton = find.widgetWithText(FilledButton, 'Очистить');
      expect(clearButton, findsOneWidget);
      await tester.ensureVisible(clearButton);
      await tester.tap(clearButton);
      await tester.pumpAndSettle();
    });
  });
}
