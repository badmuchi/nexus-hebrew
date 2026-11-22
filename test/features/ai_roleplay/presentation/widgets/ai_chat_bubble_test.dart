import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/ai_roleplay/data/datasources/ai_roleplay_seed_data.dart';
import 'package:nexus_hebrew_app/features/ai_roleplay/domain/entities/ai_chat_message.dart';
import 'package:nexus_hebrew_app/features/ai_roleplay/presentation/widgets/ai_chat_bubble.dart';

void main() {
  final cafeScenario =
      AiRoleplaySeedData.scenarios.firstWhere((s) => s.id == 'scene_cafe');
  final character = cafeScenario.character;

  group('AiChatBubble Widget Tests', () {
    testWidgets('renders AI message with Hebrew text, translation, transliteration',
        (tester) async {
      final message = AiChatMessage.ai(
        hebrewText: 'שָׁלוֹם, מָה בִּשְׁבִילְךָ?',
        russianTranslation: 'Привет, что для вас?',
        transliteration: 'Shalom, ma bishvilkha?',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AiChatBubble(
              message: message,
              character: character,
            ),
          ),
        ),
      );

      expect(find.text('שָׁלוֹם, מָה בִּשְׁבִילְךָ?'), findsOneWidget);
      expect(find.text('Привет, что для вас?'), findsOneWidget);
      expect(find.text('Shalom, ma bishvilkha?'), findsOneWidget);
      expect(find.text(character.avatarEmoji), findsOneWidget);
    });

    testWidgets('renders user message and grammar correction card if present',
        (tester) async {
      final userMessage = AiChatMessage.user(
        'קפה קרה בבקשה',
        grammarCorrection: 'Совет: Слово קָפֶה (кофе) в иврите мужского рода, поэтому правильно: קָפֶה קַר (а не קרה).',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AiChatBubble(
              message: userMessage,
              character: character,
            ),
          ),
        ),
      );

      expect(find.text('קפה קרה בבקשה'), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb_rounded), findsOneWidget);
      expect(
        find.text(
          'Совет: Слово קָפֶה (кофе) в иврите мужского рода, поэтому правильно: קָפֶה קַר (а не קרה).',
        ),
        findsOneWidget,
      );
    });

    testWidgets('toggling translation hide/show works', (tester) async {
      final message = AiChatMessage.ai(
        hebrewText: 'שָׁלוֹם',
        russianTranslation: 'Привет',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AiChatBubble(
              message: message,
              character: character,
            ),
          ),
        ),
      );

      expect(find.text('Привет'), findsOneWidget);

      // Tap translation toggle button
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      // Translation should now be hidden
      expect(find.text('Привет'), findsNothing);

      // Tap again to show
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      expect(find.text('Привет'), findsOneWidget);
    });
  });
}
