import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/core/widgets/hebrew_niqqud_keyboard.dart';
import 'package:nexus_hebrew_app/features/ai_roleplay/data/datasources/ai_roleplay_seed_data.dart';
import 'package:nexus_hebrew_app/features/ai_roleplay/domain/entities/ai_chat_message.dart';
import 'package:nexus_hebrew_app/features/ai_roleplay/domain/repositories/ai_roleplay_repository.dart';
import 'package:nexus_hebrew_app/features/ai_roleplay/presentation/screens/ai_roleplay_chat_screen.dart';

class _MockAiRoleplayRepository extends Mock implements AiRoleplayRepository {}

void main() {
  late _MockAiRoleplayRepository mockRepo;
  final cafeScenario =
      AiRoleplaySeedData.scenarios.firstWhere((s) => s.id == 'scene_cafe');

  setUpAll(() {
    registerFallbackValue(cafeScenario);
    registerFallbackValue(<AiChatMessage>[]);
  });

  setUp(() {
    mockRepo = _MockAiRoleplayRepository();
    when(() => mockRepo.getScenarios())
        .thenAnswer((_) async => const Success(AiRoleplaySeedData.scenarios));
    when(() => mockRepo.sendMessage(
          scenario: any(named: 'scenario'),
          conversationHistory: any(named: 'conversationHistory'),
          userHebrewInput: any(named: 'userHebrewInput'),
        )).thenAnswer((_) async => Success(
          AiChatMessage.ai(
            hebrewText: 'בְּבַקָּשָׁה, הִנֵּה הַקָּפֶה שֶׁלְּךָ!',
            russianTranslation: 'Пожалуйста, вот ваш кофе!',
            transliteration: 'Bevakasha, hine hakafe shelkha!',
          ),
        ));
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: AiRoleplayChatScreen(
        scenario: cafeScenario,
        repository: mockRepo,
      ),
    );
  }

  testWidgets('renders character name, greeting message and suggested prompts',
      (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Verify AppBar shows character and scenario title
    expect(find.text(cafeScenario.character.nameRussian), findsOneWidget);
    expect(find.text('(${cafeScenario.character.nameHebrew})'), findsOneWidget);

    // Verify initial greeting is displayed
    expect(
      find.text(cafeScenario.character.initialGreetingHebrew),
      findsOneWidget,
    );

    // Verify suggested prompts are displayed
    expect(find.text(cafeScenario.suggestedPrompts.first.hebrew), findsOneWidget);
  });

  testWidgets('tapping suggested prompt sends message and receives AI response',
      (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Tap on the first suggested prompt chip
    await tester.tap(find.byType(ActionChip).first);
    await tester.pumpAndSettle();

    // User message should appear in chat
    expect(find.text(cafeScenario.suggestedPrompts.first.hebrew), findsWidgets);

    // AI reply should appear
    expect(find.text('בְּבַקָּשָׁה, הִנֵּה הַקָּפֶה שֶׁלְּךָ!'), findsOneWidget);
  });

  testWidgets('toggling virtual keyboard displays HebrewNiqqudKeyboard',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.byType(HebrewNiqqudKeyboard), findsNothing);

    // Tap keyboard toggle button
    await tester.tap(find.byIcon(Icons.keyboard_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(HebrewNiqqudKeyboard), findsOneWidget);

    // Tap keyboard hide button
    await tester.tap(find.byIcon(Icons.keyboard_hide_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(HebrewNiqqudKeyboard), findsNothing);
  });

  testWidgets('typing custom text and pressing send button sends message',
      (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'בוקר טוב!');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    expect(find.text('בוקר טוב!'), findsOneWidget);
    expect(find.text('בְּבַקָּשָׁה, הִנֵּה הַקָּפֶה שֶׁלְּךָ!'), findsOneWidget);
  });

  testWidgets('opening scenario info displays modal bottom sheet',
      (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.info_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.text(cafeScenario.descriptionRussian), findsOneWidget);
  });
}
