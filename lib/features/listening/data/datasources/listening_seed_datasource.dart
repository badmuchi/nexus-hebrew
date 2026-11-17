import 'package:flutter/services.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/json_reader.dart';
import '../../../../core/result/result.dart';
import '../models/listening_exercise_dto.dart';

/// Contract for loading offline Hebrew listening exercise seeds.
abstract interface class ListeningSeedDataSource {
  /// Loads and validates bundled [ListeningExerciseDto] entries.
  Future<Result<List<ListeningExerciseDto>, Failure>> loadSeedExercises();
}

/// Loads bundled listening exercises from an asset JSON bundle.
final class AssetListeningSeedDataSource implements ListeningSeedDataSource {
  static const String _tag = 'AssetListeningSeedDataSource';
  static const String defaultAssetPath = 'assets/seed/listening_seed.json';

  AssetListeningSeedDataSource({
    AssetBundle? assetBundle,
    String assetPath = defaultAssetPath,
    required AppLogger logger,
  })  : _assetBundle = assetBundle ?? rootBundle,
        _assetPath = assetPath,
        _logger = logger;

  final AssetBundle _assetBundle;
  final String _assetPath;
  final AppLogger _logger;

  List<ListeningExerciseDto>? _cached;

  @override
  Future<Result<List<ListeningExerciseDto>, Failure>>
      loadSeedExercises() async {
    final existing = _cached;
    if (existing != null) {
      return Success(existing);
    }

    try {
      final rawJson = await _assetBundle.loadString(_assetPath);
      final rootRes = JsonReader.parseObject(rawJson);
      if (rootRes case Error(:final failure)) {
        return Error(failure);
      }

      final itemsRes = rootRes.getOrNull()!.requireObjectList('exercises');
      if (itemsRes case Error(:final failure)) {
        return Error(failure);
      }

      final dtos = <ListeningExerciseDto>[];
      for (final reader in itemsRes.getOrNull()!) {
        final dtoRes = ListeningExerciseDto.fromReader(reader);
        switch (dtoRes) {
          case Success(:final data):
            dtos.add(data);
          case Error(:final failure):
            return Error(failure);
        }
      }

      final unmodifiable = List<ListeningExerciseDto>.unmodifiable(dtos);
      _cached = unmodifiable;
      _logger.info(_tag, 'Loaded ${unmodifiable.length} listening seed items');
      return Success(unmodifiable);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to load listening seed asset "$_assetPath"',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(
        CacheFailure('Unable to load offline listening exercises seed'),
      );
    }
  }
}
