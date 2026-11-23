import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/housing/presentation/screens/apartment_rental_screen.dart';

void main() {
  testWidgets('ApartmentRentalScreen renders 3 tabs, contract clauses, and maintenance scenario',
      (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: ApartmentRentalScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify 3 tabs are present
    expect(find.text('Объявления Yad2'), findsOneWidget);
    expect(find.text('Договор и Права'), findsOneWidget);
    expect(find.text('Поломки и Словарь'), findsOneWidget);

    // Initial Tab: Yad2
    expect(find.textContaining('Поиск жилья в Израиле'), findsOneWidget);
    expect(find.textContaining('Тель-Авив • Флорентин'), findsOneWidget);

    // Switch to Tab 2: Договор и Права
    await tester.tap(find.text('Договор и Права'));
    await tester.pumpAndSettle();

    expect(find.text('Все пункты'), findsOneWidget);
    expect(find.textContaining('Размер чека безопасности'), findsOneWidget);
    expect(find.textContaining('Законно ✅'), findsWidgets);

    // Switch to Tab 3: Поломки и Словарь
    await tester.tap(find.text('Поломки и Словарь'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Хозяин квартиры'), findsOneWidget);
    expect(find.textContaining('דּוּד הַשֶּׁמֶשׁ מְקַצֵּר'), findsOneWidget);

    // Choose best response
    await tester.tap(find.textContaining('תּוּכַל לִשְׁלֹחַ טֶכְנַאי דּוּדִים'));
    await tester.pumpAndSettle();

    // Verify glossary search and terms
    expect(find.textContaining('Словарь аренды и недвижимости'), findsOneWidget);
    expect(find.textContaining('שְׂכִירוּת'), findsWidgets);
    expect(find.textContaining('בַּעַל הַבַּיִת'), findsWidgets);
  });
}
