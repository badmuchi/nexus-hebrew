import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/grammar/domain/entities/verb_conjugation.dart';
import 'package:nexus_hebrew_app/features/grammar/domain/repositories/grammar_repository.dart';
import 'package:nexus_hebrew_app/features/grammar/domain/usecases/record_grammar_practice.dart';

class _MockGrammarRepository extends Mock implements GrammarRepository {}

void main() {
  late _MockGrammarRepository repository;
  late RecordGrammarPracticeUseCase useCase;
  final fixedTime = DateTime.utc(2026, 11, 11, 20, 0);

  setUp(() {
    repository = _MockGrammarRepository();
    useCase = RecordGrammarPracticeUseCase(repository);
  });

  group('RecordGrammarPracticeUseCase', () {
    test('records practice outcome with trimmed verbId on success', () async {
      when(
        () => repository.recordPracticeAttempt(
          verbId: 'verb_paal_katav',
          tense: VerbTense.past,
          person: GrammaticalPerson.firstSingular,
          isCorrect: true,
          practicedAt: fixedTime,
        ),
      ).thenAnswer((_) async => const Success<void, Failure>(null));

      final result = await useCase(
        RecordGrammarPracticeParams(
          verbId: '  verb_paal_katav ',
          tense: VerbTense.past,
          person: GrammaticalPerson.firstSingular,
          isCorrect: true,
          practicedAt: fixedTime,
        ),
      );

      expect(result.isSuccess, isTrue);
      verify(
        () => repository.recordPracticeAttempt(
          verbId: 'verb_paal_katav',
          tense: VerbTense.past,
          person: GrammaticalPerson.firstSingular,
          isCorrect: true,
          practicedAt: fixedTime,
        ),
      ).called(1);
    });

    test('returns ValidationFailure when verbId is empty', () async {
      final result = await useCase(
        RecordGrammarPracticeParams(
          verbId: '   ',
          tense: VerbTense.present,
          person: GrammaticalPerson.masculineSingular,
          isCorrect: false,
          practicedAt: fixedTime,
        ),
      );

      expect(result.isError, isTrue);
      expect(result.failureOrNull(), isA<ValidationFailure>());
      verifyZeroInteractions(repository);
    });

    test('propagates CacheFailure from repository', () async {
      const failure = CacheFailure('SQLite write failed');
      when(
        () => repository.recordPracticeAttempt(
          verbId: 'verb_paal_katav',
          tense: VerbTense.present,
          person: GrammaticalPerson.masculineSingular,
          isCorrect: false,
          practicedAt: fixedTime,
        ),
      ).thenAnswer((_) async => const Error<void, Failure>(failure));

      final result = await useCase(
        RecordGrammarPracticeParams(
          verbId: 'verb_paal_katav',
          tense: VerbTense.present,
          person: GrammaticalPerson.masculineSingular,
          isCorrect: false,
          practicedAt: fixedTime,
        ),
      );

      expect(result.isError, isTrue);
      expect(result.failureOrNull(), failure);
    });
  });
}
