import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/dialogue_node.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../datasources/dialogue_local_datasource.dart';
import '../datasources/dialogue_remote_datasource.dart';
import '../datasources/dialogue_seed_datasource.dart';

final class ConversationRepositoryImpl implements ConversationRepository {
  static const String _tag = 'ConversationRepositoryImpl';

  final DialogueRemoteDataSource _remoteDataSource;
  final DialogueLocalDataSource _localDataSource;
  final DialogueSeedDataSource _seedDataSource;
  final AppLogger _logger;

  bool _seedHydrated = false;

  ConversationRepositoryImpl({
    required DialogueRemoteDataSource remoteDataSource,
    required DialogueLocalDataSource localDataSource,
    required DialogueSeedDataSource seedDataSource,
    required AppLogger logger,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _seedDataSource = seedDataSource,
        _logger = logger;

  @override
  Future<Result<DialogueNode, Failure>> getDialogueNode(String nodeId) async {
    await _ensureSeedHydrated();

    // 1. Offline-first: read local Drift cache first.
    final localResult = await _localDataSource.getCachedNode(nodeId);
    if (localResult case Success(:final data) when data != null) {
      return data.toDomain();
    }
    if (localResult case Error(:final failure)) {
      _logger.warning(
        _tag,
        'Local cache lookup failed for "$nodeId", falling back',
        failure: failure,
      );
    }

    // 2. Fallback to bundled seed pack if not yet cached.
    final seedResult = await _seedDataSource.findSeedNodeById(nodeId);
    if (seedResult case Success(:final data) when data != null) {
      await _localDataSource.cacheNode(data);
      return data.toDomain();
    }

    // 3. Try remote API via Dio if configured.
    if (_remoteDataSource.isRemoteEnabled) {
      final remoteResult = await _remoteDataSource.fetchNode(nodeId);
      switch (remoteResult) {
        case Success(:final data):
          final domainResult = data.toDomain();
          if (domainResult.isSuccess) {
            await _localDataSource.cacheNode(data);
          }
          return domainResult;
        case Error(:final failure):
          return Error(failure);
      }
    }

    return Error(
      CacheFailure('Dialogue node "$nodeId" was not found offline'),
    );
  }

  @override
  Future<Result<List<DialogueNode>, Failure>> searchDialoguesByHebrew(
    String normalizedQuery,
  ) async {
    final seedHydrationResult = await _ensureSeedHydrated();
    if (seedHydrationResult case Error(:final failure)) {
      _logger.warning(
        _tag,
        'Seed hydration encountered an issue before search',
        failure: failure,
      );
    }

    final searchResult = await _localDataSource.searchNodesByNormalizedHebrew(
      normalizedQuery,
    );
    switch (searchResult) {
      case Error(:final failure):
        return Error(failure);
      case Success(:final data):
        final domainNodes = <DialogueNode>[];
        for (final dto in data) {
          final domainRes = dto.toDomain();
          switch (domainRes) {
            case Success(:final data):
              domainNodes.add(data);
            case Error(:final failure):
              return Error(failure);
          }
        }
        return Success(List<DialogueNode>.unmodifiable(domainNodes));
    }
  }

  @override
  Future<Result<void, Failure>> recordDialogueSelection({
    required String nodeId,
    required String optionId,
  }) async {
    return _localDataSource.recordSelection(
      nodeId: nodeId,
      optionId: optionId,
      answeredAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<Result<int, Failure>> syncDialogueHistory() async {
    final unsyncedRes = await _localDataSource.getUnsyncedHistory();
    switch (unsyncedRes) {
      case Error(:final failure):
        return Error(failure);
      case Success(:final data):
        if (data.isEmpty) {
          return const Success(0);
        }
        if (!_remoteDataSource.isRemoteEnabled) {
          _logger.info(
            _tag,
            'Skipping remote sync (${data.length} pending offline entries): remote API not configured',
          );
          return const Success(0);
        }

        final pushRes = await _remoteDataSource.pushHistory(data);
        switch (pushRes) {
          case Error(:final failure):
            return Error(failure);
          case Success():
            final ids = data.map((e) => e.entryId).toList(growable: false);
            final markRes = await _localDataSource.markHistorySynced(ids);
            return markRes.map((_) => ids.length);
        }
    }
  }

  Future<Result<void, Failure>> _ensureSeedHydrated() async {
    if (_seedHydrated) {
      return const Success(null);
    }

    final seedRes = await _seedDataSource.loadAllSeedNodes();
    switch (seedRes) {
      case Error(:final failure):
        return Error(failure);
      case Success(:final data):
        final cacheRes = await _localDataSource.cacheNodes(data);
        if (cacheRes.isSuccess) {
          _seedHydrated = true;
        }
        return cacheRes;
    }
  }
}
