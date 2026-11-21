import '../entities/shoresh_entity.dart';
import '../repositories/shoresh_repository.dart';

/// Use case for fetching the catalog of Hebrew root families with optional filtering.
class GetShoreshRootsUseCase {
  const GetShoreshRootsUseCase(this._repository);

  final ShoreshRepository _repository;

  List<ShoreshRoot> call({String? category, String query = ''}) {
    final all = _repository.getAllRoots();
    if (category == null && query.trim().isEmpty) {
      return all;
    }

    final normalizedQuery = query.trim().toLowerCase();
    return all.where((root) {
      if (category != null && category.isNotEmpty && root.categoryRu != category) {
        return false;
      }

      if (normalizedQuery.isEmpty) return true;

      final inLetters = root.lettersDisplay.contains(normalizedQuery) ||
          root.letters.join('').contains(normalizedQuery);
      final inMeaning = root.primaryMeaningRu.toLowerCase().contains(normalizedQuery);
      final inCategory = root.categoryRu.toLowerCase().contains(normalizedQuery);
      final inDerivatives = root.derivatives.any(
        (d) =>
            d.hebrewNormalized.contains(normalizedQuery) ||
            d.russianMeaning.toLowerCase().contains(normalizedQuery) ||
            d.transliteration.toLowerCase().contains(normalizedQuery),
      );

      return inLetters || inMeaning || inCategory || inDerivatives;
    }).toList(growable: false);
  }
}
