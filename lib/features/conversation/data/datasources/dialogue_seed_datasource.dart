import 'package:flutter/services.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/json_reader.dart';
import '../../../../core/result/result.dart';
import '../models/dialogue_node_dto.dart';

abstract interface class DialogueSeedDataSource {
  Future<Result<List<DialogueNodeDto>, Failure>> loadAllSeedNodes();
  Future<Result<DialogueNodeDto?, Failure>> findSeedNodeById(String nodeId);
}

final class AssetDialogueSeedDataSource implements DialogueSeedDataSource {
  static const String _tag = 'AssetDialogueSeedDataSource';
  static const String defaultAssetPath = 'assets/seed/dialogues_seed.json';

  final AssetBundle _assetBundle;
  final String _assetPath;
  final AppLogger _logger;

  List<DialogueNodeDto>? _cachedSeedNodes;

  AssetDialogueSeedDataSource({
    AssetBundle? assetBundle,
    String assetPath = defaultAssetPath,
    required AppLogger logger,
  })  : _assetBundle = assetBundle ?? rootBundle,
        _assetPath = assetPath,
        _logger = logger;

  @override
  Future<Result<List<DialogueNodeDto>, Failure>> loadAllSeedNodes() async {
    final existing = _cachedSeedNodes;
    if (existing != null) {
      return Success(existing);
    }

    try {
      final rawJson = await _assetBundle.loadString(_assetPath);
      final readersRes = JsonReader.parseObjectList(rawJson);
      if (readersRes case Error(:final failure)) {
        return Error(failure);
      }

      final parsed = <DialogueNodeDto>[];
      for (final reader in readersRes.getOrNull()!) {
        final dtoRes = DialogueNodeDto.fromReader(reader);
        switch (dtoRes) {
          case Success(:final data):
            parsed.add(data);
          case Error(:final failure):
            return Error(failure);
        }
      }

      final immutableList = List<DialogueNodeDto>.unmodifiable(parsed);
      _cachedSeedNodes = immutableList;
      _logger.info(
        _tag,
        'Loaded ${immutableList.length} dialogue nodes from seed pack',
      );
      return Success(immutableList);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to load seed dialogue asset "$_assetPath"',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(
        CacheFailure('Unable to load offline dialogue seed pack'),
      );
    }
  }

  @override
  Future<Result<DialogueNodeDto?, Failure>> findSeedNodeById(
    String nodeId,
  ) async {
    final allRes = await loadAllSeedNodes();
    return allRes.map((nodes) {
      for (final node in nodes) {
        if (node.id == nodeId) {
          return node;
        }
      }
      return null;
    });
  }
}
