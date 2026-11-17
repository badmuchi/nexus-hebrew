import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../entities/verb_conjugation.dart';
import '../repositories/grammar_repository.dart';

/// Input parameters for querying verb paradigms.
final class GetVerbsByBinyanParams extends Equatable {
  const GetVerbsByBinyanParams({
    this.binyan,
    this.query = '',
  });

  final Binyan? binyan;
  final String query;

  @override
  List<Object?> get props => [binyan, query];
}

/// Fetches Hebrew verb lexemes and conjugation tables filtered by binyan and/or search query.
class GetVerbsByBinyanUseCase {
  const GetVerbsByBinyanUseCase(this._repository);

  final GrammarRepository _repository;

  /// Loads matching verbs from the repository.
  Future<Result<List<VerbLexeme>, Failure>> call(
    GetVerbsByBinyanParams params,
  ) {
    return _repository.getVerbs(
      binyan: params.binyan,
      query: params.query.trim(),
    );
  }
}
