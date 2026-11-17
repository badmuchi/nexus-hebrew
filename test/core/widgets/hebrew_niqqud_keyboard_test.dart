import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/core/widgets/hebrew_niqqud_keyboard.dart';

void main() {
  group('HebrewNiqqudKeyboard', () {
    testWidgets('renders letter keys and inserts letter into controller', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HebrewNiqqudKeyboard(controller: controller),
          ),
        ),
      );

      // Verify letters are present
      expect(find.text('ש'), findsOneWidget);
      expect(find.text('ל'), findsOneWidget);
      expect(find.text('ו'), findsOneWidget);
      expect(find.text('ם'), findsWidgets);

      // Tap 'ש'
      await tester.tap(find.text('ש'));
      await tester.pump();
      expect(controller.text, equals('ש'));

      // Tap 'ל'
      await tester.tap(find.text('ל'));
      await tester.pump();
      expect(controller.text, equals('של'));
    });

    testWidgets('renders quick sofit bar and inserts final letters', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HebrewNiqqudKeyboard(controller: controller),
          ),
        ),
      );

      expect(find.text('Конечные (סופיות):'), findsOneWidget);

      // Tap final mem 'ם' in quick sofit bar
      final sofitMem = find.text('ם').first;
      await tester.tap(sofitMem);
      await tester.pump();
      expect(controller.text, equals('ם'));
    });

    testWidgets('long press on base letter inserts final sofit variant', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HebrewNiqqudKeyboard(controller: controller),
          ),
        ),
      );

      // Long press 'מ' to insert 'ם'
      await tester.longPress(find.text('מ'));
      await tester.pump();
      expect(controller.text, equals('ם'));
    });

    testWidgets('toggles layout between standard and alphabetical (А-Я)', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HebrewNiqqudKeyboard(controller: controller),
          ),
        ),
      );

      expect(find.text('Клавиатура (IL)'), findsOneWidget);
      expect(find.text('А-Я'), findsOneWidget);

      await tester.tap(find.text('А-Я'));
      await tester.pump();

      expect(find.text('Алеф-Бет (А-Я)'), findsOneWidget);
      expect(find.text('Стандарт'), findsOneWidget);
    });

    testWidgets('inserts niqqud diacritic mark into controller', (tester) async {
      final controller = TextEditingController(text: 'ש');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HebrewNiqqudKeyboard(controller: controller),
          ),
        ),
      );

      // Kamatz niqqud (◌ָ)
      await tester.tap(find.text('◌ָ'));
      await tester.pump();

      // Controller text should now have 'ש' followed by Kamatz ('\u05B8')
      expect(controller.text, equals('ש\u05B8'));
    });

    testWidgets('space, backspace, and clear buttons work correctly', (tester) async {
      final controller = TextEditingController(text: 'שלום');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HebrewNiqqudKeyboard(controller: controller),
          ),
        ),
      );

      // Backspace
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();
      expect(controller.text, equals('שלו'));

      // Space
      await tester.tap(find.text('Пробел (רווח)'));
      await tester.pump();
      expect(controller.text, equals('שלו '));

      // Clear
      await tester.tap(find.text('Очистить'));
      await tester.pump();
      expect(controller.text, isEmpty);
    });

    testWidgets('toggles extended niqqud view on button tap', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HebrewNiqqudKeyboard(controller: controller),
          ),
        ),
      );

      expect(find.text('Все огласовки'), findsOneWidget);
      expect(find.text('◌ֱ'), findsNothing);

      await tester.tap(find.text('Все огласовки'));
      await tester.pump();

      expect(find.text('Меньше огласовок'), findsOneWidget);
      expect(find.text('◌ֱ'), findsOneWidget);
    });
  });
}
