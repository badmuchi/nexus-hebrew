import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/ai_roleplay/data/datasources/ai_roleplay_seed_data.dart';
import 'package:nexus_hebrew_app/features/ai_roleplay/domain/entities/ai_chat_message.dart';
import 'package:nexus_hebrew_app/features/ai_roleplay/domain/repositories/ai_roleplay_repository.dart';
import 'package:nexus_hebrew_app/features/ai_roleplay/presentation/cubit/ai_roleplay_cubit.dart';
import 'package:nexus_hebrew_app/features/ai_roleplay/presentation/cubit/ai_roleplay_state.dart';

class _MockAiRoleplayRepository extends Mock implements AiRoleplayRepository {}

void main() {
  late _MockAiRoleplayRepository mockRepo;
  final cafeScenario =
      AiRoleplaySeedData.scenarios.firstWhere((s) => s.id == 'scene_cafe');

  setUpAll(() {
    registerFallbackValue(cafeScenario);
  });

  setUp(() {
    mockRepo = _MockAiRoleplayRepository();
  });

  group('AiRoleplayCubit', () {
    blocTest<AiRoleplayCubit, AiRoleplayState>(
      'loadScenarios emits AiRoleplayCatalogLoaded when repo succeeds',
      build: () {
        when(() => mockRepo.getScenarios())
            .thenAnswer((_) async => const Success(AiRoleplaySeedData.scenarios));
        return AiRoleplayCubit(repository: mockRepo);
      },
      act: (cubit) => cubit.loadScenarios(),
      expect: () => [
        const AiRoleplayCatalogLoaded(AiRoleplaySeedData.scenarios),
      ],
    );

    test('startScenario sets AiRoleplayChatActive with initial greeting', () {
      final cubit = AiRoleplayCubit(repository: mockRepo);
      cubit.startScenario(cafeScenario);

      expect(cubit.state, isA<AiRoleplayChatActive>());
      final active = cubit.state as AiRoleplayChatActive;
      expect(active.scenario, equals(cafeScenario));
      expect(active.messages.length, equals(1));
      expect(active.messages.first.isUser, isFalse);
      expect(active.messages.first.hebrewText, equals(cafeScenario.character.initialGreetingHebrew));
    });

    blocTest<AiRoleplayCubit, AiRoleplayState>(
      'sendUserMessage appends user message, calls repository and appends reply',
      build: () {
        when(
          () => mockRepo.sendMessage(
            scenario: any(named: 'scenario'),
            conversationHistory: any(named: 'conversationHistory'),
            userHebrewInput: any(named: 'userHebrewInput'),
          ),
        ).thenAnswer(
          (_) async => Success(
            AiChatMessage(
              id: 'ai_reply_1',
              isUser: false,
              hebrewText: 'מְצֻיָּן! אֶחָד הָפוּךְ.',
              russianTranslation: 'Отлично! Один капучино.',
              timestamp: DateTime.now(),
            ),
          ),
        );
        return AiRoleplayCubit(repository: mockRepo);
      },
      seed: () => AiRoleplayChatActive(
        scenario: cafeScenario,
        messages: [
          AiChatMessage(
            id: 'init_1',
            isUser: false,
            hebrewText: 'שָׁלוֹם!',
            timestamp: DateTime.now(),
          ),
        ],
      ),
      act: (cubit) => cubit.sendUserMessage('אֶפְשָׁר קָפֶה הָפוּךְ?'),
      verify: (_) {
        verify(
          () => mockRepo.sendMessage(
            scenario: cafeScenario,
            conversationHistory: any(named: 'conversationHistory'),
            userHebrewInput: 'אֶפְשָׁר קָפֶה הָפוּךְ?',
          ),
        ).called(1);
      },
    );
  });
}
