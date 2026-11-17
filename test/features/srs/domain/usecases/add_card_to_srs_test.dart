import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/binyan.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/fsrs_models.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';
import 'package:nexus_hebrew_app/features/srs/domain/repositories/srs_repository.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/add_card_to_srs.dart';

class _MockSrsRepository extends Mock implements SrsRepository {}

void main() {
  late _MockSrsRepository repository;
  late AddCardToSrsUseCase useCase;
  final fixedNow = DateTime.utc(2026, 11, 12, 0, 30);

  setUpAll(() {
    registerFallbackValue(
      SrsCard(
        id: 'fallback',
        hebrew: const HebrewText.fixture(vocalized: 'שָׁלוֹם', normalized: 'שלום'),
        russianTranslation: 'Привет',
        attribution: const ContentAttribution(
          sourceName: 'Test',
          licenseName: 'CC0 1.0',
        ),
        memory: FsrsMemoryState.initial(now: fixedNow),
      ),
    );
  });

  setUp(() {
    repository = _MockSrsRepository();
    useCase = AddCardToSrsUseCase(
      repository: repository,
      clock: () => fixedNow,
    );
  });

  group('AddCardToSrsUseCase', () {
    test('builds valid SrsCard with shoresh/binyan and returns true when inserted',
        () async {
      when(() => repository.addCustomCard(any()))
          .thenAnswer((_) async => const Success<bool, Failure>(true));

      final result = await useCase(
        const AddCardToSrsParams(
          id: 'custom_verb_katav',
          hebrewVocalized: 'לִכְתֹּב',
          russianTranslation: 'писать',
          root: Shoresh.fixture(<String>['כ', 'ת', 'ב']),
          binyan: Binyan.paal,
          category: LexicalCategory.verb,
          exampleHebrewVocalized: 'אֲנִי כּוֹתֵב מִכְתָּב',
          exampleRussian: 'Я пишу письмо',
        ),
      );

      expect(result, const Success<bool, Failure>(true));
      final captured =
          verify(() => repository.addCustomCard(captureAny())).captured.single
              as SrsCard;
      expect(captured.id, 'custom_verb_katav');
      expect(captured.hebrew.vocalized, 'לִכְתֹּב');
      expect(captured.hebrew.normalized, 'לכתב');
      expect(captured.root?.hyphenated, 'כ-ת-ב');
      expect(captured.binyan, Binyan.paal);
      expect(captured.memory.dueAt, fixedNow);
      expect(captured.exampleHebrew?.normalized, 'אני כותב מכתב');
    });

    test('returns false when repository detects duplicate card', () async {
      when(() => repository.addCustomCard(any()))
          .thenAnswer((_) async => const Success<bool, Failure>(false));

      final result = await useCase(
        const AddCardToSrsParams(
          id: 'dup_1',
          hebrewVocalized: 'קָפֶה',
          russianTranslation: 'Кофе',
        ),
      );

      expect(result, const Success<bool, Failure>(false));
    });

    test('returns ValidationFailure on empty id, translation, or Hebrew text',
        () async {
      final badId = await useCase(
        const AddCardToSrsParams(
          id: ' ',
          hebrewVocalized: 'שָׁלוֹם',
          russianTranslation: 'Привет',
        ),
      );
      final badTrans = await useCase(
        const AddCardToSrsParams(
          id: 'c1',
          hebrewVocalized: 'שָׁלוֹם',
          russianTranslation: '  ',
        ),
      );
      final badHeb = await useCase(
        const AddCardToSrsParams(
          id: 'c2',
          hebrewVocalized: '   ',
          russianTranslation: 'Пусто',
        ),
      );

      expect(badId.failureOrNull(), isA<ValidationFailure>());
      expect(badTrans.failureOrNull(), isA<ValidationFailure>());
      expect(badHeb.failureOrNull(), isA<ValidationFailure>());
      verifyZeroInteractions(repository);
    });

    test('propagates CacheFailure when local storage insert fails', () async {
      const failure = CacheFailure('SQLite write failure');
      when(() => repository.addCustomCard(any()))
          .thenAnswer((_) async => const Error<bool, Failure>(failure));

      final result = await useCase(
        const AddCardToSrsParams(
          id: 'c3',
          hebrewVocalized: 'תּוֹדָה',
          russianTranslation: 'Спасибо',
        ),
      );

      expect(result.isError, isTrue);
      expect(result.failureOrNull(), failure);
    });
  });
}
