import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../entities/slang_expression.dart';

abstract interface class SlangRepository {
  Future<Result<List<SlangExpression>, Failure>> getExpressions({
    SlangCategory category = SlangCategory.all,
    String query = '',
  });
}
