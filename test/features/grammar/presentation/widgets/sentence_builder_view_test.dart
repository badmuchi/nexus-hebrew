import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/grammar/data/datasources/sentence_builder_seed_data.dart';
import 'package:nexus_hebrew_app/features/grammar/presentation/widgets/sentence_builder_view.dart';

void main() {
  Widget createTestWidget() {
    return const MaterialApp(
      home: Scaffold(
        body: SentenceBuilderView(),
      ),
    );
  }

  group('SentenceBuilderView', () {
    testWidgets('renders prompt, placeholder canvas, and word bank chips',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Все правила'), findsOneWidget);
      expect(find.text('Переведите на иврит:'), findsOneWidget);
      expect(find.text('Я вижу большого кота'), findsOneWidget);
      expect(
        find.text('Нажмите на карточки слов ниже в правильном порядке'),
        findsOneWidget,
      );
      expect(find.text('Банк слов:'), findsOneWidget);

      // Verify some bank chips
      expect(find.byKey(const Key('bank_token_et1_1')), findsOneWidget);
      expect(find.byKey(const Key('bank_token_et1_2')), findsOneWidget);
    });

    testWidgets('assembling words moves chips from bank to canvas and back',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap first word 'אֲנִי' (et1_1)
      final tokenChip = find.byKey(const Key('bank_token_et1_1'));
      expect(tokenChip, findsOneWidget);

      await tester.tap(tokenChip);
      await tester.pumpAndSettle();

      // Bank chip is now gone
      expect(find.byKey(const Key('bank_token_et1_1')), findsNothing);

      // Canvas now has the token and no placeholder
      expect(
        find.text('Нажмите на карточки слов ниже в правильном порядке'),
        findsNothing,
      );
      expect(find.text('Сброс'), findsOneWidget);

      // Tap on the word in canvas to remove it
      final assembledChip = find.text('אֲנִי');
      expect(assembledChip, findsOneWidget);

      await tester.tap(assembledChip);
      await tester.pumpAndSettle();

      // Bank chip returned
      expect(find.byKey(const Key('bank_token_et1_1')), findsOneWidget);
    });

    testWidgets('completing sentence and checking answer displays feedback',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final firstExercise = SentenceBuilderSeedData.allExercises.first;

      // Tap target tokens in correct order
      for (final token in firstExercise.tokens) {
        final chipFinder = find.byKey(Key('bank_token_${token.id}'));
        await tester.ensureVisible(chipFinder);
        await tester.tap(chipFinder);
        await tester.pumpAndSettle();
      }

      // Check answer
      final checkButton = find.byKey(const Key('check_answer_button'));
      expect(checkButton, findsOneWidget);
      await tester.ensureVisible(checkButton);
      await tester.tap(checkButton);
      await tester.pumpAndSettle();

      // Feedback card is visible
      expect(find.text('Отлично! Правильно!'), findsOneWidget);
      expect(find.text(firstExercise.ruleTitle), findsOneWidget);
      expect(find.byKey(const Key('next_exercise_button')), findsOneWidget);
    });

    testWidgets('category chip filters exercises', (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on 'Сопряжение (Смихут)'
      final smijutChip = find.text('Сопряжение (Смихут)');
      await tester.ensureVisible(smijutChip);
      await tester.tap(smijutChip);
      await tester.pumpAndSettle();

      expect(
        find.text('Директор школы говорит на иврите'),
        findsOneWidget,
      );
    });
  });
}
