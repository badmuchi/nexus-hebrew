import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/binyan.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/grammar/domain/entities/verb_conjugation.dart';
import 'package:nexus_hebrew_app/features/grammar/domain/usecases/check_verb_conjugation.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';

void main() {
  const useCase = CheckVerbConjugationUseCase();

  final verb = VerbLexeme(
    id: 'verb_piel_diber',
    lemma: const HebrewText.fixture(vocalized: 'דִּבֵּר', normalized: 'דיבר'),
    infinitive:
        const HebrewText.fixture(vocalized: 'לְדַבֵּר', normalized: 'לדבר'),
    root: const Shoresh.fixture(<String>['ד', 'ב', 'ר']),
    binyan: Binyan.piel,
    russianMeaning: 'говорить',
    grammarNotesRu: 'Дагеш во второй букве корня',
    conjugations: const <ConjugatedForm>[
      ConjugatedForm(
        tense: VerbTense.present,
        person: GrammaticalPerson.masculineSingular,
        form: HebrewText.fixture(vocalized: 'מְדַבֵּר', normalized: 'מדבר'),
        transliteration: 'medaber',
      ),
      ConjugatedForm(
        tense: VerbTense.past,
        person: GrammaticalPerson.firstSingular,
        form: HebrewText.fixture(vocalized: 'דִּבַּרְתִּי', normalized: 'דיברתי'),
        transliteration: 'dibarti',
      ),
    ],
    attribution: const ContentAttribution(
      sourceName: 'Kaikki / Wiktionary',
      licenseName: 'CC BY-SA 4.0',
    ),
  );

  group('CheckVerbConjugationUseCase', () {
    test('matches unvocalized user input against vocalized paradigm form', () {
      final result = useCase(
        CheckVerbConjugationParams(
          verb: verb,
          tense: VerbTense.present,
          person: GrammaticalPerson.masculineSingular,
          userInput: '  מדבר ',
        ),
      );

      expect(result.isSuccess, isTrue);
      final check = result.getOrNull()!;
      expect(check.isCorrect, isTrue);
      expect(check.normalizedUserInput, 'מדבר');
      expect(check.normalizedExpected, 'מדבר');
      expect(check.expectedForm.vocalized, 'מְדַבֵּר');
      expect(check.transliteration, 'medaber');
    });

    test('returns isCorrect=false with expected form when user enters wrong form',
        () {
      final result = useCase(
        CheckVerbConjugationParams(
          verb: verb,
          tense: VerbTense.present,
          person: GrammaticalPerson.masculineSingular,
          userInput: 'כותב',
        ),
      );

      expect(result.isSuccess, isTrue);
      final check = result.getOrNull()!;
      expect(check.isCorrect, isFalse);
      expect(check.expectedForm.vocalized, 'מְדַבֵּר');
    });

    test('returns ValidationFailure when user input is empty', () {
      final result = useCase(
        CheckVerbConjugationParams(
          verb: verb,
          tense: VerbTense.present,
          person: GrammaticalPerson.masculineSingular,
          userInput: '   ',
        ),
      );

      expect(result, isA<Error<ConjugationCheckResult, Failure>>());
      expect(result.failureOrNull(), isA<ValidationFailure>());
    });

    test('returns ValidationFailure when requested tense/person slot is absent',
        () {
      final result = useCase(
        CheckVerbConjugationParams(
          verb: verb,
          tense: VerbTense.future,
          person: GrammaticalPerson.thirdPlural,
          userInput: 'ידברו',
        ),
      );

      expect(result.isError, isTrue);
      expect(result.failureOrNull(), isA<ValidationFailure>());
    });
  });
}
