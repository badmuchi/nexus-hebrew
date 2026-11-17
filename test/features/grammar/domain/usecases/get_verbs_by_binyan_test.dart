import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/binyan.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/grammar/domain/entities/verb_conjugation.dart';
import 'package:nexus_hebrew_app/features/grammar/domain/repositories/grammar_repository.dart';
import 'package:nexus_hebrew_app/features/grammar/domain/usecases/get_verbs_by_binyan.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';

class _MockGrammarRepository extends Mock implements GrammarRepository {}

void main() {
  late _MockGrammarRepository repository;
  late GetVerbsByBinyanUseCase useCase;

  final sampleVerb = VerbLexeme(
    id: 'verb_paal_katav',
    lemma: const HebrewText.fixture(vocalized: 'כָּתַב', normalized: 'כתב'),
    infinitive:
        const HebrewText.fixture(vocalized: 'לִכְתֹּב', normalized: 'לכתוב'),
    root: const Shoresh.fixture(<String>['כ', 'ת', 'ב']),
    binyan: Binyan.paal,
    russianMeaning: 'писать',
    grammarNotesRu: 'Классический глагол',
    conjugations: const <ConjugatedForm>[
      ConjugatedForm(
        tense: VerbTense.present,
        person: GrammaticalPerson.masculineSingular,
        form: HebrewText.fixture(vocalized: 'כּוֹתֵב', normalized: 'כותב'),
        transliteration: 'kotev',
      ),
    ],
    attribution: const ContentAttribution(
      sourceName: 'Kaikki / Wiktionary',
      licenseName: 'CC BY-SA 4.0',
    ),
  );

  setUp(() {
    repository = _MockGrammarRepository();
    useCase = GetVerbsByBinyanUseCase(repository);
  });

  group('GetVerbsByBinyanUseCase', () {
    test('passes binyan filter and trimmed query to repository and returns verbs',
        () async {
      when(
        () => repository.getVerbs(binyan: Binyan.paal, query: 'כתב'),
      ).thenAnswer((_) async => Success<List<VerbLexeme>, Failure>(<VerbLexeme>[sampleVerb]));

      final result = await useCase(
        const GetVerbsByBinyanParams(binyan: Binyan.paal, query: '  כתב  '),
      );

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull(), <VerbLexeme>[sampleVerb]);
      verify(
        () => repository.getVerbs(binyan: Binyan.paal, query: 'כתב'),
      ).called(1);
    });

    test('propagates CacheFailure when repository fails', () async {
      const failure = CacheFailure('Database unavailable');
      when(
        () => repository.getVerbs(binyan: null, query: ''),
      ).thenAnswer((_) async => const Error<List<VerbLexeme>, Failure>(failure));

      final result = await useCase(const GetVerbsByBinyanParams());

      expect(result.isError, isTrue);
      expect(result.failureOrNull(), failure);
    });
  });
}
