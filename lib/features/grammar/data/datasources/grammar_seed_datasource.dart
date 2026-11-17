import 'package:flutter/services.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/json_reader.dart';
import '../../../../core/result/result.dart';
import '../models/verb_lexeme_dto.dart';

/// Contract for loading offline grammar verb conjugation seeds.
abstract interface class GrammarSeedDataSource {
  /// Loads and validates all bundled [VerbLexemeDto] entries.
  Future<Result<List<VerbLexemeDto>, Failure>> loadSeedVerbs();
}

/// Loads bundled grammar verb paradigms from a local JSON asset.
final class AssetGrammarSeedDataSource implements GrammarSeedDataSource {
  static const String _tag = 'AssetGrammarSeedDataSource';
  static const String defaultAssetPath = 'assets/seed/grammar_verbs_seed.json';

  AssetGrammarSeedDataSource({
    AssetBundle? assetBundle,
    String assetPath = defaultAssetPath,
    required AppLogger logger,
  })  : _assetBundle = assetBundle ?? rootBundle,
        _assetPath = assetPath,
        _logger = logger;

  final AssetBundle _assetBundle;
  final String _assetPath;
  final AppLogger _logger;

  List<VerbLexemeDto>? _cached;

  @override
  Future<Result<List<VerbLexemeDto>, Failure>> loadSeedVerbs() async {
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

      final verbsRes = rootRes.getOrNull()!.requireObjectList('verbs');
      if (verbsRes case Error(:final failure)) {
        return Error(failure);
      }

      final dtos = <VerbLexemeDto>[];
      for (final reader in verbsRes.getOrNull()!) {
        final dtoRes = VerbLexemeDto.fromReader(reader);
        switch (dtoRes) {
          case Success(:final data):
            dtos.add(data);
          case Error(:final failure):
            return Error(failure);
        }
      }

      final unmodifiable = List<VerbLexemeDto>.unmodifiable(dtos);
      _cached = unmodifiable;
      _logger.info(_tag, 'Loaded ${unmodifiable.length} grammar verb seeds');
      return Success(unmodifiable);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to load grammar seed asset "$_assetPath"',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(
        CacheFailure('Unable to load offline Hebrew grammar seed data'),
      );
    }
  }
}
