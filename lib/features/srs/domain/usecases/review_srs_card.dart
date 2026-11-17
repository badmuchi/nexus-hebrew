import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../entities/fsrs_models.dart';
import '../entities/srs_card.dart';
import '../repositories/srs_repository.dart';
import '../services/fsrs_scheduler.dart';

class ReviewSrsCardUseCase {
  final SrsRepository _repository;
  final FsrsScheduler _scheduler;

  const ReviewSrsCardUseCase({
    required SrsRepository repository,
    FsrsScheduler scheduler = const FsrsScheduler(),
  })  : _repository = repository,
        _scheduler = scheduler;

  Future<Result<SrsCard, Failure>> execute({
    required SrsCard card,
    required FsrsRating rating,
    required DateTime reviewedAt,
    bool wasTypedCheck = false,
    bool wasTypedExact = false,
  }) async {
    if (card.id.trim().isEmpty) {
      return const Error(ValidationFailure('SRS card ID cannot be empty'));
    }

    final stabilityBefore = card.memory.stability;
    final outcome = _scheduler.schedule(
      current: card.memory,
      rating: rating,
      now: reviewedAt,
    );
    final updatedCard = card.copyWith(memory: outcome.updatedMemory);

    final saveRes = await _repository.saveReview(
      updatedCard: updatedCard,
      rating: rating,
      scheduledDays: outcome.scheduledDays,
      stabilityBefore: stabilityBefore,
      wasTypedCheck: wasTypedCheck,
      wasTypedExact: wasTypedExact,
      reviewedAt: reviewedAt.toUtc(),
    );

    return saveRes.map((_) => updatedCard);
  }
}
