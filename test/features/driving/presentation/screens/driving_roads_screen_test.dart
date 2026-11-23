import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/driving/presentation/screens/driving_roads_screen.dart';

void main() {
  testWidgets('DrivingRoadsScreen renders 3 tabs, answers Waze prompt and scenario',
      (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: DrivingRoadsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify 3 tabs are present
    expect(find.text('Бордюры и Парковка'), findsOneWidget);
    expect(find.text('Голосовой Waze'), findsOneWidget);
    expect(find.text('Заправка и Дороги'), findsOneWidget);

    // Initial Tab: Parking
    expect(find.textContaining('Цвета бордюров в Израиле'), findsOneWidget);

    // Switch to Tab 2: Waze
    await tester.tap(find.text('Голосовой Waze'));
    await tester.pumpAndSettle();

    expect(find.text('Какое действие требует навигатор?'), findsOneWidget);
    expect(find.textContaining('פְּנֵה יְמִינָה'), findsOneWidget);

    // Select the first option: Повернуть направо
    await tester.tap(find.text('Повернуть направо через 200 метров'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Верно! Вы не пропустите нужный маневр.'), findsOneWidget);

    // Switch to Tab 3: Заправка и Дороги
    await tester.tap(find.text('Заправка и Дороги'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Заправщик на АЗС'), findsOneWidget);
    expect(find.textContaining('Атлас израильского водителя'), findsOneWidget);
    expect(find.textContaining('רִשְׁיוֹן נְהִיגָה'), findsOneWidget);
  });
}
