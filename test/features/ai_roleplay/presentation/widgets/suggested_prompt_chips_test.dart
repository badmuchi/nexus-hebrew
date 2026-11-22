import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/ai_roleplay/domain/entities/ai_roleplay_scenario.dart';
import 'package:nexus_hebrew_app/features/ai_roleplay/presentation/widgets/suggested_prompt_chips.dart';

void main() {
  group('SuggestedPromptChips Widget Tests', () {
    const samplePrompts = [
      SuggestedPromptItem(hebrew: 'שלום', russian: 'Привет'),
      SuggestedPromptItem(hebrew: 'כמה זה עולה?', russian: 'Сколько это стоит?'),
    ];

    testWidgets('renders all prompt chips with Hebrew text and Russian description',
        (tester) async {
      String? selectedPrompt;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuggestedPromptChips(
              prompts: samplePrompts,
              onPromptSelected: (p) => selectedPrompt = p,
            ),
          ),
        ),
      );

      expect(find.text('שלום'), findsOneWidget);
      expect(find.text('• Привет'), findsOneWidget);
      expect(find.text('כמה זה עולה?'), findsOneWidget);
      expect(find.text('• Сколько это стоит?'), findsOneWidget);

      await tester.tap(find.byType(ActionChip).first);
      await tester.pump();

      expect(selectedPrompt, 'שלום');
    });

    testWidgets('renders empty widget when prompts list is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuggestedPromptChips(
              prompts: const [],
              onPromptSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(ActionChip), findsNothing);
    });
  });
}
