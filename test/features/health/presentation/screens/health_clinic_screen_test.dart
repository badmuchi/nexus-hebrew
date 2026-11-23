import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/health/presentation/screens/health_clinic_screen.dart';

void main() {
  testWidgets('HealthClinicScreen renders 3 tabs and simulates medical doctor case answering',
      (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: HealthClinicScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify 3 tabs are present
    expect(find.text('Части тела и боли'), findsOneWidget);
    expect(find.text('Врач и Аптека'), findsOneWidget);
    expect(find.text('Атлас медицины'), findsOneWidget);

    // Initial tab is Body Map
    expect(find.text('Секрет анатомии в иврите:'), findsOneWidget);

    // Switch to Tab 2: Врач и Аптека
    await tester.tap(find.text('Врач и Аптека'));
    await tester.pumpAndSettle();

    expect(find.text('Что ответишь врачу или фармацевту?'), findsOneWidget);
    expect(find.textContaining('שָׁלוֹם! שֵׁב בְּבַקָּשָׁה'), findsOneWidget);

    // Select the best answer (A: כּוֹאֵב לִי הַגָּרוֹן)
    await tester.tap(find.textContaining('כּוֹאֵב לִי הַגָּרוֹן כְּבָר שְׁלוֹשָׁה יָמִים'));
    await tester.pumpAndSettle();

    // Verify feedback
    expect(find.text('Правильно и четко!'), findsOneWidget);

    // Switch to Tab 3: Атлас медицины
    await tester.tap(find.text('Атлас медицины'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Поиск по медицинскому словарю'), findsOneWidget);
    expect(find.textContaining('קֻפַּת חוֹלִים'), findsOneWidget);
    expect(find.textContaining('Больничная касса'), findsOneWidget);
  });
}
