import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/numbers/presentation/widgets/israeli_coins_counter.dart';

void main() {
  group('IsraeliCoinsCounter', () {
    testWidgets('добавляет монеты и банкноты, обновляет итог и вызывает сброс', (tester) async {
      int? submittedAmount;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IsraeliCoinsCounter(
              targetAmount: 32,
              onAmountSubmitted: (val) => submittedAmount = val,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ИТОГО К ОПЛАТЕ'), findsOneWidget);
      expect(find.text('₪0'), findsOneWidget);
      expect(find.text('₪32'), findsOneWidget);

      // Кликаем по монете ₪10
      await tester.tap(find.text('₪10'));
      await tester.pumpAndSettle();
      expect(find.text('₪10'), findsWidgets);

      // Кликаем по банкноте ₪20
      await tester.tap(find.text('₪20'));
      await tester.pumpAndSettle();
      expect(find.text('₪30'), findsOneWidget);

      // Кликаем по монете ₪2
      await tester.tap(find.text('₪2'));
      await tester.pumpAndSettle();
      expect(find.text('₪32'), findsWidgets);

      // Нажимаем "Оплатить точно!"
      final payBtn = find.text('Оплатить точно! ₪32');
      expect(payBtn, findsOneWidget);
      await tester.tap(payBtn);
      await tester.pumpAndSettle();
      expect(submittedAmount, equals(32));

      // Нажимаем "Сброс"
      final resetBtn = find.text('Сброс');
      await tester.tap(resetBtn);
      await tester.pumpAndSettle();
      expect(find.text('₪0'), findsOneWidget);
    });
  });
}
