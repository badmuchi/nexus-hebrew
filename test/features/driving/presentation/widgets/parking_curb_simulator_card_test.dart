import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/driving/data/datasources/driving_seed_data.dart';
import 'package:nexus_hebrew_app/features/driving/presentation/widgets/parking_curb_simulator_card.dart';

void main() {
  testWidgets('ParkingCurbSimulatorCard displays curb strip, sign, and answers quiz',
      (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final testCase = DrivingSeedData.parkingCurbCases[0];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ParkingCurbSimulatorCard(
              curbCase: testCase,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify title, curb hebrew, sign box
    expect(find.text(testCase.titleRu), findsOneWidget);
    expect(find.text('כָּחֹל-לָבָן'), findsOneWidget);
    expect(find.textContaining('Знак мэрии'), findsOneWidget);

    // Answer quiz: tap "Запрещено" (since testCase is blue-white in evening)
    expect(find.text('Запрещено'), findsOneWidget);
    await tester.tap(find.text('Запрещено'));
    await tester.pumpAndSettle();

    // Verify feedback
    expect(find.text('Верно! Отличная дорожная интуиция.'), findsOneWidget);
    expect(find.textContaining('Штраф ₪250'), findsOneWidget);
  });
}
