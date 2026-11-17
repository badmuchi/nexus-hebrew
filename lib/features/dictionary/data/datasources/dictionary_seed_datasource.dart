import 'package:flutter/services.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/json_reader.dart';
import '../../../../core/result/result.dart';
import '../models/dictionary_entry_dto.dart';

abstract interface class DictionarySeedDataSource {
  Future<Result<List<DictionaryEntryDto>, Failure>> loadSeedEntries();
}

final class AssetDictionarySeedDataSource implements DictionarySeedDataSource {
  static const String _tag = 'AssetDictionarySeedDataSource';
  static const String defaultAssetPath = 'assets/seed/dictionary_seed.json';

  final AssetBundle _assetBundle;
  final String _assetPath;
  final AppLogger _logger;

  List<DictionaryEntryDto>? _cached;

  AssetDictionarySeedDataSource({
    AssetBundle? assetBundle,
    String assetPath = defaultAssetPath,
    required AppLogger logger,
  })  : _assetBundle = assetBundle ?? rootBundle,
        _assetPath = assetPath,
        _logger = logger;

  @override
  Future<Result<List<DictionaryEntryDto>, Failure>> loadSeedEntries() async {
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

      final dtos = <DictionaryEntryDto>[];
      for (final reader in readersRes.getOrNull()!) {
        final dtoRes = DictionaryEntryDto.fromReader(reader);
        switch (dtoRes) {
          case Success(:final data):
            dtos.add(data);
          case Error(:final failure):
            return Error(failure);
        }
      }

      final unmodifiable = List<DictionaryEntryDto>.unmodifiable(dtos);
      _cached = unmodifiable;
      _logger.info(
        _tag,
        'Loaded ${unmodifiable.length} dictionary seed entries',
      );
      return Success(unmodifiable);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to read dictionary seed asset "$_assetPath"',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(
        CacheFailure('Не удалось загрузить встроенный словарь'),
      );
    }
  }
}
