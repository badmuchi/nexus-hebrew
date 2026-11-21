import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/shoresh/domain/entities/shoresh_entity.dart';
import 'package:nexus_hebrew_app/features/shoresh/domain/repositories/shoresh_repository.dart';
import 'package:nexus_hebrew_app/features/shoresh/domain/usecases/get_shoresh_family_use_case.dart';
import 'package:nexus_hebrew_app/features/shoresh/domain/usecases/get_shoresh_quiz_use_case.dart';
import 'package:nexus_hebrew_app/features/shoresh/domain/usecases/get_shoresh_roots_use_case.dart';
import 'package:nexus_hebrew_app/features/shoresh/domain/usecases/save_shoresh_mastery_use_case.dart';

class _MockShoreshRepository extends Mock implements ShoreshRepository {}

void main() {
  late _MockShoreshRepository repository;

  const testRoots = [
    ShoreshRoot(
      id: 'root_ktv',
      letters: ['כ', 'ת', 'ב'],
      lettersDisplay: 'כ-ת-ב',
      primaryMeaningRu: 'Письмо, текст',
      categoryRu: 'Культура',
      culturalNoteRu: 'Базовый семитский корень',
      derivatives: [
        ShoreshDerivative(
          id: 'd_ktv_1',
          hebrewVocalized: 'לִכְתֹּב',
          hebrewNormalized: 'לכתוב',
          transliteration: 'likhtov',
          russianMeaning: 'писать',
          partOfSpeech: ShoreshPartOfSpeech.verb,
          patternOrBinyan: 'пааль',
          exampleSentenceHebrew: 'אֲנִי כּוֹתֵב מִכְתָּב.',
          exampleSentenceRussian: 'Я пишу письмо.',
        ),
        ShoreshDerivative(
          id: 'd_ktv_2',
          hebrewVocalized: 'מִכְתָּב',
          hebrewNormalized: 'מכתב',
          transliteration: 'mikhtav',
          russianMeaning: 'письмо',
          partOfSpeech: ShoreshPartOfSpeech.noun,
          patternOrBinyan: 'мишкаль микталь',
          exampleSentenceHebrew: 'קִבַּלְתִּי מִכְתָּב.',
          exampleSentenceRussian: 'Я получил письмо.',
        ),
      ],
    ),
    ShoreshRoot(
      id: 'root_lmd',
      letters: ['ל', 'מ', 'ד'],
      lettersDisplay: 'ל-מ-ד',
      primaryMeaningRu: 'Учёба, знание',
      categoryRu: 'Образование',
      culturalNoteRu: 'Основа еврейской традиции учения',
      derivatives: [
        ShoreshDerivative(
          id: 'd_lmd_1',
          hebrewVocalized: 'לִלְמֹד',
          hebrewNormalized: 'ללמוד',
          transliteration: 'lilmod',
          russianMeaning: 'учиться',
          partOfSpeech: ShoreshPartOfSpeech.verb,
          patternOrBinyan: 'пааль',
          exampleSentenceHebrew: 'אֲנִי לוֹמֵד עִבְרִית.',
          exampleSentenceRussian: 'Я учу иврит.',
        ),
      ],
    ),
  ];

  setUp(() {
    repository = _MockShoreshRepository();
    when(() => repository.getAllRoots()).thenReturn(testRoots);
  });

  group('GetShoreshRootsUseCase', () {
    test('returns all roots without filters', () {
      final useCase = GetShoreshRootsUseCase(repository);
      final result = useCase();
      expect(result.length, equals(2));
    });

    test('filters roots by category', () {
      final useCase = GetShoreshRootsUseCase(repository);
      final result = useCase(category: 'Образование');
      expect(result.length, equals(1));
      expect(result.first.id, equals('root_lmd'));
    });

    test('filters roots by query matching letters', () {
      final useCase = GetShoreshRootsUseCase(repository);
      final result = useCase(query: 'כ-ת-ב');
      expect(result.length, equals(1));
      expect(result.first.id, equals('root_ktv'));
    });

    test('filters roots by query matching derivative word', () {
      final useCase = GetShoreshRootsUseCase(repository);
      final result = useCase(query: 'עִבְרִית');
      // No derivative matches ivrit, should be empty
      expect(result, isEmpty);

      final result2 = useCase(query: 'מכתב');
      expect(result2.length, equals(1));
      expect(result2.first.id, equals('root_ktv'));
    });
  });

  group('GetShoreshFamilyUseCase', () {
    test('returns root family when ID exists', () {
      when(() => repository.getRootById('root_ktv')).thenReturn(testRoots.first);
      final useCase = GetShoreshFamilyUseCase(repository);

      final result = useCase('root_ktv');
      expect(result, isNotNull);
      expect(result?.derivatives.length, equals(2));
    });

    test('returns null when ID does not exist or is empty', () {
      when(() => repository.getRootById('unknown')).thenReturn(null);
      final useCase = GetShoreshFamilyUseCase(repository);

      expect(useCase('unknown'), isNull);
      expect(useCase(''), isNull);
    });
  });

  group('GetShoreshQuizUseCase', () {
    test('calls repository with requested question count', () {
      const mockQuestions = [
        ShoreshQuizQuestion(
          id: 'q1',
          wordVocalized: 'מִכְתָּב',
          wordNormalized: 'מכתב',
          wordTranslation: 'письмо',
          correctRootLetters: ['כ', 'ת', 'ב'],
          options: ['כ-ת-ב', 'מ-ת-ב', 'כ-ת-ם'],
          correctIndex: 0,
          affixesExplanationRu: 'Приставка מִ',
        ),
      ];

      when(() => repository.generateQuizQuestions(count: 5)).thenReturn(mockQuestions);
      final useCase = GetShoreshQuizUseCase(repository);

      final result = useCase(count: 5);
      expect(result.length, equals(1));
      verify(() => repository.generateQuizQuestions(count: 5)).called(1);
    });
  });

  group('SaveShoreshMasteryUseCase', () {
    test('calls repository when params are valid', () async {
      when(() => repository.recordRootMastery(
        rootId: any(named: 'rootId'),
        isMastered: any(named: 'isMastered'),
        quizCorrectIncrement: any(named: 'quizCorrectIncrement'),
      )).thenAnswer((_) async => const Success(null));

      final useCase = SaveShoreshMasteryUseCase(repository);
      const params = SaveShoreshMasteryParams(
        rootId: 'root_ktv',
        isMastered: true,
        quizCorrectIncrement: 3,
      );

      final result = await useCase(params);
      expect(result, isA<Success<void, Failure>>());
      verify(() => repository.recordRootMastery(
        rootId: 'root_ktv',
        isMastered: true,
        quizCorrectIncrement: 3,
      )).called(1);
    });

    test('returns ValidationFailure when rootId is empty', () async {
      final useCase = SaveShoreshMasteryUseCase(repository);
      const params = SaveShoreshMasteryParams(
        rootId: '   ',
        isMastered: true,
      );

      final result = await useCase(params);
      expect(result, isA<Error<void, Failure>>());
      expect((result as Error<void, Failure>).failure, isA<ValidationFailure>());
      verifyNever(() => repository.recordRootMastery(
        rootId: any(named: 'rootId'),
        isMastered: any(named: 'isMastered'),
        quizCorrectIncrement: any(named: 'quizCorrectIncrement'),
      ));
    });
  });
}
