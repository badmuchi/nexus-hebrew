import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/slang_expression.dart';
import '../../domain/repositories/slang_repository.dart';
import '../datasources/slang_seed_datasource.dart';

final class SlangRepositoryImpl implements SlangRepository {
  final SlangSeedDataSource _dataSource;

  const SlangRepositoryImpl({
    required SlangSeedDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<Result<List<SlangExpression>, Failure>> getExpressions({
    SlangCategory category = SlangCategory.all,
    String query = '',
  }) async {
    final result = await _dataSource.loadExpressions();
    return result.map((list) {
      return list.where((item) {
        if (category != SlangCategory.all && item.category != category) {
          return false;
        }
        if (query.trim().isNotEmpty) {
          final q = query.trim().toLowerCase();
          final matchesHebrew =
              item.hebrew.vocalized.contains(q) || item.hebrew.normalized.contains(q);
          final matchesRu = item.translationRu.toLowerCase().contains(q);
          final matchesTranslit =
              item.transliteration.toLowerCase().contains(q);
          return matchesHebrew || matchesRu || matchesTranslit;
        }
        return true;
      }).toList(growable: false);
    });
  }
}
