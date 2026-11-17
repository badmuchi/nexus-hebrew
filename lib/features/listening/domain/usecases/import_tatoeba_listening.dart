import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../entities/listening_exercise.dart';
import '../repositories/listening_repository.dart';

/// Parameters for importing open-licensed Hebrew listening sentences from Tatoeba.
final class ImportTatoebaListeningParams extends Equatable {
  const ImportTatoebaListeningParams({
    required this.query,
    this.limit = 8,
  });

  final String query;
  final int limit;

  @override
  List<Object?> get props => [query, limit];
}

/// Fetches and persists open-licensed Tatoeba listening exercises into offline storage.
class ImportTatoebaListeningUseCase {
  const ImportTatoebaListeningUseCase(this._repository);

  final ListeningRepository _repository;

  /// Validates query and imports up to [params.limit] sentences.
  Future<Result<List<ListeningExercise>, Failure>> call(
    ImportTatoebaListeningParams params,
  ) async {
    final trimmed = params.query.trim();
    if (trimmed.isEmpty) {
      return const Error<List<ListeningExercise>, Failure>(
        ValidationFailure('Поисковый запрос для Tatoeba не должен быть пустым.'),
      );
    }
    if (params.limit <= 0 || params.limit > 25) {
      return const Error<List<ListeningExercise>, Failure>(
        ValidationFailure('Лимит импорта должен быть от 1 до 25.'),
      );
    }

    return _repository.importFromTatoeba(
      query: trimmed,
      limit: params.limit,
    );
  }
}
