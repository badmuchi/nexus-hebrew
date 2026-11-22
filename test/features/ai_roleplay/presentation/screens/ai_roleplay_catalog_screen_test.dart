import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/ai_roleplay/data/datasources/ai_roleplay_seed_data.dart';
import 'package:nexus_hebrew_app/features/ai_roleplay/domain/repositories/ai_roleplay_repository.dart';
import 'package:nexus_hebrew_app/features/ai_roleplay/presentation/screens/ai_roleplay_catalog_screen.dart';
import 'package:nexus_hebrew_app/features/ai_roleplay/presentation/screens/ai_roleplay_chat_screen.dart';

class _MockAiRoleplayRepository extends Mock implements AiRoleplayRepository {}

void main() {
  late _MockAiRoleplayRepository mockRepo;

  setUp(() {
    mockRepo = _MockAiRoleplayRepository();
    when(() => mockRepo.getScenarios())
        .thenAnswer((_) async => const Success(AiRoleplaySeedData.scenarios));
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: AiRoleplayCatalogScreen(repository: mockRepo),
    );
  }

  testWidgets('renders catalog screen with scenarios and promo header',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('AI-Собеседник • Диалоги'), findsOneWidget);
    expect(find.text('Интерактивная практика иврита'), findsOneWidget);

    // Verify scenarios are shown
    expect(find.text('Кофейня в Тель-Авиве'), findsOneWidget);
    expect(find.text('Супермаркет и касса'), findsOneWidget);
    expect(find.text('Автобус и Рав-Кав'), findsOneWidget);
  });

  testWidgets('filtering by level updates scenario list', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Tap on level B1 chip
    await tester.tap(find.text('Уровень B1'));
    await tester.pumpAndSettle();

    // Scenarios of A1 should not be visible
    expect(find.text('Кофейня в Тель-Авиве'), findsNothing);
    // B1 scenario should be visible
    expect(find.text('Аренда квартиры во Флорентине'), findsOneWidget);
  });

  testWidgets('tapping scenario opens AiRoleplayChatScreen', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    final startButtons = find.text('Начать диалог');
    expect(startButtons, findsWidgets);

    await tester.tap(startButtons.first);
    await tester.pumpAndSettle();

    expect(find.byType(AiRoleplayChatScreen), findsOneWidget);
  });
}
