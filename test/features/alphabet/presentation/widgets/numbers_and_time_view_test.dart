import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/alphabet/presentation/widgets/numbers_and_time_view.dart';

void main() {
  Widget createTestWidget() {
    return const MaterialApp(
      home: Scaffold(
        body: NumbersAndTimeView(),
      ),
    );
  }

  group('NumbersAndTimeView', () {
    testWidgets('renders counting tab, gender paradox banner, and simulator',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Счёт и род'), findsOneWidget);
      expect(find.text('Время'), findsOneWidget);
      expect(find.text('Тренажер'), findsOneWidget);

      expect(find.text('Парадокс рода в иврите (1–10)'), findsOneWidget);
      expect(find.text('Интерактивный симулятор счёта:'), findsOneWidget);

      // Default is 3 + shekel -> שְׁלוֹשָׁה שְׁקָלִים
      expect(find.text('שְׁלוֹשָׁה שְׁקָלִים'), findsOneWidget);
    });

    testWidgets('changing noun in simulator updates gender agreement',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on feminine noun: 'עוּגָה (ж.р.)'
      final ugaChip = find.text('עוּגָה (ж.р.)');
      await tester.ensureVisible(ugaChip);
      await tester.tap(ugaChip);
      await tester.pumpAndSettle();

      // 3 + uga -> שָׁלוֹשׁ עוּגוֹת
      expect(find.text('שָׁלוֹשׁ עוּגוֹת'), findsOneWidget);
    });

    testWidgets('switching to Time tab displays clock and handles intervals',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on 'Время' tab
      final timeTab = find.text('Время');
      await tester.tap(timeTab);
      await tester.pumpAndSettle();

      // Default time is 03:15 -> שָׁלוֹשׁ וָרֶבַע
      expect(find.text('03:15'), findsOneWidget);
      expect(find.text('שָׁלוֹשׁ וָרֶבַע'), findsOneWidget);

      // Tap on ':30 Половина (וָחֵצִי)'
      final halfPast = find.text(':30 Половина (וָחֵצִי)');
      await tester.ensureVisible(halfPast);
      await tester.tap(halfPast);
      await tester.pumpAndSettle();

      expect(find.text('03:30'), findsOneWidget);
      expect(find.text('שָׁלוֹשׁ וָחֵצִי'), findsOneWidget);
    });

    testWidgets('switching to Drill tab handles question answer and next',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on 'Тренажер' tab
      final drillTab = find.text('Тренажер');
      await tester.tap(drillTab);
      await tester.pumpAndSettle();

      expect(find.textContaining('Вопрос 1 из'), findsOneWidget);
      expect(find.textContaining('Как правильно сказать: «Три шекеля»'), findsOneWidget);

      // Tap correct answer: 'שְׁלוֹשָׁה שְׁקָלִים'
      final option = find.widgetWithText(OutlinedButton, 'שְׁלוֹשָׁה שְׁקָלִים');
      await tester.ensureVisible(option);
      await tester.tap(option);
      await tester.pumpAndSettle();

      expect(find.text('Правильно!'), findsOneWidget);
      expect(find.byKey(const Key('next_number_quiz_button')), findsOneWidget);

      // Tap next
      await tester.tap(find.byKey(const Key('next_number_quiz_button')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Вопрос 2 из'), findsOneWidget);
    });
  });
}
