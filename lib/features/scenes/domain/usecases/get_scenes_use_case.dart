import '../entities/israeli_life_scene.dart';
import '../repositories/scenes_repository.dart';

/// Use case for fetching all Israeli life scenes with optional filtering by type or search query.
final class GetScenesUseCase {
  const GetScenesUseCase(this._repository);

  final ScenesRepository _repository;

  List<IsraeliLifeScene> call({SceneType? type, String query = ''}) {
    final all = _repository.getAllScenes();
    if (type == null && query.trim().isEmpty) {
      return all;
    }

    final normalizedQuery = query.trim().toLowerCase();
    return all.where((scene) {
      final matchesType = type == null || scene.type == type;
      if (!matchesType) return false;

      if (normalizedQuery.isEmpty) return true;

      final inRussian = scene.titleRussian.toLowerCase().contains(normalizedQuery);
      final inHebrew = scene.titleHebrew.contains(normalizedQuery);
      final inDesc = scene.description.toLowerCase().contains(normalizedQuery);
      final inWords = scene.words.any(
        (w) =>
            w.russianMeaning.toLowerCase().contains(normalizedQuery) ||
            w.hebrewNormalized.contains(normalizedQuery) ||
            w.transliteration.toLowerCase().contains(normalizedQuery),
      );
      final inPhrases = scene.phrases.any(
        (p) =>
            p.russianTranslation.toLowerCase().contains(normalizedQuery) ||
            p.hebrewNormalized.contains(normalizedQuery) ||
            p.transliteration.toLowerCase().contains(normalizedQuery),
      );

      return inRussian || inHebrew || inDesc || inWords || inPhrases;
    }).toList(growable: false);
  }
}
