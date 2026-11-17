import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/binyan.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/dialogue_node.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/usecases/select_dialogue_option.dart';

class _MockConversationRepository extends Mock
    implements ConversationRepository {}

void main() {
  late SelectDialogueOptionUseCase useCase;
  late _MockConversationRepository mockRepository;

  const selectedOption = DialogueOption(
    id: 'opt_coffee',
    textHebrew: HebrewText.fixture(
      vocalized: 'אֲנִי רוֹצֶה קָפֶה',
      normalized: 'אני רוצה קפה',
    ),
    textRussian: 'Я хочу кофе',
    root: Shoresh.fixture(['ר', 'צ', 'ה']),
    binyan: Binyan.paal,
    nextNodeId: 'node_coffee_order',
  );

  const nextNode = DialogueNode.fixture(
    id: 'node_coffee_order',
    speaker: SpeakerName(
      hebrew: HebrewText.fixture(vocalized: 'מוֹכֵר', normalized: 'מוכר'),
    ),
    lineHebrew: HebrewText.fixture(vocalized: 'בְּשִׂמְחָה!', normalized: 'בשמחה!'),
    lineRussian: 'С радостью!',
    options: [],
  );

  setUp(() {
    mockRepository = _MockConversationRepository();
    useCase = SelectDialogueOptionUseCase(mockRepository);
  });

  group('SelectDialogueOptionUseCase', () {
    test('записывает выбор и возвращает следующий DialogueNode', () async {
      when(
        () => mockRepository.recordDialogueSelection(
          nodeId: 'node_market_start',
          optionId: 'opt_coffee',
        ),
      ).thenAnswer((_) async => const Success(null));

      when(() => mockRepository.getDialogueNode('node_coffee_order'))
          .thenAnswer((_) async => const Success(nextNode));

      final result = await useCase.execute(
        currentNodeId: 'node_market_start',
        selectedOption: selectedOption,
      );

      expect(result, equals(const Success<DialogueNode, Failure>(nextNode)));
      verifyInOrder([
        () => mockRepository.recordDialogueSelection(
              nodeId: 'node_market_start',
              optionId: 'opt_coffee',
            ),
        () => mockRepository.getDialogueNode('node_coffee_order'),
      ]);
    });

    test('возвращает ValidationFailure если currentNodeId или nextNodeId пустой', () async {
      const invalidOption = DialogueOption(
        id: 'opt_bad',
        textHebrew: HebrewText.fixture(vocalized: 'שָׁלוֹם', normalized: 'שלום'),
        textRussian: 'Привет',
        nextNodeId: '   ',
      );

      final emptyCurrentRes = await useCase.execute(
        currentNodeId: '',
        selectedOption: selectedOption,
      );
      final emptyNextRes = await useCase.execute(
        currentNodeId: 'node_1',
        selectedOption: invalidOption,
      );

      expect(emptyCurrentRes.failureOrNull(), isA<ValidationFailure>());
      expect(emptyNextRes.failureOrNull(), isA<ValidationFailure>());
      verifyNever(
        () => mockRepository.recordDialogueSelection(
          nodeId: any(named: 'nodeId'),
          optionId: any(named: 'optionId'),
        ),
      );
    });

    test('прерывает переход и возвращает Failure если запись прогресса упала', () async {
      const cacheFailure = CacheFailure('SQLite write locked');
      when(
        () => mockRepository.recordDialogueSelection(
          nodeId: 'node_market_start',
          optionId: 'opt_coffee',
        ),
      ).thenAnswer((_) async => const Error(cacheFailure));

      final result = await useCase.execute(
        currentNodeId: 'node_market_start',
        selectedOption: selectedOption,
      );

      expect(result, equals(const Error<DialogueNode, Failure>(cacheFailure)));
      verifyNever(() => mockRepository.getDialogueNode(any()));
    });
  });
}
