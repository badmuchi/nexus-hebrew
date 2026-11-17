import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/fsrs_models.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';
import 'package:nexus_hebrew_app/features/srs/domain/repositories/srs_repository.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/get_due_srs_cards.dart';

class _MockSrsRepository extends Mock implements SrsRepository {}

void main() {
  late GetDueSrsCardsUseCase useCase;
  late _MockSrsRepository mockRepository;

  final now = DateTime.utc(2026, 11, 11);
  final sampleCard = SrsCard(
    id: 'card_1',
    hebrew: const HebrewText.fixture(vocalized: 'שָׁלוֹם', normalized: 'שלום'),
    russianTranslation: 'Привет',
    attribution: const ContentAttribution(
      sourceName: 'Tatoeba',
      licenseName: 'CC BY 2.0 FR',
    ),
    memory: FsrsMemoryState.initial(now: now),
  );

  setUp(() {
    mockRepository = _MockSrsRepository();
    useCase = GetDueSrsCardsUseCase(mockRepository);
  });

  group('GetDueSrsCardsUseCase', () {
    test('возвращает список просроченных/новых карточек в UTC', () async {
      when(() => mockRepository.getDueCards(asOf: now, limit: 15))
          .thenAnswer((_) async => Success([sampleCard]));

      final result = await useCase.execute(asOf: now, limit: 15);

      expect(result.getOrNull(), equals([sampleCard]));
      verify(() => mockRepository.getDueCards(asOf: now, limit: 15)).called(1);
    });

    test('возвращает ValidationFailure если limit <= 0', () async {
      final result = await useCase.execute(asOf: now, limit: 0);

      expect(result.failureOrNull(), isA<ValidationFailure>());
      verifyNever(
        () => mockRepository.getDueCards(
          asOf: any(named: 'asOf'),
          limit: any(named: 'limit'),
        ),
      );
    });

    test('пробрасывает CacheFailure от репозитория', () async {
      const failure = CacheFailure('SQLite locked');
      when(() => mockRepository.getDueCards(asOf: now, limit: 20))
          .thenAnswer((_) async => const Error(failure));

      final result = await useCase.execute(asOf: now);

      expect(result, equals(const Error<List<SrsCard>, Failure>(failure)));
    });
  });
}
