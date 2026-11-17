import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../entities/slang_expression.dart';
import '../repositories/slang_repository.dart';

class GetSlangExpressionsUseCase {
  final SlangRepository _repository;

  const GetSlangExpressionsUseCase(this._repository);

  Future<Result<List<SlangExpression>, Failure>> call({
    SlangCategory category = SlangCategory.all,
    String query = '',
  }) {
    return _repository.getExpressions(category: category, query: query);
  }
}
