import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../entities/fsrs_models.dart';
import '../entities/srs_card.dart';

abstract interface class SrsRepository {
  Future<Result<List<SrsCard>, Failure>> getDueCards({
    required DateTime asOf,
    int limit = 20,
  });

  Future<Result<int, Failure>> getTotalCardsCount();

  Future<Result<void, Failure>> saveReview({
    required SrsCard updatedCard,
    required FsrsRating rating,
    required int scheduledDays,
    required double stabilityBefore,
    required bool wasTypedCheck,
    required bool wasTypedExact,
    required DateTime reviewedAt,
  });

  Future<Result<List<SrsCard>, Failure>> importOpenTatoebaCards({
    required String query,
    int limit = 10,
  });

  /// Persists a user-curated flashcard if not already present in the FSRS deck.
  /// Returns `true` if newly inserted or `false` if already present.
  Future<Result<bool, Failure>> addCustomCard(SrsCard card);
}
