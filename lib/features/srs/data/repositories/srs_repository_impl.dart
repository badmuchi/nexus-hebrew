import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/fsrs_models.dart';
import '../../domain/entities/srs_card.dart';
import '../../domain/repositories/srs_repository.dart';
import '../datasources/srs_local_datasource.dart';
import '../datasources/srs_seed_datasource.dart';
import '../datasources/tatoeba_remote_datasource.dart';

final class SrsRepositoryImpl implements SrsRepository {
  static const String _tag = 'SrsRepositoryImpl';

  final SrsLocalDataSource _localDataSource;
  final SrsSeedDataSource _seedDataSource;
  final TatoebaRemoteDataSource _tatoebaRemoteDataSource;
  final AppLogger _logger;

  bool _seedChecked = false;

  SrsRepositoryImpl({
    required SrsLocalDataSource localDataSource,
    required SrsSeedDataSource seedDataSource,
    required TatoebaRemoteDataSource tatoebaRemoteDataSource,
    required AppLogger logger,
  })  : _localDataSource = localDataSource,
        _seedDataSource = seedDataSource,
        _tatoebaRemoteDataSource = tatoebaRemoteDataSource,
        _logger = logger;

  @override
  Future<Result<List<SrsCard>, Failure>> getDueCards({
    required DateTime asOf,
    int limit = 20,
  }) async {
    final seedRes = await _ensureSeeded(now: asOf);
    if (seedRes case Error(:final failure)) {
      _logger.warning(
        _tag,
        'SRS seed check failed before reading due cards',
        failure: failure,
      );
    }

    return _localDataSource.getDueCards(asOf: asOf, limit: limit);
  }

  @override
  Future<Result<int, Failure>> getTotalCardsCount() async {
    await _ensureSeeded(now: DateTime.now().toUtc());
    return _localDataSource.countCards();
  }

  @override
  Future<Result<void, Failure>> saveReview({
    required SrsCard updatedCard,
    required FsrsRating rating,
    required int scheduledDays,
    required double stabilityBefore,
    required bool wasTypedCheck,
    required bool wasTypedExact,
    required DateTime reviewedAt,
  }) {
    return _localDataSource.saveReviewTransaction(
      updatedCard: updatedCard,
      rating: rating,
      scheduledDays: scheduledDays,
      stabilityBefore: stabilityBefore,
      wasTypedCheck: wasTypedCheck,
      wasTypedExact: wasTypedExact,
      reviewedAt: reviewedAt,
    );
  }

  @override
  Future<Result<List<SrsCard>, Failure>> importOpenTatoebaCards({
    required String query,
    int limit = 10,
  }) async {
    final remoteRes = await _tatoebaRemoteDataSource
        .searchHebrewRussianSentences(query: query, limit: limit);
    switch (remoteRes) {
      case Error(:final failure):
        return Error(failure);
      case Success(:final data):
        final now = DateTime.now().toUtc();
        final insertRes = await _localDataSource.insertSeedCardsIfAbsent(
          data,
          initialDueAt: now,
        );
        if (insertRes case Error(:final failure)) {
          return Error(failure);
        }

        final initialMemory = FsrsMemoryState.initial(now: now);
        final cards = <SrsCard>[];
        for (final dto in data) {
          final domainRes = dto.toDomain(memory: initialMemory);
          switch (domainRes) {
            case Success(:final data):
              cards.add(data);
            case Error(:final failure):
              return Error(failure);
          }
        }
        return Success(List<SrsCard>.unmodifiable(cards));
    }
  }

  @override
  Future<Result<bool, Failure>> addCustomCard(SrsCard card) async {
    await _ensureSeeded(now: card.memory.dueAt);
    return _localDataSource.insertCustomCardIfAbsent(card);
  }

  Future<Result<void, Failure>> _ensureSeeded({required DateTime now}) async {
    if (_seedChecked) {
      return const Success(null);
    }

    final countRes = await _localDataSource.countCards();
    switch (countRes) {
      case Error(:final failure):
        return Error(failure);
      case Success(:final data):
        if (data > 0) {
          _seedChecked = true;
          return const Success(null);
        }
    }

    final seedRes = await _seedDataSource.loadSeedCards();
    switch (seedRes) {
      case Error(:final failure):
        return Error(failure);
      case Success(:final data):
        final insertRes = await _localDataSource.insertSeedCardsIfAbsent(
          data,
          initialDueAt: now,
        );
        if (insertRes.isSuccess) {
          _seedChecked = true;
        }
        return insertRes;
    }
  }
}
