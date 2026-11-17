import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/utils/hebrew_normalizer.dart';
import '../entities/srs_card.dart';

class CheckHebrewTypedAnswerUseCase {
  const CheckHebrewTypedAnswerUseCase();

  Result<TypingAnswerEvaluation, Failure> execute({
    required SrsCard card,
    required String rawUserInput,
    bool normalizeFinalForms = false,
  }) {
    final normalizedInput = HebrewNormalizer.normalizeForComparison(
      rawUserInput,
      normalizeFinalForms: normalizeFinalForms,
    );
    if (normalizedInput.isEmpty) {
      return const Error(
        ValidationFailure('Введите ответ на иврите перед проверкой'),
      );
    }

    final isMatch = card.hebrew.matchesInput(
      rawUserInput,
      normalizeFinalForms: normalizeFinalForms,
    );

    return Success(
      TypingAnswerEvaluation(
        isMatch: isMatch,
        normalizedUserInput: normalizedInput,
        expectedNormalized: card.hebrew.normalized,
        expectedVocalized: card.hebrew.vocalized,
      ),
    );
  }
}
