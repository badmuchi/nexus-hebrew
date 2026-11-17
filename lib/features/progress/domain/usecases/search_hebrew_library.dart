import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../entities/learning_progress_summary.dart';
import '../repositories/progress_repository.dart';

/// Parameters for searching across all local Hebrew study resources.
final class SearchHebrewLibraryParams extends Equatable {
  const SearchHebrewLibraryParams({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Validates and executes a global shoresh / Hebrew / Russian library search.
class SearchHebrewLibraryUseCase {
  const SearchHebrewLibraryUseCase(this._repository);

  final ProgressRepository _repository;

  /// Searches FSRS cards, grammar verbs, dialogues, and listening exercises.
  Future<Result<List<GlobalHebrewSearchResult>, Failure>> call(
    SearchHebrewLibraryParams params,
  ) async {
    final trimmed = params.query.trim();
    if (trimmed.isEmpty) {
      return const Error<List<GlobalHebrewSearchResult>, Failure>(
        ValidationFailure('Введи слово, корень (כ-ת-ב) или перевод для поиска.'),
      );
    }

    return _repository.searchAcrossLibrary(trimmed);
  }
}
