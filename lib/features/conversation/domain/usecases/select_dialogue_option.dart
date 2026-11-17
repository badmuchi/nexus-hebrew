import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../entities/dialogue_node.dart';
import '../repositories/conversation_repository.dart';

class SelectDialogueOptionUseCase {
  final ConversationRepository _repository;

  const SelectDialogueOptionUseCase(this._repository);

  Future<Result<DialogueNode, Failure>> execute({
    required String currentNodeId,
    required DialogueOption selectedOption,
  }) async {
    final trimmedNodeId = currentNodeId.trim();
    final trimmedNextId = selectedOption.nextNodeId.trim();
    if (trimmedNodeId.isEmpty) {
      return const Error(
        ValidationFailure('Current node ID cannot be empty'),
      );
    }
    if (trimmedNextId.isEmpty) {
      return const Error(
        ValidationFailure('Selected option nextNodeId cannot be empty'),
      );
    }

    final recordResult = await _repository.recordDialogueSelection(
      nodeId: trimmedNodeId,
      optionId: selectedOption.id,
    );

    return recordResult.flatMapAsync(
      (_) => _repository.getDialogueNode(trimmedNextId),
    );
  }
}
