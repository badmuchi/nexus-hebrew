import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/result/result.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../../domain/entities/slang_expression.dart';

abstract interface class SlangSeedDataSource {
  Future<Result<List<SlangExpression>, Failure>> loadExpressions();
}

final class AssetSlangSeedDataSource implements SlangSeedDataSource {
  static const String _tag = 'AssetSlangSeedDataSource';
  static const String _assetPath = 'assets/seed/slang_seed.json';

  final AssetBundle _bundle;
  final AppLogger _logger;
  List<SlangExpression>? _cached;

  AssetSlangSeedDataSource({
    AssetBundle? bundle,
    required AppLogger logger,
  })  : _bundle = bundle ?? rootBundle,
        _logger = logger;

  @override
  Future<Result<List<SlangExpression>, Failure>> loadExpressions() async {
    if (_cached != null) {
      return Success(_cached!);
    }
    try {
      final jsonString = await _bundle.loadString(_assetPath);
      final rawList = jsonDecode(jsonString) as List<dynamic>;

      final expressions = <SlangExpression>[];
      for (final raw in rawList) {
        final map = raw as Map<String, dynamic>;
        final hebrewRes = HebrewText.create(map['vocalized'] as String);
        final hebrew = hebrewRes.getOrNull();
        if (hebrew == null) continue;

        expressions.add(
          SlangExpression(
            id: map['id'] as String,
            hebrew: hebrew,
            transliteration: map['transliteration'] as String,
            translationRu: map['translationRu'] as String,
            literalTranslationRu: map['literalTranslationRu'] as String,
            culturalNoteRu: map['culturalNoteRu'] as String,
            category: SlangCategory.fromId(map['category'] as String),
            exampleHebrew: map['exampleHebrew'] as String,
            exampleTranslationRu: map['exampleTranslationRu'] as String,
            audioUrl: map['audioUrl'] as String?,
          ),
        );
      }

      _cached = expressions;
      return Success(expressions);
    } on Object catch (e, stackTrace) {
      _logger.error(
        _tag,
        'Failed to parse slang seed asset $_assetPath',
        errorDetails: e.toString(),
        stackTrace: stackTrace,
      );
      return Error(ParsingFailure('Failed to load slang seed: $e'));
    }
  }
}
