import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/career/presentation/screens/job_interview_simulator_screen.dart';

void main() {
  testWidgets('JobInterviewSimulatorScreen renders 3 tabs and simulates interview answering',
      (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: JobInterviewSimulatorScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify 3 tabs are present
    expect(find.text('Собеседование'), findsOneWidget);
    expect(find.text('Тлуш Маскорет'), findsOneWidget);
    expect(find.text('Хайтек-словарь'), findsOneWidget);

    // Initial interview question: HR screening
    expect(find.textContaining('סַפֵּר לִי קְצָת עַל עַצְמְךָ'), findsOneWidget);
    expect(find.text('Как ответишь рекрутеру?'), findsOneWidget);

    // Tap first option (best option)
    await tester.tap(find.textContaining('אֲנִי מְפַתֵּחַ עִם 5 שְׁנוֹת נִסָּיוֹן'));
    await tester.pumpAndSettle();

    // Feedback should appear
    expect(find.text('Отличный ответ сабры!'), findsOneWidget);

    // Switch to Tab 2: Тлуш Маскорет
    await tester.tap(find.text('Тлуш Маскорет'));
    await tester.pumpAndSettle();

    expect(find.text('Симулятор: Брутто ➔ Чистыми на руки'), findsOneWidget);
    expect(find.text('₪25000'), findsWidgets);

    // Switch to Tab 3: Хайтек-словарь
    await tester.tap(find.text('Хайтек-словарь'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Поиск по словарю'), findsOneWidget);
    expect(find.textContaining('תְּלוּשׁ מַשְׂכֹּרֶת'), findsOneWidget);
  });
}
