import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/career/data/datasources/career_seed_data.dart';
import 'package:nexus_hebrew_app/features/career/presentation/widgets/payslip_inspector_card.dart';

void main() {
  testWidgets('PayslipInspectorCard displays header metrics, filters and item details',
      (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PayslipInspectorCard(
              payslip: CareerSeedData.sampleHighTechPayslip,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify header information
    expect(find.textContaining('סייבר-טק מעבדות'), findsOneWidget);
    expect(find.text('Брутто'), findsOneWidget);
    expect(find.text('₪25000'), findsOneWidget);
    expect(find.text('Нетто в банк'), findsOneWidget);

    // Filter switching: click "Налоги и вычеты"
    await tester.tap(find.text('Налоги и вычеты'));
    await tester.pumpAndSettle();

    // In deductions, "Базовый оклад" should no longer be in the filtered list
    expect(find.textContaining('Базовый оклад'), findsNothing);
    expect(find.textContaining('Подоходный налог'), findsOneWidget);

    // Tap on Подоходный налог to open detail bottom sheet
    await tester.tap(find.textContaining('Подоходный налог'));
    await tester.pumpAndSettle();

    expect(find.text('💡 Что это означает в Израиле:'), findsOneWidget);
    expect(find.text('⚖️ Закон и права:'), findsOneWidget);
  });
}
