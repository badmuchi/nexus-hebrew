import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../entities/dictionary_entry.dart';
import '../repositories/dictionary_repository.dart';

final class SearchOnlineDictionaryParams extends Equatable {
  const SearchOnlineDictionaryParams({
    required this.query,
    this.limit = 12,
  });

  final String query;
  final int limit;

  @override
  List<Object?> get props => [query, limit];
}

/// Searches open-licensed online sources (Tatoeba heb<->rus) and caches hits locally.
class SearchOnlineDictionaryUseCase {
  const SearchOnlineDictionaryUseCase(this._repository);

  final DictionaryRepository _repository;

  Future<Result<List<DictionaryEntry>, Failure>> call(
    SearchOnlineDictionaryParams params,
  ) async {
    final trimmed = params.query.trim();
    if (trimmed.isEmpty) {
      return const Error(
        ValidationFailure('Введи слово или фразу для онлайн-поиска.'),
      );
    }
    return _repository.searchOnlineAndCache(
      query: trimmed,
      limit: params.limit.clamp(1, 30),
    );
  }
}
