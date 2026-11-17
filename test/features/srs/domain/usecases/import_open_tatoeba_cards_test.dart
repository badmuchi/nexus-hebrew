import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/fsrs_models.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';
import 'package:nexus_hebrew_app/features/srs/domain/repositories/srs_repository.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/import_open_tatoeba_cards.dart';

class _MockSrsRepository extends Mock implements SrsRepository {}

void main() {
  late ImportOpenTatoebaCardsUseCase useCase;
  late _MockSrsRepository mockRepository;

  final importedCard = SrsCard(
    id: 'tatoeba_101',
    hebrew: const HebrewText.fixture(vocalized: 'קָפֶה', normalized: 'קפה'),
    russianTranslation: 'Кофе',
    attribution: const ContentAttribution(
      sourceName: 'Tatoeba',
      licenseName: 'CC BY 2.0 FR',
    ),
    memory: FsrsMemoryState.initial(now: DateTime.utc(2026, 11, 11)),
  );

  setUp(() {
    mockRepository = _MockSrsRepository();
    useCase = ImportOpenTatoebaCardsUseCase(mockRepository);
  });

  group('ImportOpenTatoebaCardsUseCase', () {
    test('нормализует запрос от огласовок и импортирует карточки', () async {
      when(() => mockRepository.importOpenTatoebaCards(query: 'קפה', limit: 10))
          .thenAnswer((_) async => Success([importedCard]));

      final result = await useCase.execute(rawQuery: '  קָפֶה  ');

      expect(result.getOrNull(), equals([importedCard]));
      verify(
        () => mockRepository.importOpenTatoebaCards(query: 'קפה', limit: 10),
      ).called(1);
    });

    test('возвращает ValidationFailure для пустого запроса или некорректного limit', () async {
      final emptyQueryRes = await useCase.execute(rawQuery: '   ');
      final badLimitRes = await useCase.execute(rawQuery: 'קפה', limit: 100);

      expect(emptyQueryRes.failureOrNull(), isA<ValidationFailure>());
      expect(badLimitRes.failureOrNull(), isA<ValidationFailure>());
      verifyNever(
        () => mockRepository.importOpenTatoebaCards(
          query: any(named: 'query'),
          limit: any(named: 'limit'),
        ),
      );
    });

    test('пробрасывает NetworkFailure при отсутствии соединения', () async {
      const failure = NetworkFailure('Offline');
      when(() => mockRepository.importOpenTatoebaCards(query: 'שלום', limit: 5))
          .thenAnswer((_) async => const Error(failure));

      final result = await useCase.execute(rawQuery: 'שלום', limit: 5);

      expect(result, equals(const Error<List<SrsCard>, Failure>(failure)));
    });
  });
}
