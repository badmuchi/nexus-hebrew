import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/numbers/presentation/screens/numbers_cashier_screen.dart';

void main() {
  group('NumbersCashierScreen', () {
    testWidgets('рендерит режимы, карточку вопроса и опции ответа', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      int earnedXp = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: NumbersCashierScreen(
            onXpEarned: (xp) => earnedXp += xp,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Касса и Шекели (קֻפָּה)'), findsOneWidget);
      expect(find.text('Тренажер кассы'), findsOneWidget);
      expect(find.text('Атлас чисел'), findsOneWidget);

      // Проверяем наличие чипов режимов
      expect(find.text('🛒 Касса и Сдача'), findsOneWidget);
      expect(find.text('⚖️ Блиц М.Р. / Ж.Р.'), findsOneWidget);
      expect(find.text('⏰ Который час?'), findsOneWidget);
      expect(find.text('💳 Диалог на кассе'), findsOneWidget);

      // Кликаем правильный ответ на первый вопрос (14 ₪)
      final correctOption = find.text('14 ₪');
      expect(correctOption, findsOneWidget);
      await tester.tap(correctOption);
      await tester.pumpAndSettle();

      expect(earnedXp, equals(15));
      expect(find.text('Верно! Отличная реакция!'), findsOneWidget);
      expect(find.text('Следующий вопрос ➔'), findsOneWidget);
    });

    testWidgets('переключается на вкладку Атлас чисел и отображает правила', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: NumbersCashierScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Переключаемся на вкладку "Атлас чисел"
      await tester.tap(find.text('Атлас чисел'));
      await tester.pumpAndSettle();

      expect(find.text('Золотое правило числительных 1-10:'), findsOneWidget);
      expect(find.text('Числа и цены в шекелях:'), findsOneWidget);
      expect(find.text('Полезные фразы на кассе:'), findsOneWidget);
      expect(find.text('אֶחָד'), findsOneWidget);
      expect(find.text('שְׁלוֹשָׁה'), findsOneWidget);
      expect(find.text('כַּמָּה זֶה עוֹלֶה?'), findsOneWidget);
    });

    testWidgets('позволяет переключить режим на Блиц М.Р. / Ж.Р.', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: NumbersCashierScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('⚖️ Блиц М.Р. / Ж.Р.'));
      await tester.pumpAndSettle();

      expect(find.textContaining('три шекеля'), findsOneWidget);
      expect(find.textContaining('שְׁלוֹשָׁה (шлоша)'), findsOneWidget);
    });
  });
}
