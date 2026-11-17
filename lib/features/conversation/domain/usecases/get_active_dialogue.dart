import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../entities/dialogue_node.dart';
import '../repositories/conversation_repository.dart';

class GetActiveDialogueUseCase {
  final ConversationRepository _repository;

  const GetActiveDialogueUseCase(this._repository);

  Future<Result<DialogueNode, Failure>> execute(String nodeId) async {
    final trimmed = nodeId.trim();
    if (trimmed.isEmpty) {
      return const Error(ValidationFailure('Node ID cannot be empty'));
    }
    return _repository.getDialogueNode(trimmed);
  }
}
