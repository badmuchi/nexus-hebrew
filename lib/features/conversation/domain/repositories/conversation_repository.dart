import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../entities/dialogue_node.dart';

abstract interface class ConversationRepository {
  Future<Result<DialogueNode, Failure>> getDialogueNode(String nodeId);
  Future<Result<List<DialogueNode>, Failure>> searchDialoguesByHebrew(
    String normalizedQuery,
  );
  Future<Result<void, Failure>> recordDialogueSelection({
    required String nodeId,
    required String optionId,
  });
  Future<Result<int, Failure>> syncDialogueHistory();
}
