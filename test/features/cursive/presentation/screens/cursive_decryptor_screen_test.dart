import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/cursive/presentation/screens/cursive_decryptor_screen.dart';

void main() {
  group('CursiveDecryptorScreen', () {
    testWidgets('рендерит табы, записки и фильтры категорий', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: CursiveDecryptorScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Дешифровщик Ктав Яд (כתב יד)'), findsOneWidget);
      expect(find.text('Записки из жизни'), findsOneWidget);
      expect(find.text('Блиц букв'), findsOneWidget);
      expect(find.text('Атлас Ктав Яд'), findsOneWidget);

      expect(find.text('Все записки'), findsOneWidget);
      expect(find.text('🏢 Подъезд и Ваад Байт'), findsOneWidget);
      expect(find.text('Объявление в подъезде от домкома'), findsOneWidget);
    });

    testWidgets('переключается на вкладку Атлас Ктав Яд и отображает все буквы', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: CursiveDecryptorScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Атлас Ктав Яд'));
      await tester.pumpAndSettle();

      expect(find.text('Зачем нужен Ктав Яд (כתב יד)?'), findsOneWidget);
      expect(find.text('Таблица трансформации всех 22 букв и софитов:'), findsOneWidget);
      expect(find.text('Алеф'), findsOneWidget);
      expect(find.text('Бет / Вет'), findsOneWidget);
      expect(find.text('Гимель'), findsOneWidget);
      expect(find.text('Ламед'), findsOneWidget);
    });

    testWidgets('переключается на вкладку Блиц букв и рендерит карточку задания', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: CursiveDecryptorScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Блиц букв'));
      await tester.pumpAndSettle();

      expect(find.text('Какая печатная буква соответствует этому описанию рукописи?'), findsOneWidget);
      expect(find.text('Выберите печатную букву:'), findsOneWidget);
    });
  });
}
