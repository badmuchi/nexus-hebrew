import 'package:flutter/services.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/json_reader.dart';
import '../../../../core/result/result.dart';
import '../models/srs_card_dto.dart';

abstract interface class SrsSeedDataSource {
  Future<Result<List<SrsCardDto>, Failure>> loadSeedCards();
}

final class AssetSrsSeedDataSource implements SrsSeedDataSource {
  static const String _tag = 'AssetSrsSeedDataSource';
  static const String defaultAssetPath = 'assets/seed/srs_seed.json';

  final AssetBundle _assetBundle;
  final String _assetPath;
  final AppLogger _logger;

  List<SrsCardDto>? _cached;

  AssetSrsSeedDataSource({
    AssetBundle? assetBundle,
    String assetPath = defaultAssetPath,
    required AppLogger logger,
  })  : _assetBundle = assetBundle ?? rootBundle,
        _assetPath = assetPath,
        _logger = logger;

  @override
  Future<Result<List<SrsCardDto>, Failure>> loadSeedCards() async {
    final existing = _cached;
    if (existing != null) {
      return Success(existing);
    }

    try {
      final rawJson = await _assetBundle.loadString(_assetPath);
      final readersRes = JsonReader.parseObjectList(rawJson);
      if (readersRes case Error(:final failure)) {
        return Error(failure);
      }

      final dtos = <SrsCardDto>[];
      for (final reader in readersRes.getOrNull()!) {
        final dtoRes = SrsCardDto.fromReader(reader);
        switch (dtoRes) {
          case Success(:final data):
            dtos.add(data);
          case Error(:final failure):
            return Error(failure);
        }
      }

      final unmodifiable = List<SrsCardDto>.unmodifiable(dtos);
      _cached = unmodifiable;
      _logger.info(_tag, 'Loaded ${unmodifiable.length} SRS seed cards');
      return Success(unmodifiable);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to read SRS seed asset "$_assetPath"',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(CacheFailure('Unable to load offline SRS seed deck'));
    }
  }
}
