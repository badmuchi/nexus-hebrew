import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/cursive/data/datasources/handwritten_notes_seed_data.dart';
import 'package:nexus_hebrew_app/features/cursive/presentation/widgets/handwritten_note_card.dart';

void main() {
  group('HandwrittenNoteCard', () {
    testWidgets('рендерит записку, переключает рентген-режимы и начисляет XP за верный ответ квиза', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      int earnedXp = 0;
      final testNote = HandwrittenNotesSeedData.notes.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HandwrittenNoteCard(
                note: testNote,
                onXpEarned: (xp) => earnedXp += xp,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Подъезд и Ваад Байт'), findsOneWidget);
      expect(find.text('Объявление в подъезде от домкома'), findsOneWidget);
      expect(find.text('✍️ Ктав Яд'), findsOneWidget);
      expect(find.text('🖨️ Печатный'), findsOneWidget);
      expect(find.text('🔤 Транскрипция'), findsOneWidget);
      expect(find.text('🇷🇺 Перевод'), findsOneWidget);

      // Переключаем на русский перевод
      await tester.tap(find.text('🇷🇺 Перевод'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Уважаемые жильцы, во вторник будет отключена вода'), findsOneWidget);

      // Проверяем наличие вопроса квиза
      expect(find.text('В какой промежуток времени в доме не будет воды?'), findsOneWidget);

      // Кликаем правильный вариант
      final correctOption = find.text('С 10:00 до 14:00 во вторник');
      expect(correctOption, findsOneWidget);
      await tester.tap(correctOption);
      await tester.pumpAndSettle();

      expect(earnedXp, equals(20));
      expect(find.textContaining('во вторник'), findsWidgets);
    });
  });
}
