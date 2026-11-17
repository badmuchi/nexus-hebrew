import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/dialogue_node.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/usecases/search_dialogues.dart';

class _MockConversationRepository extends Mock
    implements ConversationRepository {}

void main() {
  late SearchDialoguesUseCase useCase;
  late _MockConversationRepository mockRepository;

  const foundNode = DialogueNode.fixture(
    id: 'node_market_start',
    speaker: SpeakerName(
      hebrew: HebrewText.fixture(vocalized: 'מוֹכֵר', normalized: 'מוכר'),
    ),
    lineHebrew: HebrewText.fixture(vocalized: 'שָׁלוֹם!', normalized: 'שלום!'),
    lineRussian: 'Привет!',
    options: [],
  );

  setUp(() {
    mockRepository = _MockConversationRepository();
    useCase = SearchDialoguesUseCase(mockRepository);
  });

  group('SearchDialoguesUseCase', () {
    test('удаляет огласовки из запроса перед поиском в репозитории', () async {
      when(() => mockRepository.searchDialoguesByHebrew('שלום'))
          .thenAnswer((_) async => const Success([foundNode]));

      final result = await useCase.execute('  שָׁלוֹם  ');

      expect(
        result,
        equals(const Success<List<DialogueNode>, Failure>([foundNode])),
      );
      verify(() => mockRepository.searchDialoguesByHebrew('שלום')).called(1);
    });

    test('возвращает ValidationFailure для пустого запроса или одних огласовок', () async {
      final blankRes = await useCase.execute('   ');
      final nikkudOnlyRes = await useCase.execute('\u05B8\u05BC');

      expect(blankRes.failureOrNull(), isA<ValidationFailure>());
      expect(nikkudOnlyRes.failureOrNull(), isA<ValidationFailure>());
      verifyNever(() => mockRepository.searchDialoguesByHebrew(any()));
    });

    test('пробрасывает CacheFailure от репозитория', () async {
      const cacheFailure = CacheFailure('Database unavailable');
      when(() => mockRepository.searchDialoguesByHebrew('קפה'))
          .thenAnswer((_) async => const Error(cacheFailure));

      final result = await useCase.execute('קָפֶה');

      expect(
        result,
        equals(const Error<List<DialogueNode>, Failure>(cacheFailure)),
      );
    });
  });
}
