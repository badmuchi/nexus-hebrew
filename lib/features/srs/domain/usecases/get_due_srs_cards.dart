import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../entities/srs_card.dart';
import '../repositories/srs_repository.dart';

class GetDueSrsCardsUseCase {
  final SrsRepository _repository;

  const GetDueSrsCardsUseCase(this._repository);

  Future<Result<List<SrsCard>, Failure>> execute({
    required DateTime asOf,
    int limit = 20,
  }) async {
    if (limit <= 0) {
      return const Error(
        ValidationFailure('Card fetch limit must be greater than zero'),
      );
    }
    return _repository.getDueCards(asOf: asOf.toUtc(), limit: limit);
  }
}
