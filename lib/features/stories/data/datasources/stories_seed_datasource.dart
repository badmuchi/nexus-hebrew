import 'package:flutter/services.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/json_reader.dart';
import '../../../../core/result/result.dart';
import '../models/story_dto.dart';

abstract interface class StoriesSeedDataSource {
  Future<Result<List<StoryDto>, Failure>> loadAllSeedStories();
  Future<Result<StoryDto?, Failure>> findSeedStoryById(String id);
}

final class AssetStoriesSeedDataSource implements StoriesSeedDataSource {
  static const String _tag = 'AssetStoriesSeedDataSource';
  static const String defaultAssetPath = 'assets/seed/stories_seed.json';

  final AssetBundle _assetBundle;
  final String _assetPath;
  final AppLogger _logger;

  List<StoryDto>? _cachedStories;

  AssetStoriesSeedDataSource({
    AssetBundle? assetBundle,
    String assetPath = defaultAssetPath,
    required AppLogger logger,
  })  : _assetBundle = assetBundle ?? rootBundle,
        _assetPath = assetPath,
        _logger = logger;

  @override
  Future<Result<List<StoryDto>, Failure>> loadAllSeedStories() async {
    final existing = _cachedStories;
    if (existing != null) {
      return Success(existing);
    }

    try {
      final rawJson = await _assetBundle.loadString(_assetPath);
      final readersRes = JsonReader.parseObjectList(rawJson);
      if (readersRes case Error(:final failure)) {
        return Error(failure);
      }

      final parsed = <StoryDto>[];
      for (final reader in readersRes.getOrNull()!) {
        final dtoRes = StoryDto.fromReader(reader);
        switch (dtoRes) {
          case Success(:final data):
            parsed.add(data);
          case Error(:final failure):
            return Error(failure);
        }
      }

      final immutableList = List<StoryDto>.unmodifiable(parsed);
      _cachedStories = immutableList;
      _logger.info(
        _tag,
        'Loaded ${immutableList.length} seed stories from "$_assetPath"',
      );
      return Success(immutableList);
    } catch (e, st) {
      _logger.error(
        _tag,
        'Failed to read stories asset at "$_assetPath"',
        errorDetails: e.toString(),
        stackTrace: st,
      );
      return Error(
        CacheFailure('Failed to read stories asset: $e'),
      );
    }
  }

  @override
  Future<Result<StoryDto?, Failure>> findSeedStoryById(String id) async {
    final allRes = await loadAllSeedStories();
    switch (allRes) {
      case Success(:final data):
        for (final story in data) {
          if (story.id == id) {
            return Success(story);
          }
        }
        return const Success(null);
      case Error(:final failure):
        return Error(failure);
    }
  }
}
