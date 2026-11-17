import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/utils/hebrew_normalizer.dart';
import '../entities/srs_card.dart';
import '../repositories/srs_repository.dart';

class ImportOpenTatoebaCardsUseCase {
  final SrsRepository _repository;

  const ImportOpenTatoebaCardsUseCase(this._repository);

  Future<Result<List<SrsCard>, Failure>> execute({
    required String rawQuery,
    int limit = 10,
  }) async {
    final cleanedQuery = HebrewNormalizer.normalizeForComparison(rawQuery);
    if (cleanedQuery.isEmpty) {
      return const Error(
        ValidationFailure('Поисковый запрос для Tatoeba не может быть пустым'),
      );
    }
    if (limit <= 0 || limit > 50) {
      return const Error(
        ValidationFailure('Количество импортируемых карточек должно быть от 1 до 50'),
      );
    }

    return _repository.importOpenTatoebaCards(
      query: cleanedQuery,
      limit: limit,
    );
  }
}
