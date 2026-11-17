import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/utils/hebrew_normalizer.dart';
import '../entities/verb_conjugation.dart';

/// Parameters for validating a typed Hebrew verb conjugation against a target paradigm.
final class CheckVerbConjugationParams extends Equatable {
  const CheckVerbConjugationParams({
    required this.verb,
    required this.tense,
    required this.person,
    required this.userInput,
  });

  final VerbLexeme verb;
  final VerbTense tense;
  final GrammaticalPerson person;
  final String userInput;

  @override
  List<Object?> get props => [verb, tense, person, userInput];
}

/// Pure Domain Use Case checking typed Hebrew conjugation answers without requiring nikkud.
class CheckVerbConjugationUseCase {
  const CheckVerbConjugationUseCase();

  /// Compares [params.userInput] against the target conjugated form using [HebrewNormalizer].
  Result<ConjugationCheckResult, Failure> call(
    CheckVerbConjugationParams params,
  ) {
    final String normalizedInput = HebrewNormalizer.normalizeForComparison(
      params.userInput,
    );
    if (normalizedInput.isEmpty) {
      return const Error<ConjugationCheckResult, Failure>(
        ValidationFailure('Введи форму глагола на иврите для проверки.'),
      );
    }

    final ConjugatedForm? targetForm = params.verb.findForm(
      params.tense,
      params.person,
    );
    if (targetForm == null) {
      return Error<ConjugationCheckResult, Failure>(
        ValidationFailure(
          'Форма ${params.tense.id}/${params.person.id} отсутствует для глагола ${params.verb.id}.',
        ),
      );
    }

    final String normalizedExpected = HebrewNormalizer.normalizeForComparison(
      targetForm.form.normalized,
    );

    return Success<ConjugationCheckResult, Failure>(
      ConjugationCheckResult(
        isCorrect: normalizedInput == normalizedExpected,
        normalizedUserInput: normalizedInput,
        normalizedExpected: normalizedExpected,
        expectedForm: targetForm.form,
        transliteration: targetForm.transliteration,
        tense: params.tense,
        person: params.person,
      ),
    );
  }
}
