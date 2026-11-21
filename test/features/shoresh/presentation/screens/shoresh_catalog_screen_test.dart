import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/shoresh/data/repositories/shoresh_repository_impl.dart';
import 'package:nexus_hebrew_app/features/shoresh/presentation/screens/shoresh_catalog_screen.dart';
import 'package:nexus_hebrew_app/features/shoresh/presentation/screens/shoresh_detective_game_screen.dart';
import 'package:nexus_hebrew_app/features/shoresh/presentation/screens/shoresh_family_screen.dart';

void main() {
  group('ShoreshCatalogScreen', () {
    testWidgets('renders catalog banner, search box, category chips, and root cards', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = ShoreshRepositoryImpl();

      await tester.pumpWidget(
        MaterialApp(
          home: ShoreshCatalogScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Лаборатория корней'), findsOneWidget);
      expect(find.text('Шореш-Детектив'), findsOneWidget);
      expect(find.text('Пройти квест «Раскрой корень»'), findsOneWidget);
      expect(find.text('כ-ת-ב'), findsOneWidget);
      expect(find.text('Письмо, запись, книга'), findsOneWidget);
      expect(find.text('Все категории'), findsOneWidget);
    });

    testWidgets('filtering by search input narrows down roots', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = ShoreshRepositoryImpl();

      await tester.pumpWidget(
        MaterialApp(
          home: ShoreshCatalogScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'письмо');
      await tester.pumpAndSettle();

      expect(find.text('כ-ת-ב'), findsOneWidget);
      expect(find.text('Письмо, запись, книга'), findsOneWidget);
    });

    testWidgets('tapping root card navigates to ShoreshFamilyScreen', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = ShoreshRepositoryImpl();

      await tester.pumpWidget(
        MaterialApp(
          home: ShoreshCatalogScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      final rootCard = find.text('כ-ת-ב');
      expect(rootCard, findsOneWidget);
      await tester.tap(rootCard);
      await tester.pumpAndSettle();

      expect(find.byType(ShoreshFamilyScreen), findsOneWidget);
      expect(find.text('Семья корня כ-ת-ב'), findsOneWidget);
    });

    testWidgets('tapping detective quest banner opens ShoreshDetectiveGameScreen', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = ShoreshRepositoryImpl();

      await tester.pumpWidget(
        MaterialApp(
          home: ShoreshCatalogScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      final questBtn = find.text('Пройти квест «Раскрой корень»');
      expect(questBtn, findsOneWidget);
      await tester.tap(questBtn);
      await tester.pumpAndSettle();

      expect(find.byType(ShoreshDetectiveGameScreen), findsOneWidget);
      expect(find.text('Шореш-Детектив 🔍'), findsOneWidget);
    });
  });
}
