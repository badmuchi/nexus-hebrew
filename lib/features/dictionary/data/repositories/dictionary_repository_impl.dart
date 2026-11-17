import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/dictionary_entry.dart';
import '../../domain/repositories/dictionary_repository.dart';
import '../datasources/dictionary_local_datasource.dart';
import '../datasources/dictionary_remote_datasource.dart';
import '../datasources/dictionary_seed_datasource.dart';

typedef DictionaryRepoClockUtc = DateTime Function();

final class DictionaryRepositoryImpl implements DictionaryRepository {
  static const String _tag = 'DictionaryRepositoryImpl';

  DictionaryRepositoryImpl({
    required DictionaryLocalDataSource localDataSource,
    required DictionarySeedDataSource seedDataSource,
    required DictionaryRemoteDataSource remoteDataSource,
    required AppLogger logger,
    DictionaryRepoClockUtc? clock,
  })  : _localDataSource = localDataSource,
        _seedDataSource = seedDataSource,
        _remoteDataSource = remoteDataSource,
        _logger = logger,
        _clock = clock ?? (() => DateTime.now().toUtc());

  final DictionaryLocalDataSource _localDataSource;
  final DictionarySeedDataSource _seedDataSource;
  final DictionaryRemoteDataSource _remoteDataSource;
  final AppLogger _logger;
  final DictionaryRepoClockUtc _clock;

  bool _seedSyncedThisSession = false;

  Future<Result<void, Failure>> _ensureSeeded() async {
    if (_seedSyncedThisSession) {
      return const Success(null);
    }

    final countRes = await _localDataSource.countEntries();
    if (countRes case Error(:final failure)) {
      return Error(failure);
    }
    final localCount = countRes.getOrNull() ?? 0;

    final seedRes = await _seedDataSource.loadSeedEntries();
    if (seedRes case Error(:final failure)) {
      if (localCount > 0) {
        _seedSyncedThisSession = true;
        return const Success(null);
      }
      return Error(failure);
    }

    final seedDtos = seedRes.getOrNull()!;
    if (localCount < seedDtos.length) {
      final insertRes = await _localDataSource.insertEntriesIfAbsent(
        seedDtos,
        createdAt: _clock(),
      );
      if (insertRes case Error(:final failure)) {
        return Error(failure);
      }
      _logger.info(
        _tag,
        'Synced ${seedDtos.length} open dictionary entries into local DB',
      );
    }

    _seedSyncedThisSession = true;
    return const Success(null);
  }

  @override
  Future<Result<List<DictionaryEntry>, Failure>> getAllEntries() async {
    final seedRes = await _ensureSeeded();
    if (seedRes case Error(:final failure)) {
      return Error(failure);
    }
    return _localDataSource.getAllEntries();
  }

  @override
  Future<Result<Set<String>, Failure>> getSrsNormalizedForms() {
    return _localDataSource.getSrsNormalizedForms();
  }

  @override
  Future<Result<DictionaryEntry, Failure>> saveCustomEntry(
    DictionaryEntry entry,
  ) {
    return _localDataSource.upsertEntry(entry);
  }

  @override
  Future<Result<List<DictionaryEntry>, Failure>> searchOnlineAndCache({
    required String query,
    int limit = 12,
  }) async {
    final seedRes = await _ensureSeeded();
    if (seedRes case Error(:final failure)) {
      return Error(failure);
    }

    final remoteRes = await _remoteDataSource.searchOnline(
      query: query,
      limit: limit,
    );
    switch (remoteRes) {
      case Error(:final failure):
        return Error(failure);
      case Success(:final data):
        final now = _clock();
        final entries = <DictionaryEntry>[];
        for (final dto in data) {
          final domainRes = dto.toDomain(createdAt: now);
          if (domainRes case Success(data: final entry)) {
            entries.add(entry);
          }
        }
        if (entries.isNotEmpty) {
          final cacheRes = await _localDataSource.cacheOnlineEntries(entries);
          if (cacheRes case Error(:final failure)) {
            _logger.warning(
              _tag,
              'Online results loaded but caching skipped: ${failure.message}',
            );
          }
        }
        return Success(List<DictionaryEntry>.unmodifiable(entries));
    }
  }
}
