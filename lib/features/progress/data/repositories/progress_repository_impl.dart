import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/learning_progress_summary.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_local_datasource.dart';

/// Repository implementation aggregating local progress metrics and unified search.
final class ProgressRepositoryImpl implements ProgressRepository {
  const ProgressRepositoryImpl({
    required ProgressLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final ProgressLocalDataSource _localDataSource;

  @override
  Future<Result<LearningProgressSummary, Failure>> getProgressSummary({
    required DateTime asOf,
  }) {
    return _localDataSource.loadSummary(asOf: asOf);
  }

  @override
  Future<Result<List<GlobalHebrewSearchResult>, Failure>> searchAcrossLibrary(
    String query,
  ) {
    return _localDataSource.searchLibrary(query);
  }
}
