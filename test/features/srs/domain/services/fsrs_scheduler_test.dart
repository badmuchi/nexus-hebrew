import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/fsrs_models.dart';
import 'package:nexus_hebrew_app/features/srs/domain/services/fsrs_scheduler.dart';

void main() {
  const scheduler = FsrsScheduler();
  final baseTime = DateTime.utc(2026, 11, 11, 10, 0);

  group('FsrsScheduler (FSRS-4.5)', () {
    test('retrievability равна ~0.9 когда elapsedDays == stability', () {
      final r = scheduler.retrievability(elapsedDays: 5.0, stability: 5.0);
      expect(r, closeTo(0.9, 1e-6));
    });

    test('первое повторение новой карточки переводит в review для Good/Easy и в learning для Again/Hard', () {
      final initial = FsrsMemoryState.initial(now: baseTime);

      final againOutcome = scheduler.schedule(
        current: initial,
        rating: FsrsRating.again,
        now: baseTime,
      );
      final goodOutcome = scheduler.schedule(
        current: initial,
        rating: FsrsRating.good,
        now: baseTime,
      );
      final easyOutcome = scheduler.schedule(
        current: initial,
        rating: FsrsRating.easy,
        now: baseTime,
      );

      expect(againOutcome.updatedMemory.state, equals(FsrsCardState.learning));
      expect(againOutcome.scheduledDays, equals(0));
      expect(goodOutcome.updatedMemory.state, equals(FsrsCardState.review));
      expect(goodOutcome.scheduledDays, greaterThanOrEqualTo(3));
      expect(easyOutcome.scheduledDays, greaterThan(goodOutcome.scheduledDays));
    });

    test('успешный повторный recall увеличивает стабильность, а пропуск (Again) снижает её и увеличивает lapses', () {
      final firstGood = scheduler.schedule(
        current: FsrsMemoryState.initial(now: baseTime),
        rating: FsrsRating.good,
        now: baseTime,
      );

      final secondReviewTime =
          baseTime.add(Duration(days: firstGood.scheduledDays));
      final secondGood = scheduler.schedule(
        current: firstGood.updatedMemory,
        rating: FsrsRating.good,
        now: secondReviewTime,
      );

      expect(
        secondGood.updatedMemory.stability,
        greaterThan(firstGood.updatedMemory.stability),
      );
      expect(secondGood.updatedMemory.difficulty, inInclusiveRange(1.0, 10.0));

      final thirdReviewTime =
          secondReviewTime.add(Duration(days: secondGood.scheduledDays));
      final lapse = scheduler.schedule(
        current: secondGood.updatedMemory,
        rating: FsrsRating.again,
        now: thirdReviewTime,
      );

      expect(lapse.updatedMemory.state, equals(FsrsCardState.relearning));
      expect(lapse.updatedMemory.lapses, equals(1));
      expect(
        lapse.updatedMemory.stability,
        lessThanOrEqualTo(secondGood.updatedMemory.stability),
      );
    });

    test('previewIntervals возвращает прогноз интервалов для всех 4 оценок', () {
      final preview = scheduler.previewIntervals(
        current: FsrsMemoryState.initial(now: baseTime),
        now: baseTime,
      );

      expect(preview.keys, containsAll(FsrsRating.values));
      expect(preview[FsrsRating.again], equals(0));
      expect(preview[FsrsRating.easy]!, greaterThan(preview[FsrsRating.good]!));
    });
  });
}
