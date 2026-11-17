import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/dialogue_node.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/usecases/get_active_dialogue.dart';

class _MockConversationRepository extends Mock
    implements ConversationRepository {}

void main() {
  late GetActiveDialogueUseCase useCase;
  late _MockConversationRepository mockRepository;

  const testNode = DialogueNode.fixture(
    id: 'node_1',
    speaker: SpeakerName(
      hebrew: HebrewText.fixture(vocalized: 'מוֹכֵר', normalized: 'מוכר'),
      russian: 'Продавец',
    ),
    lineHebrew: HebrewText.fixture(vocalized: 'שָׁלוֹם', normalized: 'שלום'),
    lineRussian: 'Привет',
    options: [],
  );

  setUp(() {
    mockRepository = _MockConversationRepository();
    useCase = GetActiveDialogueUseCase(mockRepository);
  });

  group('GetActiveDialogueUseCase', () {
    test('должен вернуть DialogueNode и обрезать пробелы у nodeId при успехе', () async {
      when(() => mockRepository.getDialogueNode('node_1'))
          .thenAnswer((_) async => const Success(testNode));

      final result = await useCase.execute('  node_1  ');

      expect(result, equals(const Success<DialogueNode, Failure>(testNode)));
      verify(() => mockRepository.getDialogueNode('node_1')).called(1);
    });

    test('должен вернуть ValidationFailure если nodeId пустой или из пробелов', () async {
      final result = await useCase.execute('   ');

      expect(result, isA<Error<DialogueNode, Failure>>());
      expect(result.failureOrNull(), isA<ValidationFailure>());
      verifyNever(() => mockRepository.getDialogueNode(any()));
    });

    test('должен пробросить Failure из репозитория при ошибке чтения', () async {
      const failure = NetworkFailure('Connection timed out');
      when(() => mockRepository.getDialogueNode('node_1'))
          .thenAnswer((_) async => const Error(failure));

      final result = await useCase.execute('node_1');

      expect(result, equals(const Error<DialogueNode, Failure>(failure)));
    });
  });
}
