import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/utils/hebrew_normalizer.dart';
import '../entities/dialogue_node.dart';
import '../repositories/conversation_repository.dart';

class SearchDialoguesUseCase {
  final ConversationRepository _repository;

  const SearchDialoguesUseCase(this._repository);

  Future<Result<List<DialogueNode>, Failure>> execute(String rawQuery) async {
    final normalizedQuery = HebrewNormalizer.normalizeForComparison(rawQuery);
    if (normalizedQuery.isEmpty) {
      return const Error(
        ValidationFailure('Search query cannot be empty'),
      );
    }
    return _repository.searchDialoguesByHebrew(normalizedQuery);
  }
}
