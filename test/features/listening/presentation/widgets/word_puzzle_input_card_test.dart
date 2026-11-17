import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/listening/domain/entities/listening_exercise.dart';
import 'package:nexus_hebrew_app/features/listening/presentation/cubit/listening_state.dart';
import 'package:nexus_hebrew_app/features/listening/presentation/widgets/word_puzzle_input_card.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';

void main() {
  final testExercise = ListeningExercise(
    id: 'listen_test_1',
    transcript: HebrewText.create('אֲנִי רוֹצֶה קָפֶה').getOrNull()!,
    russianTranslation: 'Я хочу кофе',
    audioUrl: null,
    difficulty: ListeningDifficulty.beginner,
    focusWords: const ['קָפֶה'],
    attribution: const ContentAttribution(
      sourceName: 'Nexus Test',
      licenseName: 'CC0',
    ),
  );

  testWidgets('WordPuzzleInputCard allows assembling and resetting words',
      (WidgetTester tester) async {
    String? submittedText;
    ListeningAnswerMode currentMode = ListeningAnswerMode.puzzle;
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return WordPuzzleInputCard(
                exercise: testExercise,
                showNikkud: true,
                answerMode: currentMode,
                comparison: null,
                keyboardController: controller,
                onModeChanged: (mode) {
                  setState(() => currentMode = mode);
                },
                onSubmit: (text) => submittedText = text,
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify segments
    expect(find.text('Блоки'), findsOneWidget);
    expect(find.text('Клавиатура'), findsOneWidget);

    // Initial placeholder
    expect(find.text('Нажимай на слова внизу, чтобы собрать ответ'),
        findsOneWidget);

    // Find and tap a bank word chip
    final chipFinder = find.widgetWithText(ActionChip, 'אֲנִי');
    expect(chipFinder, findsOneWidget);
    await tester.tap(chipFinder);
    await tester.pumpAndSettle();

    // Now 'אֲנִי' is in the assembled line with a close icon
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);

    // Test submit button
    final submitButton = find.widgetWithText(FilledButton, 'Проверить ответ');
    expect(submitButton, findsOneWidget);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    expect(submittedText, equals('אֲנִי'));

    // Tap 'Сбросить'
    final resetButton = find.widgetWithText(OutlinedButton, 'Сбросить');
    expect(resetButton, findsOneWidget);
    await tester.tap(resetButton);
    await tester.pumpAndSettle();

    // Assembled line is empty again
    expect(find.text('Нажимай на слова внизу, чтобы собрать ответ'),
        findsOneWidget);

    // Switch to keyboard mode
    await tester.tap(find.text('Клавиатура'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    controller.dispose();
  });
}
