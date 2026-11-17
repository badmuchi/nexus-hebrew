import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/logging/app_logger.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/dialogue_node.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/dialogue_scenario_info.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/usecases/get_active_dialogue.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/usecases/select_dialogue_option.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/usecases/toggle_dialogue_audio.dart';
import 'package:nexus_hebrew_app/features/conversation/presentation/cubit/conversation_cubit.dart';
import 'package:nexus_hebrew_app/features/conversation/presentation/screens/conversation_screen.dart';
import 'package:nexus_hebrew_app/features/conversation/presentation/widgets/dialogue_history_sheet.dart';
import 'package:nexus_hebrew_app/features/conversation/presentation/widgets/scenario_catalog_sheet.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/add_card_to_srs.dart';

class _MockGetActiveDialogueUseCase extends Mock
    implements GetActiveDialogueUseCase {}

class _MockSelectDialogueOptionUseCase extends Mock
    implements SelectDialogueOptionUseCase {}

class _MockToggleDialogueAudioUseCase extends Mock
    implements ToggleDialogueAudioUseCase {}

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}

class _MockAddCardToSrsUseCase extends Mock implements AddCardToSrsUseCase {}

void main() {
  late _MockGetActiveDialogueUseCase getDialogueUseCase;
  late _MockSelectDialogueOptionUseCase selectOptionUseCase;
  late _MockToggleDialogueAudioUseCase toggleAudioUseCase;
  late _MockAddCardToSrsUseCase addCardToSrsUseCase;
  late _MockAudioPlaybackService audioService;
  late StreamController<AudioPlaybackEvent> audioEvents;

  const testNode = DialogueNode.fixture(
    id: 'node_market_start',
    speaker: SpeakerName(
      hebrew: HebrewText.fixture(vocalized: 'מוֹכֵר', normalized: 'מוכר'),
      russian: 'Продавец',
    ),
    lineHebrew: HebrewText.fixture(
      vocalized: 'שָׁלוֹם! מָה תִּרְצֶה?',
      normalized: 'שלום! מה תרצה?',
    ),
    lineRussian: 'Привет! Что ты хочешь?',
    options: [
      DialogueOption(
        id: 'opt_coffee',
        textHebrew: HebrewText.fixture(vocalized: 'קָפֶה', normalized: 'קפה'),
        textRussian: 'Кофе',
        nextNodeId: 'node_coffee',
      ),
    ],
  );

  setUp(() {
    getDialogueUseCase = _MockGetActiveDialogueUseCase();
    selectOptionUseCase = _MockSelectDialogueOptionUseCase();
    toggleAudioUseCase = _MockToggleDialogueAudioUseCase();
    addCardToSrsUseCase = _MockAddCardToSrsUseCase();
    audioService = _MockAudioPlaybackService();
    audioEvents = StreamController<AudioPlaybackEvent>.broadcast();

    when(() => audioService.statusStream).thenAnswer((_) => audioEvents.stream);
    when(() => audioService.currentSpeed).thenReturn(1.0);
    when(() => audioService.setPlaybackSpeed(any()))
        .thenAnswer((_) async => const Success(null));
    when(() => audioService.currentState)
        .thenReturn(const AudioPlaybackEvent.idle());
    when(() => audioService.stop())
        .thenAnswer((_) async => const Success(null));

    when(() => getDialogueUseCase.execute(any()))
        .thenAnswer((_) async => const Success(testNode));
  });

  tearDown(() async {
    await audioEvents.close();
  });

  Widget createTestWidget(ConversationCubit cubit) {
    return MaterialApp(
      home: BlocProvider<ConversationCubit>.value(
        value: cubit,
        child: ConversationScreen(
          audioService: audioService,
          addCardToSrsUseCase: addCardToSrsUseCase,
        ),
      ),
    );
  }

  group('DialogueScenarioInfo', () {
    test('contains 8 rich situational dialogue scenarios', () {
      expect(DialogueScenarioInfo.allScenarios.length, 8);

      final ids = DialogueScenarioInfo.allScenarios.map((s) => s.id).toSet();
      expect(ids.length, 8);

      final titles =
          DialogueScenarioInfo.allScenarios.map((s) => s.titleRussian).toList();
      expect(titles, contains('Рынок Шук Кармель'));
      expect(titles, contains('В аптеке'));
      expect(titles, contains('Заселение в отель'));
      expect(titles, contains('Знакомство в ульпане'));
      expect(titles, contains('Касса в супермаркете'));
      expect(titles, contains('В поликлинике (Купат Холим)'));
    });
  });

  group('ScenarioCatalogSheet', () {
    testWidgets('renders all scenarios and handles category filter',
        (tester) async {
      String? selectedId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScenarioCatalogSheet(
              activeScenarioId: 'node_market_start',
              onSelectScenario: (id) => selectedId = id,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ситуационные сценарии'), findsOneWidget);
      expect(find.text('Рынок Шук Кармель'), findsOneWidget);
      expect(find.text('В аптеке'), findsOneWidget);

      // Filter by category "Здоровье"
      await tester.tap(find.text('Здоровье'));
      await tester.pumpAndSettle();

      expect(find.text('В аптеке'), findsOneWidget);
      expect(find.text('В поликлинике (Купат Холим)'), findsOneWidget);

      // Tap on pharmacy
      await tester.tap(find.text('В аптеке'));
      await tester.pumpAndSettle();

      expect(selectedId, 'node_pharmacy_start');
    });
  });

  group('DialogueHistorySheet', () {
    testWidgets('displays timeline of turns and speaker names', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DialogueHistorySheet(
              historyNodes: [],
              activeNode: testNode,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('История реплик'), findsOneWidget);
      expect(find.text('Продавец'), findsOneWidget);
      expect(find.text('שָׁלוֹם! מָה תִּרְצֶה?'), findsOneWidget);
      expect(find.text('Привет! Что ты хочешь?'), findsOneWidget);
    });
  });

  group('ConversationScreen', () {
    testWidgets('renders scenario bar with all 8 chips and catalog button',
        (tester) async {
      final cubit = ConversationCubit(
        getDialogueUseCase: getDialogueUseCase,
        selectOptionUseCase: selectOptionUseCase,
        toggleAudioUseCase: toggleAudioUseCase,
        addCardToSrsUseCase: addCardToSrsUseCase,
        audioService: audioService,
        logger: const DeveloperAppLogger(),
      );

      await cubit.loadDialogueNode('node_market_start');

      await tester.pumpWidget(createTestWidget(cubit));
      await tester.pumpAndSettle();

      // Verify scenario title
      expect(find.textContaining('Рынок Шук Кармель'), findsWidgets);

      // Verify scenario catalog button in AppBar
      final catalogButton = find.byIcon(Icons.explore_outlined);
      expect(catalogButton, findsOneWidget);

      await tester.tap(catalogButton);
      await tester.pumpAndSettle();

      // Verify ScenarioCatalogSheet opened
      expect(find.byType(ScenarioCatalogSheet), findsOneWidget);

      // Select "Завтрак в кафе"
      await tester.tap(find.text('Завтрак в кафе'));
      await tester.pumpAndSettle();

      verify(() => getDialogueUseCase.execute('node_cafe_start')).called(1);
    });
  });
}
