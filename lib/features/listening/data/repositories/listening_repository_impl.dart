import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/result/result.dart';
import '../../../srs/data/datasources/tatoeba_remote_datasource.dart';
import '../../domain/entities/listening_exercise.dart';
import '../../domain/repositories/listening_repository.dart';
import '../datasources/listening_local_datasource.dart';
import '../datasources/listening_seed_datasource.dart';
import '../models/listening_exercise_dto.dart';

/// Offline-first [ListeningRepository] combining bundled seeds, Drift storage, and Tatoeba import.
final class ListeningRepositoryImpl implements ListeningRepository {
  static const String _tag = 'ListeningRepositoryImpl';

  ListeningRepositoryImpl({
    required ListeningLocalDataSource localDataSource,
    required ListeningSeedDataSource seedDataSource,
    required TatoebaRemoteDataSource remoteDataSource,
    required AppLogger logger,
  })  : _localDataSource = localDataSource,
        _seedDataSource = seedDataSource,
        _remoteDataSource = remoteDataSource,
        _logger = logger;

  final ListeningLocalDataSource _localDataSource;
  final ListeningSeedDataSource _seedDataSource;
  final TatoebaRemoteDataSource _remoteDataSource;
  final AppLogger _logger;

  Future<Result<void, Failure>>? _inFlightSeed;

  @override
  Future<Result<List<ListeningExercise>, Failure>> getExercises({
    ListeningDifficulty? difficulty,
  }) async {
    final seedRes = await _ensureSeeded();
    if (seedRes case Error(:final failure)) {
      return Error(failure);
    }

    return _localDataSource.getExercises(difficulty: difficulty);
  }

  @override
  Future<Result<List<ListeningExercise>, Failure>> importFromTatoeba({
    required String query,
    int limit = 8,
  }) async {
    final seedRes = await _ensureSeeded();
    if (seedRes case Error(:final failure)) {
      return Error(failure);
    }

    final remoteRes = await _remoteDataSource.searchHebrewRussianSentences(
      query: query,
      limit: limit,
    );
    if (remoteRes case Error(:final failure)) {
      return Error(failure);
    }

    final remoteDtos = remoteRes.getOrNull()!;
    final domainExercises = <ListeningExercise>[];
    for (final srsDto in remoteDtos) {
      final listeningDto = ListeningExerciseDto.fromTatoebaSrsDto(srsDto);
      final domainRes = listeningDto.toDomain();
      switch (domainRes) {
        case Success(:final data):
          domainExercises.add(data);
        case Error(:final failure):
          _logger.warning(
            _tag,
            'Skipping invalid Tatoeba listening item "${srsDto.id}": ${failure.message}',
          );
      }
    }

    if (domainExercises.isNotEmpty) {
      final saveRes =
          await _localDataSource.insertExercisesIfAbsent(domainExercises);
      if (saveRes case Error(:final failure)) {
        return Error(failure);
      }
    }

    return Success(List<ListeningExercise>.unmodifiable(domainExercises));
  }

  @override
  Future<Result<void, Failure>> recordAttempt({
    required String exerciseId,
    required double wordAccuracy,
    required bool isExactMatch,
    required DateTime attemptedAt,
  }) {
    return _localDataSource.recordAttempt(
      exerciseId: exerciseId,
      wordAccuracy: wordAccuracy,
      isExactMatch: isExactMatch,
      attemptedAt: attemptedAt,
    );
  }

  Future<Result<void, Failure>> _ensureSeeded() {
    final existing = _inFlightSeed;
    if (existing != null) {
      return existing;
    }

    final future = _performSeedIfEmpty().whenComplete(() {
      _inFlightSeed = null;
    });
    _inFlightSeed = future;
    return future;
  }

  Future<Result<void, Failure>> _performSeedIfEmpty() async {
    final countRes = await _localDataSource.countExercises();
    switch (countRes) {
      case Error(:final failure):
        return Error(failure);
      case Success(:final data):
        if (data > 0) {
          return const Success(null);
        }
    }

    final seedRes = await _seedDataSource.loadSeedExercises();
    if (seedRes case Error(:final failure)) {
      return Error(failure);
    }

    final domainList = <ListeningExercise>[];
    for (final dto in seedRes.getOrNull()!) {
      final mapped = dto.toDomain();
      switch (mapped) {
        case Success(:final data):
          domainList.add(data);
        case Error(:final failure):
          return Error(failure);
      }
    }

    final storeRes =
        await _localDataSource.insertExercisesIfAbsent(domainList);
    if (storeRes.isSuccess) {
      _logger.info(
        _tag,
        'Seeded ${domainList.length} Hebrew listening exercises',
      );
    }
    return storeRes;
  }
}
