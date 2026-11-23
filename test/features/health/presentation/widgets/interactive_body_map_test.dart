import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/health/data/datasources/health_seed_data.dart';
import 'package:nexus_hebrew_app/features/health/presentation/widgets/interactive_body_map.dart';

void main() {
  testWidgets('InteractiveBodyMap renders parts, filters by region, and expands pain phrase',
      (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: InteractiveBodyMap(
            bodyParts: HealthSeedData.bodyParts,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify top callout & items
    expect(find.text('Секрет анатомии в иврите:'), findsOneWidget);
    expect(find.text('Голова'), findsOneWidget);
    expect(find.text('Глаз (глаза)'), findsOneWidget);

    // Tap on "Голова" to expand pain phrase
    await tester.tap(find.text('Голова'));
    await tester.pumpAndSettle();

    expect(find.text('🗣️ Как сказать врачу:'), findsOneWidget);
    expect(find.text('כּוֹאֵב לִי הָרֹאשׁ מְאוֹד.'), findsOneWidget);
    expect(find.text('У меня очень болит голова.'), findsOneWidget);

    // Filter by "Корпус и спина"
    await tester.tap(find.text('🫁 Корпус и спина'));
    await tester.pumpAndSettle();

    expect(find.text('Спина'), findsOneWidget);
    expect(find.text('Живот / желудок'), findsOneWidget);
    expect(find.text('Голова'), findsNothing);
  });
}
