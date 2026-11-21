import '../entities/shoresh_entity.dart';
import '../repositories/shoresh_repository.dart';

/// Use case for retrieving the complete word family for a specific root.
class GetShoreshFamilyUseCase {
  const GetShoreshFamilyUseCase(this._repository);

  final ShoreshRepository _repository;

  ShoreshRoot? call(String rootId) {
    if (rootId.trim().isEmpty) return null;
    return _repository.getRootById(rootId);
  }
}
