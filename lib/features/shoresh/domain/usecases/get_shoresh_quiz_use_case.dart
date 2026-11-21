import '../entities/shoresh_entity.dart';
import '../repositories/shoresh_repository.dart';

/// Use case for generating root extractor challenge questions for the detective game.
class GetShoreshQuizUseCase {
  const GetShoreshQuizUseCase(this._repository);

  final ShoreshRepository _repository;

  List<ShoreshQuizQuestion> call({int count = 10}) {
    final effectiveCount = count <= 0 ? 10 : count;
    return _repository.generateQuizQuestions(count: effectiveCount);
  }
}
