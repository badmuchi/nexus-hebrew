import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/result/result.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../../domain/entities/verb_conjugation.dart';
import '../../domain/repositories/grammar_repository.dart';
import '../datasources/grammar_local_datasource.dart';
import '../datasources/grammar_seed_datasource.dart';

/// Offline-first [GrammarRepository] coordinating Drift local storage and JSON seeds.
final class GrammarRepositoryImpl implements GrammarRepository {
  static const String _tag = 'GrammarRepositoryImpl';

  GrammarRepositoryImpl({
    required GrammarLocalDataSource localDataSource,
    required GrammarSeedDataSource seedDataSource,
    required AppLogger logger,
  })  : _localDataSource = localDataSource,
        _seedDataSource = seedDataSource,
        _logger = logger;

  final GrammarLocalDataSource _localDataSource;
  final GrammarSeedDataSource _seedDataSource;
  final AppLogger _logger;

  Future<Result<void, Failure>>? _inFlightSeed;

  @override
  Future<Result<List<VerbLexeme>, Failure>> getVerbs({
    Binyan? binyan,
    String query = '',
  }) async {
    final seedRes = await _ensureSeeded();
    if (seedRes case Error(:final failure)) {
      return Error(failure);
    }

    return _localDataSource.getVerbs(binyan: binyan, query: query);
  }

  @override
  Future<Result<void, Failure>> recordPracticeAttempt({
    required String verbId,
    required VerbTense tense,
    required GrammaticalPerson person,
    required bool isCorrect,
    required DateTime practicedAt,
  }) {
    return _localDataSource.recordPracticeAttempt(
      verbId: verbId,
      tense: tense,
      person: person,
      isCorrect: isCorrect,
      practicedAt: practicedAt,
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
    final countRes = await _localDataSource.countVerbs();
    switch (countRes) {
      case Error(:final failure):
        return Error(failure);
      case Success(:final data):
        if (data > 0) {
          return const Success(null);
        }
    }

    final seedRes = await _seedDataSource.loadSeedVerbs();
    if (seedRes case Error(:final failure)) {
      return Error(failure);
    }

    final dtos = seedRes.getOrNull()!;
    final domainVerbs = <VerbLexeme>[];
    for (final dto in dtos) {
      final mapped = dto.toDomain();
      switch (mapped) {
        case Success(:final data):
          domainVerbs.add(data);
        case Error(:final failure):
          return Error(failure);
      }
    }

    final storeRes = await _localDataSource.upsertVerbs(domainVerbs);
    if (storeRes.isSuccess) {
      _logger.info(
        _tag,
        'Seeded ${domainVerbs.length} Hebrew grammar verbs into local database',
      );
    }
    return storeRes;
  }
}
