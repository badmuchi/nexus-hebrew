import '../entities/israeli_life_scene.dart';
import '../repositories/scenes_repository.dart';

/// Use case for retrieving a specific Israeli life scene by its identifier.
final class GetSceneByIdUseCase {
  const GetSceneByIdUseCase(this._repository);

  final ScenesRepository _repository;

  IsraeliLifeScene? call(String id) {
    if (id.trim().isEmpty) return null;
    return _repository.getSceneById(id);
  }
}
