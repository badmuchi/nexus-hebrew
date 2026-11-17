import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/fsrs_models.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';
import 'package:nexus_hebrew_app/features/srs/domain/repositories/srs_repository.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/review_srs_card.dart';

class _MockSrsRepository extends Mock implements SrsRepository {}

void main() {
  late ReviewSrsCardUseCase useCase;
  late _MockSrsRepository mockRepository;

  final now = DateTime.utc(2026, 11, 11, 12, 0);
  final sampleCard = SrsCard(
    id: 'card_1',
    hebrew: const HebrewText.fixture(vocalized: 'קָפֶה', normalized: 'קפה'),
    russianTranslation: 'Кофе',
    attribution: const ContentAttribution(
      sourceName: 'Tatoeba',
      licenseName: 'CC0 1.0',
    ),
    memory: FsrsMemoryState.initial(now: now),
  );

  setUpAll(() {
    registerFallbackValue(sampleCard);
    registerFallbackValue(FsrsRating.good);
  });

  setUp(() {
    mockRepository = _MockSrsRepository();
    useCase = ReviewSrsCardUseCase(repository: mockRepository);
  });

  group('ReviewSrsCardUseCase', () {
    test('пересчитывает FSRS-память, сохраняет ревью и возвращает обновлённую карточку', () async {
      when(
        () => mockRepository.saveReview(
          updatedCard: any(named: 'updatedCard'),
          rating: FsrsRating.good,
          scheduledDays: any(named: 'scheduledDays'),
          stabilityBefore: 0.0,
          wasTypedCheck: true,
          wasTypedExact: true,
          reviewedAt: now,
        ),
      ).thenAnswer((_) async => const Success(null));

      final result = await useCase.execute(
        card: sampleCard,
        rating: FsrsRating.good,
        reviewedAt: now,
        wasTypedCheck: true,
        wasTypedExact: true,
      );

      expect(result, isA<Success<SrsCard, Failure>>());
      final updated = result.getOrNull()!;
      expect(updated.memory.state, equals(FsrsCardState.review));
      expect(updated.memory.reps, equals(1));
      expect(updated.memory.dueAt.isAfter(now), isTrue);
    });

    test('возвращает ValidationFailure для карточки с пустым id', () async {
      final invalidCard = SrsCard(
        id: '   ',
        hebrew: sampleCard.hebrew,
        russianTranslation: 'Кофе',
        attribution: sampleCard.attribution,
        memory: sampleCard.memory,
      );

      final result = await useCase.execute(
        card: invalidCard,
        rating: FsrsRating.good,
        reviewedAt: now,
      );

      expect(result.failureOrNull(), isA<ValidationFailure>());
      verifyNever(
        () => mockRepository.saveReview(
          updatedCard: any(named: 'updatedCard'),
          rating: any(named: 'rating'),
          scheduledDays: any(named: 'scheduledDays'),
          stabilityBefore: any(named: 'stabilityBefore'),
          wasTypedCheck: any(named: 'wasTypedCheck'),
          wasTypedExact: any(named: 'wasTypedExact'),
          reviewedAt: any(named: 'reviewedAt'),
        ),
      );
    });

    test('пробрасывает CacheFailure если сохранение в Drift не удалось', () async {
      const cacheError = CacheFailure('Disk full');
      when(
        () => mockRepository.saveReview(
          updatedCard: any(named: 'updatedCard'),
          rating: FsrsRating.again,
          scheduledDays: any(named: 'scheduledDays'),
          stabilityBefore: 0.0,
          wasTypedCheck: false,
          wasTypedExact: false,
          reviewedAt: now,
        ),
      ).thenAnswer((_) async => const Error(cacheError));

      final result = await useCase.execute(
        card: sampleCard,
        rating: FsrsRating.again,
        reviewedAt: now,
      );

      expect(result, equals(const Error<SrsCard, Failure>(cacheError)));
    });
  });
}
