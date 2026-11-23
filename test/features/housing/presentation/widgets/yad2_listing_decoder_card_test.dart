import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/housing/data/datasources/housing_seed_data.dart';
import 'package:nexus_hebrew_app/features/housing/presentation/widgets/yad2_listing_decoder_card.dart';

void main() {
  testWidgets('Yad2ListingDecoderCard renders listing details, badges, and decodes abbreviation',
      (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final testListing = HousingSeedData.apartmentListings[0];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Yad2ListingDecoderCard(
              listing: testListing,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify header, price, badges
    expect(find.textContaining('Тель-Авив • Флорентин'), findsOneWidget);
    expect(find.text('₪6800 / мес'), findsOneWidget);
    expect(find.text('2.5 комн.'), findsOneWidget);
    expect(find.text('Без МАМАДа ⚠️'), findsOneWidget);

    // Tap on abbreviation chip "ש״ח"
    expect(find.text('ש״ח'), findsOneWidget);
    await tester.tap(find.text('ש״ח'));
    await tester.pumpAndSettle();

    // Detailed explanation box should appear
    expect(find.text('₪6,800 в месяц'), findsOneWidget);
    expect(find.text('שֶׁקֶל חָדָשׁ'), findsOneWidget);
    expect(find.textContaining('Стандартная цена для Флорентина'), findsOneWidget);

    // Verify trap warning is present
    expect(find.textContaining('Внимание: 2 этаж без лифта'), findsOneWidget);
  });
}
